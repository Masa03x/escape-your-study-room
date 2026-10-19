enum ChallengeType { flyingBooks, jumpCables, distractions }

extension ChallengeTypeData on ChallengeType {
  String get title {
    switch (this) {
      case ChallengeType.flyingBooks:
        return 'Dodge the Flying Books';
      case ChallengeType.jumpCables:
        return 'Jump the Cables';
      case ChallengeType.distractions:
        return 'Side-Step the Distractions';
    }
  }

  String get shortTitle {
    switch (this) {
      case ChallengeType.flyingBooks:
        return 'Flying Books';
      case ChallengeType.jumpCables:
        return 'Jump Cables';
      case ChallengeType.distractions:
        return 'Distractions';
    }
  }

  String get movement {
    switch (this) {
      case ChallengeType.flyingBooks:
        return 'SQUAT';
      case ChallengeType.jumpCables:
        return 'JUMP';
      case ChallengeType.distractions:
        return 'SIDE-STEP';
    }
  }

  String get goal {
    switch (this) {
      case ChallengeType.flyingBooks:
        return 'Dodge 5 flying books';
      case ChallengeType.jumpCables:
        return 'Jump over 5 cables';
      case ChallengeType.distractions:
        return 'Avoid 5 distractions';
    }
  }

  String get instruction {
    switch (this) {
      case ChallengeType.flyingBooks:
        return 'Squat when the flying book reaches you.';
      case ChallengeType.jumpCables:
        return 'Jump when the cable reaches your position.';
      case ChallengeType.distractions:
        return 'Step left or right when the distraction gets close.';
    }
  }

  String get countdownPrompt {
    switch (this) {
      case ChallengeType.flyingBooks:
        return 'Get ready to squat';
      case ChallengeType.jumpCables:
        return 'Get ready to jump';
      case ChallengeType.distractions:
        return 'Get ready to move';
    }
  }

  String get actionMessage {
    switch (this) {
      case ChallengeType.flyingBooks:
        return 'SQUAT NOW!';
      case ChallengeType.jumpCables:
        return 'JUMP NOW!';
      case ChallengeType.distractions:
        return 'MOVE NOW!';
    }
  }

  String get funnyLine {
    switch (this) {
      case ChallengeType.flyingBooks:
        return 'Apparently your homework learned how to fly.';
      case ChallengeType.jumpCables:
        return 'Your charger cables have chosen violence.';
      case ChallengeType.distractions:
        return 'Notifications are coming for your attention.';
    }
  }
}

class ChallengeGame {
  ChallengeGame({this.targetSuccesses = 5});

  final int targetSuccesses;

  int _successes = 0;
  int _misses = 0;

  int get successes => _successes;

  int get misses => _misses;

  bool get isComplete => _successes >= targetSuccesses;

  double get progress {
    if (targetSuccesses <= 0) {
      return 1;
    }

    return (_successes / targetSuccesses).clamp(0.0, 1.0);
  }

  bool registerSuccess() {
    if (isComplete) {
      return false;
    }

    _successes += 1;
    return true;
  }

  void registerMiss() {
    if (isComplete) {
      return;
    }

    _misses += 1;
  }

  void reset() {
    _successes = 0;
    _misses = 0;
  }
}
