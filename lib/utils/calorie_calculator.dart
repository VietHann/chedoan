class CalorieCalculator {
  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor equation
  double calculateBMR({
    required double weight, // in kg
    required double height, // in cm
    required int age,
    required String gender,
  }) {
    if (gender.toLowerCase() == 'male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  // Calculate total daily energy expenditure (TDEE)
  double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    // Activity level multipliers
    const Map<String, double> activityMultipliers = {
      'sedentary': 1.2, // Little or no exercise
      'light': 1.375, // Light exercise 1-3 days/week
      'moderate': 1.55, // Moderate exercise 3-5 days/week
      'active': 1.725, // Hard exercise 6-7 days/week
      'very_active': 1.9, // Very hard exercise & physical job or 2x training
    };

    // Default to sedentary if activity level is not recognized
    final multiplier = activityMultipliers[activityLevel.toLowerCase()] ?? 1.2;
    
    return bmr * multiplier;
  }

  // Calculate calorie needs based on goal
  int calculateCalorieNeeds({
    required double weight, // in kg
    required double height, // in cm
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    // Calculate BMR
    final bmr = calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
    );

    // Calculate TDEE
    final tdee = calculateTDEE(
      bmr: bmr,
      activityLevel: activityLevel,
    );

    // Adjust based on goal
    switch (goal.toLowerCase()) {
      case 'lose_weight':
        // 500 calorie deficit for ~1 lb per week weight loss
        return (tdee - 500).round();
      case 'gain_weight':
        // 500 calorie surplus for ~1 lb per week weight gain
        return (tdee + 500).round();
      case 'maintain':
      default:
        return tdee.round();
    }
  }

  // Calculate macronutrient distribution
  MacroDistribution calculateMacronutrients({
    required int calories,
    required String goal,
  }) {
    // Default macronutrient ratios based on goal
    double proteinRatio, carbsRatio, fatRatio;

    switch (goal.toLowerCase()) {
      case 'lose_weight':
        // Higher protein for satiety and muscle preservation during deficit
        proteinRatio = 0.35; // 35% of calories from protein
        carbsRatio = 0.40; // 40% of calories from carbs
        fatRatio = 0.25; // 25% of calories from fat
        break;
      case 'gain_weight':
        // Higher carbs for surplus energy and muscle building
        proteinRatio = 0.25; // 25% of calories from protein
        carbsRatio = 0.50; // 50% of calories from carbs
        fatRatio = 0.25; // 25% of calories from fat
        break;
      case 'maintain':
      default:
        // Balanced macros for maintenance
        proteinRatio = 0.30; // 30% of calories from protein
        carbsRatio = 0.45; // 45% of calories from carbs
        fatRatio = 0.25; // 25% of calories from fat
        break;
    }

    // Calculate grams for each macronutrient
    // Protein: 4 calories per gram
    // Carbs: 4 calories per gram
    // Fat: 9 calories per gram
    final proteinCalories = calories * proteinRatio;
    final carbsCalories = calories * carbsRatio;
    final fatCalories = calories * fatRatio;

    final proteinGrams = proteinCalories / 4;
    final carbsGrams = carbsCalories / 4;
    final fatGrams = fatCalories / 9;

    return MacroDistribution(
      protein: proteinGrams,
      carbs: carbsGrams,
      fat: fatGrams,
    );
  }
}

class MacroDistribution {
  final double protein;
  final double carbs;
  final double fat;

  MacroDistribution({
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
