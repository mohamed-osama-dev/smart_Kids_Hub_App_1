import '../../domain/entities/entities.dart';
import '../../domain/repositories/meal_repository.dart';

class GetAiMealSuggestions {
  final MealRepository repository;

  GetAiMealSuggestions(this.repository);

  Future<Map<int, List<Meal>>> call(List<String> ingredients, String childId, {List<String> allergies = const []}) async {
    return repository.getAiSuggestions(ingredients, childId, allergies: allergies);
  }
}
