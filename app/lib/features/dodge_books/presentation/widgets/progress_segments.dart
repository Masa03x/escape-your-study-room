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
      children: List.generate(total, (index) {
        final isCompleted = index < completed;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 11,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.teal : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? AppColors.teal : AppColors.border,
                width: 2,
              ),
              boxShadow:
                  isCompleted
                      ? const [
                        BoxShadow(color: Color(0x332A9D8F), blurRadius: 8),
                      ]
                      : null,
            ),
          ),
        );
      }),
    );
  }
}
