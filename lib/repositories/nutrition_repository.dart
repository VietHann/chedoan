import 'package:firebase_database/firebase_database.dart';

import '../models/meal_entry.dart';
import '../models/water_intake.dart';
import '../models/food_item.dart';
import '../services/firebase_service.dart';

class NutritionRepository {
  final FirebaseService _firebaseService;

  NutritionRepository(this._firebaseService);

  // MEAL ENTRIES METHODS
  Future<String> addMealEntry({
    required String email,
    required MealEntry mealEntry,
  }) async {
    // Get user ID from email
    final userSnapshot = await _firebaseService.getDataByValue(
      _firebaseService.usersRef,
      'email',
      email,
    );
    
    if (!userSnapshot.exists) {
      throw Exception('User not found');
    }
    
    final Map<dynamic, dynamic> users = userSnapshot.value as Map<dynamic, dynamic>;
    final String userId = users.keys.first;
    
    // Create meal entry data
    final mealData = mealEntry.toMap();
    mealData.remove('id');
    mealData['userId'] = userId;
    
    // Insert the meal entry
    return await _firebaseService.pushData(
      _firebaseService.mealEntriesRef,
      mealData,
    );
  }

  Future<void> deleteMealEntry({
    required String mealEntryId,
  }) async {
    await _firebaseService.deleteData(
      _firebaseService.mealEntriesRef.child(mealEntryId),
    );
  }

  Future<List<MealEntry>> getMealsForDate({
    required String email,
    required DateTime date,
  }) async {
    final dateString = date.toIso8601String().split('T')[0];
    
    // Get user ID from email
    final userSnapshot = await _firebaseService.getDataByValue(
      _firebaseService.usersRef,
      'email',
      email,
    );
    
    if (!userSnapshot.exists) {
      throw Exception('User not found');
    }
    
    final Map<dynamic, dynamic> users = userSnapshot.value as Map<dynamic, dynamic>;
    final String userId = users.keys.first;
    
    // Get all meal entries for the user
    final mealsSnapshot = await _firebaseService.mealEntriesRef
        .orderByChild('userId')
        .equalTo(userId)
        .get();
    
    List<MealEntry> meals = [];
    
    if (mealsSnapshot.exists) {
      final Map<dynamic, dynamic> mealsData = mealsSnapshot.value as Map<dynamic, dynamic>;
      
      // Filter meals by date
      await Future.forEach(mealsData.entries, (MapEntry<dynamic, dynamic> entry) async {
        final String mealId = entry.key;
        final Map<dynamic, dynamic> mealData = entry.value;
        
        // Check if this meal is for the requested date
        if (mealData['date'] == dateString) {
          final String foodItemId = mealData['foodItemId'];
          
          // Get the food item
          final foodSnapshot = await _firebaseService.foodItemsRef.child(foodItemId).get();
          
          if (foodSnapshot.exists) {
            final Map<dynamic, dynamic> foodData = foodSnapshot.value as Map<dynamic, dynamic>;
            final FoodItem foodItem = FoodItem.fromMap({
              'id': foodItemId,
              ...Map<String, dynamic>.from(foodData),
            });
            
            // Create meal entry with food item
            final mealEntry = MealEntry.fromMap({
              'id': mealId,
              ...Map<String, dynamic>.from(mealData),
            }, foodItem: foodItem);
            
            meals.add(mealEntry);
          }
        }
      });
    }
    
    return meals;
  }

  // WATER INTAKE METHODS
  Future<String> addWaterIntake({
    required String email,
    required WaterIntake waterIntake,
  }) async {
    // Get user ID from email
    final userSnapshot = await _firebaseService.getDataByValue(
      _firebaseService.usersRef,
      'email',
      email,
    );
    
    if (!userSnapshot.exists) {
      throw Exception('User not found');
    }
    
    final Map<dynamic, dynamic> users = userSnapshot.value as Map<dynamic, dynamic>;
    final String userId = users.keys.first;
    
    // Create water intake data
    final waterData = waterIntake.toMap();
    waterData.remove('id');
    waterData['userId'] = userId;
    
    // Insert the water intake
    return await _firebaseService.pushData(
      _firebaseService.waterIntakesRef,
      waterData,
    );
  }

  Future<int> getDailyTotalWaterIntake({
    required String email,
    required DateTime date,
  }) async {
    final waterIntakes = await getWaterIntakesForDate(
      email: email,
      date: date,
    );

    int total = 0;
    for (var intake in waterIntakes) {
      total += intake.amount;
    }

    return total;
  }

  Future<List<WaterIntake>> getWaterIntakesForDate({
    required String email,
    required DateTime date,
  }) async {
    final dateString = date.toIso8601String().split('T')[0];
    
    // Get user ID from email
    final userSnapshot = await _firebaseService.getDataByValue(
      _firebaseService.usersRef,
      'email',
      email,
    );
    
    if (!userSnapshot.exists) {
      throw Exception('User not found');
    }
    
    final Map<dynamic, dynamic> users = userSnapshot.value as Map<dynamic, dynamic>;
    final String userId = users.keys.first;
    
    // Get all water intakes for the user
    final intakeSnapshot = await _firebaseService.waterIntakesRef
        .orderByChild('userId')
        .equalTo(userId)
        .get();
    
    List<WaterIntake> waterIntakes = [];
    
    if (intakeSnapshot.exists) {
      final Map<dynamic, dynamic> intakesData = intakeSnapshot.value as Map<dynamic, dynamic>;
      
      // Filter water intakes by date
      intakesData.forEach((key, value) {
        final Map<dynamic, dynamic> intakeData = value;
        
        // Check if this intake is for the requested date
        if (intakeData['date'] == dateString) {
          waterIntakes.add(WaterIntake.fromMap({
            'id': key,
            ...Map<String, dynamic>.from(intakeData),
          }));
        }
      });
      
      // Sort by createdAt
      waterIntakes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    
    return waterIntakes;
  }
}