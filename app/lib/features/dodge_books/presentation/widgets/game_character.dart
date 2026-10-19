import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/dodge_books_game.dart';

class GameCharacter extends StatelessWidget {
  const GameCharacter({
    required this.type,
    required this.actionActive,
    this.scale = 1,
    this.sideDirection = 1,
    super.key,
  });

  final ChallengeType type;
  final bool actionActive;
  final double scale;
  final int sideDirection;

  @override
  Widget build(BuildContext context) {
    double x = 0;
    double y = 0;

    if (actionActive) {
      switch (type) {
        case ChallengeType.flyingBooks:
          y = 20;
          break;

        case ChallengeType.jumpCables:
          y = -38;
          break;

        case ChallengeType.distractions:
          x = sideDirection.isEven ? -28 : 28;
          break;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(x, y, 0),
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 88,
          height: actionActive && type == ChallengeType.flyingBooks ? 88 : 118,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Shadow
              Positioned(
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width:
                      actionActive && type == ChallengeType.jumpCables
                          ? 40
                          : 65,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // Legs
              if (!(actionActive && type == ChallengeType.flyingBooks)) ...[
                Positioned(
                  bottom: 7,
                  left: 27,
                  child: Transform.rotate(
                    angle:
                        actionActive && type == ChallengeType.distractions
                            ? -0.18
                            : 0,
                    child: _leg(),
                  ),
                ),
                Positioned(
                  bottom: 7,
                  right: 27,
                  child: Transform.rotate(
                    angle:
                        actionActive && type == ChallengeType.distractions
                            ? 0.18
                            : 0,
                    child: _leg(),
                  ),
                ),
              ],

              // Body
              Positioned(
                bottom:
                    actionActive && type == ChallengeType.flyingBooks ? 8 : 26,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width:
                      actionActive && type == ChallengeType.flyingBooks
                          ? 74
                          : 52,
                  height:
                      actionActive && type == ChallengeType.flyingBooks
                          ? 38
                          : 60,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(
                      actionActive && type == ChallengeType.flyingBooks
                          ? 22
                          : 19,
                    ),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x332A9D8F),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),

              // Arms
              Positioned(
                bottom:
                    actionActive && type == ChallengeType.flyingBooks ? 19 : 48,
                left: 10,
                child: Transform.rotate(
                  angle:
                      actionActive && type == ChallengeType.jumpCables
                          ? -1.0
                          : -0.3,
                  child: _arm(),
                ),
              ),
              Positioned(
                bottom:
                    actionActive && type == ChallengeType.flyingBooks ? 19 : 48,
                right: 10,
                child: Transform.rotate(
                  angle:
                      actionActive && type == ChallengeType.jumpCables
                          ? 1.0
                          : 0.3,
                  child: _arm(),
                ),
              ),

              // Head
              Positioned(
                top: actionActive && type == ChallengeType.flyingBooks ? 14 : 0,
                child: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0C7A5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Positioned(top: 14, left: 10, child: _Eye()),
                      const Positioned(top: 14, right: 10, child: _Eye()),
                      Positioned(
                        bottom: 9,
                        left: 14,
                        child: Container(
                          width: 13,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.textSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hair
              Positioned(
                top: actionActive && type == ChallengeType.flyingBooks ? 9 : -4,
                child: Container(
                  width: 43,
                  height: 19,
                  decoration: const BoxDecoration(
                    color: Color(0xFF49382E),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                      bottom: Radius.circular(9),
                    ),
                  ),
                ),
              ),

              // Backpack detail
              Positioned(
                bottom:
                    actionActive && type == ChallengeType.flyingBooks ? 18 : 45,
                right: 13,
                child: Container(
                  width: 13,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _arm() {
    return Container(
      width: 11,
      height: 39,
      decoration: BoxDecoration(
        color: const Color(0xFFF0C7A5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  Widget _leg() {
    return Container(
      width: 13,
      height: 33,
      decoration: BoxDecoration(
        color: AppColors.textSoft,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 7,
      decoration: const BoxDecoration(
        color: AppColors.text,
        shape: BoxShape.circle,
      ),
    );
  }
}
