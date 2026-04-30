import '../models/meal_model.dart';

abstract class MealRemoteDataSource {
  Future<Map<int, List<MealModel>>> getAiSuggestions(List<String> ingredients, String childId, {List<String> allergies = const []});
  Future<Map<int, List<MealModel>>> getSavedWeeklyPlan(String childId);
  Future<List<MealModel>> getMealsByDate(String date, String childId);
  Future<void> toggleFavorite(String mealId);
}
