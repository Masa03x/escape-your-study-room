import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'flying_book.dart';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final bookLeft =
              width * (0.88 - (bookProgress * 0.72));

          final bookTop =
              height * 0.28 -
              flyingBookVerticalOffset(bookProgress);

          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFFF1D8),
                ),
              ),

              // Soft wall decoration
              Positioned(
                left: -45,
                top: -45,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Color(0x22F4C95D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const Positioned(
                right: 20,
                top: 22,
                child: _Window(),
              ),

              Positioned(
                left: 18,
                top: 25,
                child: _Bookshelf(
                  progress: dodgedBooks,
                ),
              ),

              Positioned(
                right: 20,
                bottom: 45,
                child: _ExitDoor(
                  active: dodgedBooks >= 4,
                ),
              ),

              // Floor
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height * 0.28,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFE3C49A),
                  ),
                ),
              ),

              // Rug
              Positioned(
                left: width * 0.18,
                right: width * 0.18,
                bottom: 18,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFE3DB),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // Student
              Positioned(
                left: 28,
                bottom: squatting ? 32 : 37,
                child: _Student(
                  squatting: squatting,
                ),
              ),

              // Flying book
              Positioned(
                left: bookLeft,
                top: bookTop,
                child: FlyingBook(
                  progress: bookProgress,
                  isDangerous: canDodge,
                ),
              ),

              if (canDodge)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 14,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x44E76F51),
                            blurRadius: 14,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.keyboard_double_arrow_down_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'SQUAT!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Student extends StatelessWidget {
  const _Student({
    required this.squatting,
  });

  final bool squatting;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 72,
      height: squatting ? 72 : 112,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            top: squatting ? 17 : 0,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF0C7A5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.face_rounded,
                color: AppColors.textSoft,
                size: 25,
              ),
            ),
          ),
          Positioned(
            bottom: squatting ? 5 : 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: squatting ? 68 : 50,
              height: squatting ? 38 : 62,
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(
                  squatting ? 20 : 18,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
          ),
          if (!squatting) ...[
            Positioned(
              bottom: 0,
              left: 17,
              child: Container(
                width: 12,
                height: 27,
                decoration: BoxDecoration(
                  color: AppColors.textSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 17,
              child: Container(
                width: 12,
                height: 27,
                decoration: BoxDecoration(
                  color: AppColors.textSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bookshelf extends StatelessWidget {
  const _Bookshelf({
    required this.progress,
  });

  final int progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 112,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFB88157),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF9E6C48),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bookRow(progress > 0),
          _bookRow(progress > 2),
          _bookRow(progress > 3),
        ],
      ),
    );
  }

  Widget _bookRow(bool defeated) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2DEC2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 16,
            color: defeated
                ? AppColors.teal
                : AppColors.coral,
          ),
          const SizedBox(width: 4),
          Icon(
            defeated
                ? Icons.check_circle_rounded
                : Icons.sentiment_dissatisfied_rounded,
            size: 14,
            color: defeated
                ? AppColors.teal
                : AppColors.coral,
          ),
        ],
      ),
    );
  }
}

class _Window extends StatelessWidget {
  const _Window();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFBDE5F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22A3D8E8),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 10,
            top: 8,
            child: Icon(
              Icons.wb_sunny_rounded,
              color: AppColors.yellow,
              size: 25,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 32,
            child: Container(
              height: 3,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 40,
            child: Container(
              width: 3,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExitDoor extends StatelessWidget {
  const _ExitDoor({
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 68,
      height: 116,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFDDF3E5)
            : const Color(0xFFC89B72),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(14),
        ),
        border: Border.all(
          color: active
              ? AppColors.green
              : const Color(0xFFAA7B55),
          width: 3,
        ),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x555FAF7B),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ]
            : const [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'EXIT',
            style: TextStyle(
              color: active
                  ? AppColors.green
                  : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 13),
          Icon(
            active
                ? Icons.lock_open_rounded
                : Icons.lock_rounded,
            color: active
                ? AppColors.green
                : Colors.white,
            size: 26,
          ),
        ],
      ),
    );
  }
}