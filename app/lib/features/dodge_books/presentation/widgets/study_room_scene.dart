import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'flying_book.dart';

class StudyRoomScene extends StatelessWidget {
  const StudyRoomScene({
    required this.bookProgress,
    required this.canDodge,
    required this.squatting,
    required this.dodgedBooks,
    required this.roundNumber,
    super.key,
  });

  final double bookProgress;
  final bool canDodge;
  final bool squatting;
  final int dodgedBooks;
  final int roundNumber;

  static const List<String> _bookTitles = [
    'MATH',
    'DEADLINE',
    'ESSAY',
    'GROUP WORK',
    '8AM CLASS',
  ];

  static const List<Color> _bookColors = [
    AppColors.teal,
    Color(0xFF7087C4),
    Color(0xFFD88B5B),
    Color(0xFF9B75B5),
    Color(0xFF5FAF7B),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final height = constraints.maxHeight;

          final bookLeft = width * (0.88 - (bookProgress * 0.78));

          final bookTop =
              height * 0.29 - flyingBookVerticalOffset(bookProgress);

          final safeRound = roundNumber <= 0 ? 0 : roundNumber - 1;

          final title = _bookTitles[safeRound % _bookTitles.length];

          final color = _bookColors[safeRound % _bookColors.length];

          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFFFF1D8)),
              ),

              Positioned(
                left: -50,
                top: -50,
                child: Container(
                  width: 165,
                  height: 165,
                  decoration: const BoxDecoration(
                    color: Color(0x22F4C95D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const Positioned(right: 20, top: 22, child: _Window()),

              Positioned(
                left: 18,
                top: 24,
                child: _Bookshelf(progress: dodgedBooks),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height * 0.28,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFE3C49A)),
                ),
              ),

              Positioned(
                left: width * 0.15,
                right: width * 0.15,
                bottom: 18,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              Positioned(
                right: 18,
                bottom: 42,
                child: _ExitDoor(progress: dodgedBooks),
              ),

              Positioned(
                left: 24,
                bottom: squatting ? 29 : 34,
                child: _Student(squatting: squatting),
              ),

              Positioned(
                left: bookLeft,
                top: bookTop,
                child: FlyingBook(
                  progress: bookProgress,
                  isDangerous: canDodge,
                  title: title,
                  color: color,
                ),
              ),

              if (canDodge)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55E76F51),
                          blurRadius: 18,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.keyboard_double_arrow_down_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'SQUAT NOW!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
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
  const _Student({required this.squatting});

  final bool squatting;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: squatting ? 84 : 72,
      height: squatting ? 75 : 116,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            top: squatting ? 18 : 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0C7A5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.face_rounded,
                color: AppColors.textSoft,
                size: 26,
              ),
            ),
          ),

          Positioned(
            bottom: squatting ? 5 : 18,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: squatting ? 78 : 52,
              height: squatting ? 39 : 65,
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(squatting ? 22 : 18),
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),

          if (!squatting) ...[
            Positioned(
              left: 18,
              bottom: 0,
              child: Container(
                width: 12,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.textSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 0,
              child: Container(
                width: 12,
                height: 30,
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
  const _Bookshelf({required this.progress});

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
        border: Border.all(color: const Color(0xFF9E6C48), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bookRow(progress >= 1),
          _bookRow(progress >= 3),
          _bookRow(progress >= 5),
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
            color: defeated ? AppColors.teal : AppColors.coral,
          ),
          const SizedBox(width: 4),
          Icon(
            defeated
                ? Icons.check_circle_rounded
                : Icons.sentiment_dissatisfied_rounded,
            size: 14,
            color: defeated ? AppColors.teal : AppColors.coral,
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
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 9,
            top: 7,
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
            child: Container(height: 3, color: Colors.white),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 40,
            child: Container(width: 3, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ExitDoor extends StatelessWidget {
  const _ExitDoor({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    final almostOpen = progress >= 4;

    final open = progress >= 5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 69,
      height: 117,
      decoration: BoxDecoration(
        color:
            open || almostOpen ? AppColors.greenLight : const Color(0xFFC89B72),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border.all(
          color: open || almostOpen ? AppColors.green : const Color(0xFFAA7B55),
          width: 3,
        ),
        boxShadow:
            almostOpen || open
                ? const [
                  BoxShadow(
                    color: Color(0x555FAF7B),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ]
                : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'EXIT',
            style: TextStyle(
              color: almostOpen || open ? AppColors.green : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          Icon(
            almostOpen || open ? Icons.lock_open_rounded : Icons.lock_rounded,
            color: almostOpen || open ? AppColors.green : Colors.white,
            size: 27,
          ),

          const SizedBox(height: 8),

          Text(
            '$progress/5',
            style: TextStyle(
              color: almostOpen || open ? AppColors.green : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
