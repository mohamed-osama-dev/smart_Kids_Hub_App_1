import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../domain/entities/entities.dart';
import '../models/meal_model.dart';
import '../models/ingredient_model.dart';
import '../models/nutrition_model.dart';
import 'meal_remote_datasource.dart';

class ApiMealRemoteDataSource implements MealRemoteDataSource {
  final _client = DioClient();

  @override
  Future<List<MealModel>> getAiSuggestions(
    List<String> ingredients,
    String childId, {
    List<String> allergies = const [],
  }) async {
    final id = int.tryParse(childId) ??
        await SecureStorageService.getChildId() ??
        0;

    final response = await _client.dio.post(
      ApiConstants.generateDietPlan,
      data: {
        'childId': id,
        'availableIngredients': ingredients,
        'allergies': allergies,
        'likedFoods': <String>[],
        'dislikedFoods': <String>[],
        'planType': 'daily',
        'language': 'ar',
      },
    );

    return _parseDietPlanResponse(response.data);
  }

  @override
  Future<List<MealModel>> getMealsByDate(String date, String childId) async {
    final id = int.tryParse(childId) ??
        await SecureStorageService.getChildId() ??
        0;

    final response = await _client.dio.get(
      '${ApiConstants.getDietPlan}/$id',
    );

    return _parseDietPlanResponse(response.data);
  }

  @override
  Future<void> toggleFavorite(String mealId) async {
    // Not supported by the backend yet — no-op
  }

  /// Parse the DietPlan API response into MealModel list
  List<MealModel> _parseDietPlanResponse(dynamic responseData) {
    final List<MealModel> meals = [];

    if (responseData is! Map<String, dynamic>) return meals;

    final data = responseData['data'];
    if (data is! Map<String, dynamic>) return meals;

    final days = data['days'] as List<dynamic>? ?? [];

    for (final day in days) {
      if (day is! Map<String, dynamic>) continue;
      final dayMeals = day['meals'] as List<dynamic>? ?? [];

      for (final meal in dayMeals) {
        if (meal is! Map<String, dynamic>) continue;

        // Parse ingredients
        final ingredientsList = meal['ingredients'] as List<dynamic>? ?? [];
        final ingredients = ingredientsList.map((ing) {
          if (ing is Map<String, dynamic>) {
            return IngredientModel(
              id: 'ing_${ing['name'].hashCode}',
              name: (ing['nameAr'] ?? ing['name'] ?? '').toString(),
            );
          }
          return IngredientModel(id: 'unknown', name: ing.toString());
        }).toList();

        // Parse meal slot to emoji
        final mealSlot = (meal['mealSlot'] ?? '').toString().toLowerCase();
        String emoji;
        switch (mealSlot) {
          case 'breakfast':
            emoji = '🍳';
            break;
          case 'lunch':
            emoji = '🍽️';
            break;
          case 'dinner':
            emoji = '🌙';
            break;
          case 'snack':
            emoji = '🍎';
            break;
          default:
            emoji = '🥗';
        }

        // Map meal slot to time label
        String timeLabel;
        switch (mealSlot) {
          case 'breakfast':
            timeLabel = '8:00 ص';
            break;
          case 'lunch':
            timeLabel = '1:00 م';
            break;
          case 'dinner':
            timeLabel = '7:00 م';
            break;
          case 'snack':
            timeLabel = '4:00 م';
            break;
          default:
            timeLabel = '';
        }

        meals.add(MealModel(
          id: 'meal_${meal['name'].hashCode}_${meals.length}',
          name: (meal['name'] ?? '').toString(),
          emoji: emoji,
          mealTime: _parseMealSlot(mealSlot),
          timeLabel: timeLabel,
          ingredients: ingredients,
          nutrition: NutritionModel(
            calories: (meal['calories'] as num?)?.toDouble() ?? 0,
            protein: (meal['proteinG'] as num?)?.toDouble() ?? 0,
            carbs: (meal['carbsG'] as num?)?.toDouble() ?? 0,
            fat: (meal['fatG'] as num?)?.toDouble() ?? 0,
          ),
        ));
      }
    }

    return meals;
  }

  static MealTime _parseMealSlot(String slot) {
    switch (slot) {
      case 'breakfast':
        return MealTime.breakfast;
      case 'lunch':
        return MealTime.lunch;
      case 'dinner':
        return MealTime.dinner;
      case 'snack':
        return MealTime.snack;
      default:
        return MealTime.breakfast;
    }
  }
}
