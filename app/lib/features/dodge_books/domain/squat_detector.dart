class SquatDetector {
  SquatDetector({
    this.downThreshold = -1.8,
    this.upThreshold = 1.3,
    this.maximumSequence = const Duration(milliseconds: 1200),
    this.cooldown = const Duration(milliseconds: 900),
  });

  final double downThreshold;
  final double upThreshold;
  final Duration maximumSequence;
  final Duration cooldown;

  DateTime? _downMovementAt;
  DateTime? _lastDetectedSquatAt;

  bool addSample({
    required double verticalAcceleration,
    required DateTime time,
  }) {
    final lastSquat = _lastDetectedSquatAt;
    if (lastSquat != null && time.difference(lastSquat) < cooldown) {
      return false;
    }

    if (verticalAcceleration <= downThreshold) {
      _downMovementAt = time;
      return false;
    }

    final downTime = _downMovementAt;
    if (downTime == null) {
      return false;
    }

    final elapsed = time.difference(downTime);
    if (elapsed > maximumSequence) {
      _downMovementAt = null;
      return false;
    }

    if (verticalAcceleration >= upThreshold) {
      _downMovementAt = null;
      _lastDetectedSquatAt = time;
      return true;
    }

    return false;
  }

  void reset() {
    _downMovementAt = null;
    _lastDetectedSquatAt = null;
  }
}
