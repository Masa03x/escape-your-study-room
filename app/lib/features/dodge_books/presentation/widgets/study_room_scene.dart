import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'flying_book.dart';
import 'student_character.dart';

class StudyRoomScene extends StatelessWidget {
  const StudyRoomScene({
    required this.bookProgress,
    required this.canDodge,
    required this.squatting,
    required this.dodgedBooks,
    super.key,
  });

  final double bookProgress;
  final bool canDodge;
  final bool squatting;
  final int dodgedBooks;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final bookLeft = width * (0.88 - bookProgress * 0.74);

        final bookTop = height * 0.28 - flyingBookVerticalOffset(bookProgress);

        final doorGlow = dodgedBooks >= 2;
        final brightDoor = dodgedBooks >= 4;

        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      brightDoor
                          ? const Color(0xFF0A1A12)
                          : const Color(0xFF141240),
                      AppColors.surface,
                      AppColors.background,
                    ],
                  ),
                ),
              ),

              const Positioned(top: 22, right: 20, child: _StudyWindow()),

              const Positioned(left: 18, top: 28, child: _Bookshelf()),

              Positioned(
                right: 20,
                bottom: 40,
                child: _ExitDoor(glowing: doorGlow, bright: brightDoor),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height * 0.24,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3D2408), Color(0xFF1F1205)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 28,
                bottom: squatting ? 27 : 35,
                child: StudentCharacter(
                  squatting: squatting,
                  width: squatting ? 76 : 60,
                ),
              ),

              Positioned(
                left: bookLeft,
                top: bookTop,
                child: FlyingBook(
                  progress: bookProgress,
                  isDangerous: canDodge,
                  width: 72,
                  bookColor: _bookColor(),
                  spineColor: _spineColor(),
                  title: _bookTitle(),
                  emotion: _bookEmotion(),
                ),
              ),

              if (canDodge)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withValues(alpha: 0.35),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Text(
                        'SQUAT NOW!',
                        style: AppTheme.fredoka(
                          fontSize: 13,
                          color: const Color(0xFF211705),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _bookColor() {
    const colors = [
      AppColors.red,
      AppColors.blue,
      Color(0xFFD97706),
      AppColors.purple,
      Color(0xFFDC2626),
    ];

    return colors[dodgedBooks % colors.length];
  }

  Color _spineColor() {
    const colors = [
      AppColors.redDark,
      AppColors.blueDark,
      Color(0xFF92400E),
      AppColors.purpleDark,
      AppColors.redDark,
    ];

    return colors[dodgedBooks % colors.length];
  }

  String _bookTitle() {
    const titles = ['MATHS', 'HISTORY', 'ESSAY', 'THESIS', 'ALGEBRA'];

    return titles[dodgedBooks % titles.length];
  }

  BookEmotion _bookEmotion() {
    if (dodgedBooks >= 4) {
      return BookEmotion.dizzy;
    }

    if (dodgedBooks >= 2) {
      return BookEmotion.scared;
    }

    return BookEmotion.angry;
  }
}

class _Bookshelf extends StatelessWidget {
  const _Bookshelf();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF302049),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ShelfBooks(),
          Divider(color: AppColors.borderLight, height: 2),
          _ShelfBooks(),
          Divider(color: AppColors.borderLight, height: 2),
          _ShelfBooks(),
        ],
      ),
    );
  }
}

class _ShelfBooks extends StatelessWidget {
  const _ShelfBooks();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _book(AppColors.red, 25),
        const SizedBox(width: 3),
        _book(AppColors.blue, 21),
        const SizedBox(width: 3),
        _book(AppColors.purple, 27),
      ],
    );
  }

  Widget _book(Color color, double h) {
    return Container(
      width: 10,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _StudyWindow extends StatelessWidget {
  const _StudyWindow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 67,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1334),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderLight, width: 3),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 10,
            top: 8,
            child: Icon(
              Icons.nightlight_round,
              color: Color(0xFFFDE68A),
              size: 20,
            ),
          ),
          ...List.generate(
            5,
            (index) => Positioned(
              left: 8.0 + index * 14,
              top: 10.0 + (index % 2) * 24,
              child: const CircleAvatar(
                radius: 1.5,
                backgroundColor: AppColors.purpleLight,
              ),
            ),
          ),
          Positioned(
            left: 41,
            top: 0,
            bottom: 0,
            child: Container(width: 2, color: AppColors.borderLight),
          ),
        ],
      ),
    );
  }
}

class _ExitDoor extends StatelessWidget {
  const _ExitDoor({required this.glowing, required this.bright});

  final bool glowing;
  final bool bright;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: 67,
      height: 116,
      decoration: BoxDecoration(
        color: const Color(0xFF241D39),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
        border: Border.all(
          width: 3,
          color: glowing ? AppColors.green : AppColors.borderLight,
        ),
        boxShadow:
            glowing
                ? [
                  BoxShadow(
                    color: AppColors.green.withValues(
                      alpha: bright ? 0.8 : 0.45,
                    ),
                    blurRadius: bright ? 30 : 16,
                    spreadRadius: bright ? 4 : 1,
                  ),
                ]
                : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'EXIT',
            style: AppTheme.fredoka(
              fontSize: 10,
              color: glowing ? AppColors.greenLight : AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Icon(
            Icons.door_front_door_rounded,
            size: 34,
            color: glowing ? AppColors.greenLight : AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
