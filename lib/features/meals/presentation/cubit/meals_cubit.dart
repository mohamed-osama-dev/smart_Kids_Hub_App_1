import 'package:flutter/foundation.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

enum MealsStatus { initial, loading, loaded, error }

class MealsState {
  final MealsStatus status;
  final List<Meal> meals;
  final List<String> ingredients;
  final List<String> allergies;
  final String? errorMessage;
  final int selectedDayIndex;

  const MealsState({
    this.status = MealsStatus.initial,
    this.meals = const [],
    this.ingredients = const ['دجاج', 'أرز', 'طماطم', 'بيض'],
    this.allergies = const [],
    this.errorMessage,
    this.selectedDayIndex = 0,
  });

  MealsState copyWith({
    MealsStatus? status,
    List<Meal>? meals,
    List<String>? ingredients,
    List<String>? allergies,
    String? errorMessage,
    int? selectedDayIndex,
  }) {
    return MealsState(
      status: status ?? this.status,
      meals: meals ?? this.meals,
      ingredients: ingredients ?? this.ingredients,
      allergies: allergies ?? this.allergies,
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
      final childId = await SecureStorageService.getChildId();
      if (childId == null) {
        throw Exception('بيانات الطفل غير متوفرة. يرجى تسجيل الدخول أولاً.');
      }
      final meals = await _getAiMealSuggestions(
        _state.ingredients,
        childId.toString(),
        allergies: _state.allergies,
      );
      _state = _state.copyWith(status: MealsStatus.loaded, meals: meals);
      notifyListeners();
    } catch (e) {
      print('❌ AI Suggestions error: $e');
      _state = _state.copyWith(
        status: MealsStatus.error,
        errorMessage: 'حدث خطأ أثناء تحميل الاقتراحات. تحقق من الاتصال بالإنترنت.',
      );
      notifyListeners();
    }
  }

  Future<void> getMealsByDate(String date) async {
    _state = _state.copyWith(status: MealsStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final childId = await SecureStorageService.getChildId();
      if (childId == null) {
        throw Exception('بيانات الطفل غير متوفرة.');
      }
      final meals = await _getMealsByDate(date, childId.toString());
      _state = _state.copyWith(status: MealsStatus.loaded, meals: meals);
      notifyListeners();
    } catch (e) {
      print('❌ getMealsByDate error: $e');
      _state = _state.copyWith(
        status: MealsStatus.error,
        errorMessage: 'حدث خطأ أثناء تحميل الوجبات. تحقق من الاتصال بالإنترنت.',
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

  void addAllergy(String allergy) {
    if (allergy.trim().isEmpty) return;
    final updated = [..._state.allergies, allergy.trim()];
    _state = _state.copyWith(allergies: updated);
    notifyListeners();
  }

  void removeAllergy(String allergy) {
    final updated = _state.allergies.where((a) => a != allergy).toList();
    _state = _state.copyWith(allergies: updated);
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
