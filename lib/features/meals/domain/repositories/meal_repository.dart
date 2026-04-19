import '../entities/entities.dart';

abstract class MealRepository {
  Future<List<Meal>> getAiSuggestions(List<String> ingredients, String childId);
  Future<List<Meal>> getMealsByDate(String date, String childId);
  Future<void> toggleFavorite(String mealId);
}
