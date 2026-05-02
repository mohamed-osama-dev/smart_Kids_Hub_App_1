import '../../domain/repositories/meal_repository.dart';

class ToggleFavoriteMeal {
  final MealRepository repository;

  ToggleFavoriteMeal(this.repository);

  Future<void> call(String mealId) {
    return repository.toggleFavorite(mealId);
  }
}
