# Dodge the Flying Books — Testing

## What is already tested in code

Automated tests cover:

- game progress starts at 0/5;
- successful dodges increase progress;
- progress stops at 5/5;
- reset clears the challenge;
- the squat detector recognises a down-then-up movement sequence;
- movements that take too long are rejected;
- a cooldown prevents the same movement from being counted repeatedly.

GitHub Actions runs `flutter analyze` and `flutter test` for the feature branch.

## Real-device technical test still needed

The movement thresholds are prototype values. They need to be tested on a real iPhone because sensor values can change depending on how the phone is held and how quickly the student squats.

During the technical test I want to check:

1. Does a normal squat register consistently?
2. Does normal hand movement accidentally count as a squat?
3. Is the dodge window long enough?
4. Does the cooldown prevent double-counting?
5. Is the visual feedback fast enough after a successful movement?

## User test still needed

I have not added user-test results yet because they should come from an actual test.

For the next user test I want to observe whether the student understands:

- what movement they need to make;
- when they need to squat;
- whether the progress is clear;
- whether pause/resume is easy to find;
- whether the completion screen feels like a clear ending;
- whether the challenge feels like a short active break instead of an endless game.

The results can be added to this document after the test and then used for the next design/development iteration.
