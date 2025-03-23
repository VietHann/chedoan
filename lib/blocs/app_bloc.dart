import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/user_repository.dart';
import '../repositories/nutrition_repository.dart';
import '../models/user_profile.dart';
import '../models/meal_entry.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final UserRepository userRepository;
  final NutritionRepository nutritionRepository;
  final SharedPreferences sharedPreferences;

  static const String kEmailKey = 'user_email';
  UserProfile? _currentUser;

  AppBloc({
    required this.userRepository,
    required this.nutritionRepository,
    required this.sharedPreferences,
  }) : super(AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<LoadDailyNutrition>(_onLoadDailyNutrition);
    on<AddMealEntry>(_onAddMealEntry);
    on<DeleteMealEntry>(_onDeleteMealEntry);
    on<AddWaterIntake>(_onAddWaterIntake);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AppState> emit,
  ) async {
    emit(AppLoading());
    try {
      final email = sharedPreferences.getString(kEmailKey);
      if (email != null && email.isNotEmpty) {
        final user = await userRepository.getUserByEmail(email);
        if (user != null) {
          _currentUser = user;

          // Load dữ liệu dinh dưỡng cho ngày hiện tại
          final today = DateTime.now();
          final meals = await nutritionRepository.getMealsForDate(
            email: _currentUser!.email,
            date: today,
          );

          final waterIntake =
              await nutritionRepository.getDailyTotalWaterIntake(
            email: _currentUser!.email,
            date: today,
          );

          double totalCalories = 0;
          double totalProtein = 0;
          double totalCarbs = 0;
          double totalFat = 0;

          for (final meal in meals) {
            totalCalories += meal.calories;
            totalProtein += meal.protein;
            totalCarbs += meal.carbs;
            totalFat += meal.fat;
          }

          emit(AppDailyNutritionLoaded(
            user: _currentUser!,
            date: today,
            meals: meals,
            waterIntake: waterIntake,
            targetWaterIntake: _currentUser!.targetWater ?? 2000,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
          ));
          return;
        }
      }
      emit(AppUnauthenticated());
    } catch (e) {
      print('Error in _onAppStarted: $e');
      emit(AppError('Không thể kiểm tra trạng thái đăng nhập: $e'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(AppLoading());
    try {
      final user = await userRepository.authenticateUser(
        event.email,
        event.password,
      );

      if (user != null) {
        _currentUser = user;
        await sharedPreferences.setString(kEmailKey, event.email);

        // Load dữ liệu dinh dưỡng cho ngày hiện tại
        final today = DateTime.now();
        final meals = await nutritionRepository.getMealsForDate(
          email: _currentUser!.email,
          date: today,
        );

        final waterIntake = await nutritionRepository.getDailyTotalWaterIntake(
          email: _currentUser!.email,
          date: today,
        );

        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;

        for (final meal in meals) {
          totalCalories += meal.calories;
          totalProtein += meal.protein;
          totalCarbs += meal.carbs;
          totalFat += meal.fat;
        }

        emit(AppDailyNutritionLoaded(
          user: _currentUser!,
          date: today,
          meals: meals,
          waterIntake: waterIntake,
          targetWaterIntake: _currentUser!.targetWater ?? 2000,
          totalCalories: totalCalories,
          totalProtein: totalProtein,
          totalCarbs: totalCarbs,
          totalFat: totalFat,
        ));
      } else {
        emit(AppError('Email hoặc mật khẩu không chính xác'));
      }
    } catch (e) {
      print('Login error: $e');
      emit(AppError('Đăng nhập thất bại: $e'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(AppLoading());
    try {
      // Tạo user mới trong Realtime Database
      final user = await userRepository.createUser(
        email: event.email,
        password: event.password,
        name: event.name,
      );

      // Lưu email vào SharedPreferences
      await sharedPreferences.setString(kEmailKey, event.email);

      // Cập nhật state
      _currentUser = user;

      // Load dữ liệu dinh dưỡng cho ngày hiện tại
      final today = DateTime.now();
      final meals = await nutritionRepository.getMealsForDate(
        email: _currentUser!.email,
        date: today,
      );

      final waterIntake = await nutritionRepository.getDailyTotalWaterIntake(
        email: _currentUser!.email,
        date: today,
      );

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final meal in meals) {
        totalCalories += meal.calories;
        totalProtein += meal.protein;
        totalCarbs += meal.carbs;
        totalFat += meal.fat;
      }

      emit(AppDailyNutritionLoaded(
        user: _currentUser!,
        date: today,
        meals: meals,
        waterIntake: waterIntake,
        targetWaterIntake: _currentUser!.targetWater ?? 2000,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
      ));
    } catch (e) {
      print('Register error: $e');
      emit(AppError('Đăng ký thất bại: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(AppLoading());
    try {
      await sharedPreferences.remove(kEmailKey);
      _currentUser = null;
      emit(AppUnauthenticated());
    } catch (e) {
      emit(AppError('Đăng xuất thất bại: $e'));
    }
  }

  Future<void> _onLoadDailyNutrition(
    LoadDailyNutrition event,
    Emitter<AppState> emit,
  ) async {
    // Nếu đang ở trạng thái loading, bỏ qua
    if (state is AppLoading) {
      return;
    }

    // Kiểm tra xem có đang ở state AppDailyNutritionLoaded không
    if (state is AppDailyNutritionLoaded) {
      final currentState = state as AppDailyNutritionLoaded;
      // Nếu đang load dữ liệu cho cùng một ngày, bỏ qua
      if (currentState.date.year == event.date.year &&
          currentState.date.month == event.date.month &&
          currentState.date.day == event.date.day) {
        return;
      }
    }

    if (_currentUser == null) {
      emit(AppUnauthenticated());
      return;
    }

    emit(AppLoading());

    try {
      final meals = await nutritionRepository.getMealsForDate(
        email: _currentUser!.email,
        date: event.date,
      );

      final waterIntake = await nutritionRepository.getDailyTotalWaterIntake(
        email: _currentUser!.email,
        date: event.date,
      );

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final meal in meals) {
        totalCalories += meal.calories;
        totalProtein += meal.protein;
        totalCarbs += meal.carbs;
        totalFat += meal.fat;
      }

      emit(AppDailyNutritionLoaded(
        user: _currentUser!,
        date: event.date,
        meals: meals,
        waterIntake: waterIntake,
        targetWaterIntake: _currentUser!.targetWater ?? 2000,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
      ));
    } catch (e) {
      print('Error loading daily nutrition: $e');
      // Nếu có lỗi, emit AppDailyNutritionLoaded với dữ liệu trống
      emit(AppDailyNutritionLoaded(
        user: _currentUser!,
        date: event.date,
        meals: [],
        waterIntake: 0,
        targetWaterIntake: _currentUser!.targetWater ?? 2000,
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
      ));
    }
  }

  Future<void> _onAddMealEntry(
    AddMealEntry event,
    Emitter<AppState> emit,
  ) async {
    if (_currentUser == null) {
      emit(AppUnauthenticated());
      return;
    }

    try {
      await nutritionRepository.addMealEntry(
        email: _currentUser!.email,
        mealEntry: event.mealEntry,
      );

      // Load lại dữ liệu dinh dưỡng
      final meals = await nutritionRepository.getMealsForDate(
        email: _currentUser!.email,
        date: event.mealEntry.date,
      );

      final waterIntake = await nutritionRepository.getDailyTotalWaterIntake(
        email: _currentUser!.email,
        date: event.mealEntry.date,
      );

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final meal in meals) {
        totalCalories += meal.calories;
        totalProtein += meal.protein;
        totalCarbs += meal.carbs;
        totalFat += meal.fat;
      }

      emit(AppDailyNutritionLoaded(
        user: _currentUser!,
        date: event.mealEntry.date,
        meals: meals,
        waterIntake: waterIntake,
        targetWaterIntake: _currentUser!.targetWater ?? 2000,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
      ));
    } catch (e) {
      print('Error adding meal: $e');
      emit(AppError('Không thể thêm bữa ăn: $e'));
    }
  }

  Future<void> _onDeleteMealEntry(
    DeleteMealEntry event,
    Emitter<AppState> emit,
  ) async {
    if (_currentUser == null) {
      emit(AppUnauthenticated());
      return;
    }

    emit(AppLoading());
    try {
      await nutritionRepository.deleteMealEntry(
        mealEntryId: event.mealEntryId,
      );

      // Load lại dữ liệu cho ngày đã chọn
      final meals = await nutritionRepository.getMealsForDate(
        email: _currentUser!.email,
        date: event.date,
      );

      final waterIntake = await nutritionRepository.getDailyTotalWaterIntake(
        email: _currentUser!.email,
        date: event.date,
      );

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final meal in meals) {
        totalCalories += meal.calories;
        totalProtein += meal.protein;
        totalCarbs += meal.carbs;
        totalFat += meal.fat;
      }

      emit(AppDailyNutritionLoaded(
        user: _currentUser!,
        date: event.date,
        meals: meals,
        waterIntake: waterIntake,
        targetWaterIntake: _currentUser!.targetWater ?? 2000,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
      ));
    } catch (e) {
      emit(AppError('Không thể xóa bữa ăn: $e'));
    }
  }

  Future<void> _onAddWaterIntake(
    AddWaterIntake event,
    Emitter<AppState> emit,
  ) async {
    if (_currentUser == null) {
      emit(AppUnauthenticated());
      return;
    }

    emit(AppLoading());
    try {
      await nutritionRepository.addWaterIntake(
        email: _currentUser!.email,
        waterIntake: event.waterIntake,
      );

      // Load lại dữ liệu cho ngày đã chọn
      final meals = await nutritionRepository.getMealsForDate(
        email: _currentUser!.email,
        date: event.waterIntake.date,
      );

      final waterIntake = await nutritionRepository.getDailyTotalWaterIntake(
        email: _currentUser!.email,
        date: event.waterIntake.date,
      );

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final meal in meals) {
        totalCalories += meal.calories;
        totalProtein += meal.protein;
        totalCarbs += meal.carbs;
        totalFat += meal.fat;
      }

      emit(AppDailyNutritionLoaded(
        user: _currentUser!,
        date: event.waterIntake.date,
        meals: meals,
        waterIntake: waterIntake,
        targetWaterIntake: _currentUser!.targetWater ?? 2000,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
      ));
    } catch (e) {
      emit(AppError('Không thể thêm nước: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<AppState> emit,
  ) async {
    if (_currentUser == null) {
      emit(AppUnauthenticated());
      return;
    }

    emit(AppLoading());
    try {
      final updatedUser = _currentUser!.copyWith(
        name: event.name,
        age: event.age,
        gender: event.gender,
        height: event.height,
        weight: event.weight,
        goal: event.goal,
        activityLevel: event.activityLevel,
      );

      // Calculate targets
      int? targetCalories;
      double? targetProtein;
      double? targetCarbs;
      double? targetFat;
      int? targetWater;

      if (updatedUser.weight != null &&
          updatedUser.height != null &&
          updatedUser.age != null &&
          updatedUser.gender != null &&
          updatedUser.activityLevel != null &&
          updatedUser.goal != null) {
        // Simple calorie calculation
        final bmr = updatedUser.gender == 'male'
            ? (10 * updatedUser.weight! +
                6.25 * updatedUser.height! -
                5 * updatedUser.age! +
                5)
            : (10 * updatedUser.weight! +
                6.25 * updatedUser.height! -
                5 * updatedUser.age! -
                161);

        // Activity multipliers
        double activityMultiplier = 1.2; // Default - sedentary
        switch (updatedUser.activityLevel) {
          case 'light':
            activityMultiplier = 1.375;
            break;
          case 'moderate':
            activityMultiplier = 1.55;
            break;
          case 'active':
            activityMultiplier = 1.725;
            break;
          case 'very_active':
            activityMultiplier = 1.9;
            break;
        }

        double tdee = bmr * activityMultiplier;

        // Adjust for goal
        switch (updatedUser.goal) {
          case 'lose_weight':
            targetCalories = (tdee - 500).round();
            break;
          case 'gain_weight':
            targetCalories = (tdee + 500).round();
            break;
          default:
            targetCalories = tdee.round();
            break;
        }

        // Macros based on goal
        double proteinRatio = 0.3; // Default 30%
        double carbsRatio = 0.45; // Default 45%
        double fatRatio = 0.25; // Default 25%

        if (updatedUser.goal == 'lose_weight') {
          proteinRatio = 0.35;
          carbsRatio = 0.4;
          fatRatio = 0.25;
        } else if (updatedUser.goal == 'gain_weight') {
          proteinRatio = 0.25;
          carbsRatio = 0.5;
          fatRatio = 0.25;
        }

        // Calculate macros
        targetProtein = (targetCalories * proteinRatio / 4).round().toDouble();
        targetCarbs = (targetCalories * carbsRatio / 4).round().toDouble();
        targetFat = (targetCalories * fatRatio / 9).round().toDouble();

        // Water - 30ml per kg
        targetWater = (updatedUser.weight! * 30).round();
      }

      final finalUser = updatedUser.copyWith(
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
        targetWater: targetWater,
      );

      await userRepository.updateUser(finalUser);
      _currentUser = finalUser;

      emit(AppAuthenticated(finalUser));
    } catch (e) {
      emit(AppError('Không thể cập nhật hồ sơ: $e'));
    }
  }
}
