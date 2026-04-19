import '../models/meal_model.dart';

abstract class MealRemoteDataSource {
  Future<List<MealModel>> getAiSuggestions(List<String> ingredients, String childId);
  Future<List<MealModel>> getMealsByDate(String date, String childId);
  Future<void> toggleFavorite(String mealId);
}
