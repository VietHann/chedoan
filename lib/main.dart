import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app_theme.dart';
import 'blocs/authentication/auth_bloc.dart';
import 'blocs/authentication/auth_event.dart';
import 'blocs/authentication/auth_state.dart';
import 'blocs/nutrition/nutrition_bloc.dart';
import 'blocs/profile/profile_bloc.dart';
import 'repositories/food_repository.dart';
import 'repositories/meal_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/water_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Firebase service
  final FirebaseService firebaseService = FirebaseService();

  // Initialize sample food data
  await firebaseService.addSampleFoodItems();

  // Initialize repositories
  final userRepository = UserRepository(firebaseService);
  final foodRepository = FoodRepository(firebaseService);
  final mealRepository = MealRepository(firebaseService);
  final waterRepository = WaterRepository(firebaseService);

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<UserRepository>(create: (_) => userRepository),
        Provider<FoodRepository>(create: (_) => foodRepository),
        Provider<MealRepository>(create: (_) => mealRepository),
        Provider<WaterRepository>(create: (_) => waterRepository),
        Provider<SharedPreferences>(create: (_) => sharedPreferences),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              userRepository: context.read<UserRepository>(),
              sharedPreferences: sharedPreferences,
            )..add(CheckLoginStatus()),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              userRepository: context.read<UserRepository>(),
            ),
          ),
          BlocProvider<NutritionBloc>(
            create: (context) => NutritionBloc(
              mealRepository: context.read<MealRepository>(),
              waterRepository: context.read<WaterRepository>(),
              userRepository: context.read<UserRepository>(),
            ),
          ),
        ],
        child: const NutritionTrackerApp(),
      ),
    ),
  );
}

class NutritionTrackerApp extends StatelessWidget {
  const NutritionTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theo dõi dinh dưỡng',
      theme: AppTheme.lightTheme,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial) {
            return const SplashScreen();
          }
          if (state is Authenticated) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
