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
            duration: const Duration(milliseconds: 400),
            height: 8,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient:
                  active
                      ? const LinearGradient(
                        colors: [AppColors.green, AppColors.greenLight],
                      )
                      : null,
              color: active ? null : Colors.white.withValues(alpha: 0.10),
              boxShadow:
                  active
                      ? [
                        BoxShadow(
                          color: AppColors.green.withValues(alpha: 0.55),
                          blurRadius: 10,
                        ),
                      ]
                      : null,
            ),
          ),
        );
      }),
    );
  }
}
