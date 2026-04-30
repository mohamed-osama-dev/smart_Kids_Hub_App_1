import 'package:dio/dio.dart';
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
  Future<Map<int, List<MealModel>>> getAiSuggestions(
    List<String> ingredients,
    String childId, {
    List<String> allergies = const [],
  }) async {
    final id = int.tryParse(childId) ??
        await SecureStorageService.getChildId() ??
        0;

    try {
      print('🍽️ Requesting weekly diet plan for childId=$id ...');
      final response = await _client.dio.post(
        ApiConstants.generateDietPlan,
        data: {
          'childId': id,
          'availableIngredients': ingredients,
          'allergies': allergies,
          'likedFoods': <String>[],
          'dislikedFoods': <String>[],
          'planType': 'weekly',
          'language': 'ar',
        },
        options: Options(
          // AI generation for 7 days can take a while
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      print('✅ Weekly diet plan response received');
      print('📦 Response type: ${response.data.runtimeType}');
      print('📦 Response data: ${response.data}');

      return _parseWeeklyDietPlanResponse(response.data);
    } on DioException catch (e) {
      print('❌ DioException in getAiSuggestions:');
      print('   Type: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      print('   Message: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<Map<int, List<MealModel>>> getSavedWeeklyPlan(String childId) async {
    final id = int.tryParse(childId) ??
        await SecureStorageService.getChildId() ??
        0;

    final response = await _client.dio.get(
      '${ApiConstants.getDietPlan}/$id',
    );

    return _parseWeeklyDietPlanResponse(response.data);
  }

  @override
  Future<List<MealModel>> getMealsByDate(String date, String childId) async {
    final id = int.tryParse(childId) ??
        await SecureStorageService.getChildId() ??
        0;

    final response = await _client.dio.get(
      '${ApiConstants.getDietPlan}/$id',
    );

    return _parseDayMeals(response.data);
  }

  @override
  Future<void> toggleFavorite(String mealId) async {
    // Not supported by the backend yet — no-op
  }

  /// Parse a weekly DietPlan API response into a Map of day index → meals
  Map<int, List<MealModel>> _parseWeeklyDietPlanResponse(dynamic responseData) {
    final Map<int, List<MealModel>> weeklyMeals = {};

    // Initialize all 7 days with empty lists
    for (int i = 0; i < 7; i++) {
      weeklyMeals[i] = [];
    }

    if (responseData is! Map<String, dynamic>) return weeklyMeals;

    final data = responseData['data'];
    if (data is! Map<String, dynamic>) return weeklyMeals;

    final days = data['days'] as List<dynamic>? ?? [];

    for (int dayIndex = 0; dayIndex < days.length && dayIndex < 7; dayIndex++) {
      final day = days[dayIndex];
      if (day is! Map<String, dynamic>) continue;

      // Use dayIndex from response if available, otherwise use iteration index
      final actualIndex = day['dayIndex'] as int? ?? dayIndex;
      final clampedIndex = actualIndex.clamp(0, 6);

      final dayMeals = day['meals'] as List<dynamic>? ?? [];
      final parsedMeals = <MealModel>[];

      for (final meal in dayMeals) {
        if (meal is! Map<String, dynamic>) continue;
        parsedMeals.add(_parseSingleMeal(meal, parsedMeals.length));
      }

      weeklyMeals[clampedIndex] = parsedMeals;
    }

    return weeklyMeals;
  }

  /// Parse a single day response (for getMealsByDate)
  List<MealModel> _parseDayMeals(dynamic responseData) {
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
        meals.add(_parseSingleMeal(meal, meals.length));
      }
    }

    return meals;
  }

  /// Parse a single meal JSON object into a MealModel
  MealModel _parseSingleMeal(Map<String, dynamic> meal, int index) {
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

    return MealModel(
      id: 'meal_${meal['name'].hashCode}_$index',
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
    );
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

