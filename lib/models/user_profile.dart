class UserProfile {
  final String? id;
  final String email;
  final String? name;
  final int? age;
  final String? gender;
  final double? height;  // in cm
  final double? weight;  // in kg
  final String? goal;    // "lose_weight", "maintain", "gain_weight"
  final String? activityLevel;  // "sedentary", "light", "moderate", "active", "very_active"
  final int? targetCalories;
  final double? targetProtein;  // in grams
  final double? targetCarbs;    // in grams
  final double? targetFat;      // in grams
  final int? targetWater;       // in ml

  UserProfile({
    this.id,
    required this.email,
    this.name,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.goal,
    this.activityLevel,
    this.targetCalories,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
    this.targetWater,
  });

  bool get isProfileComplete {
    return name != null &&
        age != null &&
        gender != null &&
        height != null &&
        weight != null &&
        goal != null &&
        activityLevel != null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal': goal,
      'activityLevel': activityLevel,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
      'targetWater': targetWater,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      email: map['email'] ?? '',
      name: map['name'],
      age: map['age'] is int ? map['age'] : (map['age'] is double ? (map['age'] as double).toInt() : null),
      gender: map['gender'],
      height: map['height'] != null ? (map['height']).toDouble() : null,
      weight: map['weight'] != null ? (map['weight']).toDouble() : null,
      goal: map['goal'],
      activityLevel: map['activityLevel'],
      targetCalories: map['targetCalories'],
      targetProtein: map['targetProtein'] != null ? (map['targetProtein']).toDouble() : null,
      targetCarbs: map['targetCarbs'] != null ? (map['targetCarbs']).toDouble() : null,
      targetFat: map['targetFat'] != null ? (map['targetFat']).toDouble() : null,
      targetWater: map['targetWater'],
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? goal,
    String? activityLevel,
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    int? targetWater,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      targetWater: targetWater ?? this.targetWater,
    );
  }
}