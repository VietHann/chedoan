import 'food_item.dart';
import 'nutrition_data.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealEntry {
  final String? id;
  final DateTime date;
  final MealType mealType;
  final String foodItemId;
  final FoodItem? foodItem; // Will be null when storing in DB but populated when fetching
  final double amount; // Amount in grams
  final NutritionData? nutritionData; // Calculated based on food item and amount

  MealEntry({
    this.id,
    required this.date,
    required this.mealType,
    required this.foodItemId,
    this.foodItem,
    required this.amount,
    this.nutritionData,
  });

  // Helper to get meal type as string
  String get mealTypeString {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  // Calculate nutrition data based on food item and amount
  NutritionData calculateNutritionData() {
    if (foodItem == null) {
      return NutritionData(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
      );
    }

    return NutritionData(
      calories: foodItem!.getCalories(amount),
      protein: foodItem!.getProtein(amount),
      carbs: foodItem!.getCarbs(amount),
      fat: foodItem!.getFat(amount),
      fiber: foodItem!.getFiber(amount),
      sugar: foodItem!.getSugar(amount),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // Store just the date
      'meal_type': mealType.index,
      'food_item_id': foodItemId,
      'amount': amount,
    };
  }

  factory MealEntry.fromMap(Map<String, dynamic> map, {FoodItem? foodItem}) {
    // Parse date from string or from timestamp
    DateTime parsedDate;
    if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      // Handle Firebase timestamp or other date format
      parsedDate = DateTime.now(); // Default to today if cannot parse
    }

    final mealEntry = MealEntry(
      id: map['id'],
      date: parsedDate,
      mealType: MealType.values[map['meal_type'] ?? 0],
      foodItemId: map['food_item_id'] ?? '',
      foodItem: foodItem,
      amount: (map['amount'] ?? 0).toDouble(),
    );

    // If we have the food item, calculate nutrition data
    if (foodItem != null) {
      return mealEntry.copyWith(
        nutritionData: mealEntry.calculateNutritionData(),
      );
    }

    return mealEntry;
  }

  MealEntry copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    String? foodItemId,
    FoodItem? foodItem,
    double? amount,
    NutritionData? nutritionData,
  }) {
    return MealEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodItemId: foodItemId ?? this.foodItemId,
      foodItem: foodItem ?? this.foodItem,
      amount: amount ?? this.amount,
      nutritionData: nutritionData ?? this.nutritionData,
    );
  }
}