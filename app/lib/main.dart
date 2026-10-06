import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dodge_books/presentation/dodge_books_screen.dart';

void main() {
  runApp(const EscapeYourStudyRoomApp());
}

class EscapeYourStudyRoomApp extends StatelessWidget {
  const EscapeYourStudyRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escape Your Study Room',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DodgeBooksScreen(),
    );
  }
}