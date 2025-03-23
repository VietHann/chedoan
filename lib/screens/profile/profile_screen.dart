import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_theme.dart';
import '../../blocs/app_bloc.dart';
import '../../blocs/app_event.dart';
import '../../blocs/app_state.dart';
import '../../models/user_profile.dart';
import '../../widgets/custom_app_bar.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Thông tin cá nhân',
        showBackButton: true,
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AppLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AppDailyNutritionLoaded) {
            return _buildProfileContent(state.user);
          } else if (state is AppError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          } else {
            return const Center(child: Text('Không có thông tin người dùng'));
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(UserProfile user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Thông tin cá nhân'),
          _buildInfoRow('Họ và tên', user.name ?? 'Chưa cập nhật'),
          _buildInfoRow('Tuổi', user.age?.toString() ?? 'Chưa cập nhật'),
          _buildInfoRow(
              'Giới tính', user.gender?.capitalize() ?? 'Chưa cập nhật'),
          _buildInfoRow(
              'Chiều cao', '${user.height?.toString() ?? "Chưa cập nhật"} cm'),
          _buildInfoRow(
              'Cân nặng', '${user.weight?.toString() ?? "Chưa cập nhật"} kg'),
          const SizedBox(height: 24),
          _buildSectionTitle('Mục tiêu và hoạt động'),
          _buildInfoRow('Mục tiêu', _getGoalText(user.goal)),
          _buildInfoRow(
              'Mức độ hoạt động', _getActivityLevelText(user.activityLevel)),
          const SizedBox(height: 24),
          _buildSectionTitle('Mục tiêu dinh dưỡng'),
          _buildInfoRow('Calo mục tiêu',
              '${user.targetCalories?.toString() ?? "Chưa cập nhật"} kcal'),
          _buildInfoRow('Đạm mục tiêu',
              '${user.targetProtein?.toString() ?? "Chưa cập nhật"} g'),
          _buildInfoRow('Tinh bột mục tiêu',
              '${user.targetCarbs?.toString() ?? "Chưa cập nhật"} g'),
          _buildInfoRow('Chất béo mục tiêu',
              '${user.targetFat?.toString() ?? "Chưa cập nhật"} g'),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(profile: user),
                  ),
                );
              },
              child: const Text('Chỉnh sửa thông tin'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<AppBloc>().add(LogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đăng xuất'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getGoalText(String? goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Giảm cân';
      case 'maintain':
        return 'Duy trì';
      case 'gain_weight':
        return 'Tăng cân';
      default:
        return 'Chưa cập nhật';
    }
  }

  String _getActivityLevelText(String? activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return 'Ít vận động';
      case 'light':
        return 'Vận động nhẹ';
      case 'moderate':
        return 'Vận động vừa phải';
      case 'active':
        return 'Vận động nhiều';
      case 'very_active':
        return 'Vận động rất nhiều';
      default:
        return 'Chưa cập nhật';
    }
  }
}

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

  final List<String> _genders = ['Nam', 'Nữ', 'Khác'];
  final List<String> _goals = ['Giảm cân', 'Duy trì', 'Tăng cân'];
  final List<String> _activityLevels = [
    'Ít vận động',
    'Vận động nhẹ',
    'Vận động vừa phải',
    'Vận động nhiều',
    'Vận động rất nhiều'
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
          _selectedGoal = 'Giảm cân';
          break;
        case 'maintain':
          _selectedGoal = 'Duy trì';
          break;
        case 'gain_weight':
          _selectedGoal = 'Tăng cân';
          break;
      }
    }

    if (widget.profile.activityLevel != null) {
      switch (widget.profile.activityLevel) {
        case 'sedentary':
          _selectedActivityLevel = 'Ít vận động';
          break;
        case 'light':
          _selectedActivityLevel = 'Vận động nhẹ';
          break;
        case 'moderate':
          _selectedActivityLevel = 'Vận động vừa phải';
          break;
        case 'active':
          _selectedActivityLevel = 'Vận động nhiều';
          break;
        case 'very_active':
          _selectedActivityLevel = 'Vận động rất nhiều';
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

    // Convert display values to database values
    String? databaseGoal;
    if (_selectedGoal != null) {
      switch (_selectedGoal) {
        case 'Giảm cân':
          databaseGoal = 'lose_weight';
          break;
        case 'Duy trì':
          databaseGoal = 'maintain';
          break;
        case 'Tăng cân':
          databaseGoal = 'gain_weight';
          break;
      }
    }

    String? databaseActivityLevel;
    if (_selectedActivityLevel != null) {
      switch (_selectedActivityLevel) {
        case 'Ít vận động':
          databaseActivityLevel = 'sedentary';
          break;
        case 'Vận động nhẹ':
          databaseActivityLevel = 'light';
          break;
        case 'Vận động vừa phải':
          databaseActivityLevel = 'moderate';
          break;
        case 'Vận động nhiều':
          databaseActivityLevel = 'active';
          break;
        case 'Vận động rất nhiều':
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
    context.read<AppBloc>().add(
          UpdateProfile(
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
        title: 'Chỉnh sửa thông tin',
        showBackButton: true,
      ),
      body: BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          if (state is AppError) {
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
                _buildSectionTitle('Thông tin cá nhân'),

                // Name field
                _buildTextField(
                  controller: _nameController,
                  label: 'Họ và tên',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ tên của bạn';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Age field
                _buildTextField(
                  controller: _ageController,
                  label: 'Tuổi',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tuổi của bạn';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0 || age > 120) {
                      return 'Vui lòng nhập tuổi hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Gender dropdown
                _buildDropdownField(
                  label: 'Giới tính',
                  icon: Icons.person,
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn giới tính';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('Thông tin sức khỏe'),

                // Height field
                _buildTextField(
                  controller: _heightController,
                  label: 'Chiều cao (cm)',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập chiều cao của bạn';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height <= 0 || height > 300) {
                      return 'Chiều cao không hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Weight field
                _buildTextField(
                  controller: _weightController,
                  label: 'Cân nặng (kg)',
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập cân nặng của bạn';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0 || weight > 500) {
                      return 'Cân nặng không hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                _buildSectionTitle('Mục tiêu và hoạt động'),

                // Goal dropdown
                _buildDropdownField(
                  label: 'Mục tiêu',
                  icon: Icons.flag,
                  value: _selectedGoal,
                  items: _goals,
                  onChanged: (value) {
                    setState(() {
                      _selectedGoal = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn mục tiêu của bạn';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Activity Level dropdown
                _buildDropdownField(
                  label: 'Mức độ hoạt động',
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
                      return 'Vui lòng chọn mức độ hoạt động của bạn';
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Lưu thay đổi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
