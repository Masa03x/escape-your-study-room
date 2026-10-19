import 'package:escape_your_study_room/features/dodge_books/domain/squat_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SquatDetector', () {
    test('detects a complete squat movement', () {
      final detector = SquatDetector();
      final startTime = DateTime(2026, 1, 1, 12);

      expect(
        detector.addSample(verticalAcceleration: -2.0, time: startTime),
        false,
      );

      expect(
        detector.addSample(
          verticalAcceleration: 1.5,
          time: startTime.add(const Duration(milliseconds: 500)),
        ),
        true,
      );
    });

    test('ignores movement below the squat threshold', () {
      final detector = SquatDetector();
      final startTime = DateTime(2026, 1, 1, 12);

      expect(
        detector.addSample(verticalAcceleration: -0.8, time: startTime),
        false,
      );

      expect(
        detector.addSample(
          verticalAcceleration: 0.7,
          time: startTime.add(const Duration(milliseconds: 400)),
        ),
        false,
      );
    });
  });

  group('JumpDetector', () {
    test('detects a complete jump movement', () {
      final detector = JumpDetector();
      final startTime = DateTime(2026, 1, 1, 12);

      expect(
        detector.addSample(verticalAcceleration: -3.5, time: startTime),
        false,
      );

      expect(
        detector.addSample(
          verticalAcceleration: 3.0,
          time: startTime.add(const Duration(milliseconds: 400)),
        ),
        true,
      );
    });

    test('ignores weak jump movement', () {
      final detector = JumpDetector();
      final startTime = DateTime(2026, 1, 1, 12);

      expect(
        detector.addSample(verticalAcceleration: -1.0, time: startTime),
        false,
      );

      expect(
        detector.addSample(
          verticalAcceleration: 1.0,
          time: startTime.add(const Duration(milliseconds: 300)),
        ),
        false,
      );
    });
  });

  group('SideStepDetector', () {
    test('detects movement to the right', () {
      final detector = SideStepDetector();
      final time = DateTime(2026, 1, 1, 12);

      expect(detector.addSample(horizontalAcceleration: 2.5, time: time), true);
    });

    test('detects movement to the left', () {
      final detector = SideStepDetector();
      final time = DateTime(2026, 1, 1, 12);

      expect(
        detector.addSample(horizontalAcceleration: -2.5, time: time),
        true,
      );
    });

    test('ignores small horizontal movement', () {
      final detector = SideStepDetector();
      final time = DateTime(2026, 1, 1, 12);

      expect(
        detector.addSample(horizontalAcceleration: 1.0, time: time),
        false,
      );
    });
  });
}
