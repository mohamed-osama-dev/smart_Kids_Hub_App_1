import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back arrow
          const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 16),
          // Progress bar
          Expanded(
            child: Row(
              children: List.generate(
                totalSteps,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index < currentStep
                          ? AppColors.primary
                          : AppColors.textHint.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
