import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';

class HealthConditionCheckbox extends StatelessWidget {
  final String label;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final bool isFirst;

  const HealthConditionCheckbox({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onChanged,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isFirst && isChecked
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isFirst && isChecked
                ? AppColors.primary
                : AppColors.borderColor,
            width: isFirst ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppStyles.regular14Black,
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : AppColors.whiteColor,
                border: Border.all(
                  color: isChecked
                      ? AppColors.primary
                      : AppColors.textHint,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.whiteColor,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
