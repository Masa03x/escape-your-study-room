import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ProgressSegments extends StatelessWidget {
  const ProgressSegments({
    required this.completed,
    required this.total,
    super.key,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isCompleted = index < completed;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 42,
          height: 42,
          margin: EdgeInsets.only(
            right: index == total - 1 ? 0 : 9,
          ),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.teal
                : AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted
                  ? AppColors.teal
                  : AppColors.border,
              width: 2,
            ),
            boxShadow: isCompleted
                ? const [
                    BoxShadow(
                      color: Color(0x332A9D8F),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: Icon(
            isCompleted
                ? Icons.check_rounded
                : Icons.menu_book_rounded,
            size: 20,
            color: isCompleted
                ? Colors.white
                : AppColors.textMuted,
          ),
        );
      }),
    );
  }
}