import '../../domain/entities/nutrition.dart';

class NutritionModel extends Nutrition {
  const NutritionModel({
    required super.calories,
    required super.protein,
    required super.carbs,
    super.fat,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory NutritionModel.mock({
    double calories = 350,
    double protein = 15,
    double carbs = 50,
    double fat = 10,
  }) {
    return NutritionModel(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }
}
