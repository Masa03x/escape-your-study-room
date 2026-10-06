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

enum ChallengeView {
  intro,
  countdown,
  playing,
  paused,
  completed,
}

class DodgeBooksScreen extends StatefulWidget {
  const DodgeBooksScreen({super.key});

  @override
  State<DodgeBooksScreen> createState() =>
      _DodgeBooksScreenState();
}

class _DodgeBooksScreenState
    extends State<DodgeBooksScreen> {
  final DodgeBooksGame _game = DodgeBooksGame();
  final SquatDetector _squatDetector = SquatDetector();

  StreamSubscription<UserAccelerometerEvent>?
      _sensorSubscription;

  Timer? _countdownTimer;
  Timer? _roundTimer;

  ChallengeView _view = ChallengeView.intro;

  int _countdown = 3;
  int _sessionToken = 0;

  double _bookProgress = 0;
  bool _canDodge = false;
  bool _squatting = false;

  String _feedback =
      'Watch the room. Your books are getting angry.';

  bool get _supportsSensors {
    if (kIsWeb) return false;

    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  void initState() {
    super.initState();

    if (_supportsSensors) {
      _sensorSubscription =
          userAccelerometerEventStream().listen(
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

  void _handleSensorEvent(
    UserAccelerometerEvent event,
  ) {
    if (_view != ChallengeView.playing ||
        !_canDodge) {
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

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
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

        Future<void>.delayed(
          const Duration(milliseconds: 650),
          () {
            if (!mounted ||
                token != _sessionToken) {
              return;
            }

            _startPlaying();
          },
        );
      },
    );
  }

  void _startPlaying() {
    setState(() {
      _view = ChallengeView.playing;
      _feedback = 'Watch the flying book.';
    });

    _startRound();
  }

  void _startRound() {
    if (!mounted ||
        _view != ChallengeView.playing ||
        _game.isComplete) {
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

    _roundTimer = Timer.periodic(
      const Duration(milliseconds: 45),
      (timer) {
        if (!mounted ||
            token != _sessionToken ||
            _view != ChallengeView.playing) {
          timer.cancel();
          return;
        }

        final nextProgress =
            _bookProgress + 0.022;

        final nextCanDodge =
            nextProgress >= 0.54 &&
            nextProgress <= 0.84;

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
            _feedback =
                'That one got past you. Next book!';
          });

          _scheduleNextRound(
            token: token,
            delay:
                const Duration(milliseconds: 700),
          );
        }
      },
    );
  }

  void _scheduleNextRound({
    required int token,
    required Duration delay,
  }) {
    Future<void>.delayed(
      delay,
      () {
        if (!mounted ||
            token != _sessionToken ||
            _view != ChallengeView.playing ||
            _game.isComplete) {
          return;
        }

        _startRound();
      },
    );
  }

  void _attemptDodge() {
    if (_view != ChallengeView.playing ||
        !_canDodge ||
        _game.isComplete) {
      return;
    }

    _roundTimer?.cancel();

    final accepted = _game.registerDodge();

    if (!accepted) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _canDodge = false;
      _squatting = true;

      _feedback = _game.isComplete
          ? 'Final dodge! The exit is open.'
          : 'Nice dodge! That book almost got you.';
    });

    final token = _sessionToken;

    if (_game.isComplete) {
      Future<void>.delayed(
        const Duration(milliseconds: 800),
        () {
          if (!mounted ||
              token != _sessionToken) {
            return;
          }

          setState(() {
            _view = ChallengeView.completed;
          });
        },
      );

      return;
    }

    _scheduleNextRound(
      token: token,
      delay: const Duration(milliseconds: 750),
    );
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
      _feedback =
          'Ready again. Watch the next book.';
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

      _feedback =
          'Watch the room. Your books are getting angry.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration:
              const Duration(milliseconds: 250),
          child: switch (_view) {
            ChallengeView.intro => _buildIntro(),
            ChallengeView.countdown =>
              _buildCountdown(),
            ChallengeView.playing => _buildGame(),
            ChallengeView.paused => _buildPaused(),
            ChallengeView.completed =>
              _buildCompleted(),
          },
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return SingleChildScrollView(
      key: const ValueKey('intro'),
      padding:
          const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESCAPE YOUR STUDY ROOM',
                      style: TextStyle(
                        color: AppColors.tealDark,
                        fontWeight:
                            FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Quick active break',
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
            'Take a quick movement break before getting back to your study session.',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 26),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius:
                  BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.border,
              ),
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
                    size: 55,
                    color: AppColors.teal,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'The books are coming for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Squat in real life when a book flies toward you. Dodge 5 books to unlock the exit.',
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
            iconBackground:
                AppColors.elevated,
            title: 'Your movement',
            text:
                'Stand up and perform a clear squat when the app tells you to.',
          ),

          const SizedBox(height: 12),

          const _InfoCard(
            icon: Icons.health_and_safety_outlined,
            iconColor: AppColors.coral,
            iconBackground:
                Color(0xFFFFE5DE),
            title: 'Before you start',
            text:
                'Make sure there is enough clear space around you to move safely.',
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton.icon(
              onPressed: _beginCountdown,
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
              label: const Text(
                'Start Challenge',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Text(
              'READY TO MOVE?',
              style: TextStyle(
                color: AppColors.tealDark,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 28),

            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 220),
              width: 180,
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _countdown == 0
                    ? AppColors.greenLight
                    : AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _countdown == 0
                      ? AppColors.green
                      : AppColors.teal,
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
                duration:
                    const Duration(milliseconds: 220),
                child: Text(
                  _countdown == 0
                      ? 'GO!'
                      : '$_countdown',
                  key: ValueKey(_countdown),
                  style: TextStyle(
                    color: _countdown == 0
                        ? AppColors.green
                        : AppColors.tealDark,
                    fontSize:
                        _countdown == 0 ? 60 : 92,
                    fontWeight:
                        FontWeight.w900,
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

            const SizedBox(height: 6),

            const Text(
              'The first book is on its way.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Padding(
      key: const ValueKey('game'),
      padding:
          const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _pause,
                style: IconButton.styleFrom(
                  backgroundColor:
                      AppColors.card,
                  foregroundColor:
                      AppColors.text,
                  side: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                icon: const Icon(
                  Icons.pause_rounded,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DODGE MODE',
                      style: TextStyle(
                        color: AppColors.tealDark,
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Keep moving!',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.teal,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_game.dodgedBooks}/${_game.targetDodges}',
                      style: const TextStyle(
                        color: AppColors.tealDark,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ProgressSegments(
            completed: _game.dodgedBooks,
            total: _game.targetDodges,
          ),

          const SizedBox(height: 17),

          Expanded(
            child: StudyRoomScene(
              bookProgress: _bookProgress,
              canDodge: _canDodge,
              squatting: _squatting,
              dodgedBooks:
                  _game.dodgedBooks,
            ),
          ),

          const SizedBox(height: 14),

          AnimatedContainer(
            duration:
                const Duration(milliseconds: 180),
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: _canDodge
                  ? const Color(0xFFFFE5DE)
                  : AppColors.card,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: _canDodge
                    ? AppColors.coral
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  _canDodge
                      ? Icons
                          .keyboard_double_arrow_down_rounded
                      : Icons
                          .visibility_rounded,
                  color: _canDodge
                      ? AppColors.coral
                      : AppColors.teal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _feedback,
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: _canDodge
                          ? AppColors.coral
                          : AppColors.text,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!_supportsSensors) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _canDodge
                    ? _attemptDodge
                    : null,
                icon: const Icon(
                  Icons.developer_mode_rounded,
                ),
                label: const Text(
                  'Demo control: simulate squat',
                ),
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
            color: const Color(0x993D3932),
            child: Center(
              child: Container(
                width: 325,
                margin:
                    const EdgeInsets.all(24),
                padding:
                    const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration:
                          const BoxDecoration(
                        color:
                            AppColors.elevated,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pause_rounded,
                        size: 38,
                        color: AppColors.teal,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Taking a pause?',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 25,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'No problem. Continue whenever you are ready.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _PauseButton(
                      text: 'Resume',
                      onPressed: _resume,
                      primary: true,
                    ),

                    const SizedBox(height: 10),

                    _PauseButton(
                      text:
                          'Restart Challenge',
                      onPressed: _restart,
                    ),

                    const SizedBox(height: 10),

                    _PauseButton(
                      text: 'Leave Challenge',
                      onPressed:
                          _leaveChallenge,
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
              width: 120,
              height: 120,
              decoration:
                  const BoxDecoration(
                color: AppColors.greenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.door_front_door_rounded,
                color: AppColors.green,
                size: 62,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'You Escaped!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 9),

            const Text(
              'You defeated your homework. For now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSoft,
                fontSize: 17,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 26),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 16,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'CHALLENGE COMPLETE',
                    style: TextStyle(
                      color: AppColors.tealDark,
                      fontSize: 12,
                      letterSpacing: 1.3,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons
                            .auto_stories_rounded,
                        color: AppColors.teal,
                        size: 29,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_game.dodgedBooks}/${_game.targetDodges}',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 30,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'books successfully dodged',
                    style: TextStyle(
                      color:
                          AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 27),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed:
                    _leaveChallenge,
                icon: const Icon(
                  Icons.school_rounded,
                ),
                label: const Text(
                  'Back to Studying',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: _restart,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Play the challenge again',
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
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  text,
                  style: const TextStyle(
                    color:
                        AppColors.textMuted,
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
      height: 48,
      child: primary
          ? FilledButton(
              onPressed: onPressed,
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
    );
  }
}