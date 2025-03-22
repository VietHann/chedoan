import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/food_item.dart';

class NutritionixService {
  final Dio _dio = Dio();
  
  // API credentials (in a real app, these would be stored securely)
  final String _appId = 'your_app_id_here'; // Replace with actual app_id from environment
  final String _appKey = 'your_app_key_here'; // Replace with actual app_key from environment
  
  // Base URL for the API
  final String _baseUrl = 'https://trackapi.nutritionix.com/v2';

  // Search for food
  Future<List<FoodItem>> searchFood(String query) async {
    try {
      // For this MVP we'll return mock results if API keys aren't set
      if (_appId == 'your_app_id_here' || _appKey == 'your_app_key_here') {
        return [];
      }
      
      final response = await _dio.get(
        '$_baseUrl/search/instant',
        queryParameters: {
          'query': query,
          'detailed': true,
        },
        options: Options(
          headers: {
            'x-app-id': _appId,
            'x-app-key': _appKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> commonItems = response.data['common'] ?? [];
        final List<dynamic> brandedItems = response.data['branded'] ?? [];
        
        List<FoodItem> foodItems = [];
        
        // Convert common items to FoodItem objects
        for (var item in commonItems) {
          try {
            // Get detailed nutrition data for this item
            final nutrientData = await getDetailedNutrients(item['food_name']);
            foodItems.add(nutrientData);
          } catch (e) {
            debugPrint('Error getting detailed nutrients: $e');
          }
        }
        
        // Convert branded items to FoodItem objects
        for (var item in brandedItems) {
          foodItems.add(FoodItem(
            name: item['food_name'],
            brand: item['brand_name'],
            caloriesPer100g: item['nf_calories'] ?? 0,
            proteinPer100g: item['nf_protein'] ?? 0,
            carbsPer100g: item['nf_total_carbohydrate'] ?? 0,
            fatPer100g: item['nf_total_fat'] ?? 0,
            fiberPer100g: item['nf_dietary_fiber'],
            sugarPer100g: item['nf_sugars'],
            servingUnit: item['serving_unit'],
            servingSize: item['serving_qty'],
            servingCalories: item['nf_calories'],
          ));
        }
        
        return foodItems;
      } else {
        throw Exception('Failed to search food: ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('Error searching food: $e');
      return [];
    }
  }

  // Get detailed nutrient information for a food item
  Future<FoodItem> getDetailedNutrients(String foodName) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/natural/nutrients',
        data: {
          'query': foodName,
        },
        options: Options(
          headers: {
            'x-app-id': _appId,
            'x-app-key': _appKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['foods'] != null) {
        final food = response.data['foods'][0];
        
        return FoodItem(
          name: food['food_name'],
          caloriesPer100g: (food['nf_calories'] / food['serving_weight_grams']) * 100,
          proteinPer100g: (food['nf_protein'] / food['serving_weight_grams']) * 100,
          carbsPer100g: (food['nf_total_carbohydrate'] / food['serving_weight_grams']) * 100,
          fatPer100g: (food['nf_total_fat'] / food['serving_weight_grams']) * 100,
          fiberPer100g: food['nf_dietary_fiber'] != null 
            ? (food['nf_dietary_fiber'] / food['serving_weight_grams']) * 100 
            : null,
          sugarPer100g: food['nf_sugars'] != null
            ? (food['nf_sugars'] / food['serving_weight_grams']) * 100
            : null,
          servingUnit: food['serving_unit'],
          servingSize: food['serving_weight_grams'],
          servingCalories: food['nf_calories'],
        );
      } else {
        throw Exception('Failed to get detailed nutrients');
      }
    } catch (e) {
      debugPrint('Error getting detailed nutrients: $e');
      // Return a default food item with the name but empty nutrition data
      return FoodItem(
        name: foodName,
        caloriesPer100g: 0,
        proteinPer100g: 0,
        carbsPer100g: 0,
        fatPer100g: 0,
      );
    }
  }
}
