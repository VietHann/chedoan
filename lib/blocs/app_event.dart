import '../models/meal_entry.dart';
import '../models/water_intake.dart';

abstract class AppEvent {}

class AppStarted extends AppEvent {}

class LoginRequested extends AppEvent {
  final String email;
  final String password;

  LoginRequested({
    required this.email,
    required this.password,
  });
}

class RegisterRequested extends AppEvent {
  final String name;
  final String email;
  final String password;

  RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });
}

class LogoutRequested extends AppEvent {}

class LoadDailyNutrition extends AppEvent {
  final DateTime date;

  LoadDailyNutrition(this.date);
}

class AddMealEntry extends AppEvent {
  final MealEntry mealEntry;

  AddMealEntry(this.mealEntry);
}

class DeleteMealEntry extends AppEvent {
  final String mealEntryId;
  final DateTime date;

  DeleteMealEntry({
    required this.mealEntryId,
    required this.date,
  });
}

class AddWaterIntake extends AppEvent {
  final WaterIntake waterIntake;

  AddWaterIntake(this.waterIntake);
}

class UpdateProfile extends AppEvent {
  final String? name;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? goal;
  final String? activityLevel;

  UpdateProfile({
    this.name,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.goal,
    this.activityLevel,
  });
}