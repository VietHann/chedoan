import '../models/meal_entry.dart';
import '../models/user_profile.dart';

abstract class AppState {}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppAuthenticated extends AppState {
  final UserProfile user;
  
  AppAuthenticated(this.user);
}

class AppUnauthenticated extends AppState {}

class AppDailyNutritionLoaded extends AppState {
  final UserProfile user;
  final DateTime date;
  final List<MealEntry> meals;
  final int waterIntake;
  final int targetWaterIntake;
  
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  
  AppDailyNutritionLoaded({
    required this.user,
    required this.date,
    required this.meals,
    required this.waterIntake,
    required this.targetWaterIntake,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });
  
  double get calorieProgress => 
      user.targetCalories != null && user.targetCalories! > 0 
          ? (totalCalories / user.targetCalories!).clamp(0.0, 1.0) 
          : 0.0;
  
  double get proteinProgress => 
      user.targetProtein != null && user.targetProtein! > 0 
          ? (totalProtein / user.targetProtein!).clamp(0.0, 1.0) 
          : 0.0;
  
  double get carbsProgress => 
      user.targetCarbs != null && user.targetCarbs! > 0 
          ? (totalCarbs / user.targetCarbs!).clamp(0.0, 1.0) 
          : 0.0;
  
  double get fatProgress => 
      user.targetFat != null && user.targetFat! > 0 
          ? (totalFat / user.targetFat!).clamp(0.0, 1.0) 
          : 0.0;
  
  double get waterProgress => 
      targetWaterIntake > 0 
          ? (waterIntake / targetWaterIntake).clamp(0.0, 1.0) 
          : 0.0;
  
  List<MealEntry> getMealsByType(MealType type) {
    return meals.where((meal) => meal.mealType == type).toList();
  }
}

class AppError extends AppState {
  final String message;
  
  AppError(this.message);
}