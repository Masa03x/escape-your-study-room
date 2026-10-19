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
        final completedSegment = index < completed;

        return Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 5),
            decoration: BoxDecoration(
              color: completedSegment ? AppColors.lime : AppColors.card,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: completedSegment ? AppColors.lime : AppColors.border,
              ),
            ),
          ),
        );
      }),
    );
  }
}
