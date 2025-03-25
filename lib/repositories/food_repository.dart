import 'package:firebase_database/firebase_database.dart';

import '../models/food_item.dart';
import '../services/firebase_service.dart';
import '../services/nutritionix_service.dart';

class FoodRepository {
  final FirebaseService _firebaseService;
  final NutritionixService _nutritionixService = NutritionixService();

  FoodRepository(this._firebaseService);

  // Search for food in local database
  Future<List<FoodItem>> searchFoodLocal(String query) async {
    // Search in Firebase
    final snapshot = await _firebaseService.foodItemsRef.get();
    
    if (!snapshot.exists) {
      return [];
    }
    
    final Map<dynamic, dynamic> foods = snapshot.value as Map<dynamic, dynamic>;
    List<FoodItem> results = [];
    
    // Filter foods that match the query
    foods.forEach((key, value) {
      final Map<String, dynamic> foodData = Map<String, dynamic>.from(value);
      final String name = foodData['name'] ?? '';
      
      if (name.toLowerCase().contains(query.toLowerCase())) {
        results.add(FoodItem.fromMap({
          'id': key,
          ...foodData,
        }));
      }
    });
    
    return results.take(20).toList(); // Limit to 20 results
  }

  // Search for food using Nutritionix API
  Future<List<FoodItem>> searchFoodAPI(String query) async {
    try {
      return await _nutritionixService.searchFood(query);
    } catch (e) {
      // If API fails, return empty list
      return [];
    }
  }

  // Get a food item by ID
  Future<FoodItem?> getFoodItemById(String id) async {
    final snapshot = await _firebaseService.foodItemsRef.child(id).get();
    
    if (snapshot.exists) {
      final Map<dynamic, dynamic> foodData = snapshot.value as Map<dynamic, dynamic>;
      
      return FoodItem.fromMap({
        'id': id,
        ...Map<String, dynamic>.from(foodData),
      });
    }
    
    // Food not found
    return null;
  }

  // Add a food item to database
  Future<String> addFoodItem(FoodItem foodItem) async {
    // Convert to Map for storage
    final foodData = foodItem.toMap();
    foodData.remove('id'); // Remove id as it will be generated by Firebase
    
    // Add to database
    return await _firebaseService.pushData(
      _firebaseService.foodItemsRef,
      foodData,
    );
  }

  // Update food item
  Future<void> updateFoodItem(FoodItem foodItem) async {
    if (foodItem.id == null) {
      throw Exception('Cannot update food without ID');
    }
    
    // Convert to Map for storage
    final foodData = foodItem.toMap();
    foodData.remove('id'); // Remove id as it's already in the path
    
    // Update in database
    await _firebaseService.updateData(
      _firebaseService.foodItemsRef.child(foodItem.id!),
      foodData,
    );
  }

  // Toggle favorite
  Future<void> toggleFavorite(String foodItemId) async {
    // Get current food item
    final foodItem = await getFoodItemById(foodItemId);
    if (foodItem != null) {
      // Toggle the favorite status
      final updatedFoodItem = foodItem.copyWith(
        isFavorite: !foodItem.isFavorite,
      );
      
      // Update in database
      await updateFoodItem(updatedFoodItem);
    }
  }

  // Get favorite foods
  Future<List<FoodItem>> getFavoriteFoods() async {
    // Get all foods that are marked as favorite
    final snapshot = await _firebaseService.getDataByValue(
      _firebaseService.foodItemsRef,
      'isFavorite',
      true,
    );
    
    List<FoodItem> favorites = [];
    
    if (snapshot.exists) {
      final Map<dynamic, dynamic> foods = snapshot.value as Map<dynamic, dynamic>;
      
      foods.forEach((key, value) {
        final Map<String, dynamic> foodData = Map<String, dynamic>.from(value);
        favorites.add(FoodItem.fromMap({
          'id': key,
          ...foodData,
        }));
      });
    }
    
    return favorites;
  }

  // Get recently used foods
  Future<List<FoodItem>> getRecentFoods() async {
    // This is a bit more complex with Firebase Realtime DB
    // We need to get all meal entries, sort by date, and get the food items
    // For simplicity, we'll just return the first 10 food items
    
    final snapshot = await _firebaseService.foodItemsRef.limitToFirst(10).get();
    List<FoodItem> recentFoods = [];
    
    if (snapshot.exists) {
      final Map<dynamic, dynamic> foods = snapshot.value as Map<dynamic, dynamic>;
      
      foods.forEach((key, value) {
        final Map<String, dynamic> foodData = Map<String, dynamic>.from(value);
        recentFoods.add(FoodItem.fromMap({
          'id': key,
          ...foodData,
        }));
      });
    }
    
    return recentFoods;
  }
}