import 'food_item.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealEntry {
  final String? id;
  final DateTime date;
  final MealType mealType;
  final String foodItemId;
  final FoodItem? foodItem;
  final double amount;  // Amount in grams
  
  MealEntry({
    this.id,
    required this.date,
    required this.mealType,
    required this.foodItemId,
    this.foodItem,
    required this.amount,
  });

  String get mealTypeString {
    switch (mealType) {
      case MealType.breakfast: return 'Bữa sáng';
      case MealType.lunch: return 'Bữa trưa';
      case MealType.dinner: return 'Bữa tối';
      case MealType.snack: return 'Bữa phụ';
    }
  }
  
  // Calculated nutrition values
  double get calories => foodItem?.getCalories(amount) ?? 0;
  double get protein => foodItem?.getProtein(amount) ?? 0;
  double get carbs => foodItem?.getCarbs(amount) ?? 0;
  double get fat => foodItem?.getFat(amount) ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'mealType': mealType.index,
      'foodItemId': foodItemId,
      'amount': amount,
    };
  }

  factory MealEntry.fromMap(Map<String, dynamic> map, {FoodItem? foodItem}) {
    DateTime parsedDate;
    if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      parsedDate = DateTime.now();
    }

    return MealEntry(
      id: map['id'],
      date: parsedDate,
      mealType: MealType.values[map['mealType'] ?? 0],
      foodItemId: map['foodItemId'] ?? '',
      foodItem: foodItem,
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }

  MealEntry copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    String? foodItemId,
    FoodItem? foodItem,
    double? amount,
  }) {
    return MealEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodItemId: foodItemId ?? this.foodItemId,
      foodItem: foodItem ?? this.foodItem,
      amount: amount ?? this.amount,
    );
  }
}