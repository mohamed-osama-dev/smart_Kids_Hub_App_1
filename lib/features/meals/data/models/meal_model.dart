import '../../domain/entities/entities.dart';
import 'ingredient_model.dart';
import 'nutrition_model.dart';

class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.name,
    required super.emoji,
    required super.mealTime,
    required super.timeLabel,
    super.imageUrl,
    required super.ingredients,
    required super.nutrition,
    super.isFavorite,
    super.isChecked,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ingredientsJson = json['ingredients'] as List<dynamic>? ?? [];
    final List<Ingredient> ingredients = ingredientsJson
        .map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '',
      mealTime: _parseMealTime(json['mealTime'] as String?),
      timeLabel: json['timeLabel'] as String,
      imageUrl: json['imageUrl'] as String?,
      ingredients: ingredients,
      nutrition: NutritionModel.fromJson(
        json['nutrition'] as Map<String, dynamic>,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isChecked: json['isChecked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'mealTime': mealTime.name,
      'timeLabel': timeLabel,
      'imageUrl': imageUrl,
      'ingredients': (ingredients as List<IngredientModel>).map((i) => i.toJson()).toList(),
      'nutrition': (nutrition as NutritionModel).toJson(),
      'isFavorite': isFavorite,
      'isChecked': isChecked,
    };
  }

  factory MealModel.mock({
    required String name,
    required String emoji,
    required String mealTimeKey,
    required String timeLabel,
    required List<String> ingredientNames,
    required double calories,
    required double protein,
    required double carbs,
    String? imageUrl,
    bool isFavorite = false,
    bool isChecked = false,
  }) {
    final ingredients = ingredientNames
        .map((n) => IngredientModel.mock(n))
        .toList();

    return MealModel(
      id: 'meal_${name.hashCode}',
      name: name,
      emoji: emoji,
      mealTime: _parseMealTime(mealTimeKey),
      timeLabel: timeLabel,
      imageUrl: imageUrl,
      ingredients: ingredients,
      nutrition: NutritionModel.mock(
        calories: calories,
        protein: protein,
        carbs: carbs,
      ),
      isFavorite: isFavorite,
      isChecked: isChecked,
    );
  }

  static MealTime _parseMealTime(String? key) {
    switch (key) {
      case 'الفطار':
      case 'breakfast':
        return MealTime.breakfast;
      case 'الغداء':
      case 'lunch':
        return MealTime.lunch;
      case 'العشاء':
      case 'dinner':
        return MealTime.dinner;
      case 'وجبة خفيفة':
      case 'snack':
        return MealTime.snack;
      default:
        return MealTime.breakfast;
    }
  }
}
