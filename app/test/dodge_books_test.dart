import 'package:escape_your_study_room/features/dodge_books/domain/dodge_books_game.dart';
import 'package:escape_your_study_room/features/dodge_books/domain/squat_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DodgeBooksGame', () {
    test('starts with zero dodged books', () {
      final game = DodgeBooksGame();

      expect(game.dodgedBooks, 0);
      expect(game.isComplete, isFalse);
      expect(game.progress, 0);
    });

    test('registers dodges until the target is reached', () {
      final game = DodgeBooksGame();

      for (var i = 0; i < 5; i++) {
        expect(game.registerDodge(), isTrue);
      }

      expect(game.dodgedBooks, 5);
      expect(game.isComplete, isTrue);
      expect(game.progress, 1);
    });

    test('does not add extra dodges after completion', () {
      final game = DodgeBooksGame();

      for (var i = 0; i < 5; i++) {
        game.registerDodge();
      }

      expect(game.registerDodge(), isFalse);
      expect(game.dodgedBooks, 5);
    });

    test('reset clears progress', () {
      final game = DodgeBooksGame();
      game.registerDodge();
      game.registerDodge();

      game.reset();

      expect(game.dodgedBooks, 0);
      expect(game.isComplete, isFalse);
    });
  });

  group('SquatDetector', () {
    test('detects a down then up movement inside the allowed time', () {
      final detector = SquatDetector();
      final start = DateTime(2026, 9, 27, 12);

      expect(
        detector.addSample(
          verticalAcceleration: -2.2,
          time: start,
        ),
        isFalse,
      );

      expect(
        detector.addSample(
          verticalAcceleration: 1.8,
          time: start.add(const Duration(milliseconds: 450)),
        ),
        isTrue,
      );
    });

    test('does not detect a movement sequence that is too slow', () {
      final detector = SquatDetector();
      final start = DateTime(2026, 9, 27, 12);

      detector.addSample(
        verticalAcceleration: -2.2,
        time: start,
      );

      expect(
        detector.addSample(
          verticalAcceleration: 1.8,
          time: start.add(const Duration(seconds: 2)),
        ),
        isFalse,
      );
    });

    test('applies a cooldown after a detected squat', () {
      final detector = SquatDetector();
      final start = DateTime(2026, 9, 27, 12);

      detector.addSample(
        verticalAcceleration: -2.2,
        time: start,
      );
      expect(
        detector.addSample(
          verticalAcceleration: 1.8,
          time: start.add(const Duration(milliseconds: 350)),
        ),
        isTrue,
      );

      detector.addSample(
        verticalAcceleration: -2.4,
        time: start.add(const Duration(milliseconds: 500)),
      );

      expect(
        detector.addSample(
          verticalAcceleration: 2,
          time: start.add(const Duration(milliseconds: 700)),
        ),
        isFalse,
      );
    });
  });
}
