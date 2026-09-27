# Dodge the Flying Books

## User story

As a student taking a study break, I want to dodge flying books by squatting so that I can move while progressing through the escape game.

## Why I chose this as the first feature

For the first portfolio submission I want to show one complete feature instead of trying to develop the whole app at once. This feature combines the main idea of the project: student wellbeing, physical movement, humour and a clear ending.

## Feature flow

1. The student reads the challenge instructions.
2. A 3-2-1 countdown starts.
3. A book flies toward the student.
4. The interface shows when the student should squat.
5. The phone movement sensor checks for the squat movement.
6. A successful dodge increases the progress.
7. The student repeats this until 5 books are dodged.
8. The exit opens and the challenge ends.

## Acceptance criteria

- The student can understand what movement is expected before starting.
- The challenge gives a clear countdown.
- The gameplay shows when the squat should happen.
- A successful movement gives immediate visual feedback.
- Progress is visible from 0/5 to 5/5.
- The challenge can be paused, resumed, restarted or left.
- After 5 successful dodges, the challenge has a clear ending.
- The completion screen encourages the student to return to studying.

## Technical approach

The game progress and squat detection are separated from the UI. This makes it easier to test the logic and adjust the movement thresholds without rewriting the design.

On iOS and Android the prototype uses `sensors_plus` and the user accelerometer. The current squat detector looks for a downward movement followed by an upward movement within a short time window. The thresholds are prototype values and should be validated on the real device during technical testing.

On desktop and web, a clearly labelled development button can simulate a squat. This is only for testing the interface and is not presented as real sensor detection.
