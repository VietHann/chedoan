import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_theme.dart';
import '../../blocs/authentication/auth_bloc.dart';
import '../../blocs/authentication/auth_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../models/user_profile.dart';
import '../../widgets/custom_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  
  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedActivityLevel;
  
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _goals = ['Lose Weight', 'Maintain', 'Gain Weight'];
  final List<String> _activityLevels = [
    'Sedentary', 
    'Lightly Active', 
    'Moderately Active', 
    'Very Active', 
    'Extremely Active'
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeDropdowns();
  }
  
  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.profile.name);
    _ageController = TextEditingController(
      text: widget.profile.age?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.profile.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.profile.weight?.toString() ?? '',
    );
  }
  
  void _initializeDropdowns() {
    // Convert database values to display values
    if (widget.profile.gender != null) {
      _selectedGender = widget.profile.gender!.capitalize();
    }
    
    if (widget.profile.goal != null) {
      switch (widget.profile.goal) {
        case 'lose_weight':
          _selectedGoal = 'Lose Weight';
          break;
        case 'maintain':
          _selectedGoal = 'Maintain';
          break;
        case 'gain_weight':
          _selectedGoal = 'Gain Weight';
          break;
      }
    }
    
    if (widget.profile.activityLevel != null) {
      switch (widget.profile.activityLevel) {
        case 'sedentary':
          _selectedActivityLevel = 'Sedentary';
          break;
        case 'light':
          _selectedActivityLevel = 'Lightly Active';
          break;
        case 'moderate':
          _selectedActivityLevel = 'Moderately Active';
          break;
        case 'active':
          _selectedActivityLevel = 'Very Active';
          break;
        case 'very_active':
          _selectedActivityLevel = 'Extremely Active';
          break;
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
  
  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    
    // Convert display values to database values
    String? databaseGoal;
    if (_selectedGoal != null) {
      switch (_selectedGoal) {
        case 'Lose Weight':
          databaseGoal = 'lose_weight';
          break;
        case 'Maintain':
          databaseGoal = 'maintain';
          break;
        case 'Gain Weight':
          databaseGoal = 'gain_weight';
          break;
      }
    }
    
    String? databaseActivityLevel;
    if (_selectedActivityLevel != null) {
      switch (_selectedActivityLevel) {
        case 'Sedentary':
          databaseActivityLevel = 'sedentary';
          break;
        case 'Lightly Active':
          databaseActivityLevel = 'light';
          break;
        case 'Moderately Active':
          databaseActivityLevel = 'moderate';
          break;
        case 'Very Active':
          databaseActivityLevel = 'active';
          break;
        case 'Extremely Active':
          databaseActivityLevel = 'very_active';
          break;
      }
    }
    
    // Parse numeric values
    int? age;
    double? height;
    double? weight;
    
    if (_ageController.text.isNotEmpty) {
      age = int.tryParse(_ageController.text);
    }
    
    if (_heightController.text.isNotEmpty) {
      height = double.tryParse(_heightController.text);
    }
    
    if (_weightController.text.isNotEmpty) {
      weight = double.tryParse(_weightController.text);
    }
    
    // Dispatch update event
    context.read<ProfileBloc>().add(
      UpdateProfile(
        email: authState.user.email,
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        age: age,
        gender: _selectedGender?.toLowerCase(),
        height: height,
        weight: weight,
        goal: databaseGoal,
        activityLevel: databaseActivityLevel,
      ),
    );
    
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Edit Profile',
        showBackButton: true,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Personal Information'),
                
                // Name field
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Age field
                _buildTextField(
                  controller: _ageController,
                  label: 'Age',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0 || age > 120) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Gender dropdown
                _buildDropdown(
                  label: 'Gender',
                  icon: Icons.people_outline,
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Height field
                _buildTextField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  icon: Icons.height,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height <= 0 || height > 300) {
                      return 'Please enter a valid height';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Weight field
                _buildTextField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0 || weight > 500) {
                      return 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                _buildSectionTitle('Fitness Goals'),
                
                // Goal dropdown
                _buildDropdown(
                  label: 'Goal',
                  icon: Icons.flag_outlined,
                  value: _selectedGoal,
                  items: _goals,
                  onChanged: (value) {
                    setState(() {
                      _selectedGoal = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your goal';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Activity level dropdown
                _buildDropdown(
                  label: 'Activity Level',
                  icon: Icons.directions_run,
                  value: _selectedActivityLevel,
                  items: _activityLevels,
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityLevel = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your activity level';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
  
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
