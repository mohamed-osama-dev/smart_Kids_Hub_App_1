import '../../domain/entities/entities.dart';
import '../../domain/repositories/meal_repository.dart';

class GetAiMealSuggestions {
  final MealRepository repository;

  GetAiMealSuggestions(this.repository);

  Future<List<Meal>> call(List<String> ingredients, String childId) async {
    return repository.getAiSuggestions(ingredients, childId);
  }
}
