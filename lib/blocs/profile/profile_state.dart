import '../../models/user_profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  ProfileLoaded({required this.profile});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}
