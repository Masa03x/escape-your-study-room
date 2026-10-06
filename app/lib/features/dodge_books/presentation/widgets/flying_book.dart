import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class FlyingBook extends StatelessWidget {
  const FlyingBook({
    required this.progress,
    required this.isDangerous,
    super.key,
  });

  final double progress;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    final rotation = -0.22 + (progress * 0.42);

    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: 94,
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 5,
              right: 0,
              top: 6,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD7CAB9),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            Positioned.fill(
              right: 5,
              bottom: 6,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isDangerous
                      ? AppColors.coral
                      : AppColors.teal,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDangerous
                          ? const Color(0x44E76F51)
                          : const Color(0x442A9D8F),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 10,
                      top: 8,
                      bottom: 8,
                      child: Container(
                        width: 7,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        isDangerous
                            ? Icons.sentiment_very_dissatisfied_rounded
                            : Icons.sentiment_dissatisfied_rounded,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const Positioned(
                      right: 8,
                      bottom: 7,
                      child: Icon(
                        Icons.auto_stories_rounded,
                        size: 17,
                        color: Colors.white70,
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
}

double flyingBookVerticalOffset(double progress) {
  return math.sin(progress * math.pi) * 28;
}