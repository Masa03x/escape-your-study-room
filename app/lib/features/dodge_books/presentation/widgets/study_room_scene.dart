import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dodge_books_game.dart';
import 'flying_book.dart';
import 'game_character.dart';

class ChallengeScene extends StatelessWidget {
  const ChallengeScene({
    required this.type,
    required this.obstacleProgress,
    required this.canAct,
    required this.actionActive,
    required this.completed,
    required this.roundNumber,
    super.key,
  });

  final ChallengeType type;

  final double obstacleProgress;

  final bool canAct;
  final bool actionActive;

  final int completed;
  final int roundNumber;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final progress = obstacleProgress.clamp(0.0, 1.0);

          final obstacleLeft = width * (0.93 - (progress * 0.80));

          return Stack(
            fit: StackFit.expand,
            children: [
              const _RoomBackground(),

              Positioned(left: 17, top: 17, child: _MissionLabel(type: type)),

              const Positioned(right: 18, top: 20, child: _Window()),

              const Positioned(left: 17, bottom: 58, child: _Desk()),

              Positioned(
                right: 18,
                bottom: 41,
                child: _ExitDoor(completed: completed),
              ),

              Positioned(
                left: 24,
                bottom: 35,
                child: GameCharacter(
                  type: type,
                  actionActive: actionActive,
                  sideDirection: roundNumber,
                ),
              ),

              if (type == ChallengeType.jumpCables)
                Positioned(
                  left: obstacleLeft,
                  bottom: 43,
                  child: GameObstacle(
                    type: type,
                    isDangerous: canAct,
                    index: roundNumber,
                  ),
                )
              else
                Positioned(
                  left: obstacleLeft,
                  top:
                      type == ChallengeType.flyingBooks
                          ? height * 0.28 - gameObstacleVerticalOffset(progress)
                          : height * 0.33,
                  child: GameObstacle(
                    type: type,
                    isDangerous: canAct,
                    index: roundNumber,
                  ),
                ),

              if (canAct)
                Positioned(
                  left: 15,
                  right: 15,
                  bottom: 11,
                  child: _ActionBanner(type: type),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RoomBackground extends StatelessWidget {
  const _RoomBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFFFFF1D8)),

        Positioned(
          left: -60,
          top: -65,
          child: Container(
            width: 190,
            height: 190,
            decoration: const BoxDecoration(
              color: Color(0x22F4C95D),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          right: -65,
          top: 95,
          child: Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0x202A9D8F),
              shape: BoxShape.circle,
            ),
          ),
        ),

        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 90,
          child: ColoredBox(color: Color(0xFFE0BE91)),
        ),

        Positioned(
          left: 55,
          right: 55,
          bottom: 17,
          child: Container(
            height: 31,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),

        const Positioned(
          left: 125,
          top: 35,
          child: _StickyNote(text: 'FOCUS!', angle: -0.08),
        ),

        const Positioned(
          right: 118,
          top: 94,
          child: _StickyNote(text: 'YOU GOT\nTHIS', angle: 0.09),
        ),

        const Positioned(
          left: 110,
          top: 118,
          child: Icon(Icons.star_rounded, color: AppColors.yellow, size: 16),
        ),
      ],
    );
  }
}

class _StickyNote extends StatelessWidget {
  const _StickyNote({required this.text, required this.angle});

  final String text;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 50,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.yellowSoft,
          borderRadius: BorderRadius.circular(3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 7,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MissionLabel extends StatelessWidget {
  const _MissionLabel({required this.type});

  final ChallengeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.videogame_asset_rounded,
            size: 14,
            color: AppColors.teal,
          ),
          const SizedBox(width: 5),
          Text(
            type.shortTitle.toUpperCase(),
            style: const TextStyle(
              color: AppColors.tealDark,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
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
      width: 83,
      height: 69,
      decoration: BoxDecoration(
        color: const Color(0xFFBDE5F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Color(0x16A3D8E8), blurRadius: 10)],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 8,
            top: 6,
            child: Icon(
              Icons.wb_sunny_rounded,
              color: AppColors.yellow,
              size: 22,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 30,
            child: Container(height: 3, color: Colors.white),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 38,
            child: Container(width: 3, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Desk extends StatelessWidget {
  const _Desk();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 90,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 35,
            child: Container(
              height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFFA56E43),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            left: 9,
            top: 46,
            child: Container(
              width: 8,
              height: 43,
              color: const Color(0xFF8C5C38),
            ),
          ),
          Positioned(
            right: 9,
            top: 46,
            child: Container(
              width: 8,
              height: 43,
              color: const Color(0xFF8C5C38),
            ),
          ),
          Positioned(
            left: 24,
            top: 2,
            child: Container(
              width: 59,
              height: 37,
              decoration: BoxDecoration(
                color: AppColors.textSoft,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Text(
                  '</study>',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            right: 3,
            top: 10,
            child: Icon(Icons.coffee_rounded, color: AppColors.coral, size: 27),
          ),
        ],
      ),
    );
  }
}

class _ExitDoor extends StatelessWidget {
  const _ExitDoor({required this.completed});

  final int completed;

  @override
  Widget build(BuildContext context) {
    final close = completed >= 4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 67,
      height: 116,
      decoration: BoxDecoration(
        color: close ? AppColors.greenLight : const Color(0xFFC89B72),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border.all(
          color: close ? AppColors.green : const Color(0xFFAA7B55),
          width: 3,
        ),
        boxShadow:
            close
                ? const [
                  BoxShadow(
                    color: Color(0x445FAF7B),
                    blurRadius: 20,
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
              color: close ? AppColors.green : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 11),
          Icon(
            close ? Icons.lock_open_rounded : Icons.lock_rounded,
            color: close ? AppColors.green : Colors.white,
            size: 25,
          ),
          const SizedBox(height: 7),
          Text(
            '$completed/5',
            style: TextStyle(
              color: close ? AppColors.green : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  const _ActionBanner({required this.type});

  final ChallengeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55E76F51),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            switch (type) {
              ChallengeType.flyingBooks =>
                Icons.keyboard_double_arrow_down_rounded,
              ChallengeType.jumpCables =>
                Icons.keyboard_double_arrow_up_rounded,
              ChallengeType.distractions => Icons.swap_horiz_rounded,
            },
            color: Colors.white,
            size: 25,
          ),
          const SizedBox(width: 7),
          Text(
            type.actionMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
