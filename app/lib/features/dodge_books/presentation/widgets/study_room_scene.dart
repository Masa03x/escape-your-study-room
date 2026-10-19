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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bookPosition = width * (0.82 - (bookProgress * 0.65));

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 14,
                top: 14,
                child: Text(
                  'DODGE AREA',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              Positioned(
                right: 18,
                bottom: 28,
                child: _ExitDoor(dodgedBooks: dodgedBooks),
              ),

              Positioned(
                left: 24,
                bottom: squatting ? 30 : 46,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: squatting ? 72 : 60,
                  height: squatting ? 45 : 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    borderRadius: BorderRadius.circular(squatting ? 10 : 30),
                  ),
                  child: Text(
                    squatting ? 'SQUAT' : 'YOU',
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: bookPosition,
                top: constraints.maxHeight * 0.30,
                child: FlyingBook(canDodge: canDodge),
              ),

              if (canDodge)
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'SQUAT NOW',
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
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
}

class _ExitDoor extends StatelessWidget {
  const _ExitDoor({required this.dodgedBooks});

  final int dodgedBooks;

  @override
  Widget build(BuildContext context) {
    final almostFinished = dodgedBooks >= 4;

    return Container(
      width: 58,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: almostFinished ? AppColors.lime : AppColors.border,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            almostFinished
                ? Icons.lock_open_rounded
                : Icons.lock_outline_rounded,
            color: almostFinished ? AppColors.lime : AppColors.textMuted,
          ),
          const SizedBox(height: 8),
          Text(
            'EXIT',
            style: TextStyle(
              color: almostFinished ? AppColors.lime : AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dodgedBooks/5',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
