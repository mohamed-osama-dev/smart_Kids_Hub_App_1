import 'ingredient.dart';
import 'nutrition.dart';

enum MealTime { breakfast, lunch, dinner, snack }

class Meal {
  final String id;
  final String name;
  final String emoji;
  final MealTime mealTime;
  final String timeLabel;
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final Nutrition nutrition;
  final bool isFavorite;
  final bool isChecked;

  const Meal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.mealTime,
    required this.timeLabel,
    this.imageUrl,
    required this.ingredients,
    required this.nutrition,
    this.isFavorite = false,
    this.isChecked = false,
  });
}
