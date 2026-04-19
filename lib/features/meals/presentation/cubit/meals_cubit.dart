import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

enum MealsStatus { initial, loading, loaded, error }

class MealsState {
  final MealsStatus status;
  final List<Meal> meals;
  final List<String> ingredients;
  final String? errorMessage;
  final int selectedDayIndex;

  const MealsState({
    this.status = MealsStatus.initial,
    this.meals = const [],
    this.ingredients = const ['دجاج', 'أرز', 'طماطم', 'بيض'],
    this.errorMessage,
    this.selectedDayIndex = 0,
  });

  MealsState copyWith({
    MealsStatus? status,
    List<Meal>? meals,
    List<String>? ingredients,
    String? errorMessage,
    int? selectedDayIndex,
  }) {
    return MealsState(
      status: status ?? this.status,
      meals: meals ?? this.meals,
      ingredients: ingredients ?? this.ingredients,
      errorMessage: errorMessage,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
    );
  }
}

class MealsCubit extends ChangeNotifier {
  final GetAiMealSuggestions _getAiMealSuggestions;
  final GetMealsByDate _getMealsByDate;
  final ToggleFavoriteMeal _toggleFavoriteMeal;

  MealsState _state = const MealsState();
  MealsState get state => _state;

  MealsCubit({
    required GetAiMealSuggestions getAiMealSuggestions,
    required GetMealsByDate getMealsByDate,
    required ToggleFavoriteMeal toggleFavoriteMeal,
  })  : _getAiMealSuggestions = getAiMealSuggestions,
        _getMealsByDate = getMealsByDate,
        _toggleFavoriteMeal = toggleFavoriteMeal;

  Future<void> getAiSuggestions() async {
    _state = _state.copyWith(status: MealsStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      // Using a default childId for now — will be replaced with real auth data later
      const childId = 'child_001';
      final meals = await _getAiMealSuggestions(_state.ingredients, childId);
      _state = _state.copyWith(status: MealsStatus.loaded, meals: meals);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        status: MealsStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> getMealsByDate(String date) async {
    _state = _state.copyWith(status: MealsStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      const childId = 'child_001';
      final meals = await _getMealsByDate(date, childId);
      _state = _state.copyWith(status: MealsStatus.loaded, meals: meals);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        status: MealsStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  void addIngredient(String ingredient) {
    if (ingredient.trim().isEmpty) return;
    final updated = [..._state.ingredients, ingredient.trim()];
    _state = _state.copyWith(ingredients: updated);
    notifyListeners();
  }

  void removeIngredient(String ingredient) {
    final updated = _state.ingredients.where((i) => i != ingredient).toList();
    _state = _state.copyWith(ingredients: updated);
    notifyListeners();
  }

  void selectDay(int index) {
    _state = _state.copyWith(selectedDayIndex: index);
    notifyListeners();
  }

  Future<void> toggleFavorite(String mealId) async {
    await _toggleFavoriteMeal(mealId);
    // Optimistically toggle
    final updatedMeals = _state.meals.map((meal) {
      if (meal.id == mealId) {
        return Meal(
          id: meal.id,
          name: meal.name,
          emoji: meal.emoji,
          mealTime: meal.mealTime,
          timeLabel: meal.timeLabel,
          imageUrl: meal.imageUrl,
          ingredients: meal.ingredients,
          nutrition: meal.nutrition,
          isFavorite: !meal.isFavorite,
          isChecked: meal.isChecked,
        );
      }
      return meal;
    }).toList();
    _state = _state.copyWith(meals: updatedMeals);
    notifyListeners();
  }

  void reset() {
    _state = const MealsState();
    notifyListeners();
  }
}
