class DodgeBooksGame {
  DodgeBooksGame({this.targetDodges = 5});

  final int targetDodges;

  int _dodgedBooks = 0;

  int get dodgedBooks => _dodgedBooks;

  bool get isComplete => _dodgedBooks >= targetDodges;

  double get progress {
    if (targetDodges <= 0) return 1;
    return (_dodgedBooks / targetDodges).clamp(0.0, 1.0);
  }

  bool registerDodge() {
    if (isComplete) return false;

    _dodgedBooks += 1;
    return true;
  }

  void reset() {
    _dodgedBooks = 0;
  }
}
