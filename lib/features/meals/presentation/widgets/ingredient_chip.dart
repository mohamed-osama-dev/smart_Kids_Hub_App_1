import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';

class IngredientChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;
  final bool isMatched;

  const IngredientChip({
    super.key,
    required this.label,
    this.onRemove,
    this.isMatched = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMatched)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.check_circle, size: 14, color: AppColors.primary),
            ),
          Text(
            label,
            style: AppStyles.bold14Primary.copyWith(fontSize: 13),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 16, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
