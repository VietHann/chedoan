import '../models/food_item.dart';
import '../services/firebase_service.dart';

class FoodRepository {
  final FirebaseService _firebaseService;

  FoodRepository(this._firebaseService);

  Future<List<FoodItem>> searchFood(String query) async {
    final snapshot = await _firebaseService.foodItemsRef.get();
    
    if (!snapshot.exists) {
      return [];
    }
    
    final Map<dynamic, dynamic> foods = snapshot.value as Map<dynamic, dynamic>;
    List<FoodItem> results = [];
    
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
    
    return results.take(20).toList();
  }

  Future<FoodItem?> getFoodItemById(String id) async {
    final snapshot = await _firebaseService.foodItemsRef.child(id).get();
    
    if (snapshot.exists) {
      final Map<dynamic, dynamic> foodData = snapshot.value as Map<dynamic, dynamic>;
      
      return FoodItem.fromMap({
        'id': id,
        ...Map<String, dynamic>.from(foodData),
      });
    }
    
    return null;
  }

  Future<String> addFoodItem(FoodItem foodItem) async {
    final foodData = foodItem.toMap();
    foodData.remove('id');
    
    return await _firebaseService.pushData(
      _firebaseService.foodItemsRef,
      foodData,
    );
  }

  Future<void> updateFoodItem(FoodItem foodItem) async {
    if (foodItem.id == null) {
      throw Exception('Cannot update food without ID');
    }
    
    final foodData = foodItem.toMap();
    foodData.remove('id');
    
    await _firebaseService.updateData(
      _firebaseService.foodItemsRef.child(foodItem.id!),
      foodData,
    );
  }

  Future<void> toggleFavorite(String foodItemId) async {
    final foodItem = await getFoodItemById(foodItemId);
    if (foodItem != null) {
      final updatedFoodItem = foodItem.copyWith(
        isFavorite: !foodItem.isFavorite,
      );
      
      await updateFoodItem(updatedFoodItem);
    }
  }

  Future<List<FoodItem>> getFavoriteFoods() async {
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

  Future<List<FoodItem>> getRecentFoods() async {
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