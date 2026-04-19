import '../../domain/entities/entities.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/datasources.dart';

class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource remoteDataSource;

  MealRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Meal>> getAiSuggestions(
    List<String> ingredients,
    String childId,
  ) async {
    final mealModels = await remoteDataSource.getAiSuggestions(ingredients, childId);
    return mealModels;
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
