import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../blocs/authentication/auth_bloc.dart';
import '../../blocs/authentication/auth_state.dart';
import '../../blocs/nutrition/nutrition_bloc.dart';
import '../../blocs/nutrition/nutrition_event.dart';
import '../../models/meal_entry.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/nutrient_distribution_chart.dart';

class MealDetailsScreen extends StatelessWidget {
  final MealEntry mealEntry;

  const MealDetailsScreen({
    Key? key,
    required this.mealEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Chi tiết bữa ăn',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic meal information card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Food icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Food info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mealEntry.foodItem?.name ??
                                    'Thực phẩm không xác định',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (mealEntry.foodItem?.brand != null)
                                Text(
                                  mealEntry.foodItem!.brand!,
                                  style: const TextStyle(
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '${mealEntry.amount.toStringAsFixed(0)}${mealEntry.foodItem?.servingUnit ?? 'g'} - ${mealEntry.mealTypeString}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                DateFormat.yMMMd().format(mealEntry.date),
                                style: const TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // Calorie information
                    if (mealEntry.nutritionData != null) ...[
                      Text(
                        'Calo: ${mealEntry.nutritionData!.calories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Nutrition information
            if (mealEntry.nutritionData != null) ...[
              Text(
                'Thông tin dinh dưỡng',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Display protein, carbs, fat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNutrientColumn(
                            'Đạm',
                            mealEntry.nutritionData!.protein.toStringAsFixed(1),
                            'g',
                            AppTheme.secondaryColor,
                          ),
                          _buildNutrientColumn(
                            'Tinh bột',
                            mealEntry.nutritionData!.carbs.toStringAsFixed(1),
                            'g',
                            AppTheme.accentColor,
                          ),
                          _buildNutrientColumn(
                            'Chất béo',
                            mealEntry.nutritionData!.fat.toStringAsFixed(1),
                            'g',
                            Colors.purpleAccent,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Macronutrient distribution chart
                      SizedBox(
                        height: 200,
                        child: NutrientDistributionChart(
                          protein: mealEntry.nutritionData!.protein,
                          carbs: mealEntry.nutritionData!.carbs,
                          fat: mealEntry.nutritionData!.fat,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Additional nutrition info
                      if (mealEntry.nutritionData!.fiber != null ||
                          mealEntry.nutritionData!.sugar != null) ...[
                        const Divider(),
                        const SizedBox(height: 8),

                        // Additional nutrients
                        Column(
                          children: [
                            if (mealEntry.nutritionData!.fiber != null)
                              _buildNutrientRow(
                                'Chất xơ',
                                '${mealEntry.nutritionData!.fiber!.toStringAsFixed(1)}g',
                              ),
                            if (mealEntry.nutritionData!.sugar != null)
                              _buildNutrientRow(
                                'Đường',
                                '${mealEntry.nutritionData!.sugar!.toStringAsFixed(1)}g',
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientColumn(
      String label, String value, String unit, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteMeal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Hàm này cần được sửa trong file meal_details_screen.dart
  // Thay thế hàm _deleteMeal hiện tại với hàm này

  void _deleteMeal(BuildContext context) {
    if (mealEntry.id == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      // Delete meal entry
      context.read<NutritionBloc>().add(
            DeleteMealEntry(
              email: authState.user.email,
              mealEntryId: mealEntry.id!, // String now, not int
              date: mealEntry.date,
            ),
          );

      // Navigate back twice (details screen and the screen that launched it)
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }
}
