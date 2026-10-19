import 'package:escape_your_study_room/features/dodge_books/domain/squat_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SquatDetector', () {
    test('detects a down and up movement', () {
      final detector = SquatDetector();

      final start = DateTime(2026, 1, 1, 12);

      final down = detector.addSample(verticalAcceleration: -2.0, time: start);

      final up = detector.addSample(
        verticalAcceleration: 1.5,
        time: start.add(const Duration(milliseconds: 500)),
      );

      expect(down, false);

      expect(up, true);
    });

    test('does not detect slow movement', () {
      final detector = SquatDetector();

      final start = DateTime(2026, 1, 1, 12);

      detector.addSample(verticalAcceleration: -2.0, time: start);

      final result = detector.addSample(
        verticalAcceleration: 1.5,
        time: start.add(const Duration(seconds: 2)),
      );

      expect(result, false);
    });
  });
}
