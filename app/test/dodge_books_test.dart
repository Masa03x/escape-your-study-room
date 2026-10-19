import 'package:escape_your_study_room/features/dodge_books/domain/dodge_books_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DodgeBooksGame', () {
    test('starts with zero progress', () {
      final game = DodgeBooksGame();

      expect(game.dodgedBooks, 0);

      expect(game.missedBooks, 0);

      expect(game.isComplete, false);
    });

    test('registers successful dodges', () {
      final game = DodgeBooksGame();

      game.registerDodge();
      game.registerDodge();

      expect(game.dodgedBooks, 2);

      expect(game.progress, 0.4);
    });

    test('registers missed books', () {
      final game = DodgeBooksGame();

      game.registerMiss();

      expect(game.missedBooks, 1);

      expect(game.dodgedBooks, 0);
    });

    test('challenge completes after five dodges', () {
      final game = DodgeBooksGame();

      for (var i = 0; i < 5; i++) {
        game.registerDodge();
      }

      expect(game.dodgedBooks, 5);

      expect(game.isComplete, true);

      expect(game.progress, 1);
    });

    test('reset clears the challenge', () {
      final game = DodgeBooksGame();

      game.registerDodge();
      game.registerMiss();

      game.reset();

      expect(game.dodgedBooks, 0);

      expect(game.missedBooks, 0);
    });
  });
}
