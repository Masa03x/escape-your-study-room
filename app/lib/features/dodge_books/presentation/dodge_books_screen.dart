import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/dodge_books_game.dart';
import '../domain/squat_detector.dart';
import 'widgets/flying_book.dart';
import 'widgets/game_character.dart';
import 'widgets/progress_segments.dart';
import 'widgets/study_room_scene.dart';

enum GameView {
  missionOverview,
  instructions,
  countdown,
  playing,
  paused,
  challengeComplete,
  gameComplete,
}

class EscapeGameScreen extends StatefulWidget {
  const EscapeGameScreen({super.key});

  @override
  State<EscapeGameScreen> createState() => _EscapeGameScreenState();
}

class _EscapeGameScreenState extends State<EscapeGameScreen> {
  final ChallengeGame _game = ChallengeGame();

  final SquatDetector _squatDetector = SquatDetector();
  final JumpDetector _jumpDetector = JumpDetector();
  final SideStepDetector _sideStepDetector = SideStepDetector();

  StreamSubscription<UserAccelerometerEvent>? _sensorSubscription;

  Timer? _countdownTimer;
  Timer? _roundTimer;

  GameView _view = GameView.missionOverview;

  int _challengeIndex = 0;
  int _countdown = 3;
  int _sessionToken = 0;
  int _roundNumber = 0;

  double _obstacleProgress = 0;

  bool _canAct = false;
  bool _actionActive = false;
  bool _roundResolved = false;

  String _feedback = 'Get ready to escape.';

  final List<int> _challengeMisses = [0, 0, 0];

  ChallengeType get _currentChallenge => ChallengeType.values[_challengeIndex];

  bool get _supportsSensors {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  void initState() {
    super.initState();

    if (_supportsSensors) {
      _sensorSubscription = userAccelerometerEventStream().listen(
        _handleSensorEvent,
        onError: (_) {},
      );
    }
  }

  @override
  void dispose() {
    _sessionToken += 1;

    _sensorSubscription?.cancel();
    _countdownTimer?.cancel();
    _roundTimer?.cancel();

    super.dispose();
  }

  void _handleSensorEvent(UserAccelerometerEvent event) {
    if (_view != GameView.playing || !_canAct || _roundResolved) {
      return;
    }

    final now = DateTime.now();

    bool detected = false;

    switch (_currentChallenge) {
      case ChallengeType.flyingBooks:
        detected = _squatDetector.addSample(
          verticalAcceleration: event.y,
          time: now,
        );
        break;

      case ChallengeType.jumpCables:
        detected = _jumpDetector.addSample(
          verticalAcceleration: event.y,
          time: now,
        );
        break;

      case ChallengeType.distractions:
        detected = _sideStepDetector.addSample(
          horizontalAcceleration: event.x,
          time: now,
        );
        break;
    }

    if (detected) {
      _registerSuccessfulMove();
    }
  }

  void _openFirstMission() {
    _game.reset();
    _resetDetectors();

    setState(() {
      _challengeIndex = 0;
      _view = GameView.instructions;
    });
  }

  void _beginCountdown() {
    _sessionToken += 1;

    final token = _sessionToken;

    _countdownTimer?.cancel();
    _roundTimer?.cancel();

    _game.reset();
    _resetDetectors();

    setState(() {
      _view = GameView.countdown;

      _countdown = 3;
      _roundNumber = 0;

      _obstacleProgress = 0;

      _canAct = false;
      _actionActive = false;
      _roundResolved = false;

      _feedback = _currentChallenge.countdownPrompt;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || token != _sessionToken) {
        timer.cancel();
        return;
      }

      if (_countdown > 1) {
        setState(() {
          _countdown -= 1;
        });

        return;
      }

      timer.cancel();

      setState(() {
        _countdown = 0;
      });

      Future<void>.delayed(const Duration(milliseconds: 650), () {
        if (!mounted || token != _sessionToken) {
          return;
        }

        _startPlaying();
      });
    });
  }

  void _startPlaying() {
    setState(() {
      _view = GameView.playing;
      _feedback = _watchMessage();
    });

    _startRound();
  }

