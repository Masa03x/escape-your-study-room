import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class FlyingBook extends StatelessWidget {
  const FlyingBook({required this.canDodge, super.key});

  final bool canDodge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 88,
      decoration: BoxDecoration(
        color: canDodge ? AppColors.red : AppColors.cyan,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.text, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, color: AppColors.black, size: 34),
          const SizedBox(height: 6),
          Text(
            canDodge ? 'DODGE!' : 'BOOK',
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
