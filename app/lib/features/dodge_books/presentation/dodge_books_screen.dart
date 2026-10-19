import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/dodge_books_game.dart';
import '../domain/squat_detector.dart';
import 'widgets/progress_segments.dart';
import 'widgets/study_room_scene.dart';

enum ChallengeView { intro, countdown, playing, paused, completed }

class DodgeBooksScreen extends StatefulWidget {
  const DodgeBooksScreen({super.key});

  @override
  State<DodgeBooksScreen> createState() => _DodgeBooksScreenState();
}

class _DodgeBooksScreenState extends State<DodgeBooksScreen> {
  final DodgeBooksGame _game = DodgeBooksGame();

  final SquatDetector _squatDetector = SquatDetector();

  StreamSubscription<UserAccelerometerEvent>? _sensorSubscription;

  Timer? _countdownTimer;
  Timer? _roundTimer;

  ChallengeView _view = ChallengeView.intro;

  int _countdown = 3;

  int _sessionToken = 0;

  int _roundNumber = 0;

  double _bookProgress = 0;

  bool _canDodge = false;
  bool _squatting = false;
  bool _roundResolved = false;

  String _feedback = 'The books are getting restless...';

  static const List<String> _successfulDodgeMessages = [
    'Nice dodge! Homework denied.',
    'Clean dodge! That deadline missed you.',
    'Great move! One less problem to deal with.',
    'Perfect! The book never stood a chance.',
  ];

  static const List<String> _missMessages = [
    'Missed! That book was faster than expected.',
    'Too late! Apparently homework can fly.',
    'Close one. Get ready for the next book.',
  ];

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
    if (_view != ChallengeView.playing || !_canDodge || _roundResolved) {
      return;
    }

    final detected = _squatDetector.addSample(
      verticalAcceleration: event.y,
      time: DateTime.now(),
    );

