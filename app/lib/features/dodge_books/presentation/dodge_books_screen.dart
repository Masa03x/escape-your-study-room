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

  double _bookProgress = 0;

  bool _canDodge = false;
  bool _squatting = false;

  String _feedback = 'Watch the incoming book.';

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
    if (_view != ChallengeView.playing || !_canDodge) {
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
      _bookProgress = 0;
      _canDodge = false;
      _squatting = false;
      _feedback = 'Get ready.';
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
      _feedback = 'Watch the incoming book.';
    });

    _startRound();
  }

  void _startRound() {
    if (!mounted || _view != ChallengeView.playing || _game.isComplete) {
      return;
    }

    _roundTimer?.cancel();

    setState(() {
      _bookProgress = 0;
      _canDodge = false;
      _squatting = false;
      _feedback = 'Watch the incoming book.';
    });

    final token = _sessionToken;

    _roundTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (!mounted ||
          token != _sessionToken ||
          _view != ChallengeView.playing) {
        timer.cancel();
        return;
      }

      final nextProgress = _bookProgress + 0.022;

      final nextCanDodge = nextProgress >= 0.54 && nextProgress <= 0.84;

      setState(() {
        _bookProgress = nextProgress;
        _canDodge = nextCanDodge;

        if (nextCanDodge) {
          _feedback = 'Squat now!';
        }
      });

      if (nextProgress >= 1) {
        timer.cancel();

        setState(() {
          _bookProgress = 1;
          _canDodge = false;
          _feedback = 'Missed! Get ready for the next book.';
        });

        _scheduleNextRound(
          token: token,
          delay: const Duration(milliseconds: 700),
        );
      }
    });
  }

  void _scheduleNextRound({required int token, required Duration delay}) {
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

  void _attemptDodge() {
    if (_view != ChallengeView.playing || !_canDodge || _game.isComplete) {
      return;
    }

    _roundTimer?.cancel();

    final accepted = _game.registerDodge();

    if (!accepted) {
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _canDodge = false;
      _squatting = true;

      _feedback =
          _game.isComplete ? 'Final dodge! Exit unlocked.' : 'Nice dodge!';
    });

    final token = _sessionToken;

    if (_game.isComplete) {
      Future<void>.delayed(const Duration(milliseconds: 800), () {
        if (!mounted || token != _sessionToken) {
          return;
        }

        setState(() {
          _view = ChallengeView.completed;
        });
      });

      return;
    }

    _scheduleNextRound(token: token, delay: const Duration(milliseconds: 750));
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

    setState(() {
      _view = ChallengeView.playing;
      _feedback = 'Get ready.';
    });

    _startRound();
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
      _bookProgress = 0;
      _canDodge = false;
      _squatting = false;
      _feedback = 'Watch the incoming book.';
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE BREAK',
            style: TextStyle(
              color: AppColors.cyan,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Dodge the\nFlying Books',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 42,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Squat when a book moves toward you.',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 16,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.menu_book_rounded, color: AppColors.lime, size: 60),

                SizedBox(height: 16),

                Text(
                  'Your Goal',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Dodge 5 books to unlock the exit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.accessibility_new,
                        color: AppColors.cyan,
                        size: 36,
                      ),
                      SizedBox(height: 7),
                      Text(
                        '1. STAND',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted),

                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.lime,
                        size: 40,
                      ),
                      SizedBox(height: 7),
                      Text(
                        '2. SQUAT',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.yellow, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Make sure you have enough space around you.',
                  style: TextStyle(color: AppColors.textSoft, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _beginCountdown,
              child: const Text('Start Challenge'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Center(
      key: const ValueKey('countdown'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'GET READY',
            style: TextStyle(
              color: AppColors.cyan,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: 170,
            height: 170,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _countdown == 0 ? AppColors.lime : AppColors.cyan,
                width: 4,
              ),
            ),
            child: Text(
              _countdown == 0 ? 'GO' : '$_countdown',
              style: TextStyle(
                color: _countdown == 0 ? AppColors.lime : AppColors.text,
                fontSize: _countdown == 0 ? 60 : 90,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Watch the book and get ready to squat.',
            style: TextStyle(color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    return Padding(
      key: const ValueKey('game'),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _pause,
                style: IconButton.styleFrom(backgroundColor: AppColors.card),
                icon: const Icon(Icons.pause_rounded),
              ),

              const Expanded(
                child: Text(
                  'DODGE MODE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              Text(
                '${_game.dodgedBooks}/${_game.targetDodges}',
                style: const TextStyle(
                  color: AppColors.lime,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ProgressSegments(
            completed: _game.dodgedBooks,
            total: _game.targetDodges,
          ),

          const SizedBox(height: 18),

          Expanded(
            child: StudyRoomScene(
              bookProgress: _bookProgress,
              canDodge: _canDodge,
              squatting: _squatting,
              dodgedBooks: _game.dodgedBooks,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _canDodge ? AppColors.lime : AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _feedback,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _canDodge ? AppColors.black : AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          if (!_supportsSensors) ...[
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _canDodge ? _attemptDodge : null,
                child: const Text('Simulate Squat'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaused() {
    return Container(
      key: const ValueKey('paused'),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_outline,
              color: AppColors.cyan,
              size: 58,
            ),

            const SizedBox(height: 14),

            const Text(
              'Paused',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${_game.dodgedBooks}/${_game.targetDodges} books dodged',
              style: const TextStyle(color: AppColors.textMuted),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _resume,
                child: const Text('Resume'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restart,
                child: const Text('Restart Challenge'),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: _leaveChallenge,
              child: const Text(
                'Leave Challenge',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        ),
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
              width: 100,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                color: AppColors.black,
                size: 52,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'You Escaped!',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 38,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'You completed your active break.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSoft, fontSize: 16),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${_game.dodgedBooks}/${_game.targetDodges}',
                    style: const TextStyle(
                      color: AppColors.lime,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'BOOKS DODGED',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _leaveChallenge,
                child: const Text('Back to Studying'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restart,
                child: const Text('Play Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
