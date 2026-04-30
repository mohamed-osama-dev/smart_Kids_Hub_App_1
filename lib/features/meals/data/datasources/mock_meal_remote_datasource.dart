import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';
import 'meal_remote_datasource.dart';

class MockMealRemoteDataSource implements MealRemoteDataSource {
  // Simulate network delay
  Future<void> _delay() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<Map<int, List<MealModel>>> getAiSuggestions(
    List<String> ingredients,
    String childId, {
    List<String> allergies = const [],
  }) async {
    await _delay();
    debugPrint('MockMealRemoteDataSource: getAiSuggestions (weekly) for child $childId with ingredients: $ingredients');

    // Return a weekly plan: 7 days (0=Saturday ... 6=Friday)
    return {
      0: [ // السبت
        MealModel.mock(name: 'فول مدمس بالطحينة', emoji: '🫘', mealTimeKey: 'الفطار', timeLabel: '8:00 ص', ingredientNames: ['فول', 'طحينة', 'ليمون'], calories: 320, protein: 15, carbs: 40),
        MealModel.mock(name: 'كشري مصري', emoji: '🍚', mealTimeKey: 'الغداء', timeLabel: '1:00 م', ingredientNames: ['أرز', 'عدس', 'مكرونة', 'طماطم'], calories: 485, protein: 18, carbs: 78),
        MealModel.mock(name: 'محشي ورق عنب', emoji: '🍃', mealTimeKey: 'العشاء', timeLabel: '7:00 م', ingredientNames: ['أرز', 'ورق عنب', 'لحمة'], calories: 340, protein: 12, carbs: 45),
      ],
      1: [ // الأحد
        MealModel.mock(name: 'بيض مقلي بالخضار', emoji: '🍳', mealTimeKey: 'الفطار', timeLabel: '8:00 ص', ingredientNames: ['بيض', 'فلفل', 'طماطم'], calories: 280, protein: 16, carbs: 12),
        MealModel.mock(name: 'دجاج مشوي بالأرز', emoji: '🍗', mealTimeKey: 'الغداء', timeLabel: '1:00 م', ingredientNames: ['دجاج', 'أرز', 'بهارات'], calories: 520, protein: 35, carbs: 55),
        MealModel.mock(name: 'شوربة عدس', emoji: '🥣', mealTimeKey: 'العشاء', timeLabel: '7:00 م', ingredientNames: ['عدس', 'جزر', 'بصل'], calories: 220, protein: 14, carbs: 35),
      ],
      2: [ // الإثنين
        MealModel.mock(name: 'فطائر بالجبنة', emoji: '🥧', mealTimeKey: 'الفطار', timeLabel: '8:00 ص', ingredientNames: ['دقيق', 'جبنة', 'زبدة'], calories: 350, protein: 12, carbs: 42),
        MealModel.mock(name: 'ملوخية بالأرنب', emoji: '🥬', mealTimeKey: 'الغداء', timeLabel: '1:00 م', ingredientNames: ['ملوخية', 'أرنب', 'أرز'], calories: 450, protein: 30, carbs: 48),
        MealModel.mock(name: 'سلطة تونة', emoji: '🥗', mealTimeKey: 'العشاء', timeLabel: '7:00 م', ingredientNames: ['تونة', 'خس', 'طماطم'], calories: 250, protein: 22, carbs: 15),
      ],
      3: [ // الثلاثاء
        MealModel.mock(name: 'شكشوكة', emoji: '🍳', mealTimeKey: 'الفطار', timeLabel: '8:00 ص', ingredientNames: ['بيض', 'طماطم', 'فلفل'], calories: 300, protein: 18, carbs: 20),
        MealModel.mock(name: 'كباب وكفتة', emoji: '🥩', mealTimeKey: 'الغداء', timeLabel: '1:00 م', ingredientNames: ['لحمة', 'بصل', 'بقدونس'], calories: 550, protein: 40, carbs: 30),
        MealModel.mock(name: 'زبادي بالفواكه', emoji: '🍓', mealTimeKey: 'العشاء', timeLabel: '7:00 م', ingredientNames: ['زبادي', 'فراولة', 'موز'], calories: 180, protein: 8, carbs: 28),
      ],
      4: [ // الأربعاء
        MealModel.mock(name: 'بليلة بالحليب', emoji: '🥛', mealTimeKey: 'الفطار', timeLabel: '8:00 ص', ingredientNames: ['قمح', 'حليب', 'سكر'], calories: 290, protein: 10, carbs: 50),
        MealModel.mock(name: 'سمك مشوي بالخضار', emoji: '🐟', mealTimeKey: 'الغداء', timeLabel: '1:00 م', ingredientNames: ['سمك', 'بطاطس', 'طماطم'], calories: 400, protein: 32, carbs: 35),
        MealModel.mock(name: 'ساندويتش جبنة', emoji: '🧀', mealTimeKey: 'العشاء', timeLabel: '7:00 م', ingredientNames: ['خبز', 'جبنة', 'خيار'], calories: 280, protein: 14, carbs: 32),
      ],
      5: [ // الخميس
        MealModel.mock(name: 'فول بالزيت والليمون', emoji: '🫘', mealTimeKey: 'الفطار', timeLabel: '8:00 ص', ingredientNames: ['فول', 'زيت زيتون', 'ليمون'], calories: 310, protein: 16, carbs: 38),
        MealModel.mock(name: 'فتة باللحمة', emoji: '🍖', mealTimeKey: 'الغداء', timeLabel: '1:00 م', ingredientNames: ['لحمة', 'خبز', 'أرز', 'طماطم'], calories: 580, protein: 35, carbs: 60),
        MealModel.mock(name: 'بطاطس محمرة', emoji: '🍟', mealTimeKey: 'العشاء', timeLabel: '7:00 م', ingredientNames: ['بطاطس', 'زيت', 'ملح'], calories: 320, protein: 5, carbs: 45),
      ],
      6: [ // الجمعة
        MealModel.mock(name: 'عسل أبيض بالطحينة', emoji: '🍯', mealTimeKey: 'الفطار', timeLabel: '8:00 ص', ingredientNames: ['عسل', 'طحينة', 'خبز'], calories: 350, protein: 8, carbs: 55),
        MealModel.mock(name: 'رقبة ضاني محمرة', emoji: '🍖', mealTimeKey: 'الغداء', timeLabel: '1:00 م', ingredientNames: ['لحم ضاني', 'بطاطس', 'بهارات'], calories: 620, protein: 42, carbs: 40),
        MealModel.mock(name: 'أرز بالحليب', emoji: '🍚', mealTimeKey: 'العشاء', timeLabel: '7:00 م', ingredientNames: ['أرز', 'حليب', 'سكر'], calories: 280, protein: 8, carbs: 50),
      ],
    };
  }

