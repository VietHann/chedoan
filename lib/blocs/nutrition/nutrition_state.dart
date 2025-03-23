import '../../models/meal_entry.dart';

abstract class NutritionState {}

class NutritionInitial extends NutritionState {}

class NutritionLoading extends NutritionState {}

class DailyNutritionLoaded extends NutritionState {
  final DateTime date;
  final List<MealEntry> meals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  final int waterIntake;
  final int targetWaterIntake;

  DailyNutritionLoaded({
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.waterIntake,
    required this.targetWaterIntake,
  });

  double get calorieProgress => 
      targetCalories > 0 ? (totalCalories / targetCalories).clamp(0.0, 1.0) : 0.0;
  
  double get proteinProgress => 
      targetProtein > 0 ? (totalProtein / targetProtein).clamp(0.0, 1.0) : 0.0;
  
  double get carbsProgress => 
      targetCarbs > 0 ? (totalCarbs / targetCarbs).clamp(0.0, 1.0) : 0.0;
  
  double get fatProgress => 
      targetFat > 0 ? (totalFat / targetFat).clamp(0.0, 1.0) : 0.0;
  
  double get waterProgress => 
      targetWaterIntake > 0 ? (waterIntake / targetWaterIntake).clamp(0.0, 1.0) : 0.0;
  
  List<MealEntry> getMealsByType(MealType type) {
    return meals.where((meal) => meal.mealType == type).toList();
  }
}

class WeeklyStatsLoaded extends NutritionState {
  final List<DateTime> dates;
  final List<double> dailyCalories;
  final List<double> dailyProtein;
  final List<double> dailyCarbs;
  final List<double> dailyFat;
  final List<int> dailyWaterIntake;
  final int targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  final int targetWaterIntake;

  WeeklyStatsLoaded({
    required this.dates,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
    required this.dailyWaterIntake,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.targetWaterIntake,
  });

  // Helper method to get average calories for the week
  double get averageCalories {
    if (dailyCalories.isEmpty) return 0;
    return dailyCalories.reduce((a, b) => a + b) / dailyCalories.length;
  }

  // Helper method to get average protein for the week
  double get averageProtein {
    if (dailyProtein.isEmpty) return 0;
    return dailyProtein.reduce((a, b) => a + b) / dailyProtein.length;
  }

  // Helper method to get average carbs for the week
  double get averageCarbs {
    if (dailyCarbs.isEmpty) return 0;
    return dailyCarbs.reduce((a, b) => a + b) / dailyCarbs.length;
  }

  // Helper method to get average fat for the week
  double get averageFat {
    if (dailyFat.isEmpty) return 0;
    return dailyFat.reduce((a, b) => a + b) / dailyFat.length;
  }

  // Helper method to get average water intake for the week
  double get averageWaterIntake {
    if (dailyWaterIntake.isEmpty) return 0;
    return dailyWaterIntake.reduce((a, b) => a + b) / dailyWaterIntake.length;
  }
}

class NutritionError extends NutritionState {
  final String message;

  NutritionError({required this.message});
}
