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
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Log Out'),
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
        title: 'My Profile',
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
                    child: Text('Error: ${state.message}'),
                  );
                } else {
                  return const Center(
                    child: Text('No profile data available'),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: Text('Please log in to view your profile'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(UserProfile profile) {
    // Calculate BMI if height and weight are available
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
          // Profile header
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      (profile.name?.isNotEmpty ?? false) 
                          ? profile.name![0].toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    profile.name ?? 'Name not set',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  
                  // Email
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Edit Profile Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(profile: profile),
                        ),
                      ).then((_) => _loadUserProfile());
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Health Info Section
          _buildSectionTitle('Health Information'),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Basic Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Age', profile.age?.toString() ?? 'Not set', 'years'),
                      _buildStatColumn('Height', profile.height?.toString() ?? 'Not set', 'cm'),
                      _buildStatColumn('Weight', profile.weight?.toString() ?? 'Not set', 'kg'),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // BMI Information
                  if (bmi != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BMI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${bmi.toStringAsFixed(1)} - $bmiCategory',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getBmiColor(bmi),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (bmi / 40).clamp(0.0, 1.0), // Scale BMI to 0-1 range (max BMI considered is 40)
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_getBmiColor(bmi)),
                    ),
                  ] else ...[
                    const Text(
                      'Complete your profile to see BMI information',
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
          
          const SizedBox(height: 24),
          
          // Nutrition Goals Section
          _buildSectionTitle('Nutrition Goals'),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildGoalRow('Goal', profile.goal?.replaceAll('_', ' ').toUpperCase() ?? 'Not set'),
                  const SizedBox(height: 8),
                  _buildGoalRow('Activity Level', _formatActivityLevel(profile.activityLevel)),
                  const SizedBox(height: 8),
                  _buildGoalRow('Target Calories', '${profile.targetCalories ?? 'Not calculated'} kcal'),
                  const SizedBox(height: 8),
                  _buildGoalRow('Target Water', '${profile.targetWater != null ? '${profile.targetWater! / 1000} L' : 'Not calculated'}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Macro Targets Section
          _buildSectionTitle('Macronutrient Targets'),
          
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
                    _buildMacroRow('Protein', profile.targetProtein!.toInt(), AppTheme.secondaryColor),
                    const SizedBox(height: 8),
                    _buildMacroRow('Carbs', profile.targetCarbs!.toInt(), AppTheme.accentColor),
                    const SizedBox(height: 8),
                    _buildMacroRow('Fat', profile.targetFat!.toInt(), Colors.purpleAccent),
                  ] else ...[
                    const Text(
                      'Complete your profile to see macronutrient targets',
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
              label: const Text('Log Out'),
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

  Widget _buildStatColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 12,
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
    if (activityLevel == null) return 'Not set';
    
    switch (activityLevel) {
      case 'sedentary':
        return 'Sedentary';
      case 'light':
        return 'Lightly Active';
      case 'moderate':
        return 'Moderately Active';
      case 'active':
        return 'Very Active';
      case 'very_active':
        return 'Extremely Active';
      default:
        return activityLevel.replaceAll('_', ' ').toUpperCase();
    }
  }
}
