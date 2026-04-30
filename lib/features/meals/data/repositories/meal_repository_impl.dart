import '../../domain/entities/entities.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/datasources.dart';

class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource remoteDataSource;

  MealRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<int, List<Meal>>> getAiSuggestions(
    List<String> ingredients,
    String childId, {
    List<String> allergies = const [],
  }) async {
    final weeklyMeals = await remoteDataSource.getAiSuggestions(ingredients, childId, allergies: allergies);
    return weeklyMeals;
  }

  @override
  Future<Map<int, List<Meal>>> getSavedWeeklyPlan(String childId) async {
    return await remoteDataSource.getSavedWeeklyPlan(childId);
  }

  @override
  Future<List<Meal>> getMealsByDate(String date, String childId) async {
    final mealModels = await remoteDataSource.getMealsByDate(date, childId);
    return mealModels;
  }

  @override
  Future<void> toggleFavorite(String mealId) async {
    await remoteDataSource.toggleFavorite(mealId);
  }
}
