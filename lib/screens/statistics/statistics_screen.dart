import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../blocs/app_bloc.dart';
import '../../blocs/app_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_navigation.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final int _selectedIndex = 1; // Statistics tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Thống kê',
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AppLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AppDailyNutritionLoaded) {
            return _buildStatisticsContent(state);
          } else {
            return const Center(
              child: Text('Vui lòng đăng nhập để xem thống kê của bạn'),
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

  Widget _buildStatisticsContent(AppDailyNutritionLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calories Card
          _buildStatCard(
            title: 'Calories',
            value: state.totalCalories.toStringAsFixed(0),
            unit: 'kcal',
            target: state.user.targetCalories?.toDouble() ?? 2000,
            current: state.totalCalories,
            color: AppTheme.primaryColor,
          ),

          const SizedBox(height: 20),

          // Macronutrients Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phân bố dinh dưỡng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMacroItem(
                    label: 'Protein',
                    value: state.totalProtein,
                    target: state.user.targetProtein ?? 50,
                    color: AppTheme.secondaryColor,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildMacroItem(
                    label: 'Carbs', 
                    value: state.totalCarbs,
                    target: state.user.targetCarbs ?? 250,
                    color: AppTheme.accentColor,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildMacroItem(
                    label: 'Fat',
                    value: state.totalFat,
                    target: state.user.targetFat ?? 70,
                    color: Colors.purpleAccent,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Water Intake Card
          _buildStatCard(
            title: 'Lượng nước uống',
            value: (state.waterIntake / 1000).toStringAsFixed(1),
            unit: 'L',
            target: state.targetWaterIntake.toDouble(),
            current: state.waterIntake.toDouble(),
            color: Colors.blue,
          ),

          const SizedBox(height: 20),
          
          // Weekly overview
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng quan tuần',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Simple weekly bars
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        // Random values for demo
                        double height = 0.3 + (index * 0.1);
                        if (height > 1) height = 0.8;
                        
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 100 * height,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][index],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required double target,
    required double current,
    required Color color,
  }) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(
                          fontSize: 14,
                          color: color.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage% của mục tiêu',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem({
    required String label,
    required double value,
    required double target,
    required Color color,
  }) {
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                Text(label),
              ],
            ),
            Text(
              '${value.toStringAsFixed(1)}/${target.toInt()}g',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}