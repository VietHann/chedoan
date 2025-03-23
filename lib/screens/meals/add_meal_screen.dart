import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../blocs/app_bloc.dart';
import '../../blocs/app_event.dart';
import '../../blocs/app_state.dart';
import '../../models/food_item.dart';
import '../../models/meal_entry.dart';
import '../../widgets/custom_app_bar.dart';
import 'food_search_screen.dart';

class AddMealScreen extends StatefulWidget {
  final DateTime initialDate;
  final MealType initialMealType;
  final FoodItem? preselectedFood;

  const AddMealScreen({
    Key? key,
    required this.initialDate,
    required this.initialMealType,
    this.preselectedFood,
  }) : super(key: key);

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late MealType _selectedMealType;
  FoodItem? _selectedFood;
  final TextEditingController _amountController = TextEditingController(text: '100');

  final List<String> _mealTypes = ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Bữa phụ'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedMealType = widget.initialMealType;

    if (widget.preselectedFood != null) {
      _selectedFood = widget.preselectedFood;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectFood() async {
    final FoodItem? selectedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FoodSearchScreen(),
      ),
    );

    if (selectedFood != null) {
      setState(() {
        _selectedFood = selectedFood;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addMeal() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một món ăn')),
      );
      return;
    }

    // Parse amount
    final double amount = double.tryParse(_amountController.text) ?? 100;

    // Create meal entry
    final MealEntry mealEntry = MealEntry(
      date: _selectedDate,
      mealType: _selectedMealType,
      foodItemId: _selectedFood!.id ?? '',
      foodItem: _selectedFood,
      amount: amount,
    );

    // Add meal entry
    context.read<AppBloc>().add(AddMealEntry(mealEntry));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Thêm món ăn',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and meal type selection
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Date selection
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              'Ngày: ${DateFormat.yMMMd().format(_selectedDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),

                      const Divider(height: 32),

                      // Meal type selection
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Loại bữa ăn',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant_menu),
                        ),
                        value: _mealTypeToString(_selectedMealType),
                        items: _mealTypes.map((mealType) {
                          return DropdownMenuItem(
                            value: mealType,
                            child: Text(mealType),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMealType = _stringToMealType(value);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Food selection section
              const Text(
                'Thực phẩm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Selected food item or selection button
              if (_selectedFood == null)
                _buildSelectFoodButton()
              else
                _buildSelectedFoodCard(),

              const SizedBox(height: 24),

              // Amount input section
              if (_selectedFood != null) ...[
                const Text(
                  'Số lượng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Amount input field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng (g)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.scale),
                    suffixText: 'g',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số lượng';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Vui lòng nhập số lượng hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Quick amount buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAmountButton(50),
                    _buildQuickAmountButton(100),
                    _buildQuickAmountButton(150),
                    _buildQuickAmountButton(200),
                  ],
                ),

                const SizedBox(height: 16),

                // Nutrition summary for selected amount
                _buildNutritionSummary(),
              ],

              const SizedBox(height: 32),

              // Add meal button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedFood != null ? _addMeal : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Thêm vào nhật ký'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectFoodButton() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _selectFood,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(
                Icons.search,
                size: 48,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tìm kiếm món ăn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tìm món ăn từ cơ sở dữ liệu hoặc thêm món mới',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFoodCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Food icon
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            // Food info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFood!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (_selectedFood!.brand != null && _selectedFood!.brand!.isNotEmpty)
                    Text(
                      _selectedFood!.brand!,
                      style: const TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedFood!.caloriesPer100g.toStringAsFixed(0)} kcal / 100g',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Change food button
            TextButton(
              onPressed: _selectFood,
              child: const Text('Thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _amountController.text = amount.toString();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: double.tryParse(_amountController.text) == amount
            ? AppTheme.primaryColor
            : Colors.grey[200],
        foregroundColor: double.tryParse(_amountController.text) == amount
            ? Colors.white
            : AppTheme.textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text('${amount.toInt()}g'),
    );
  }

  Widget _buildNutritionSummary() {
    if (_selectedFood == null) return const SizedBox.shrink();

    final double amount = double.tryParse(_amountController.text) ?? 0;
    final double calories = _selectedFood!.getCalories(amount);
    final double protein = _selectedFood!.getProtein(amount);
    final double carbs = _selectedFood!.getCarbs(amount);
    final double fat = _selectedFood!.getFat(amount);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan dinh dưỡng',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNutrientItem('Calo', calories.toStringAsFixed(0), 'kcal', AppTheme.primaryColor),
                _buildNutrientItem('Protein', protein.toStringAsFixed(1), 'g', AppTheme.secondaryColor),
                _buildNutrientItem('Tinh bột', carbs.toStringAsFixed(1), 'g', AppTheme.accentColor),
                _buildNutrientItem('Chất béo', fat.toStringAsFixed(1), 'g', Colors.purpleAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  String _mealTypeToString(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Bữa sáng';
      case MealType.lunch:
        return 'Bữa trưa';
      case MealType.dinner:
        return 'Bữa tối';
      case MealType.snack:
        return 'Bữa phụ';
    }
  }

  MealType _stringToMealType(String mealTypeString) {
    switch (mealTypeString) {
      case 'Bữa sáng':
        return MealType.breakfast;
      case 'Bữa trưa':
        return MealType.lunch;
      case 'Bữa tối':
        return MealType.dinner;
      case 'Bữa phụ':
      default:
        return MealType.snack;
    }
  }
}