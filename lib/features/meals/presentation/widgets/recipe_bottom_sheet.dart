import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../domain/entities/entities.dart';

class RecipeBottomSheet extends StatelessWidget {
  final Meal meal;

  const RecipeBottomSheet({super.key, required this.meal});

  static void show(BuildContext context, Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecipeBottomSheet(meal: meal),
    );
  }

  String _getMealTimeLabel() {
    switch (meal.mealTime) {
      case MealTime.breakfast:
        return 'الفطار 🍳';
      case MealTime.lunch:
        return 'الغداء 🍚';
      case MealTime.dinner:
        return 'العشاء 🌙';
      case MealTime.snack:
        return 'وجبة خفيفة 🍎';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Meal emoji + name
              Center(
                child: Text(
                  meal.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  meal.name,
                  style: AppStyles.bold20Black,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getMealTimeLabel()} • ${meal.timeLabel}',
                    style: AppStyles.regular12Grey.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nutrition cards
              _buildSectionTitle('القيمة الغذائية', '📊'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildNutritionCard('سعرات', '${meal.nutrition.calories.toInt()}', 'kcal', Colors.orange),
                  const SizedBox(width: 8),
                  _buildNutritionCard('بروتين', '${meal.nutrition.protein.toInt()}', 'g', Colors.red),
                  const SizedBox(width: 8),
                  _buildNutritionCard('كربوهيدرات', '${meal.nutrition.carbs.toInt()}', 'g', Colors.blue),
                  const SizedBox(width: 8),
                  _buildNutritionCard('دهون', '${meal.nutrition.fat.toInt()}', 'g', Colors.amber),
                ],
              ),
              const SizedBox(height: 24),

              // Ingredients
              _buildSectionTitle('المكونات', '🧂'),
              const SizedBox(height: 12),
              ...meal.ingredients.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final ingredient = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLighter,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: AppStyles.bold12White.copyWith(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        ingredient.name,
                        style: AppStyles.regular14Grey.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: AppStyles.bold16Black),
      ],
    );
  }

  Widget _buildNutritionCard(String label, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppStyles.bold18Black.copyWith(
                color: color,
                fontSize: 18,
              ),
            ),
            Text(
              unit,
              style: AppStyles.regular12Grey.copyWith(fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppStyles.regular12Grey.copyWith(fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
