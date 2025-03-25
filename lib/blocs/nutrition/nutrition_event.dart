import '../../models/meal_entry.dart';
import '../../models/water_intake.dart';

abstract class NutritionEvent {}

class LoadDailyNutrition extends NutritionEvent {
  final String email;
  final DateTime date;

  LoadDailyNutrition({
    required this.email,
    required this.date,
  });
}

class AddMealEntry extends NutritionEvent {
  final String email;
  final MealEntry mealEntry;

  AddMealEntry({
    required this.email,
    required this.mealEntry,
  });
}

class DeleteMealEntry extends NutritionEvent {
  final String email;
  final String mealEntryId; // Changed from int to String for Firebase
  final DateTime date;

  DeleteMealEntry({
    required this.email,
    required this.mealEntryId,
    required this.date,
  });
}

class AddWaterIntake extends NutritionEvent {
  final String email;
  final WaterIntake waterIntake;

  AddWaterIntake({
    required this.email,
    required this.waterIntake,
  });
}

class LoadWeeklyStats extends NutritionEvent {
  final String email;

  LoadWeeklyStats({
    required this.email,
  });
}