class BMICalculator {
  // Calculate BMI: weight (kg) / (height (m))^2
  static double calculateBMI(double weightKg, double heightCm) {
    // Convert height from cm to m
    final heightM = heightCm / 100;
    
    // Calculate BMI
    return weightKg / (heightM * heightM);
  }

  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Get recommended weight range based on height
  static Map<String, double> getRecommendedWeightRange(double heightCm) {
    // Convert height from cm to m
    final heightM = heightCm / 100;
    
    // Calculate weight range for normal BMI (18.5 - 24.9)
    final minWeight = 18.5 * (heightM * heightM);
    final maxWeight = 24.9 * (heightM * heightM);
    
    return {
      'min': minWeight,
      'max': maxWeight,
    };
  }

  // Get health feedback based on BMI
  static String getHealthFeedback(double bmi) {
    if (bmi < 18.5) {
      return 'You are underweight. Consider adding more nutrient-dense foods to your diet.';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'You have a healthy weight. Maintain your balanced diet and regular physical activity.';
    } else if (bmi >= 25 && bmi < 30) {
      return 'You are overweight. Consider increasing physical activity and monitoring your calorie intake.';
    } else {
      return 'You are in the obese category. Consider consulting a healthcare professional for a weight management plan.';
    }
  }
}
