import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';
import 'meal_remote_datasource.dart';

class MockMealRemoteDataSource implements MealRemoteDataSource {
  // Simulate network delay
  Future<void> _delay() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<List<MealModel>> getAiSuggestions(
    List<String> ingredients,
    String childId,
  ) async {
    await _delay();
    debugPrint('MockMealRemoteDataSource: getAiSuggestions for child $childId with ingredients: $ingredients');

    return [
      MealModel.mock(
        name: 'فول مدمس بالطحينة',
        emoji: '🫘',
        mealTimeKey: 'الفطار',
        timeLabel: '8:00 ص',
        ingredientNames: ['بيض', 'طماطم', 'فول'],
        calories: 320,
        protein: 15,
        carbs: 40,
      ),
      MealModel.mock(
        name: 'كشري مصري',
        emoji: '🍚',
        mealTimeKey: 'الغداء',
        timeLabel: '1:00 م',
        ingredientNames: ['أرز', 'عدس', 'مكرونة', 'طماطم', 'بصل'],
        calories: 485,
        protein: 18,
        carbs: 78,
      ),
      MealModel.mock(
        name: 'محشي ورق عنب',
        emoji: '🍃',
        mealTimeKey: 'العشاء',
        timeLabel: '7:00 م',
        ingredientNames: ['أرز', 'طماطم', 'ورق عنب', 'لحمة'],
        calories: 340,
        protein: 12,
        carbs: 45,
      ),
    ];
  }

  @override
  Future<List<MealModel>> getMealsByDate(String date, String childId) async {
    await _delay();
    debugPrint('MockMealRemoteDataSource: getMealsByDate for child $childId on $date');

    return [
      MealModel.mock(
        name: 'فول مدمس بالطحينة',
        emoji: '🫘',
        mealTimeKey: 'الفطار',
        timeLabel: '8:00 ص',
        ingredientNames: ['بيض', 'طماطم', 'فول'],
        calories: 320,
        protein: 15,
        carbs: 40,
      ),
      MealModel.mock(
        name: 'كشري مصري',
        emoji: '🍚',
        mealTimeKey: 'الغداء',
        timeLabel: '1:00 م',
        ingredientNames: ['أرز', 'عدس', 'مكرونة', 'طماطم', 'بصل'],
        calories: 485,
        protein: 18,
        carbs: 78,
      ),
      MealModel.mock(
        name: 'محشي ورق عنب',
        emoji: '🍃',
        mealTimeKey: 'العشاء',
        timeLabel: '7:00 م',
        ingredientNames: ['أرز', 'طماطم', 'ورق عنب', 'لحمة'],
        calories: 340,
        protein: 12,
        carbs: 45,
      ),
    ];
  }

  @override
  Future<void> toggleFavorite(String mealId) async {
    await _delay();
    debugPrint('MockMealRemoteDataSource: toggleFavorite for meal $mealId');
  }
}
