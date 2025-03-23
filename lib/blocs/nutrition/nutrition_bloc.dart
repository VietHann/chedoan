import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/food_item.dart';
import '../../models/meal_entry.dart';
import '../../models/nutrition_data.dart';
import '../../models/user_profile.dart';
import '../../models/water_intake.dart';
import '../../repositories/meal_repository.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/water_repository.dart';
import 'nutrition_event.dart';
import 'nutrition_state.dart';

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final MealRepository mealRepository;
  final WaterRepository waterRepository;
  final UserRepository userRepository;

  NutritionBloc({
    required this.mealRepository,
    required this.waterRepository,
    required this.userRepository,
  }) : super(NutritionInitial()) {
    on<LoadDailyNutrition>(_onLoadDailyNutrition);
    on<AddMealEntry>(_onAddMealEntry);
    on<DeleteMealEntry>(_onDeleteMealEntry);
    on<AddWaterIntake>(_onAddWaterIntake);
    on<LoadWeeklyStats>(_onLoadWeeklyStats);
  }

  Future<void> _onLoadDailyNutrition(
    LoadDailyNutrition event,
    Emitter<NutritionState> emit,
  ) async {
    emit(NutritionLoading());
    try {
      // Get user profile for targets
      final user = await userRepository.getUserByEmail(event.email);
      if (user == null) {
        emit(NutritionError(message: 'Không tìm thấy người dùng'));
        return;
      }

      // Load meals for the day
      final meals = await mealRepository.getMealsForDate(
        email: event.email,
        date: event.date,
      );

      // Load water intake for the day
      final waterIntakes = await waterRepository.getWaterIntakesForDate(
        email: event.email,
        date: event.date,
      );

      // Calculate total water intake
      int totalWaterIntake = 0;
      for (var intake in waterIntakes) {
        totalWaterIntake += intake.amount;
      }

      // Calculate daily nutrition totals
      NutritionData dailyTotal = NutritionData.empty();
      for (var meal in meals) {
        if (meal.nutritionData != null) {
          dailyTotal = dailyTotal + meal.nutritionData!;
        }
      }

      emit(DailyNutritionLoaded(
        date: event.date,
        meals: meals,
        totalCalories: dailyTotal.calories,
        totalProtein: dailyTotal.protein,
        totalCarbs: dailyTotal.carbs,
        totalFat: dailyTotal.fat,
        targetCalories: user.targetCalories ?? 2000, // Default if not set
        targetProtein: user.targetProtein ?? 50, // Default if not set
        targetCarbs: user.targetCarbs ?? 250, // Default if not set
        targetFat: user.targetFat ?? 70, // Default if not set
        waterIntake: totalWaterIntake,
        targetWaterIntake: user.targetWater ?? 2000, // Default if not set
      ));
    } catch (e) {
      emit(NutritionError(message: 'Không thể tải dữ liệu dinh dưỡng: $e'));
    }
  }

  Future<void> _onAddMealEntry(
    AddMealEntry event,
    Emitter<NutritionState> emit,
  ) async {
    // Store current state to restore if needed
    final currentState = state;
    emit(NutritionLoading());
    try {
      // Create and add meal entry
      await mealRepository.addMealEntry(
        email: event.email,
        mealEntry: event.mealEntry,
      );

      // Reload the day's nutrition
      add(LoadDailyNutrition(
        email: event.email,
        date: event.mealEntry.date,
      ));
    } catch (e) {
      emit(NutritionError(message: 'Không thể thêm bữa ăn: $e'));
      // Restore previous state
      if (currentState is DailyNutritionLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteMealEntry(
    DeleteMealEntry event,
    Emitter<NutritionState> emit,
  ) async {
    // Store current state to restore if needed
    final currentState = state;
    emit(NutritionLoading());
    try {
      // Delete meal entry - Changed from int to String for Firebase
      await mealRepository.deleteMealEntry(
        mealEntryId: event.mealEntryId,
      );

      // Reload the day's nutrition
      add(LoadDailyNutrition(
        email: event.email,
        date: event.date,
      ));
    } catch (e) {
      emit(NutritionError(message: 'Không thể xóa bữa ăn: $e'));
      // Restore previous state
      if (currentState is DailyNutritionLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onAddWaterIntake(
    AddWaterIntake event,
    Emitter<NutritionState> emit,
  ) async {
    // Store current state to restore if needed
    final currentState = state;
    emit(NutritionLoading());
    try {
      // Create and add water intake
      await waterRepository.addWaterIntake(
        email: event.email,
        waterIntake: event.waterIntake,
      );

      // Reload the day's nutrition
      add(LoadDailyNutrition(
        email: event.email,
        date: event.waterIntake.date,
      ));
    } catch (e) {
      emit(NutritionError(message: 'Không thể thêm lượng nước: $e'));
      // Restore previous state
      if (currentState is DailyNutritionLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onLoadWeeklyStats(
    LoadWeeklyStats event,
    Emitter<NutritionState> emit,
  ) async {
    emit(NutritionLoading());
    try {
      final today = DateTime.now();
      final startDate = today.subtract(Duration(days: 6)); // Last 7 days

      // Get user profile for targets
      final user = await userRepository.getUserByEmail(event.email);
      if (user == null) {
        emit(NutritionError(message: 'Không tìm thấy người dùng'));
        return;
      }

      // Prepare data structures for weekly stats
      final List<double> dailyCalories = [];
      final List<double> dailyProtein = [];
      final List<double> dailyCarbs = [];
      final List<double> dailyFat = [];
      final List<int> dailyWaterIntake = [];
      final List<DateTime> dates = [];

      // Get data for each day
      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        dates.add(date);

        // Get meals for the day
        final meals = await mealRepository.getMealsForDate(
          email: event.email,
          date: date,
        );

        // Calculate daily nutrition totals
        NutritionData dailyTotal = NutritionData.empty();
        for (var meal in meals) {
          if (meal.nutritionData != null) {
            dailyTotal = dailyTotal + meal.nutritionData!;
          }
        }

        // Add to lists
        dailyCalories.add(dailyTotal.calories);
        dailyProtein.add(dailyTotal.protein);
        dailyCarbs.add(dailyTotal.carbs);
        dailyFat.add(dailyTotal.fat);

        // Get water intakes for the day
        final waterIntakes = await waterRepository.getWaterIntakesForDate(
          email: event.email,
          date: date,
        );

        // Calculate total water intake
        int totalWaterIntake = 0;
        for (var intake in waterIntakes) {
          totalWaterIntake += intake.amount;
        }
        dailyWaterIntake.add(totalWaterIntake);
      }

      emit(WeeklyStatsLoaded(
        dates: dates,
        dailyCalories: dailyCalories,
        dailyProtein: dailyProtein,
        dailyCarbs: dailyCarbs,
        dailyFat: dailyFat,
        dailyWaterIntake: dailyWaterIntake,
        targetCalories: user.targetCalories ?? 2000,
        targetProtein: user.targetProtein ?? 50,
        targetCarbs: user.targetCarbs ?? 250,
        targetFat: user.targetFat ?? 70,
        targetWaterIntake: user.targetWater ?? 2000,
      ));
    } catch (e) {
      emit(NutritionError(message: 'Không thể tải thống kê tuần: $e'));
    }
  }
}
