class FoodItem {
  final String? id;
  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final bool isFavorite;

  FoodItem({
    this.id,
    required this.name,
    this.brand,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.isFavorite = false,
  });

  double getCalories(double amount) => caloriesPer100g * amount / 100;
  double getProtein(double amount) => proteinPer100g * amount / 100;
  double getCarbs(double amount) => carbsPer100g * amount / 100;
  double getFat(double amount) => fatPer100g * amount / 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'isFavorite': isFavorite,
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
      isFavorite: map['isFavorite'] ?? false,
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
    bool? isFavorite,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}