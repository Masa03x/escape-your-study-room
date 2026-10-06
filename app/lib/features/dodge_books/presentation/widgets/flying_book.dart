import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

enum BookEmotion { angry, scared, dizzy }

class FlyingBook extends StatelessWidget {
  const FlyingBook({
    required this.progress,
    required this.isDangerous,
    this.width = 80,
    this.bookColor,
    this.spineColor,
    this.title = 'MATH',
    this.emotion = BookEmotion.angry,
    this.rotation,
    this.showMotionLines = true,
    super.key,
  });

  final double progress;
  final bool isDangerous;

  final double width;
  final Color? bookColor;
  final Color? spineColor;
  final String title;
  final BookEmotion emotion;
  final double? rotation;
  final bool showMotionLines;

  @override
  Widget build(BuildContext context) {
    final color = bookColor ?? (isDangerous ? AppColors.red : AppColors.purple);

    final spine =
        spineColor ?? (isDangerous ? AppColors.redDark : AppColors.purpleDark);

    return Transform.rotate(
      angle: rotation ?? (-0.20 + progress * 0.35),
      child: CustomPaint(
        size: Size(width, width * 1.25),
        painter: _FlyingBookPainter(
          color: color,
          spineColor: spine,
          title: title,
          emotion: emotion,
          showMotionLines: showMotionLines,
        ),
      ),
    );
  }
}

class _FlyingBookPainter extends CustomPainter {
  const _FlyingBookPainter({
    required this.color,
    required this.spineColor,
    required this.title,
    required this.emotion,
    required this.showMotionLines,
  });

  final Color color;
  final Color spineColor;
  final String title;
  final BookEmotion emotion;
  final bool showMotionLines;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 80;
    final sy = size.height / 100;

    canvas.save();
    canvas.scale(sx, sy);

    if (showMotionLines) {
      final motionPaint =
          Paint()
            ..color = Colors.white.withValues(alpha: 0.20)
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(const Offset(0, 28), const Offset(-16, 28), motionPaint);

      motionPaint.strokeWidth = 2.5;

      canvas.drawLine(const Offset(0, 38), const Offset(-20, 38), motionPaint);

      motionPaint.strokeWidth = 1.5;

      canvas.drawLine(const Offset(0, 48), const Offset(-12, 48), motionPaint);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(73, 5, 4, 88),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFFF5F5),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5, 3, 70, 92),
        const Radius.circular(6),
      ),
      Paint()..color = color,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5, 3, 13, 92),
        const Radius.circular(5),
      ),
      Paint()..color = spineColor,
    );

    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: AppTheme.fredoka(
          fontSize: 7,
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 45);

    titlePainter.paint(canvas, Offset(44 - titlePainter.width / 2, 14));

    final decorationPaint =
        Paint()..color = Colors.white.withValues(alpha: 0.20);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(22, 25, 44, 2.5),
        const Radius.circular(1.2),
      ),
      decorationPaint,
    );

    decorationPaint.color = Colors.white.withValues(alpha: 0.12);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(22, 30, 30, 2),
        const Radius.circular(1),
      ),
      decorationPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(44, 65), width: 52, height: 48),
      Paint()..color = const Color(0xFFFEF2F2),
    );

    switch (emotion) {
      case BookEmotion.angry:
        _paintAngryFace(canvas);
        break;

      case BookEmotion.scared:
        _paintScaredFace(canvas);
        break;

      case BookEmotion.dizzy:
        _paintDizzyFace(canvas);
        break;
    }

    canvas.restore();
  }

  void _paintAngryFace(Canvas canvas) {
    final dark = Paint()..color = const Color(0xFF1F2937);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(36, 60), width: 10, height: 10),
      dark,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(52, 60), width: 10, height: 10),
      dark,
    );

    final white = Paint()..color = Colors.white;

    canvas.drawCircle(const Offset(37, 58.5), 1.8, white);
    canvas.drawCircle(const Offset(53, 58.5), 1.8, white);

    final stroke =
        Paint()
          ..color = const Color(0xFF1F2937)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(28, 51), const Offset(43, 56), stroke);

    canvas.drawLine(const Offset(60, 51), const Offset(45, 56), stroke);

    final mouth =
        Path()
          ..moveTo(33, 75)
          ..quadraticBezierTo(44, 70, 55, 75);

    stroke.strokeWidth = 2.5;
    canvas.drawPath(mouth, stroke);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(29, 68), width: 10, height: 6),
      Paint()..color = AppColors.red.withValues(alpha: 0.30),
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(59, 68), width: 10, height: 6),
      Paint()..color = AppColors.red.withValues(alpha: 0.30),
    );

    final arm =
        Paint()
          ..color = color
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(5, 58), const Offset(-9, 48), arm);

    canvas.drawLine(const Offset(75, 58), const Offset(89, 48), arm);

    canvas.drawCircle(const Offset(-9, 47), 7, Paint()..color = spineColor);

    canvas.drawCircle(const Offset(89, 47), 7, Paint()..color = spineColor);
  }

  void _paintScaredFace(Canvas canvas) {
    final dark = Paint()..color = const Color(0xFF1F2937);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(36, 60), width: 11, height: 12),
      dark,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(52, 60), width: 11, height: 12),
      dark,
    );

    canvas.drawCircle(const Offset(37, 57), 2, Paint()..color = Colors.white);

    canvas.drawCircle(const Offset(53, 57), 2, Paint()..color = Colors.white);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(44, 75), width: 14, height: 10),
      dark,
    );
  }

  void _paintDizzyFace(Canvas canvas) {
    final stroke =
        Paint()
          ..color = const Color(0xFF1F2937)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(29, 54), const Offset(43, 68), stroke);

    canvas.drawLine(const Offset(43, 54), const Offset(29, 68), stroke);

    canvas.drawLine(const Offset(47, 54), const Offset(61, 68), stroke);

    canvas.drawLine(const Offset(61, 54), const Offset(47, 68), stroke);

    final mouth =
        Path()
          ..moveTo(32, 75)
          ..quadraticBezierTo(36, 79, 44, 75)
          ..quadraticBezierTo(52, 71, 56, 75);

    final mouthPaint =
        Paint()
          ..color = const Color(0xFF1F2937)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawPath(mouth, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant _FlyingBookPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.spineColor != spineColor ||
        oldDelegate.title != title ||
        oldDelegate.emotion != emotion;
  }
}

double flyingBookVerticalOffset(double progress) {
  return math.sin(progress * math.pi) * 28;
}
