import '../entities/entities.dart';

abstract class MealRepository {
  Future<Map<int, List<Meal>>> getAiSuggestions(List<String> ingredients, String childId, {List<String> allergies = const []});
  Future<Map<int, List<Meal>>> getSavedWeeklyPlan(String childId);
  Future<List<Meal>> getMealsByDate(String date, String childId);
  Future<void> toggleFavorite(String mealId);
}
