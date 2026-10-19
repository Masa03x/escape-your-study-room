class DodgeBooksGame {
  DodgeBooksGame({this.targetDodges = 5});

  final int targetDodges;

  int _dodgedBooks = 0;
  int _missedBooks = 0;

  int get dodgedBooks => _dodgedBooks;

  int get missedBooks => _missedBooks;

  int get totalAttempts => _dodgedBooks + _missedBooks;

  bool get isComplete => _dodgedBooks >= targetDodges;

  double get progress {
    if (targetDodges <= 0) {
      return 1;
    }

    return (_dodgedBooks / targetDodges).clamp(0.0, 1.0);
  }

  bool registerDodge() {
    if (isComplete) {
      return false;
    }

    _dodgedBooks += 1;

    return true;
  }

  void registerMiss() {
    if (isComplete) {
      return;
    }

    _missedBooks += 1;
  }

  void reset() {
    _dodgedBooks = 0;
    _missedBooks = 0;
  }
}
