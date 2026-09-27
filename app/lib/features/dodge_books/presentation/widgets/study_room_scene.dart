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
      borderRadius: BorderRadius.circular(26),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final bookLeft = width * (0.92 - (bookProgress * 0.72));
          final bookTop =
              height * 0.30 - flyingBookVerticalOffset(bookProgress);

          return Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF181443),
                      Color(0xFF0D0B2A),
                      Color(0xFF08071E),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 26,
                child: _Shelf(progress: dodgedBooks),
              ),
              const Positioned(
                right: 24,
                top: 24,
                child: _Window(),
              ),
              Positioned(
                right: 18,
                bottom: 30,
                child: _ExitDoor(active: dodgedBooks >= 4),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF17142F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned(
                left: (width / 2) - 34,
                bottom: squatting ? 42 : 46,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 68,
                  height: squatting ? 62 : 98,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.purpleLight,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x667C3AED),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Icon(
                    squatting
                        ? Icons.airline_seat_legroom_reduced_rounded
                        : Icons.person_rounded,
                    size: squatting ? 46 : 64,
                    color: AppColors.text,
                  ),
                ),
              ),
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
                  top: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x55F59E0B),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Text(
                        'SQUAT NOW!',
                        style: TextStyle(
                          color: Color(0xFF211705),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
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

class _Shelf extends StatelessWidget {
  const _Shelf({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 116,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF201B45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(defeated ? '📘' : '📕', style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 4),
        Text(defeated ? '😵' : '😠', style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _Window extends StatelessWidget {
  const _Window();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFF171D46),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purpleLight, width: 2),
      ),
      child: const Center(
        child: Text(
          '✦  ☾  ✦',
          style: TextStyle(color: AppColors.textSoft),
        ),
      ),
    );
  }
}

class _ExitDoor extends StatelessWidget {
  const _ExitDoor({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 74,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF201C3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppColors.green : AppColors.border,
          width: 3,
        ),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x7722C55E),
                  blurRadius: 24,
                  spreadRadius: 3,
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
              color: active ? AppColors.greenLight : AppColors.textMuted,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Icon(
            Icons.door_front_door_rounded,
            color: active ? AppColors.greenLight : AppColors.textMuted,
            size: 36,
          ),
        ],
      ),
    );
  }
}
