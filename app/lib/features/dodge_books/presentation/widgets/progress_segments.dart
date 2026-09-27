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
          child: Container(
            height: 10,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 7),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.green : AppColors.elevated,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: isCompleted ? AppColors.greenLight : AppColors.border,
              ),
            ),
          ),
        );
      }),
    );
  }
}
