class Nutrition {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    this.fat = 0,
  });
}
