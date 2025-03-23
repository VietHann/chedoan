import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Database references
  DatabaseReference get usersRef => _database.ref('users');
  DatabaseReference get foodItemsRef => _database.ref('food_items');
  DatabaseReference get mealEntriesRef => _database.ref('meal_entries');
  DatabaseReference get waterIntakesRef => _database.ref('water_intakes');

  // CRUD operations for Firebase Realtime Database
  Future<void> setData(DatabaseReference ref, Map<String, dynamic> data) async {
    await ref.set(data);
  }

  Future<String> pushData(
      DatabaseReference ref, Map<String, dynamic> data) async {
    final newRef = ref.push();
    await newRef.set(data);
    return newRef.key ?? '';
  }

  Future<DataSnapshot> getData(DatabaseReference ref) async {
    return await ref.get();
  }

  Future<void> updateData(
      DatabaseReference ref, Map<String, dynamic> data) async {
    await ref.update(data);
  }

  Future<void> deleteData(DatabaseReference ref) async {
    await ref.remove();
  }

  Future<DataSnapshot> getDataByValue(
    DatabaseReference ref,
    String child,
    dynamic value,
  ) async {
    return await ref.orderByChild(child).equalTo(value).get();
  }

  // Add sample food items
  Future<void> addSampleFoodItems() async {
    // Check if food items exist
    final foodsSnapshot = await foodItemsRef.limitToFirst(1).get();
    if (foodsSnapshot.exists) {
      return;
    }

    // Sample food data
    final List<Map<String, dynamic>> foods = [
      {
        'name': 'Apple',
        'brand': 'Generic',
        'caloriesPer100g': 52.0,
        'proteinPer100g': 0.3,
        'carbsPer100g': 14.0,
        'fatPer100g': 0.2,
        'isFavorite': false,
      },
      {
        'name': 'Banana',
        'brand': 'Generic',
        'caloriesPer100g': 89.0,
        'proteinPer100g': 1.1,
        'carbsPer100g': 22.8,
        'fatPer100g': 0.3,
        'isFavorite': false,
      },
      {
        'name': 'Chicken Breast',
        'brand': 'Generic',
        'caloriesPer100g': 165.0,
        'proteinPer100g': 31.0,
        'carbsPer100g': 0.0,
        'fatPer100g': 3.6,
        'isFavorite': false,
      },
      {
        'name': 'White Rice (cooked)',
        'brand': 'Generic',
        'caloriesPer100g': 130.0,
        'proteinPer100g': 2.7,
        'carbsPer100g': 28.0,
        'fatPer100g': 0.3,
        'isFavorite': false,
      },
      {
        'name': 'Egg',
        'brand': 'Generic',
        'caloriesPer100g': 155.0,
        'proteinPer100g': 12.6,
        'carbsPer100g': 1.1,
        'fatPer100g': 11.0,
        'isFavorite': false,
      }
    ];

    // Add each food item
    for (var food in foods) {
      await foodItemsRef.push().set(food);
    }
  }
}