  void _startRound() {
    if (!mounted || _view != GameView.playing || _game.isComplete) {
      return;
    }

    _roundTimer?.cancel();

    _resetDetectors();

    setState(() {
      _roundNumber += 1;

      _obstacleProgress = 0;

      _canAct = false;
      _actionActive = false;
      _roundResolved = false;

      _feedback = _watchMessage();
    });

    _runRoundTimer();
  }

  void _runRoundTimer() {
    final token = _sessionToken;

    _roundTimer?.cancel();

    _roundTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (!mounted ||
          token != _sessionToken ||
          _view != GameView.playing ||
          _roundResolved) {
        timer.cancel();
        return;
      }

      final nextProgress = _obstacleProgress + 0.022;

      final nextCanAct = nextProgress >= 0.54 && nextProgress <= 0.84;

      setState(() {
        _obstacleProgress = nextProgress;
        _canAct = nextCanAct;

        if (nextCanAct) {
          _feedback = _currentChallenge.actionMessage;
        } else if (nextProgress > 0.84) {
          _feedback = 'Too late!';
        }
      });

      if (nextProgress >= 1) {
        timer.cancel();
        _registerMiss();
      }
    });
  }

  void _registerSuccessfulMove() {
    if (_view != GameView.playing ||
        !_canAct ||
        _roundResolved ||
        _game.isComplete) {
      return;
    }

    _roundTimer?.cancel();

    final accepted = _game.registerSuccess();

    if (!accepted) {
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _canAct = false;
      _actionActive = true;
      _roundResolved = true;

      _feedback = _game.isComplete ? _finalSuccessMessage() : _successMessage();
    });

    final token = _sessionToken;

    if (_game.isComplete) {
      _challengeMisses[_challengeIndex] = _game.misses;

      Future<void>.delayed(const Duration(milliseconds: 850), () {
        if (!mounted || token != _sessionToken) {
          return;
        }

        setState(() {
          _view = GameView.challengeComplete;
        });
      });

      return;
    }

    _scheduleNextRound();
  }

  void _registerMiss() {
    if (_roundResolved || _game.isComplete) {
      return;
    }

    _game.registerMiss();

    setState(() {
      _obstacleProgress = 1;

      _canAct = false;
      _actionActive = false;
      _roundResolved = true;

      _feedback = _missMessage();
    });

    _scheduleNextRound();
  }

  void _scheduleNextRound() {
    final token = _sessionToken;

    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted ||
          token != _sessionToken ||
          _view != GameView.playing ||
          _game.isComplete) {
        return;
      }

      _startRound();
    });
  }

  void _pause() {
    if (_view != GameView.playing) {
      return;
    }

    _roundTimer?.cancel();

    setState(() {
      _view = GameView.paused;
      _canAct = false;
    });
  }

  void _resume() {
    if (_view != GameView.paused) {
      return;
    }

    final resolved = _roundResolved;

    setState(() {
      _view = GameView.playing;

      if (!resolved) {
        _canAct = _obstacleProgress >= 0.54 && _obstacleProgress <= 0.84;

        _feedback = _canAct ? _currentChallenge.actionMessage : _watchMessage();
      }
    });

    if (resolved) {
      _startRound();
    } else {
      _runRoundTimer();
    }
  }

  void _restartChallenge() {
    _beginCountdown();
  }

  void _nextChallenge() {
    if (_challengeIndex >= ChallengeType.values.length - 1) {
      setState(() {
        _view = GameView.gameComplete;
      });

      return;
    }

    setState(() {
      _challengeIndex += 1;

      _game.reset();
      _resetDetectors();

      _view = GameView.instructions;
    });
  }

  void _restartWholeGame() {
    _sessionToken += 1;

    _roundTimer?.cancel();
    _countdownTimer?.cancel();

    _game.reset();
    _resetDetectors();

    for (var i = 0; i < _challengeMisses.length; i++) {
      _challengeMisses[i] = 0;
    }

    setState(() {
      _challengeIndex = 0;

      _view = GameView.missionOverview;

      _countdown = 3;
      _roundNumber = 0;

      _obstacleProgress = 0;

      _canAct = false;
      _actionActive = false;
      _roundResolved = false;

      _feedback = 'Get ready to escape.';
    });
  }

  void _playAgain() {
    _restartWholeGame();

    Future<void>.delayed(Duration.zero, () {
      if (!mounted) {
        return;
      }

      _openFirstMission();
    });
  }

  void _leaveToMenu() {
    _restartWholeGame();
  }

  void _resetDetectors() {
    _squatDetector.reset();
    _jumpDetector.reset();
    _sideStepDetector.reset();
  }

  String _watchMessage() {
    switch (_currentChallenge) {
      case ChallengeType.flyingBooks:
        return 'Keep your eyes on the flying book.';

      case ChallengeType.jumpCables:
        return 'Watch the floor. The cable is coming.';

      case ChallengeType.distractions:
        return 'Stay focused. A distraction is coming.';
    }
  }

  String _successMessage() {
    switch (_currentChallenge) {
      case ChallengeType.flyingBooks:
        return 'Nice dodge! Homework denied.';

      case ChallengeType.jumpCables:
        return 'Perfect jump! Cable defeated.';

      case ChallengeType.distractions:
        return 'Nice move! Distraction avoided.';
    }
  }

  String _finalSuccessMessage() {
    switch (_currentChallenge) {
      case ChallengeType.flyingBooks:
        return 'Five books dodged! Mission cleared!';

      case ChallengeType.jumpCables:
        return 'Five cables cleared! Mission cleared!';

      case ChallengeType.distractions:
        return 'Five distractions avoided! Mission cleared!';
    }
  }

  String _missMessage() {
    switch (_currentChallenge) {
      case ChallengeType.flyingBooks:
        return 'Ouch. That homework got you. Next book!';

      case ChallengeType.jumpCables:
        return 'Caught by the cable! Try the next one.';

      case ChallengeType.distractions:
        return 'You got distracted. Refocus!';
    }
  }

  Widget _fitGameScreen({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: padding,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: SizedBox(
                width: constraints.maxWidth - padding.horizontal,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_view) {
            GameView.missionOverview => _buildMissionOverview(),

            GameView.instructions => _buildInstructions(),

            GameView.countdown => _buildCountdown(),

            GameView.playing => _buildGame(),

            GameView.paused => _buildPaused(),

            GameView.challengeComplete => _buildChallengeComplete(),

            GameView.gameComplete => _buildGameComplete(),
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // GAME START SCREEN
  // ---------------------------------------------------------

  Widget _buildMissionOverview() {
    return _fitGameScreen(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _HomeRoomArtwork(),

          const SizedBox(height: 18),

          const Text(
            'Escape Your\nStudy Room',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 38,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Studied enough? Your study room is fighting back.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _openFirstMission,
              child: const Text('Start Active Break'),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'YOUR ESCAPE ROUTE',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 11),

          const _MissionPath(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // CHALLENGE PREVIEW
  // ---------------------------------------------------------

  Widget _buildInstructions() {
    final type = _currentChallenge;

    return _fitGameScreen(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _leaveToMenu,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card,
                  side: const BorderSide(color: AppColors.border),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),

              const SizedBox(width: 10),

              const Text(
                'CHALLENGE PREVIEW',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),

              const Spacer(),

              Text(
                '${_challengeIndex + 1}/3',
                style: const TextStyle(
                  color: AppColors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _ChallengePreviewArtwork(type: type),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 15,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _challengeBackground(type),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    'MISSION ${_challengeIndex + 1}',
                    style: TextStyle(
                      color: _challengeColor(type),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  type.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 26,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  type.funnyLine,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 13),

                _GameGoalBox(type: type),

                const SizedBox(height: 11),

                _MovementTutorial(type: type),
              ],
            ),
          ),

          const SizedBox(height: 10),

          const _SafetyCard(),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _beginCountdown,
              child: Text('Play Mission ${_challengeIndex + 1}'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // COUNTDOWN
  // ---------------------------------------------------------

  Widget _buildCountdown() {
    final type = _currentChallenge;

    return Container(
      key: ValueKey('countdown-${type.name}'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'MISSION ${_challengeIndex + 1}',
                style: TextStyle(
                  color: _challengeColor(type),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),

              const Spacer(),

              Text(
                type.shortTitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _challengeBackground(type),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 28,
                    child: Text(
                      'GET READY',
                      style: TextStyle(
                        color: _challengeColor(type),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  Positioned(
                    left: 25,
                    bottom: 35,
                    child: GameCharacter(
                      type: type,
                      actionActive: false,
                      scale: 1.15,
                    ),
                  ),

                  Positioned(
                    right: 25,
                    bottom: 70,
                    child: GameObstacle(
                      type: type,
                      isDangerous: false,
                      index: 0,
                      scale: 1.05,
                    ),
                  ),

                  Container(
                    width: 170,
                    height: 170,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _countdown == 0
                                ? AppColors.green
                                : _challengeColor(type),
                        width: 6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _challengeColor(type).withValues(alpha: 0.18),
                          blurRadius: 35,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        _countdown == 0 ? 'GO!' : '$_countdown',
                        key: ValueKey(_countdown),
                        style: TextStyle(
                          color:
                              _countdown == 0
                                  ? AppColors.green
                                  : _challengeColor(type),
                          fontSize: _countdown == 0 ? 55 : 87,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 17),

          Text(
            type.countdownPrompt,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            type.instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // GAMEPLAY
  // ---------------------------------------------------------

  Widget _buildGame() {
    final type = _currentChallenge;

    return Padding(
      key: ValueKey('game-${type.name}'),
      padding: const EdgeInsets.fromLTRB(17, 8, 17, 17),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _pause,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card,
                  side: const BorderSide(color: AppColors.border),
                ),
                icon: const Icon(Icons.pause_rounded),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MISSION ${_challengeIndex + 1} / 3',
                      style: TextStyle(
                        color: _challengeColor(type),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      type.shortTitle,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_game.successes}/5',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ProgressSegments(completed: _game.successes, total: 5),

          const SizedBox(height: 10),

          Expanded(
            child: ChallengeScene(
              type: type,
              obstacleProgress: _obstacleProgress,
              canAct: _canAct,
              actionActive: _actionActive,
              completed: _game.successes,
              roundNumber: _roundNumber,
            ),
          ),

          const SizedBox(height: 10),

          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _canAct ? AppColors.coral : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _canAct ? AppColors.coral : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_canAct) ...[
                  Icon(_movementIcon(type), color: Colors.white, size: 20),

                  const SizedBox(width: 6),
                ],

                Flexible(
                  child: Text(
                    _feedback,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _canAct ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // PAUSE SCREEN
  // ---------------------------------------------------------

  Widget _buildPaused() {
    return _fitGameScreen(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pause_rounded,
                color: AppColors.teal,
                size: 42,
              ),
            ),

            const SizedBox(height: 17),

            const Text(
              'Game Paused',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'The study room promises not to attack while you are away.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.4),
            ),

            const SizedBox(height: 21),

            ProgressSegments(completed: _game.successes, total: 5),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _resume,
                child: const Text('Resume Mission'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restartChallenge,
                child: const Text('Restart Mission'),
              ),
            ),

            const SizedBox(height: 5),

            TextButton(
              onPressed: _leaveToMenu,
              child: const Text(
                'Leave Game',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // MISSION COMPLETE
  // ---------------------------------------------------------

  Widget _buildChallengeComplete() {
    final type = _currentChallenge;

    final last = _challengeIndex == ChallengeType.values.length - 1;

    return _fitGameScreen(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  color: _challengeBackground(type),
                  shape: BoxShape.circle,
                ),
              ),

              const Positioned(
                top: 5,
                right: 13,
                child: Icon(
                  Icons.star_rounded,
                  color: AppColors.yellow,
                  size: 30,
                ),
              ),

              GameCharacter(
                type: type,
                actionActive: true,
                scale: 1.15,
                sideDirection: _roundNumber,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'Mission ${_challengeIndex + 1}\nComplete!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            _missionCompleteMessage(type),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSoft,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: _ResultItem(
                    value: '5/5',
                    label: 'CLEARED',
                    color: AppColors.teal,
                  ),
                ),

                Container(width: 1, height: 47, color: AppColors.border),

                Expanded(
                  child: _ResultItem(
                    value: '${_game.misses}',
                    label: 'MISSED',
                    color: AppColors.coral,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nextChallenge,
              child: Text(last ? 'Open the Exit' : 'Next Mission'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // FINAL COMPLETE SCREEN
  // ---------------------------------------------------------

  Widget _buildGameComplete() {
    final totalMisses = _challengeMisses.fold<int>(
      0,
      (total, value) => total + value,
    );

    return _fitGameScreen(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
              ),

              const Icon(
                Icons.door_front_door_rounded,
                color: AppColors.green,
                size: 78,
              ),

              const Positioned(
                top: 0,
                left: 7,
                child: Icon(
                  Icons.star_rounded,
                  color: AppColors.yellow,
                  size: 30,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          const Text(
            'You Escaped!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 39,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'All three missions cleared.\nYour study room has officially lost.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 19),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Text(
                  'ESCAPE RESULTS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 13),

                Row(
                  children: [
                    const Expanded(
                      child: _ResultItem(
                        value: '15/15',
                        label: 'MOVES',
                        color: AppColors.teal,
                      ),
                    ),

                    Container(width: 1, height: 45, color: AppColors.border),

                    const Expanded(
                      child: _ResultItem(
                        value: '3/3',
                        label: 'MISSIONS',
                        color: AppColors.green,
                      ),
                    ),

                    Container(width: 1, height: 45, color: AppColors.border),

                    Expanded(
                      child: _ResultItem(
                        value: '$totalMisses',
                        label: 'MISSED',
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _restartWholeGame,
              child: const Text('Back to Studying'),
            ),
          ),

          const SizedBox(height: 9),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _playAgain,
              child: const Text('Play Again'),
            ),
          ),
        ],
      ),
    );
  }

  String _missionCompleteMessage(ChallengeType type) {
    switch (type) {
      case ChallengeType.flyingBooks:
        return 'The books are down, but the room has another trick waiting.';

      case ChallengeType.jumpCables:
        return 'Cable problem solved. One last enemy is blocking the exit.';

      case ChallengeType.distractions:
        return 'You ignored the distractions and finally unlocked the exit.';
    }
  }

  IconData _movementIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.flyingBooks:
        return Icons.keyboard_double_arrow_down_rounded;

      case ChallengeType.jumpCables:
        return Icons.keyboard_double_arrow_up_rounded;

      case ChallengeType.distractions:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _challengeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.flyingBooks:
        return AppColors.teal;

      case ChallengeType.jumpCables:
        return AppColors.blue;

      case ChallengeType.distractions:
        return AppColors.purple;
    }
  }

  Color _challengeBackground(ChallengeType type) {
    switch (type) {
      case ChallengeType.flyingBooks:
        return AppColors.elevated;

      case ChallengeType.jumpCables:
        return AppColors.blueSoft;

      case ChallengeType.distractions:
        return AppColors.purpleSoft;
    }
  }
}

// ---------------------------------------------------------
// HOME ROOM ARTWORK
// ---------------------------------------------------------

class _HomeRoomArtwork extends StatelessWidget {
  const _HomeRoomArtwork();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 225,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D8),
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -45,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0x20F4C95D),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            const Positioned(
              top: 24,
              right: 27,
              child: GameObstacle(
                type: ChallengeType.flyingBooks,
                isDangerous: false,
                index: 0,
                scale: 0.78,
              ),
            ),

            const Positioned(
              top: 34,
              left: 28,
              child: GameObstacle(
                type: ChallengeType.distractions,
                isDangerous: false,
                index: 2,
                scale: 0.62,
              ),
            ),

            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 62,
              child: ColoredBox(color: Color(0xFFE0BE91)),
            ),

            Positioned(
              left: 30,
              right: 30,
              bottom: 16,
              child: Container(
                height: 21,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            const Positioned(
              left: 29,
              bottom: 26,
              child: GameCharacter(
                type: ChallengeType.flyingBooks,
                actionActive: false,
                scale: 1.05,
              ),
            ),

            Positioned(
              right: 21,
              bottom: 35,
              child: Container(
                width: 58,
                height: 92,
                decoration: BoxDecoration(
                  color: const Color(0xFFC89B72),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  border: Border.all(color: const Color(0xFFAA7B55), width: 3),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EXIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 9),

                    Icon(Icons.lock_rounded, color: Colors.white, size: 21),
                  ],
                ),
              ),
            ),

            const Positioned(
              left: 116,
              bottom: 55,
              child: Text(
                'MOVE TO\nESCAPE!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.tealDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// MISSION ROUTE
// ---------------------------------------------------------

class _MissionPath extends StatelessWidget {
  const _MissionPath();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _PathMission(
            number: '1',
            label: 'SQUAT',
            icon: Icons.auto_stories_rounded,
            color: AppColors.teal,
            background: AppColors.elevated,
          ),
        ),

        _connector(),

        const Expanded(
          child: _PathMission(
            number: '2',
            label: 'JUMP',
            icon: Icons.power_rounded,
            color: AppColors.blue,
            background: AppColors.blueSoft,
          ),
        ),

        _connector(),

        const Expanded(
          child: _PathMission(
            number: '3',
            label: 'MOVE',
            icon: Icons.notifications_active_rounded,
            color: AppColors.purple,
            background: AppColors.purpleSoft,
          ),
        ),
      ],
    );
  }

  Widget _connector() {
    return Container(
      width: 18,
      height: 3,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _PathMission extends StatelessWidget {
  const _PathMission({
    required this.number,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String number;
  final String label;

  final IconData icon;

  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 59,
              height: 59,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 27),
            ),

            Positioned(
              right: -3,
              top: -3,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------
// CHALLENGE PREVIEW ARTWORK
// ---------------------------------------------------------

class _ChallengePreviewArtwork extends StatelessWidget {
  const _ChallengePreviewArtwork({required this.type});

  final ChallengeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _background(type),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: 14,
            right: 27,
            child: Icon(Icons.star_rounded, color: AppColors.yellow, size: 20),
          ),

          Positioned(
            top: 35,
            left: 24,
            child: GameCharacter(type: type, actionActive: false, scale: 1.05),
          ),

          Positioned(
            right: 25,
            top: 39,
            child: GameObstacle(
              type: type,
              isDangerous: true,
              index: 0,
              scale: 1.05,
            ),
          ),

          const Positioned(
            bottom: 18,
            child: Text(
              'YOU VS. THE STUDY ROOM',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _background(ChallengeType type) {
    switch (type) {
      case ChallengeType.flyingBooks:
        return AppColors.elevated;

      case ChallengeType.jumpCables:
        return AppColors.blueSoft;

      case ChallengeType.distractions:
        return AppColors.purpleSoft;
    }
  }
}

// ---------------------------------------------------------
// GOAL BOX
// ---------------------------------------------------------

class _GameGoalBox extends StatelessWidget {
  const _GameGoalBox({required this.type});

  final ChallengeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GOAL',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            type.goal,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// MOVEMENT TUTORIAL
// ---------------------------------------------------------

class _MovementTutorial extends StatelessWidget {
  const _MovementTutorial({required this.type});

  final ChallengeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          const Text(
            'HOW TO MOVE',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameCharacter(type: type, actionActive: false, scale: 0.58),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 13),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.coral,
                  size: 27,
                ),
              ),

              GameCharacter(
                type: type,
                actionActive: true,
                scale: 0.58,
                sideDirection: 1,
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'READY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),

              Text(
                type.movement,
                style: const TextStyle(
                  color: AppColors.coral,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.coral,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'WAIT FOR "${type.actionMessage}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// SAFETY
// ---------------------------------------------------------

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.yellowSoft,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Clear some space around you before the mission starts.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSoft,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// RESULTS
// ---------------------------------------------------------

class _ResultItem extends StatelessWidget {
  const _ResultItem({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