    if (detected) {
      _attemptDodge();
    }
  }

  void _beginCountdown() {
    _sessionToken += 1;

    final token = _sessionToken;

    _countdownTimer?.cancel();
    _roundTimer?.cancel();

    _game.reset();
    _squatDetector.reset();

    setState(() {
      _view = ChallengeView.countdown;

      _countdown = 3;

      _roundNumber = 0;

      _bookProgress = 0;

      _canDodge = false;

      _squatting = false;

      _roundResolved = false;

      _feedback = 'Get ready to move.';
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
      _view = ChallengeView.playing;

      _feedback = 'Watch the flying book.';
    });

    _startRound();
  }

  void _startRound() {
    if (!mounted || _view != ChallengeView.playing || _game.isComplete) {
      return;
    }

    _roundTimer?.cancel();

    _squatDetector.reset();

    setState(() {
      _roundNumber += 1;

      _bookProgress = 0;

      _canDodge = false;

      _squatting = false;

      _roundResolved = false;

      _feedback = 'Watch the flying book.';
    });

    _runRoundTimer();
  }

  void _runRoundTimer() {
    final token = _sessionToken;

    _roundTimer?.cancel();

    _roundTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (!mounted ||
          token != _sessionToken ||
          _view != ChallengeView.playing ||
          _roundResolved) {
        timer.cancel();

        return;
      }

      final nextProgress = _bookProgress + 0.022;

      final nextCanDodge = nextProgress >= 0.54 && nextProgress <= 0.84;

      setState(() {
        _bookProgress = nextProgress;

        _canDodge = nextCanDodge;

        if (nextCanDodge) {
          _feedback = 'SQUAT NOW! Dodge the book!';
        } else if (nextProgress > 0.84) {
          _feedback = 'Too late! Get ready for another chance.';
        }
      });

      if (nextProgress >= 1) {
        timer.cancel();

        _registerMiss();
      }
    });
  }

  void _registerMiss() {
    if (_roundResolved || _game.isComplete) {
      return;
    }

    _game.registerMiss();

    final messageIndex = (_game.missedBooks - 1) % _missMessages.length;

    setState(() {
      _bookProgress = 1;

      _canDodge = false;

      _roundResolved = true;

      _feedback = _missMessages[messageIndex];
    });

    _scheduleNextRound(delay: const Duration(milliseconds: 800));
  }

  void _attemptDodge() {
    if (_view != ChallengeView.playing ||
        !_canDodge ||
        _roundResolved ||
        _game.isComplete) {
      return;
    }

    _roundTimer?.cancel();

    final accepted = _game.registerDodge();

    if (!accepted) {
      return;
    }

    HapticFeedback.mediumImpact();

    final successIndex =
        (_game.dodgedBooks - 1) % _successfulDodgeMessages.length;

    setState(() {
      _canDodge = false;

      _squatting = true;

      _roundResolved = true;

      _feedback =
          _game.isComplete
              ? 'Final dodge! The exit is open!'
              : _successfulDodgeMessages[successIndex];
    });

    final token = _sessionToken;

    if (_game.isComplete) {
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (!mounted || token != _sessionToken) {
          return;
        }

        setState(() {
          _view = ChallengeView.completed;
        });
      });

      return;
    }

    _scheduleNextRound(delay: const Duration(milliseconds: 800));
  }

  void _scheduleNextRound({required Duration delay}) {
    final token = _sessionToken;

    Future<void>.delayed(delay, () {
      if (!mounted ||
          token != _sessionToken ||
          _view != ChallengeView.playing ||
          _game.isComplete) {
        return;
      }

      _startRound();
    });
  }

  void _pause() {
    if (_view != ChallengeView.playing) {
      return;
    }

    _roundTimer?.cancel();

    setState(() {
      _view = ChallengeView.paused;

      _canDodge = false;
    });
  }

  void _resume() {
    if (_view != ChallengeView.paused) {
      return;
    }

    final roundWasResolved = _roundResolved;

    setState(() {
      _view = ChallengeView.playing;

      if (!roundWasResolved) {
        _canDodge = _bookProgress >= 0.54 && _bookProgress <= 0.84;

        _feedback =
            _canDodge ? 'SQUAT NOW! Dodge the book!' : 'Watch the flying book.';
      }
    });

    if (roundWasResolved) {
      _startRound();
    } else {
      _runRoundTimer();
    }
  }

  void _restart() {
    _beginCountdown();
  }

  void _leaveChallenge() {
    _sessionToken += 1;

    _countdownTimer?.cancel();
    _roundTimer?.cancel();

    _game.reset();
    _squatDetector.reset();

    setState(() {
      _view = ChallengeView.intro;

      _countdown = 3;

      _roundNumber = 0;

      _bookProgress = 0;

      _canDodge = false;

      _squatting = false;

      _roundResolved = false;

      _feedback = 'The books are getting restless...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_view) {
            ChallengeView.intro => _buildIntro(),
            ChallengeView.countdown => _buildCountdown(),
            ChallengeView.playing => _buildGame(),
            ChallengeView.paused => _buildPaused(),
            ChallengeView.completed => _buildCompleted(),
          },
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return SingleChildScrollView(
      key: const ValueKey('intro'),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  color: AppColors.teal,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESCAPE YOUR STUDY ROOM',
                      style: TextStyle(
                        color: AppColors.tealDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'A quick active study break',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Dodge the\nFlying Books',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 42,
              height: 1.02,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Take a short movement break before getting back to studying.',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 16,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 26),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 105,
                  height: 105,
                  decoration: const BoxDecoration(
                    color: AppColors.elevated,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 54,
                    color: AppColors.teal,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Your homework is fighting back.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Squat when a book flies toward you. Dodge 5 books to unlock the exit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const _InfoCard(
            icon: Icons.sports_gymnastics_rounded,
            iconColor: AppColors.teal,
            iconBackground: AppColors.elevated,
            title: 'How to dodge',
            text:
                'Stand normally and perform a clear squat when you see SQUAT NOW.',
          ),

          const SizedBox(height: 12),

          const _InfoCard(
            icon: Icons.health_and_safety_outlined,
            iconColor: AppColors.coral,
            iconBackground: AppColors.coralSoft,
            title: 'Move safely',
            text: 'Make sure you have enough space around you before starting.',
          ),

          const SizedBox(height: 12),

          _SensorCard(supportsSensors: _supportsSensors),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _beginCountdown,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Challenge'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Center(
      key: const ValueKey('countdown'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GET READY TO MOVE',
              style: TextStyle(
                color: AppColors.tealDark,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),

            const SizedBox(height: 30),

            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 180,
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _countdown == 0 ? AppColors.greenLight : AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _countdown == 0 ? AppColors.green : AppColors.teal,
                  width: 5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x182A9D8F),
                    blurRadius: 30,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _countdown == 0 ? 'GO!' : '$_countdown',
                  key: ValueKey(_countdown),
                  style: TextStyle(
                    color:
                        _countdown == 0 ? AppColors.green : AppColors.tealDark,
                    fontSize: _countdown == 0 ? 60 : 92,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Stand up and get ready.',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'The first book is on its way.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Padding(
      key: const ValueKey('game'),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _pause,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card,
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.border),
                ),
                icon: const Icon(Icons.pause_rounded),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DODGE THE BOOKS',
                      style: TextStyle(
                        color: AppColors.tealDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Active break',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_game.dodgedBooks}/${_game.targetDodges}',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ProgressSegments(
            completed: _game.dodgedBooks,
            total: _game.targetDodges,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _SmallStatus(
                icon:
                    _supportsSensors
                        ? Icons.sensors_rounded
                        : Icons.developer_mode_rounded,
                text: _supportsSensors ? 'Motion active' : 'Demo mode',
              ),

              const Spacer(),

              if (_game.missedBooks > 0)
                _SmallStatus(
                  icon: Icons.refresh_rounded,
                  text: 'Missed ${_game.missedBooks}',
                ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: StudyRoomScene(
              bookProgress: _bookProgress,
              canDodge: _canDodge,
              squatting: _squatting,
              dodgedBooks: _game.dodgedBooks,
              roundNumber: _roundNumber,
            ),
          ),

          const SizedBox(height: 13),

          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _canDodge ? AppColors.coral : AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _canDodge ? AppColors.coral : AppColors.border,
              ),
            ),
            child: Text(
              _feedback,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _canDodge ? Colors.white : AppColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),

          if (!_supportsSensors) ...[
            const SizedBox(height: 9),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _canDodge && !_roundResolved ? _attemptDodge : null,
                icon: const Icon(Icons.sports_gymnastics_rounded),
                label: const Text('Demo: Simulate Squat'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaused() {
    return SingleChildScrollView(
      key: const ValueKey('paused'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 45),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x15000000),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.elevated,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause_rounded,
                    color: AppColors.teal,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Challenge Paused',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'The books will wait. Probably.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '${_game.dodgedBooks}/${_game.targetDodges}',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ProgressSegments(
                  completed: _game.dodgedBooks,
                  total: _game.targetDodges,
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _resume,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Resume'),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Restart Challenge'),
                  ),
                ),

                const SizedBox(height: 5),

                TextButton.icon(
                  onPressed: _leaveChallenge,
                  icon: const Icon(Icons.close_rounded, color: AppColors.red),
                  label: const Text(
                    'Leave Challenge',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w800,
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

  Widget _buildCompleted() {
    return Center(
      key: const ValueKey('completed'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 112,
              height: 112,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.greenLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x335FAF7B),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.door_front_door_rounded,
                color: AppColors.green,
                size: 58,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'You Escaped!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 39,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 9),

            const Text(
              'You defeated your homework.\nFor now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSoft,
                fontSize: 17,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ResultItem(
                      icon: Icons.check_circle_rounded,
                      value: '${_game.dodgedBooks}/${_game.targetDodges}',
                      label: 'Dodged',
                      color: AppColors.teal,
                    ),
                  ),

                  Container(width: 1, height: 54, color: AppColors.border),

                  Expanded(
                    child: _ResultItem(
                      icon: Icons.refresh_rounded,
                      value: '${_game.missedBooks}',
                      label: 'Missed',
                      color: AppColors.coral,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ProgressSegments(
              completed: _game.dodgedBooks,
              total: _game.targetDodges,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _leaveChallenge,
                icon: const Icon(Icons.school_rounded),
                label: const Text('Back to Studying'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Play Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.supportsSensors});

  final bool supportsSensors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: supportsSensors ? AppColors.greenLight : AppColors.yellowSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            supportsSensors
                ? Icons.sensors_rounded
                : Icons.developer_mode_rounded,
            color: supportsSensors ? AppColors.green : AppColors.textSoft,
            size: 21,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              supportsSensors
                  ? 'Phone movement detection is ready.'
                  : 'Demo mode: use the simulate squat button during testing.',
              style: const TextStyle(
                color: AppColors.textSoft,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatus extends StatelessWidget {
  const _SmallStatus({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ResultItem extends StatelessWidget {
  const _ResultItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),

        const SizedBox(height: 5),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
