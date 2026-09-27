# Flutter application

This folder contains the Flutter source for **Escape Your Study Room**.

The first implemented portfolio feature is developed on:

`feature/dodge-books`

## First local setup

After cloning the repository and checking out the feature branch:

```bash
cd app
flutter create . --project-name escape_your_study_room
flutter pub get
flutter analyze
flutter test
flutter run
```

`flutter create .` generates the local Android, iOS, macOS, web, Linux and Windows project files that Flutter needs to run the source.

Generated cache/build folders are ignored by Git.

## Current feature structure

```text
lib/
├── main.dart
├── core/
│   └── theme/
│       └── app_theme.dart
└── features/
    └── dodge_books/
        ├── domain/
        │   ├── dodge_books_game.dart
        │   └── squat_detector.dart
        └── presentation/
            ├── dodge_books_screen.dart
            └── widgets/
                ├── flying_book.dart
                ├── progress_segments.dart
                └── study_room_scene.dart
```

The movement detector uses `sensors_plus` on iOS and Android. Desktop/web shows a clearly labelled demo control for testing the interface without pretending that sensor input is active.
