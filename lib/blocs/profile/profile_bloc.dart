import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_profile.dart';
import '../../repositories/user_repository.dart';
import '../../utils/bmi_calculator.dart';
import '../../utils/calorie_calculator.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({required this.userRepository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await userRepository.getUserByEmail(event.email);
      if (user != null) {
        emit(ProfileLoaded(profile: user));
      } else {
        emit(ProfileError(message: 'Không tìm thấy người dùng'));
      }
    } catch (e) {
      emit(ProfileError(message: 'Không thể tải hồ sơ: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // Get current user
      final currentUser = await userRepository.getUserByEmail(event.email);
      if (currentUser == null) {
        emit(ProfileError(message: 'Không tìm thấy người dùng'));
        return;
      }

      // Create updated user with new values
      final updatedProfile = currentUser.copyWith(
        name: event.name ?? currentUser.name,
        age: event.age ?? currentUser.age,
        gender: event.gender ?? currentUser.gender,
        height: event.height ?? currentUser.height,
        weight: event.weight ?? currentUser.weight,
        goal: event.goal ?? currentUser.goal,
        activityLevel: event.activityLevel ?? currentUser.activityLevel,
      );

      // Calculate BMI and calorie needs if we have enough information
      if (updatedProfile.height != null &&
          updatedProfile.weight != null &&
          updatedProfile.age != null &&
          updatedProfile.gender != null &&
          updatedProfile.activityLevel != null &&
          updatedProfile.goal != null) {
        // Calculate calorie needs
        final calorieCalculator = CalorieCalculator();
        final calorieNeeds = calorieCalculator.calculateCalorieNeeds(
          weight: updatedProfile.weight!,
          height: updatedProfile.height!,
          age: updatedProfile.age!,
          gender: updatedProfile.gender!,
          activityLevel: updatedProfile.activityLevel!,
          goal: updatedProfile.goal!,
        );

        // Calculate macronutrient distribution
        final macros = calorieCalculator.calculateMacronutrients(
          calories: calorieNeeds,
          goal: updatedProfile.goal!,
        );

        // Update profile with calculated values
        final finalProfile = updatedProfile.copyWith(
          targetCalories: calorieNeeds.round(),
          targetProtein: macros.protein,
          targetCarbs: macros.carbs,
          targetFat: macros.fat,
          targetWater: (updatedProfile.weight! * 30)
              .round(), // 30ml per kg of body weight
        );

        await userRepository.updateUser(finalProfile);
        emit(ProfileLoaded(profile: finalProfile));
      } else {
        // Just update the profile without calculating nutrition targets
        await userRepository.updateUser(updatedProfile);
        emit(ProfileLoaded(profile: updatedProfile));
      }
    } catch (e) {
      emit(ProfileError(message: 'Không thể cập nhật hồ sơ: $e'));
    }
  }
}
