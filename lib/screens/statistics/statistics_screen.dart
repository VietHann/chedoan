import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../blocs/authentication/auth_bloc.dart';
import '../../blocs/authentication/auth_state.dart';
import '../../blocs/nutrition/nutrition_bloc.dart';
import '../../blocs/nutrition/nutrition_event.dart';
import '../../blocs/nutrition/nutrition_state.dart';
import '../../widgets/calorie_chart.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_navigation.dart';
import '../../widgets/nutrient_distribution_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final int _selectedIndex = 1; // Statistics tab
  
  @override
  void initState() {
    super.initState();
    _loadWeeklyStats();
  }
  
  void _loadWeeklyStats() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<NutritionBloc>().add(
        LoadWeeklyStats(
          email: authState.user.email,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Statistics',
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
                } else if (state is WeeklyStatsLoaded) {
                  return _buildStatisticsContent(state);
                } else if (state is NutritionError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                } else {
                  return const Center(
                    child: Text('No statistics available'),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: Text('Please log in to view your statistics'),
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          if (index != _selectedIndex) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
  
  Widget _buildStatisticsContent(WeeklyStatsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadWeeklyStats();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Overview Title
            Text(
              'Weekly Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            
            Text(
              DateFormat.yMMMd().format(state.dates.first) + 
              ' - ' + 
              DateFormat.yMMMd().format(state.dates.last),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 16),
            
            // Calorie Chart
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calorie Intake',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    SizedBox(
                      height: 200,
                      child: CalorieChart(
                        calories: state.dailyCalories,
                        dates: state.dates,
                        targetCalories: state.targetCalories.toDouble(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildCalorieStats(state),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Macronutrient Distribution
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Macronutrient Distribution',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      height: 200,
                      child: NutrientDistributionChart(
                        protein: state.averageProtein,
                        carbs: state.averageCarbs,
                        fat: state.averageFat,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildMacronutrientStats(state),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Water Intake
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Water Intake',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildWaterStats(state),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCalorieStats(WeeklyStatsLoaded state) {
    // Count days where calories were within target range
    int daysOnTarget = 0;
    for (final dailyCalories in state.dailyCalories) {
      if (dailyCalories >= state.targetCalories * 0.9 && 
          dailyCalories <= state.targetCalories * 1.1) {
        daysOnTarget++;
      }
    }
    
    // Calculate average calories
    final avgCalories = state.averageCalories.round();
    final percentOfTarget = (state.averageCalories / state.targetCalories * 100).round();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              label: 'Average Calories',
              value: '$avgCalories',
              unit: 'kcal',
            ),
            _buildStatItem(
              label: 'Target Calories',
              value: '${state.targetCalories}',
              unit: 'kcal',
            ),
            _buildStatItem(
              label: 'Days on Target',
              value: '$daysOnTarget',
              unit: '/ 7',
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Progress bar showing average vs target
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$percentOfTarget% of target', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (state.averageCalories / state.targetCalories).clamp(0.0, 2.0) / 2,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getCalorieColor(state.averageCalories.toDouble(), state.targetCalories.toDouble())),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMacronutrientStats(WeeklyStatsLoaded state) {
    // Calculate percentages
    final totalGrams = state.averageProtein + state.averageCarbs + state.averageFat;
    final proteinPercent = totalGrams > 0 ? (state.averageProtein / totalGrams * 100).round() : 0;
    final carbsPercent = totalGrams > 0 ? (state.averageCarbs / totalGrams * 100).round() : 0;
    final fatPercent = totalGrams > 0 ? (state.averageFat / totalGrams * 100).round() : 0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNutrientStatItem(
              label: 'Protein',
              value: '${state.averageProtein.toStringAsFixed(1)}g',
              percent: '$proteinPercent%',
              color: AppTheme.secondaryColor,
            ),
            _buildNutrientStatItem(
              label: 'Carbs',
              value: '${state.averageCarbs.toStringAsFixed(1)}g',
              percent: '$carbsPercent%',
              color: AppTheme.accentColor,
            ),
            _buildNutrientStatItem(
              label: 'Fat',
              value: '${state.averageFat.toStringAsFixed(1)}g',
              percent: '$fatPercent%',
              color: Colors.purpleAccent,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Compare with targets
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Protein Target'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (state.averageProtein / state.targetProtein).clamp(0.0, 1.5),
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(state.averageProtein / state.targetProtein * 100).round()}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Carbs Target'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (state.averageCarbs / state.targetCarbs).clamp(0.0, 1.5),
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(state.averageCarbs / state.targetCarbs * 100).round()}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fat Target'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (state.averageFat / state.targetFat).clamp(0.0, 1.5),
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(state.averageFat / state.targetFat * 100).round()}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildWaterStats(WeeklyStatsLoaded state) {
    // Count days where water intake met target
    int daysMetTarget = 0;
    for (final dailyWater in state.dailyWaterIntake) {
      if (dailyWater >= state.targetWaterIntake) {
        daysMetTarget++;
      }
    }
    
    // Calculate average water intake in liters
    final avgWaterMl = state.averageWaterIntake.round();
    final avgWaterL = (avgWaterMl / 1000).toStringAsFixed(1);
    final percentOfTarget = (avgWaterMl / state.targetWaterIntake * 100).round();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              label: 'Average Intake',
              value: avgWaterL,
              unit: 'L',
              color: Colors.blue,
            ),
            _buildStatItem(
              label: 'Target Intake',
              value: (state.targetWaterIntake / 1000).toStringAsFixed(1),
              unit: 'L',
              color: Colors.blue,
            ),
            _buildStatItem(
              label: 'Days Target Met',
              value: '$daysMetTarget',
              unit: '/ 7',
              color: Colors.blue,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Progress bar showing average vs target
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$percentOfTarget% of target', 
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (avgWaterMl / state.targetWaterIntake).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
        
        // Water intake history visualization
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            children: List.generate(state.dailyWaterIntake.length, (index) {
              final date = state.dates[index];
              final waterIntake = state.dailyWaterIntake[index];
              final percentOfDailyTarget = (waterIntake / state.targetWaterIntake).clamp(0.0, 1.0);
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              heightFactor: percentOfDailyTarget,
                              widthFactor: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.E().format(date).substring(0, 1),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatItem({
    required String label,
    required String value,
    required String unit,
    Color color = AppTheme.primaryColor,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildNutrientStatItem({
    required String label,
    required String value,
    required String percent,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  percent,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }
  
  Color _getCalorieColor(double average, double target) {
    final ratio = average / target;
    
    if (ratio < 0.8) {
      return Colors.blue; // Too low
    } else if (ratio >= 0.8 && ratio <= 1.2) {
      return AppTheme.secondaryColor; // Good range
    } else {
      return AppTheme.errorColor; // Too high
    }
  }
}
