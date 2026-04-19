import '../../domain/entities/entities.dart';
import '../../domain/repositories/meal_repository.dart';

class GetMealsByDate {
  final MealRepository repository;

  GetMealsByDate(this.repository);

  Future<List<Meal>> call(String date, String childId) async {
    return repository.getMealsByDate(date, childId);
  }
}
