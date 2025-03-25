import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../blocs/app_bloc.dart';
import '../../blocs/app_event.dart';
import '../../blocs/app_state.dart';
import '../../models/meal_entry.dart';
import '../../models/water_intake.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_navigation.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/nutrition_progress_card.dart';
import '../../widgets/water_tracker.dart';
import '../meals/add_meal_screen.dart';
import '../profile/profile_screen.dart';
import '../statistics/statistics_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData(_selectedDate);
  }

  void _loadData(DateTime date) {
    context.read<AppBloc>().add(LoadDailyNutrition(date));
  }

  void _changeDate(DateTime newDate) {
    if (_selectedDate != newDate) {
      setState(() {
        _selectedDate = newDate;
      });
      _loadData(newDate);
    }
  }

  void _onNavigationItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0: // Home - already on this screen
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 1: // Statistics
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatisticsScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
      case 2: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
    }
  }

  void _navigateToAddMeal(MealType mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealScreen(
          initialDate: _selectedDate,
          initialMealType: mealType,
        ),
      ),
    ).then((_) => _loadData(_selectedDate));
  }

  void _addWater(int amount) {
    final waterIntake = WaterIntake(
      date: _selectedDate,
      amount: amount,
    );

    context.read<AppBloc>().add(AddWaterIntake(waterIntake));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: const CustomAppBar(
            title: 'Theo dõi dinh dưỡng',
          ),
          body: _buildBody(state),
          bottomNavigationBar: CustomBottomNavigation(
            selectedIndex: _selectedIndex,
            onItemTapped: _onNavigationItemTapped,
          ),
        );
      },
    );
  }

  Widget _buildBody(AppState state) {
    if (state is AppLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AppDailyNutritionLoaded) {
      return _buildDashboard(state);
    }

    return const Center(child: Text('Đang tải dữ liệu...'));
  }

  Widget _buildDashboard(AppDailyNutritionLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AppBloc>().add(LoadDailyNutrition(_selectedDate));
      },
      child: ListView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
        ),
        children: [
          // Date Display
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeDate(
                    _selectedDate.subtract(const Duration(days: 1)),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      locale: const Locale('vi', 'VN'),
                    );
                    if (picked != null) {
                      _changeDate(DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                      ));
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.yMMMd('vi').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _selectedDate.isBefore(
                          DateTime.now().subtract(const Duration(days: 1)))
                      ? () => _changeDate(
                            _selectedDate.add(const Duration(days: 1)),
                          )
                      : null,
                ),
              ],
            ),
          ),

          // Calorie Progress Card
          NutritionProgressCard(
            title: 'Calo',
            current: state.totalCalories,
            target: state.user.targetCalories?.toDouble() ?? 2000,
            progressColor: AppTheme.primaryColor,
            unit: 'kcal',
          ),

          const SizedBox(height: 8),

          // Protein and Carbs row
          Row(
            children: [
              Expanded(
                child: NutritionProgressCard(
                  title: 'Đạm',
                  current: state.totalProtein,
                  target: state.user.targetProtein ?? 50,
                  progressColor: AppTheme.secondaryColor,
                  unit: 'g',
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NutritionProgressCard(
                  title: 'Tinh bột',
                  current: state.totalCarbs,
                  target: state.user.targetCarbs ?? 250,
                  progressColor: AppTheme.accentColor,
                  unit: 'g',
                  isCompact: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Fat card
          NutritionProgressCard(
            title: 'Chất béo',
            current: state.totalFat,
            target: state.user.targetFat ?? 70,
            progressColor: Colors.purpleAccent,
            unit: 'g',
          ),

          const SizedBox(height: 24),

          // Water Tracker
          WaterTracker(
            currentIntake: state.waterIntake,
            targetIntake: state.targetWaterIntake,
            onAddWater: _addWater,
          ),

          const SizedBox(height: 24),

          // Meals Section
          Column(
            children: [
              _buildMealSection(
                'Bữa sáng',
                MealType.breakfast,
                state.getMealsByType(MealType.breakfast),
              ),
              _buildMealSection(
                'Bữa trưa',
                MealType.lunch,
                state.getMealsByType(MealType.lunch),
              ),
              _buildMealSection(
                'Bữa tối',
                MealType.dinner,
                state.getMealsByType(MealType.dinner),
              ),
              _buildMealSection(
                'Bữa phụ',
                MealType.snack,
                state.getMealsByType(MealType.snack),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(
      String title, MealType mealType, List<MealEntry> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppTheme.primaryColor,
                onPressed: () => _navigateToAddMeal(mealType),
              ),
            ],
          ),
        ),
        if (meals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                'Chưa có $title nào',
                style: const TextStyle(color: AppTheme.secondaryTextColor),
              ),
            ),
          )
        else
          ...meals.map((meal) => MealCard(
                mealEntry: meal,
                onDelete: () {
                  if (meal.id != null) {
                    context.read<AppBloc>().add(DeleteMealEntry(
                          mealEntryId: meal.id!,
                          date: _selectedDate,
                        ));
                  }
                },
              )),
        const Divider(),
      ],
    );
  }
}
