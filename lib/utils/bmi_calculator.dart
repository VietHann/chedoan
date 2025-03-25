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
      return 'Thiếu cân';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Bình thường';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Thừa cân';
    } else {
      return 'Béo phì';
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
      return 'Bạn đang thiếu cân. Hãy cân nhắc thêm các thực phẩm giàu dinh dưỡng vào chế độ ăn của bạn.';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Bạn có cân nặng khỏe mạnh. Hãy duy trì chế độ ăn cân bằng và hoạt động thể chất thường xuyên.';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Bạn đang thừa cân. Hãy cân nhắc tăng cường hoạt động thể chất và theo dõi lượng calo nạp vào.';
    } else {
      return 'Bạn đang trong nhóm béo phì. Hãy cân nhắc tham khảo ý kiến chuyên gia y tế để có kế hoạch quản lý cân nặng phù hợp.';
    }
  }
}
