import 'package:escape_your_study_room/features/dodge_books/domain/dodge_books_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChallengeGame', () {
    test('starts empty', () {
      final game = ChallengeGame();

      expect(game.successes, 0);

      expect(game.misses, 0);

      expect(game.isComplete, false);
    });

    test('registers successful moves', () {
      final game = ChallengeGame();

      game.registerSuccess();
      game.registerSuccess();

      expect(game.successes, 2);

      expect(game.progress, 0.4);
    });

    test('registers missed attempts', () {
      final game = ChallengeGame();

      game.registerMiss();

      expect(game.misses, 1);
    });

    test('completes after five successes', () {
      final game = ChallengeGame();

      for (var i = 0; i < 5; i++) {
        game.registerSuccess();
      }

      expect(game.successes, 5);

      expect(game.isComplete, true);

      expect(game.progress, 1);
    });

    test('reset clears progress', () {
      final game = ChallengeGame();

      game.registerSuccess();
      game.registerMiss();

      game.reset();

      expect(game.successes, 0);

      expect(game.misses, 0);
    });
  });
}
