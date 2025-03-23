import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../repositories/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;
  final SharedPreferences sharedPreferences;

  static const String kEmailKey = 'user_email';

  AuthBloc({
    required this.userRepository,
    required this.sharedPreferences,
  }) : super(AuthInitial()) {
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckLoginStatus(
    CheckLoginStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final email = sharedPreferences.getString(kEmailKey);
      if (email != null && email.isNotEmpty) {
        final user = await userRepository.getUserByEmail(email);
        if (user != null) {
          emit(Authenticated(user: user));
          return;
        }
      }
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Không thể kiểm tra trạng thái đăng nhập: $e'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Create user if not exists
      var user = await userRepository.getUserByEmail(event.email);

      if (user == null) {
        // In a real app, we would validate password here
        // For this MVP using Firebase, we'll create a new user
        user = await userRepository.createUser(
          email: event.email,
        );
      }

      // Save user email to preferences
      await sharedPreferences.setString(kEmailKey, event.email);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: 'Đăng nhập thất bại: $e'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Check if user already exists
      final existingUser = await userRepository.getUserByEmail(event.email);
      if (existingUser != null) {
        emit(AuthError(message: 'Người dùng đã tồn tại'));
        return;
      }

      // Create new user
      final user = await userRepository.createUser(
        email: event.email,
        name: event.name,
      );

      // Save user email to preferences
      await sharedPreferences.setString(kEmailKey, event.email);

      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: 'Đăng ký thất bại: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await sharedPreferences.remove(kEmailKey);
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Đăng xuất thất bại: $e'));
    }
  }
}