  @override
  Future<Map<int, List<MealModel>>> getSavedWeeklyPlan(String childId) async {
    await _delay();
    debugPrint('MockMealRemoteDataSource: getSavedWeeklyPlan for child $childId');
    // Reuse the same mock data as getAiSuggestions
    return getAiSuggestions([], childId);
  }

  @override
  Future<List<MealModel>> getMealsByDate(String date, String childId) async {
    await _delay();
    debugPrint('MockMealRemoteDataSource: getMealsByDate for child $childId on $date');

    return [
      MealModel.mock(name: 'فول مدمس بالطحينة', emoji: '🫘', mealTimeKey: 'الفطار', timeLabel: '8:00 ص', ingredientNames: ['بيض', 'طماطم', 'فول'], calories: 320, protein: 15, carbs: 40),
      MealModel.mock(name: 'كشري مصري', emoji: '🍚', mealTimeKey: 'الغداء', timeLabel: '1:00 م', ingredientNames: ['أرز', 'عدس', 'مكرونة', 'طماطم', 'بصل'], calories: 485, protein: 18, carbs: 78),
      MealModel.mock(name: 'محشي ورق عنب', emoji: '🍃', mealTimeKey: 'العشاء', timeLabel: '7:00 م', ingredientNames: ['أرز', 'طماطم', 'ورق عنب', 'لحمة'], calories: 340, protein: 12, carbs: 45),
    ];
  }

  @override
  Future<void> toggleFavorite(String mealId) async {
    await _delay();
    debugPrint('MockMealRemoteDataSource: toggleFavorite for meal $mealId');
  }
}

