import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_theme.dart';
import '../../blocs/authentication/auth_bloc.dart';
import '../../blocs/authentication/auth_event.dart';
import '../../blocs/authentication/auth_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../models/user_profile.dart';
import '../../utils/bmi_calculator.dart';
import '../../widgets/custom_app_bar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ProfileBloc>().add(LoadProfile(
            email: authState.user.email,
          ));
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Hồ sơ của tôi',
        showBackButton: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            return BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ProfileLoaded) {
                  return _buildProfileContent(state.profile);
                } else if (state is ProfileError) {
                  return Center(
                    child: Text('Lỗi: ${state.message}'),
                  );
                } else {
                  return const Center(
                    child: Text('Không có dữ liệu hồ sơ'),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: Text('Vui lòng đăng nhập để xem hồ sơ của bạn'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(UserProfile profile) {
    double? bmi;
    String? bmiCategory;
    if (profile.height != null && profile.weight != null) {
      bmi = BMICalculator.calculateBMI(profile.weight!, profile.height!);
      bmiCategory = BMICalculator.getBMICategory(bmi);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with gradient background
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.primaryColor
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile avatar with border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Text(
                      (profile.name?.isNotEmpty ?? false)
                          ? profile.name![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name with larger text
                Text(
                  profile.name ?? 'Chưa đặt tên',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Email with subtle styling
                Text(
                  profile.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 20),

                // Edit Profile Button with transparent background
                Container(
                  width: 200, // Fixed width for button
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(profile: profile),
                        ),
                      ).then((_) => _loadUserProfile());
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Chỉnh sửa hồ sơ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Health Info Section with improved styling
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Text(
              'Thông tin sức khỏe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          // Health stats card with modern design
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Basic Stats with improved layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildEnhancedStatColumn(
                        'Tuổi',
                        profile.age?.toString() ?? '?',
                        'tuổi',
                        Icons.cake,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _buildEnhancedStatColumn(
                        'Chiều cao',
                        profile.height?.toString() ?? '?',
                        'cm',
                        Icons.height,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _buildEnhancedStatColumn(
                        'Cân nặng',
                        profile.weight?.toString() ?? '?',
                        'kg',
                        Icons.monitor_weight_outlined,
                      ),
                    ],
                  ),

                  if (bmi != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(),
                    ),
                    // BMI display with improved visualization
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Chỉ số BMI',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getBmiColor(bmi).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${bmi.toStringAsFixed(1)} - $bmiCategory',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _getBmiColor(bmi),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (bmi / 40).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _getBmiColor(bmi)),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Hoàn thành hồ sơ để xem thông tin BMI',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Nutrition Goals Section
          _buildSectionTitle('Mục tiêu dinh dưỡng'),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildGoalRow('Mục tiêu',
                      _formatGoal(profile.goal) ?? 'Chưa thiết lập'),
                  const SizedBox(height: 8),
                  _buildGoalRow('Mức độ hoạt động',
                      _formatActivityLevel(profile.activityLevel)),
                  const SizedBox(height: 8),
                  _buildGoalRow('Mục tiêu calo',
                      '${profile.targetCalories ?? 'Chưa tính'} kcal'),
                  const SizedBox(height: 8),
                  _buildGoalRow('Mục tiêu nước',
                      '${profile.targetWater != null ? '${profile.targetWater! / 1000} L' : 'Chưa tính'}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Macro Targets Section
          _buildSectionTitle('Mục tiêu dinh dưỡng đa lượng'),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (profile.targetProtein != null &&
                      profile.targetCarbs != null &&
                      profile.targetFat != null) ...[
                    _buildMacroRow('Đạm', profile.targetProtein!.toInt(),
                        AppTheme.secondaryColor),
                    const SizedBox(height: 8),
                    _buildMacroRow('Tinh bột', profile.targetCarbs!.toInt(),
                        AppTheme.accentColor),
                    const SizedBox(height: 8),
                    _buildMacroRow('Chất béo', profile.targetFat!.toInt(),
                        Colors.purpleAccent),
                  ] else ...[
                    const Text(
                      'Hoàn thành hồ sơ để xem mục tiêu dinh dưỡng đa lượng',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: AppTheme.errorColor),
              label: const Text('Đăng xuất'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildEnhancedStatColumn(
      String label, String value, String unit, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          '$value g',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue; // Underweight
    } else if (bmi >= 18.5 && bmi < 25) {
      return AppTheme.secondaryColor; // Normal weight
    } else if (bmi >= 25 && bmi < 30) {
      return AppTheme.accentColor; // Overweight
    } else {
      return AppTheme.errorColor; // Obese
    }
  }

  String _formatActivityLevel(String? activityLevel) {
    if (activityLevel == null) return 'Chưa thiết lập';

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
        return activityLevel.replaceAll('_', ' ').toUpperCase();
    }
  }

  String? _formatGoal(String? goal) {
    if (goal == null) return null;

    switch (goal.toLowerCase()) {
      case 'lose_weight':
        return 'Giảm cân';
      case 'maintain':
        return 'Duy trì';
      case 'gain_weight':
        return 'Tăng cân';
      default:
        return goal.replaceAll('_', ' ').toUpperCase();
    }
  }
}
