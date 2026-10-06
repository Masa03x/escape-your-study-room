import 'package:flutter/material.dart';

class StudentCharacter extends StatelessWidget {
  const StudentCharacter({required this.squatting, this.width = 68, super.key});

  final bool squatting;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (squatting) {
      return CustomPaint(
        size: Size(width * 1.32, width * 1.05),
        painter: const _SquattingStudentPainter(),
      );
    }

    return CustomPaint(
      size: Size(width, width * 1.45),
      painter: const _StandingStudentPainter(),
    );
  }
}

class _StandingStudentPainter extends CustomPainter {
  const _StandingStudentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(size.width / 58, size.height / 84);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(29, 83), width: 36, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(16, 79), width: 18, height: 9),
      Paint()..color = const Color(0xFF1F2937),
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(43, 79), width: 18, height: 9),
      Paint()..color = const Color(0xFF1F2937),
    );

    final legs =
        Paint()
          ..color = const Color(0xFF1E3A8A)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(22, 57), const Offset(17, 77), legs);

    canvas.drawLine(const Offset(36, 57), const Offset(42, 77), legs);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 25, 30, 34),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF7C3AED),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(43, 27, 12, 22),
        const Radius.circular(3.5),
      ),
      Paint()..color = const Color(0xFF5B21B6),
    );

    final arms =
        Paint()
          ..color = const Color(0xFFFBBF24)
          ..strokeWidth = 6.5
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(14, 33), const Offset(2, 22), arms);

    canvas.drawLine(const Offset(44, 33), const Offset(56, 22), arms);

    canvas.drawCircle(
      const Offset(2, 21),
      4.5,
      Paint()..color = const Color(0xFFFBBF24),
    );

    canvas.drawCircle(
      const Offset(56, 21),
      4.5,
      Paint()..color = const Color(0xFFFBBF24),
    );

    canvas.drawCircle(
      const Offset(29, 16),
      14,
      Paint()..color = const Color(0xFFFBBF24),
    );

    final hair =
        Path()
          ..moveTo(15, 13)
          ..quadraticBezierTo(15, 1, 29, 1)
          ..quadraticBezierTo(43, 1, 43, 13)
          ..quadraticBezierTo(40, 8, 29, 9)
          ..quadraticBezierTo(18, 9, 15, 13);

    canvas.drawPath(hair, Paint()..color = const Color(0xFF1F2937));

    final face = Paint()..color = const Color(0xFF1F2937);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(24, 16), width: 5.6, height: 6.4),
      face,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(34, 16), width: 5.6, height: 6.4),
      face,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(29, 22), width: 8, height: 7),
      Paint()..color = const Color(0xFFDC2626),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SquattingStudentPainter extends CustomPainter {
  const _SquattingStudentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(size.width / 90, size.height / 72);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(45, 71), width: 56, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(10, 66), width: 22, height: 10),
      Paint()..color = const Color(0xFF1F2937),
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(74, 66), width: 22, height: 10),
      Paint()..color = const Color(0xFF1F2937),
    );

    final legs =
        Paint()
          ..color = const Color(0xFF1E3A8A)
          ..strokeWidth = 8.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final leftLeg =
        Path()
          ..moveTo(33, 44)
          ..quadraticBezierTo(20, 56, 12, 65);

    final rightLeg =
        Path()
          ..moveTo(49, 44)
          ..quadraticBezierTo(63, 56, 73, 65);

    canvas.drawPath(leftLeg, legs);
    canvas.drawPath(rightLeg, legs);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 22, 34, 24),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF7C3AED),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(57, 24, 13, 18),
        const Radius.circular(3.5),
      ),
      Paint()..color = const Color(0xFF5B21B6),
    );

    final arms =
        Paint()
          ..color = const Color(0xFFFBBF24)
          ..strokeWidth = 6.5
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(24, 31), const Offset(6, 42), arms);

    canvas.drawLine(const Offset(58, 31), const Offset(76, 44), arms);

    canvas.drawCircle(
      const Offset(6, 42),
      4.5,
      Paint()..color = const Color(0xFFFBBF24),
    );

    canvas.drawCircle(
      const Offset(76, 44),
      4.5,
      Paint()..color = const Color(0xFFFBBF24),
    );

    canvas.drawCircle(
      const Offset(41, 14),
      13,
      Paint()..color = const Color(0xFFFBBF24),
    );

    final hair =
        Path()
          ..moveTo(28, 12)
          ..quadraticBezierTo(28, 1, 41, 1)
          ..quadraticBezierTo(54, 1, 54, 12)
          ..quadraticBezierTo(51, 7, 41, 8)
          ..quadraticBezierTo(31, 8, 28, 12);

    canvas.drawPath(hair, Paint()..color = const Color(0xFF1F2937));

    final eyePaint = Paint()..color = const Color(0xFF1F2937);

    canvas.drawCircle(const Offset(36, 14), 2.8, eyePaint);

    canvas.drawCircle(const Offset(46, 14), 2.8, eyePaint);

    final smile =
        Path()
          ..moveTo(34, 20)
          ..quadraticBezierTo(41, 24, 48, 20);

    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF1F2937)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
