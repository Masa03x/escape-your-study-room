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
        final active = index < completed;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 11,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? AppColors.teal : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? AppColors.teal : AppColors.border,
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }
}
