import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

enum MealsStatus { initial, loading, loaded, error }

class MealsState {
  final MealsStatus status;
  final Map<int, List<Meal>> weeklyMeals;
  final List<String> ingredients;
  final List<String> allergies;
  final String? errorMessage;
  final int selectedDayIndex;

  const MealsState({
    this.status = MealsStatus.initial,
    this.weeklyMeals = const {},
    this.ingredients = const [],
    this.allergies = const [],
    this.errorMessage,
    this.selectedDayIndex = 0,
  });

  
  List<Meal> get meals => weeklyMeals[selectedDayIndex] ?? [];

  MealsState copyWith({
    MealsStatus? status,
    Map<int, List<Meal>>? weeklyMeals,
    List<String>? ingredients,
    List<String>? allergies,
    String? errorMessage,
    int? selectedDayIndex,
  }) {
    return MealsState(
      status: status ?? this.status,
      weeklyMeals: weeklyMeals ?? this.weeklyMeals,
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
  final GetSavedWeeklyPlan _getSavedWeeklyPlan;

  MealsState _state = const MealsState();
  MealsState get state => _state;

  MealsCubit({
    required GetAiMealSuggestions getAiMealSuggestions,
    required GetMealsByDate getMealsByDate,
    required ToggleFavoriteMeal toggleFavoriteMeal,
    required GetSavedWeeklyPlan getSavedWeeklyPlan,
  })  : _getAiMealSuggestions = getAiMealSuggestions,
        _getMealsByDate = getMealsByDate,
        _toggleFavoriteMeal = toggleFavoriteMeal,
        _getSavedWeeklyPlan = getSavedWeeklyPlan;

  /// Load saved weekly plan from backend (called when screen opens)
  Future<void> loadSavedPlan() async {
    // Don't reload if already loaded
    if (_state.status == MealsStatus.loaded && _state.weeklyMeals.isNotEmpty) return;

    _state = _state.copyWith(status: MealsStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final childId = await SecureStorageService.getChildId();
      if (childId == null) return;

      final weeklyMeals = await _getSavedWeeklyPlan(childId.toString());
      _state = _state.copyWith(
        status: MealsStatus.loaded,
        weeklyMeals: weeklyMeals,
      );
      notifyListeners();
    } catch (e) {
      print('📋 No saved plan found, showing initial state');
      // No saved plan — show initial state (not error)
      _state = _state.copyWith(status: MealsStatus.initial);
      notifyListeners();
    }
  }

  Future<void> getAiSuggestions() async {
    _state = _state.copyWith(status: MealsStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final childId = await SecureStorageService.getChildId();
      if (childId == null) {
        throw Exception('بيانات الطفل غير متوفرة. يرجى تسجيل الدخول أولاً.');
      }
      final weeklyMeals = await _getAiMealSuggestions(
        _state.ingredients,
        childId.toString(),
        allergies: _state.allergies,
      );
      _state = _state.copyWith(
        status: MealsStatus.loaded,
        weeklyMeals: weeklyMeals,
      );
      notifyListeners();
    } catch (e) {
      print('❌ AI Suggestions error: $e');

      String errorMessage = 'حدث خطأ أثناء تحميل الاقتراحات. تحقق من الاتصال بالإنترنت.';

      // Extract actual API error message if available
      if (e is DioException && e.response?.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        final apiMessage = responseData['message'] as String?;
        final errors = responseData['errors'] as List<dynamic>?;

        if (apiMessage != null && apiMessage.isNotEmpty) {
          errorMessage = apiMessage;
          if (errors != null && errors.isNotEmpty) {
            errorMessage += '\n\nجرب إضافة مكونات متنوعة أكثر (مثل: بيض، حليب، خبز، جبنة) لتغطية جميع الوجبات.';
          }
        }
      }

      _state = _state.copyWith(
        status: MealsStatus.error,
        errorMessage: errorMessage,
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
      // Store in current selected day
      final updatedWeekly = Map<int, List<Meal>>.from(_state.weeklyMeals);
      updatedWeekly[_state.selectedDayIndex] = meals;
      _state = _state.copyWith(status: MealsStatus.loaded, weeklyMeals: updatedWeekly);
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
    // Optimistically toggle in current day
    final currentDayMeals = _state.meals;
    final updatedMeals = currentDayMeals.map((meal) {
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

    final updatedWeekly = Map<int, List<Meal>>.from(_state.weeklyMeals);
    updatedWeekly[_state.selectedDayIndex] = updatedMeals;
    _state = _state.copyWith(weeklyMeals: updatedWeekly);
    notifyListeners();
  }

  void reset() {
    _state = const MealsState();
    notifyListeners();
  }
}

