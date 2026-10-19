import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dodge_books_game.dart';

class GameObstacle extends StatelessWidget {
  const GameObstacle({
    required this.type,
    required this.isDangerous,
    required this.index,
    this.scale = 1,
    super.key,
  });

  final ChallengeType type;
  final bool isDangerous;
  final int index;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: switch (type) {
        ChallengeType.flyingBooks => _AngryBook(
          isDangerous: isDangerous,
          index: index,
        ),
        ChallengeType.jumpCables => _CableObstacle(isDangerous: isDangerous),
        ChallengeType.distractions => _DistractionObstacle(
          isDangerous: isDangerous,
          index: index,
        ),
      },
    );
  }
}

class _AngryBook extends StatelessWidget {
  const _AngryBook({required this.isDangerous, required this.index});

  final bool isDangerous;
  final int index;

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.coral,
      AppColors.teal,
      AppColors.blue,
      AppColors.purple,
      AppColors.green,
    ];

    const titles = ['MATH', 'ESSAY', 'DEADLINE', 'EXAM', 'GROUP WORK'];

    final color = isDangerous ? AppColors.coral : colors[index % colors.length];

    final title = titles[index % titles.length];

    return Transform.rotate(
      angle: -0.10,
      child: SizedBox(
        width: 102,
        height: 91,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -14,
              top: 39,
              child: Transform.rotate(angle: -0.8, child: _bookArm()),
            ),
            Positioned(
              right: -13,
              top: 34,
              child: Transform.rotate(angle: 0.8, child: _bookArm()),
            ),
            Positioned(
              left: 6,
              right: 0,
              top: 7,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD7CAB9),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Positioned.fill(
              right: 6,
              bottom: 7,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.32),
                      blurRadius: isDangerous ? 20 : 12,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 9,
                      top: 7,
                      bottom: 7,
                      child: Container(
                        width: 7,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.34),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const _AngryFace(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookArm() {
    return Container(
      width: 24,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _AngryFace extends StatelessWidget {
  const _AngryFace();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 43,
      height: 28,
      child: Stack(
        children: [
          Positioned(
            left: 4,
            top: 4,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 13,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 13,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 9,
            top: 10,
            child: CircleAvatar(radius: 3, backgroundColor: Colors.white),
          ),
          const Positioned(
            right: 9,
            top: 10,
            child: CircleAvatar(radius: 3, backgroundColor: Colors.white),
          ),
          Positioned(
            left: 13,
            bottom: 1,
            child: Container(
              width: 17,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CableObstacle extends StatelessWidget {
  const _CableObstacle({required this.isDangerous});

  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    final color = isDangerous ? AppColors.coral : AppColors.blue;

    return SizedBox(
      width: 120,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(112, 62),
            painter: _CablePainter(color: color),
          ),
          Positioned(left: 0, bottom: 11, child: _Plug(color: color)),
          Positioned(
            right: 0,
            bottom: 11,
            child: Transform.flip(flipX: true, child: _Plug(color: color)),
          ),
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'TRIP HAZARD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CablePainter extends CustomPainter {
  _CablePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(12, size.height - 18);

    path.cubicTo(
      size.width * 0.30,
      size.height - 48,
      size.width * 0.55,
      size.height - 3,
      size.width - 12,
      size.height - 21,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CablePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _Plug extends StatelessWidget {
  const _Plug({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 29,
      height: 27,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.power_rounded, color: Colors.white, size: 17),
    );
  }
}

class _DistractionObstacle extends StatelessWidget {
  const _DistractionObstacle({required this.isDangerous, required this.index});

  final bool isDangerous;
  final int index;

  @override
  Widget build(BuildContext context) {
    const labels = [
      'NEW REEL',
      '3 MESSAGES',
      'NEW VIDEO',
      'GROUP CHAT',
      'SCROLL?',
    ];

    final label = labels[index % labels.length];

    return SizedBox(
      width: 116,
      height: 103,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 16,
            top: 16,
            child: Transform.rotate(
              angle: -0.10,
              child: Container(
                width: 88,
                height: 65,
                decoration: BoxDecoration(
                  color: AppColors.yellowSoft,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Transform.rotate(
              angle: 0.12,
              child: Container(
                width: 88,
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x228A72B4),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isDangerous)
            const Positioned(
              left: -2,
              bottom: 1,
              child: Icon(
                Icons.priority_high_rounded,
                color: AppColors.coral,
                size: 36,
              ),
            ),
        ],
      ),
    );
  }
}

double gameObstacleVerticalOffset(double progress) {
  return math.sin(progress * math.pi) * 25;
}
