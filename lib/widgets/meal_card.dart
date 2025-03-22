import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../models/meal_entry.dart';
import '../screens/meals/meal_details_screen.dart';

class MealCard extends StatelessWidget {
  final MealEntry mealEntry;
  final VoidCallback? onDelete;

  const MealCard({
    Key? key,
    required this.mealEntry,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealDetailsScreen(mealEntry: mealEntry),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Food icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getMealTypeColor(mealEntry.mealType).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getMealTypeIcon(mealEntry.mealType),
                  color: _getMealTypeColor(mealEntry.mealType),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealEntry.foodItem?.name ?? 'Unknown Food',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${mealEntry.amount.toStringAsFixed(0)}${mealEntry.foodItem?.servingUnit ?? 'g'}',
                      style: const TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Calories and delete button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${mealEntry.nutritionData?.calories.toStringAsFixed(0) ?? '0'} kcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (onDelete != null)
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppTheme.errorColor,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMealTypeColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return AppTheme.primaryColor;
      case MealType.dinner:
        return Colors.purple;
      case MealType.snack:
        return AppTheme.secondaryColor;
    }
  }

  IconData _getMealTypeIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.breakfast_dining;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cake;
    }
  }
}
