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
  String _feedback = 'Watch the room. Your books are getting angry.';

  bool get _supportsSensors {
    if (kIsWeb) return false;

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
        if (!mounted || token != _sessionToken) return;
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

    setState(() {
      _bookProgress = 0;
      _canDodge = false;
      _squatting = false;
      _feedback = 'Watch the flying book.';
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
          _feedback = 'Squat now to dodge!';
        }
      });

      if (nextProgress >= 1) {
        timer.cancel();

        setState(() {
          _bookProgress = 1;
          _canDodge = false;
          _feedback = 'That one got past you. Next book!';
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
    if (!accepted) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _canDodge = false;
      _squatting = true;
      _feedback =
          _game.isComplete
              ? 'Final dodge! The exit is open.'
              : 'Nice dodge! That book almost got you.';
    });

    final token = _sessionToken;

    if (_game.isComplete) {
      Future<void>.delayed(const Duration(milliseconds: 800), () {
        if (!mounted || token != _sessionToken) return;

        setState(() {
          _view = ChallengeView.completed;
        });
      });
      return;
    }

    _scheduleNextRound(token: token, delay: const Duration(milliseconds: 750));
  }

  void _pause() {
    if (_view != ChallengeView.playing) return;

    _roundTimer?.cancel();

    setState(() {
      _view = ChallengeView.paused;
      _canDodge = false;
    });
  }

  void _resume() {
    if (_view != ChallengeView.paused) return;

    setState(() {
      _view = ChallengeView.playing;
      _feedback = 'Ready again. Watch the next book.';
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
      _feedback = 'Watch the room. Your books are getting angry.';
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
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESCAPE YOUR STUDY ROOM',
            style: TextStyle(
              color: AppColors.purpleLight,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
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
            'Your study break just turned into an escape challenge.',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 17,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF211A59), AppColors.card],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Text('📚', style: TextStyle(fontSize: 64)),
                SizedBox(height: 16),
                Text(
                  'Squat when a book flies toward you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Dodge 5 books to open the exit and finish your active break.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _InfoRow(
            icon: Icons.directions_run_rounded,
            title: 'Movement',
            text: 'Stand with enough space and perform a clear squat.',
          ),
          const SizedBox(height: 12),
          const _InfoRow(
            icon: Icons.shield_outlined,
            title: 'Safety',
            text: 'Keep the floor around you clear before starting.',
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton(
              onPressed: _beginCountdown,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Start Challenge',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
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
              color: AppColors.purpleLight,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              _countdown == 0 ? 'MOVE!' : '$_countdown',
              key: ValueKey(_countdown),
              style: TextStyle(
                color: _countdown == 0 ? AppColors.greenLight : AppColors.text,
                fontSize: _countdown == 0 ? 72 : 110,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Books incoming...',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    return Padding(
      key: const ValueKey('game'),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Books Dodged: ${_game.dodgedBooks}/${_game.targetDodges}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: _pause,
                icon: const Icon(Icons.pause_rounded),
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
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _canDodge ? const Color(0xFF3A2A13) : AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _canDodge ? AppColors.orange : AppColors.border,
              ),
            ),
            child: Text(
              _feedback,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!_supportsSensors) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _canDodge ? _attemptDodge : null,
                icon: const Icon(Icons.developer_mode_rounded),
                label: const Text('Demo control: simulate squat'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaused() {
    return Stack(
      key: const ValueKey('paused'),
      children: [
        _buildGame(),
        Positioned.fill(
          child: ColoredBox(
            color: const Color(0xCC06051A),
            child: Center(
              child: Container(
                width: 320,
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.pause_circle_filled_rounded,
                      color: AppColors.purpleLight,
                      size: 58,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Challenge Paused',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _PauseButton(
                      text: 'Resume',
                      onPressed: _resume,
                      primary: true,
                    ),
                    const SizedBox(height: 10),
                    _PauseButton(
                      text: 'Restart Challenge',
                      onPressed: _restart,
                    ),
                    const SizedBox(height: 10),
                    _PauseButton(
                      text: 'Leave Challenge',
                      onPressed: _leaveChallenge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
              width: 116,
              height: 116,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF113C2A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x6622C55E),
                    blurRadius: 35,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const Text('🚪', style: TextStyle(fontSize: 58)),
            ),
            const SizedBox(height: 26),
            const Text(
              'You Escaped!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You defeated your homework. For now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSoft,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.green),
              ),
              child: Text(
                '${_game.dodgedBooks}/${_game.targetDodges} Books Dodged',
                style: const TextStyle(
                  color: AppColors.greenLight,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _leaveChallenge,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: const Color(0xFF05180D),
                ),
                child: const Text(
                  'Back to Studying',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _restart,
              child: const Text('Play the challenge again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.purpleLight),
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

class _PauseButton extends StatelessWidget {
  const _PauseButton({
    required this.text,
    required this.onPressed,
    this.primary = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child:
          primary
              ? FilledButton(onPressed: onPressed, child: Text(text))
              : OutlinedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
