import '../entities/entities.dart';
import '../repositories/meal_repository.dart';

class GetSavedWeeklyPlan {
  final MealRepository repository;

  GetSavedWeeklyPlan(this.repository);

  Future<Map<int, List<Meal>>> call(String childId) {
    return repository.getSavedWeeklyPlan(childId);
  }
}
