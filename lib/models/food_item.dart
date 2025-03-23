class FoodItem {
  final String? id;
  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double? fiberPer100g;
  final double? sugarPer100g;
  final String? servingUnit; // e.g., "g", "ml", "oz"
  final double? servingSize; // size in servingUnit
  final double? servingCalories; // calories per serving
  final bool isFavorite;
  final bool isCustom; // Whether this was added by the user or from API

  FoodItem({
    this.id,
    required this.name,
    this.brand,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    this.servingUnit,
    this.servingSize,
    this.servingCalories,
    this.isFavorite = false,
    this.isCustom = false,
  });

  // Calculate nutrition values for a given amount (in grams)
  double getCalories(double amount) => caloriesPer100g * amount / 100;
  double getProtein(double amount) => proteinPer100g * amount / 100;
  double getCarbs(double amount) => carbsPer100g * amount / 100;
  double getFat(double amount) => fatPer100g * amount / 100;
  double? getFiber(double amount) => fiberPer100g != null ? fiberPer100g! * amount / 100 : null;
  double? getSugar(double amount) => sugarPer100g != null ? sugarPer100g! * amount / 100 : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'fiberPer100g': fiberPer100g,
      'sugarPer100g': sugarPer100g,
      'servingUnit': servingUnit,
      'servingSize': servingSize,
      'servingCalories': servingCalories,
      'isFavorite': isFavorite,
      'isCustom': isCustom,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'] ?? '',
      brand: map['brand'],
      caloriesPer100g: (map['caloriesPer100g'] ?? 0.0).toDouble(),
      proteinPer100g: (map['proteinPer100g'] ?? 0.0).toDouble(),
      carbsPer100g: (map['carbsPer100g'] ?? 0.0).toDouble(),
      fatPer100g: (map['fatPer100g'] ?? 0.0).toDouble(),
      fiberPer100g: map['fiberPer100g'] != null ? (map['fiberPer100g']).toDouble() : null,
      sugarPer100g: map['sugarPer100g'] != null ? (map['sugarPer100g']).toDouble() : null,
      servingUnit: map['servingUnit'],
      servingSize: map['servingSize'] != null ? (map['servingSize']).toDouble() : null,
      servingCalories: map['servingCalories'] != null ? (map['servingCalories']).toDouble() : null,
      isFavorite: map['isFavorite'] ?? false,
      isCustom: map['isCustom'] ?? false,
    );
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? brand,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? fiberPer100g,
    double? sugarPer100g,
    String? servingUnit,
    double? servingSize,
    double? servingCalories,
    bool? isFavorite,
    bool? isCustom,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      fiberPer100g: fiberPer100g ?? this.fiberPer100g,
      sugarPer100g: sugarPer100g ?? this.sugarPer100g,
      servingUnit: servingUnit ?? this.servingUnit,
      servingSize: servingSize ?? this.servingSize,
      servingCalories: servingCalories ?? this.servingCalories,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}