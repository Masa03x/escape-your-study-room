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
    final rotation = -0.28 + (progress * 0.5);

    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 92,
        height: 72,
        decoration: BoxDecoration(
          color: isDangerous ? AppColors.red : AppColors.purple,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDangerous
                ? const Color(0xFFFF8A8A)
                : AppColors.purpleLight,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(
                isDangerous ? 239 : 124,
                isDangerous ? 68 : 58,
                isDangerous ? 68 : 237,
                0.45,
              ),
              blurRadius: 20,
              spreadRadius: 2,
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
                width: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A164F),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const Center(
              child: Text(
                '📕',
                style: TextStyle(fontSize: 35),
              ),
            ),
            Positioned(
              right: 9,
              top: 8,
              child: Text(
                isDangerous ? '😠' : '😵',
                style: const TextStyle(fontSize: 18),
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
