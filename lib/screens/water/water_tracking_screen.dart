import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../blocs/authentication/auth_bloc.dart';
import '../../blocs/authentication/auth_state.dart';
import '../../blocs/nutrition/nutrition_bloc.dart';
import '../../blocs/nutrition/nutrition_event.dart';
import '../../blocs/nutrition/nutrition_state.dart';
import '../../models/water_intake.dart';
import '../../widgets/custom_app_bar.dart';

class WaterTrackingScreen extends StatefulWidget {
  final DateTime initialDate;

  const WaterTrackingScreen({
    Key? key,
    required this.initialDate,
  }) : super(key: key);

  @override
  State<WaterTrackingScreen> createState() => _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends State<WaterTrackingScreen> {
  late DateTime _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _loadDailyNutrition();
  }
  
  void _loadDailyNutrition() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<NutritionBloc>().add(LoadDailyNutrition(
        email: authState.user.email,
        date: _selectedDate,
      ));
    }
  }
  
  void _addWater(int amount) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final waterIntake = WaterIntake(
        date: _selectedDate,
        amount: amount,
      );
      
      context.read<NutritionBloc>().add(AddWaterIntake(
        email: authState.user.email,
        waterIntake: waterIntake,
      ));
    }
  }
  
  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadDailyNutrition();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Water Tracking',
        showBackButton: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            return BlocBuilder<NutritionBloc, NutritionState>(
              builder: (context, state) {
                if (state is NutritionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is DailyNutritionLoaded) {
                  return _buildWaterTracker(state);
                } else if (state is NutritionError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                } else {
                  return const Center(
                    child: Text('No water tracking data available'),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: Text('Please log in to track water intake'),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildWaterTracker(DailyNutritionLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date selector
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _changeDate(
                      _selectedDate.subtract(const Duration(days: 1)),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        DateFormat.yMMMd().format(_selectedDate),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        DateFormat.EEEE().format(_selectedDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _changeDate(
                      _selectedDate.add(const Duration(days: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Water intake visualization
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Water intake progress
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress indicator
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: CircularProgressIndicator(
                            value: state.waterProgress,
                            strokeWidth: 15,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                        
                        // Center text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(state.waterIntake / 1000).toStringAsFixed(1)}L',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'of ${(state.targetWaterIntake / 1000).toStringAsFixed(1)}L',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick add buttons
                  Text(
                    'Quick Add',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWaterAddButton(100, '100ml'),
                      _buildWaterAddButton(200, '200ml'),
                      _buildWaterAddButton(300, '300ml'),
                      _buildWaterAddButton(500, '500ml'),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWaterAddButton(1000, '1L', isWide: true),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Custom amount section
                  Text(
                    'Custom Amount',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildCustomAmountSelector(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tips section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hydration Tips',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildTipItem(
                    'Drink water first thing in the morning to kickstart your metabolism.',
                  ),
                  _buildTipItem(
                    'Keep a water bottle with you throughout the day for easy access.',
                  ),
                  _buildTipItem(
                    'Set reminders to drink water regularly throughout the day.',
                  ),
                  _buildTipItem(
                    'Eat water-rich foods like fruits and vegetables to boost hydration.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWaterAddButton(int amount, String label, {bool isWide = false}) {
    return ElevatedButton(
      onPressed: () => _addWater(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 24.0 : 12.0,
          vertical: 12.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildCustomAmountSelector() {
    final TextEditingController customAmountController = TextEditingController();
    
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: customAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter amount in ml',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            final amount = int.tryParse(customAmountController.text);
            if (amount != null && amount > 0) {
              _addWater(amount);
              customAmountController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 14.0),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
  
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tip),
          ),
        ],
      ),
    );
  }
}
