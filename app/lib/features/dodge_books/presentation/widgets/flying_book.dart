import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class FlyingBook extends StatelessWidget {
  const FlyingBook({
    required this.progress,
    required this.isDangerous,
    required this.title,
    required this.color,
    super.key,
  });

  final double progress;
  final bool isDangerous;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final rotation = -0.20 + (progress * 0.38);

    return Transform.rotate(
      angle: rotation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 94,
        height: 78,
        decoration: BoxDecoration(
          color: isDangerous ? AppColors.coral : color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color:
                  isDangerous
                      ? const Color(0x55E76F51)
                      : const Color(0x332A9D8F),
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
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDangerous
                        ? Icons.sentiment_very_dissatisfied_rounded
                        : Icons.sentiment_dissatisfied_rounded,
                    color: Colors.white,
                    size: 31,
                  ),

                  const SizedBox(height: 3),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Positioned(
              right: 7,
              bottom: 6,
              child: Icon(
                Icons.auto_stories_rounded,
                color: Colors.white70,
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double flyingBookVerticalOffset(double progress) {
  return math.sin(progress * math.pi) * 25;
}
