import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Database references
  DatabaseReference get usersRef => _database.ref('users');
  DatabaseReference get foodItemsRef => _database.ref('food_items');
  DatabaseReference get mealEntriesRef => _database.ref('meal_entries');
  DatabaseReference get waterIntakesRef => _database.ref('water_intakes');

  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Current user
  User? get currentUser => _auth.currentUser;
  
  // Check authentication status
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Realtime Database CRUD operations
  
  // Create data
  Future<void> setData(DatabaseReference ref, Map<String, dynamic> data) async {
    await ref.set(data);
  }
  
  // Create data with a generated key
  Future<String> pushData(DatabaseReference ref, Map<String, dynamic> data) async {
    final newRef = ref.push();
    await newRef.set(data);
    return newRef.key ?? '';
  }

  // Read data
  Future<DataSnapshot> getData(DatabaseReference ref) async {
    return await ref.get();
  }

  // Read data with query
  Future<DataSnapshot> getDataQuery(
    DatabaseReference ref, {
    String? orderByChild,
    dynamic equalTo,
    dynamic startAt,
    dynamic endAt,
    int? limitToFirst,
    int? limitToLast,
  }) async {
    Query query = ref;
    
    if (orderByChild != null) {
      query = query.orderByChild(orderByChild);
    }
    
    if (equalTo != null) {
      query = query.equalTo(equalTo);
    }
    
    if (startAt != null) {
      query = query.startAt(startAt);
    }
    
    if (endAt != null) {
      query = query.endAt(endAt);
    }
    
    if (limitToFirst != null) {
      query = query.limitToFirst(limitToFirst);
    }
    
    if (limitToLast != null) {
      query = query.limitToLast(limitToLast);
    }
    
    return await query.get();
  }

  // Update data
  Future<void> updateData(DatabaseReference ref, Map<String, dynamic> data) async {
    await ref.update(data);
  }

  // Delete data
  Future<void> deleteData(DatabaseReference ref) async {
    await ref.remove();
  }
  
  // Get data by value
  Future<DataSnapshot> getDataByValue(
    DatabaseReference ref,
    String child,
    dynamic value,
  ) async {
    return await ref.orderByChild(child).equalTo(value).get();
  }
  
  // Get data for date range
  Future<DataSnapshot> getDataForDateRange(
    DatabaseReference ref,
    String dateField,
    DateTime startDate,
    DateTime endDate,
    String userId,
  ) async {
    return await ref
        .orderByChild(dateField)
        .startAt(startDate.millisecondsSinceEpoch)
        .endAt(endDate.millisecondsSinceEpoch)
        .get();
  }
  
  // Helper methods for date conversion
  int dateTimeToInt(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }
  
  DateTime intToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  // Parse date string to timestamp
  int? parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString).millisecondsSinceEpoch;
    } catch (_) {
      return null;
    }
  }
  
  // Format timestamp to date string
  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date.toIso8601String().split('T')[0];
  }
  
  // Add sample foods to database
  Future<void> addSampleFoodItems() async {
    // Sample food items
    final List<Map<String, dynamic>> foods = [
      {
        'name': 'Apple',
        'brand': 'Generic',
        'caloriesPer100g': 52.0,
        'proteinPer100g': 0.3,
        'carbsPer100g': 14.0,
        'fatPer100g': 0.2,
        'fiberPer100g': 2.4,
        'servingUnit': 'g',
        'servingSize': 100.0,
        'isFavorite': false,
        'isCustom': false
      },
      {
        'name': 'Banana',
        'brand': 'Generic',
        'caloriesPer100g': 89.0,
        'proteinPer100g': 1.1,
        'carbsPer100g': 22.8,
        'fatPer100g': 0.3,
        'fiberPer100g': 2.6,
        'servingUnit': 'g',
        'servingSize': 100.0,
        'isFavorite': false,
        'isCustom': false
      },
      {
        'name': 'Chicken Breast',
        'brand': 'Generic',
        'caloriesPer100g': 165.0,
        'proteinPer100g': 31.0,
        'carbsPer100g': 0.0,
        'fatPer100g': 3.6,
        'servingUnit': 'g',
        'servingSize': 100.0,
        'isFavorite': false,
        'isCustom': false
      },
      {
        'name': 'White Rice (cooked)',
        'brand': 'Generic',
        'caloriesPer100g': 130.0,
        'proteinPer100g': 2.7,
        'carbsPer100g': 28.0,
        'fatPer100g': 0.3,
        'fiberPer100g': 0.4,
        'servingUnit': 'g',
        'servingSize': 100.0,
        'isFavorite': false,
        'isCustom': false
      },
      {
        'name': 'Egg',
        'brand': 'Generic',
        'caloriesPer100g': 155.0,
        'proteinPer100g': 12.6,
        'carbsPer100g': 1.1,
        'fatPer100g': 11.0,
        'servingUnit': 'g',
        'servingSize': 50.0,
        'isFavorite': false,
        'isCustom': false
      },
      {
        'name': 'Whole Milk',
        'brand': 'Generic',
        'caloriesPer100g': 61.0,
        'proteinPer100g': 3.2,
        'carbsPer100g': 4.8,
        'fatPer100g': 3.6,
        'servingUnit': 'ml',
        'servingSize': 100.0,
        'isFavorite': false,
        'isCustom': false
      },
      {
        'name': 'Oatmeal (cooked)',
        'brand': 'Generic',
        'caloriesPer100g': 71.0,
        'proteinPer100g': 2.5,
        'carbsPer100g': 12.0,
        'fatPer100g': 1.5,
        'fiberPer100g': 2.0,
        'servingUnit': 'g',
        'servingSize': 100.0,
        'isFavorite': false,
        'isCustom': false
      },
      {
        'name': 'Beef Steak',
        'brand': 'Generic',
        'caloriesPer100g': 250.0,
        'proteinPer100g': 26.0,
        'carbsPer100g': 0.0,
        'fatPer100g': 17.0,
        'servingUnit': 'g',
        'servingSize': 100.0,
        'isFavorite': false,
        'isCustom': false
      },
      {
        'name': 'Broccoli',
        'brand': 'Generic',
        'caloriesPer100g': 34.0,
        'proteinPer100g': 2.8,
        'carbsPer100g': 7.0,
        'fatPer100g': 0.4,
        'fiberPer100g': 2.6,
        'servingUnit': 'g',
        'servingSize': 100.0,
        'isFavorite': false,
        'isCustom': false
      },
      {
        'name': 'Salmon',
        'brand': 'Generic',
        'caloriesPer100g': 206.0,
        'proteinPer100g': 22.0,
        'carbsPer100g': 0.0,
        'fatPer100g': 13.0,
        'servingUnit': 'g',
        'servingSize': 100.0,
        'isFavorite': false,
        'isCustom': false
      }
    ];

    // Check if food items exist
    final foodsSnapshot = await foodItemsRef.limitToFirst(1).get();
    if (foodsSnapshot.exists) {
      // Foods already exist, don't add again
      return;
    }

    // Add each food item
    for (var food in foods) {
      await foodItemsRef.push().set(food);
    }
  }
}