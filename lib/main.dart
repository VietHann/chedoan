import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';
import 'blocs/app_bloc.dart';
import 'blocs/app_event.dart';
import 'blocs/app_state.dart';
import 'repositories/user_repository.dart';
import 'repositories/food_repository.dart';
import 'repositories/nutrition_repository.dart';
import 'services/firebase_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize services and repositories
  final firebaseService = FirebaseService();
  await firebaseService.addSampleFoodItems();

  final sharedPreferences = await SharedPreferences.getInstance();
  final userRepository = UserRepository(firebaseService);
  final foodRepository = FoodRepository(firebaseService);
  final nutritionRepository = NutritionRepository(firebaseService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: foodRepository),
        RepositoryProvider.value(value: nutritionRepository),
      ],
      child: BlocProvider(
        create: (context) => AppBloc(
          userRepository: userRepository,
          nutritionRepository: nutritionRepository,
          sharedPreferences: sharedPreferences,
        )..add(AppStarted()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrition Tracker',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
      ],
      locale: const Locale('vi', 'VN'),
      home: BlocConsumer<AppBloc, AppState>(
        listener: (context, state) {
          if (state is AppUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          } else if (state is AppDailyNutritionLoaded) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AppLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is AppUnauthenticated) {
            return const LoginScreen();
          }
          if (state is AppDailyNutritionLoaded) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
