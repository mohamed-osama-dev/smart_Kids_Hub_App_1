import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../domain/entities/entities.dart';
import 'ingredient_chip.dart';
import 'recipe_bottom_sheet.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onCheck;
  final VoidCallback? onViewRecipe;

  const MealCard({
    super.key,
    required this.meal,
    this.onCheck,
    this.onViewRecipe,
  });

  String _getMealTimeEmoji() {
    switch (meal.mealTime) {
      case MealTime.breakfast:
        return '🍳';
      case MealTime.lunch:
        return '🍚';
      case MealTime.dinner:
        return '🍽️';
      case MealTime.snack:
        return '🥗';
    }
  }

  String _getMealTimeLabel() {
    switch (meal.mealTime) {
      case MealTime.breakfast:
        return 'الفطار';
      case MealTime.lunch:
        return 'الغداء';
      case MealTime.dinner:
        return 'العشاء';
      case MealTime.snack:
        return 'وجبة خفيفة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                    ? Image.network(
                        meal.imageUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              // Meal time badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getMealTimeLabel(),
                        style: AppStyles.bold12White.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        meal.timeLabel,
                        style: AppStyles.bold12White.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal name
                Text(
                  meal.name,
                  style: AppStyles.bold18Black,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                // Ingredient chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.start,
                  children: meal.ingredients.map((ingredient) {
                    final isMatched = _isIngredientMatched(ingredient.name);
                    return IngredientChip(
                      label: ingredient.name,
                      isMatched: isMatched,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // Nutrition row
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.local_fire_department, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${meal.nutrition.calories.toInt()} سعر',
                      style: AppStyles.regular12Grey.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${meal.nutrition.protein.toInt()}g بروتين',
                      style: AppStyles.regular12Grey.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${meal.nutrition.carbs.toInt()}g كربوهيدرات',
                      style: AppStyles.regular12Grey.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View recipe button
                    TextButton(
                      onPressed: onViewRecipe ?? () => RecipeBottomSheet.show(context, meal),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'عرض الوصفة',
                            style: AppStyles.semi14Primary,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    // Check button
                    IconButton(
                      onPressed: onCheck,
                      icon: Icon(
                        meal.isChecked ? Icons.check_circle : Icons.check_circle_outline,
                        color: meal.isChecked ? AppColors.success : AppColors.textSecondary,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 160,
      width: double.infinity,
      color: AppColors.primaryLighter,
      child: Center(
        child: Text(
          _getMealTimeEmoji(),
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }

  bool _isIngredientMatched(String ingredientName) {
    // This would compare with the user's available ingredients
    // For now, we'll mark some as matched for visual demonstration
    final matchedIngredients = ['بيض', 'طماطم', 'فول', 'أرز', 'طماطم'];
    return matchedIngredients.contains(ingredientName);
  }
}
