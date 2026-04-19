import 'package:flutter/material.dart';
import '../../domain/models/child.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';

class GenderSelector extends StatelessWidget {
  final Gender selectedGender;
  final ValueChanged<Gender> onGenderChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Male option
        Expanded(
          child: _GenderButton(
            label: 'ذكر',
            icon: Icons.male,
            isSelected: selectedGender == Gender.male,
            onTap: () => onGenderChanged(Gender.male),
          ),
        ),
        const SizedBox(width: 12),
        // Female option
        Expanded(
          child: _GenderButton(
            label: 'أنثى',
            icon: Icons.female,
            isSelected: selectedGender == Gender.female,
            onTap: () => onGenderChanged(Gender.female),
          ),
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.whiteColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: isSelected
                  ? AppStyles.bold16White
                  : AppStyles.bold16Grey,
            ),
          ],
        ),
      ),
    );
  }
}
