import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../blocs/authentication/auth_bloc.dart';
import '../../blocs/authentication/auth_state.dart';
import '../../blocs/nutrition/nutrition_bloc.dart';
import '../../blocs/nutrition/nutrition_event.dart';
import '../../blocs/nutrition/nutrition_state.dart';
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
import '../water/water_tracking_screen.dart';
import '../../widgets/nutrient_distribution_chart.dart';

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
    _loadNutritionData();
  }

  void _loadNutritionData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<NutritionBloc>().add(LoadDailyNutrition(
            email: authState.user.email,
            date: _selectedDate,
          ));
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
                MaterialPageRoute(
                    builder: (context) => const StatisticsScreen()))
            .then((_) => setState(() => _selectedIndex = 0));
        break;
      case 2: // Profile
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()))
            .then((_) => setState(() => _selectedIndex = 0));
        break;
      default:
        setState(() {
          _selectedIndex = index;
        });
        break;
    }
  }

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadNutritionData();
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
    ).then((_) => _loadNutritionData());
  }

  void _navigateToWaterTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterTrackingScreen(
          initialDate: _selectedDate,
        ),
      ),
    ).then((_) => _loadNutritionData());
  }

  void _addWater(int amount) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final waterIntake = WaterIntake(
        date: _selectedDate,
        amount: amount,
      );

      context.read<NutritionBloc>().add(AddWaterIntake(
            email: authState.user.email,
            waterIntake: waterIntake,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: CustomAppBar(
          title: 'Bảng điều khiển',
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context),
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocBuilder<NutritionBloc, NutritionState>(
                builder: (context, state) {
                  if (state is NutritionLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is DailyNutritionLoaded) {
                    return _buildDashboard(state);
                  } else if (state is NutritionError) {
                    return Center(
                      child: Text('Lỗi: ${state.message}'),
                    );
                  } else {
                    return const Center(
                      child: Text('Không có dữ liệu dinh dưỡng'),
                    );
                  }
                },
              );
            } else {
              return const Center(
                child: Text(
                    'Vui lòng đăng nhập để xem dữ liệu dinh dưỡng của bạn'),
              );
            }
          },
        ),
        bottomNavigationBar: CustomBottomNavigation(
          selectedIndex: _selectedIndex,
          onItemTapped: _onNavigationItemTapped,
        ),
      ),
    );
  }

  Widget _buildDashboard(DailyNutritionLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadNutritionData();
      },
      child: ListView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).padding.bottom + 80.0,
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
                Text(
                  DateFormat.yMMMd().format(_selectedDate),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeDate(
                    _selectedDate.add(const Duration(days: 1)),
                  ),
                ),
              ],
            ),
          ),

          // Calorie Progress Card
          NutritionProgressCard(
            title: 'Calo',
            current: state.totalCalories.toInt(),
            target: state.targetCalories,
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
                  current: state.totalProtein.toInt(),
                  target: state.targetProtein.toInt(),
                  progressColor: AppTheme.secondaryColor,
                  unit: 'g',
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NutritionProgressCard(
                  title: 'Tinh bột',
                  current: state.totalCarbs.toInt(),
                  target: state.targetCarbs.toInt(),
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
            current: state.totalFat.toInt(),
            target: state.targetFat.toInt(),
            progressColor: Colors.purpleAccent,
            unit: 'g',
          ),

          const SizedBox(height: 24),

          // Water Tracker
          WaterTracker(
            currentIntake: state.waterIntake,
            targetIntake: state.targetWaterIntake,
            onAddWater: _addWater,
            onTap: _navigateToWaterTracking,
          ),

          const SizedBox(height: 24),

          // Meals Section
          Column(
            children: [
              _buildMealSection(
                'Breakfast',
                MealType.breakfast,
                state.getMealsByType(MealType.breakfast),
              ),
              _buildMealSection(
                'Lunch',
                MealType.lunch,
                state.getMealsByType(MealType.lunch),
              ),
              _buildMealSection(
                'Dinner',
                MealType.dinner,
                state.getMealsByType(MealType.dinner),
              ),
              _buildMealSection(
                'Snacks',
                MealType.snack,
                state.getMealsByType(MealType.snack),
              ),
            ],
          ),

          const SizedBox(height: 80),
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
                style: Theme.of(context).textTheme.titleLarge,
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
                'No $title logged yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...meals.map((meal) => MealCard(
                mealEntry: meal,
                onDelete: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is Authenticated && meal.id != null) {
                    context.read<NutritionBloc>().add(DeleteMealEntry(
                          email: authState.user.email,
                          mealEntryId: meal.id!, // String now, not int
                          date: _selectedDate,
                        ));
                  }
                },
              )),
        const Divider(),
      ],
    );
  }

  Widget _buildNutrientInfo(
      String title, int current, int target, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$current/$target g',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _changeDate(picked);
    }
  }
}
