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
  DateTime? _lastDetectedAt;

  bool addSample({
    required double verticalAcceleration,
    required DateTime time,
  }) {
    final lastDetected = _lastDetectedAt;

    if (lastDetected != null && time.difference(lastDetected) < cooldown) {
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
      _lastDetectedAt = time;
      return true;
    }

    return false;
  }

  void reset() {
    _downMovementAt = null;
    _lastDetectedAt = null;
  }
}

class JumpDetector {
  JumpDetector({
    this.downThreshold = -3.0,
    this.upThreshold = 2.7,
    this.maximumSequence = const Duration(milliseconds: 900),
    this.cooldown = const Duration(milliseconds: 1100),
  });

  final double downThreshold;
  final double upThreshold;

  final Duration maximumSequence;
  final Duration cooldown;

  DateTime? _firstMovementAt;
  DateTime? _lastDetectedAt;

  bool addSample({
    required double verticalAcceleration,
    required DateTime time,
  }) {
    final lastDetected = _lastDetectedAt;

    if (lastDetected != null && time.difference(lastDetected) < cooldown) {
      return false;
    }

    if (verticalAcceleration <= downThreshold) {
      _firstMovementAt = time;
      return false;
    }

    final firstMovement = _firstMovementAt;

    if (firstMovement == null) {
      return false;
    }

    final elapsed = time.difference(firstMovement);

    if (elapsed > maximumSequence) {
      _firstMovementAt = null;
      return false;
    }

    if (verticalAcceleration >= upThreshold) {
      _firstMovementAt = null;
      _lastDetectedAt = time;
      return true;
    }

    return false;
  }

  void reset() {
    _firstMovementAt = null;
    _lastDetectedAt = null;
  }
}

class SideStepDetector {
  SideStepDetector({
    this.horizontalThreshold = 2.2,
    this.cooldown = const Duration(milliseconds: 900),
  });

  final double horizontalThreshold;
  final Duration cooldown;

  DateTime? _lastDetectedAt;

  bool addSample({
    required double horizontalAcceleration,
    required DateTime time,
  }) {
    final lastDetected = _lastDetectedAt;

    if (lastDetected != null && time.difference(lastDetected) < cooldown) {
      return false;
    }

    if (horizontalAcceleration.abs() >= horizontalThreshold) {
      _lastDetectedAt = time;
      return true;
    }

    return false;
  }

  void reset() {
    _lastDetectedAt = null;
  }
}
