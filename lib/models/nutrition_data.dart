class NutritionData {
  final double calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final double? fiber; // in grams
  final double? sugar; // in grams

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
  });

  // Add two nutrition data objects
  NutritionData operator +(NutritionData other) {
    return NutritionData(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: (fiber ?? 0) + (other.fiber ?? 0),
      sugar: (sugar ?? 0) + (other.sugar ?? 0),
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
    };
  }

  // Create from map
  factory NutritionData.fromMap(Map<String, dynamic> map) {
    return NutritionData(
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      fiber: map['fiber'],
      sugar: map['sugar'],
    );
  }

  // Create an empty nutrition data object
  factory NutritionData.empty() {
    return NutritionData(
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      sugar: 0,
    );
  }
}
