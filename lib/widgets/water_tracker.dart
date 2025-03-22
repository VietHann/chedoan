import 'package:flutter/material.dart';

import '../app_theme.dart';

class WaterTracker extends StatelessWidget {
  final int currentIntake;
  final int targetIntake;
  final Function(int) onAddWater;
  final VoidCallback? onTap;

  const WaterTracker({
    Key? key,
    required this.currentIntake,
    required this.targetIntake,
    required this.onAddWater,
    this.onTap,
  }) : super(key: key);

  double get _progressValue {
    if (targetIntake == 0) return 0.0;
    final value = currentIntake / targetIntake;
    return value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title row
              Row(
                children: [
                  const Icon(
                    Icons.water_drop,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Water Intake',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(currentIntake / 1000).toStringAsFixed(1)}/${(targetIntake / 1000).toStringAsFixed(1)} L',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Water progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    // Background
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.grey[200],
                    ),
                    // Water fill
                    FractionallySizedBox(
                      widthFactor: _progressValue,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF5DADE2),
                              Colors.blue,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Quick add buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWaterButton(100, '+100ml'),
                  _buildWaterButton(250, '+250ml'),
                  _buildWaterButton(500, '+500ml'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterButton(int amount, String label) {
    return ElevatedButton(
      onPressed: () => onAddWater(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 0,
      ),
      child: Text(label),
    );
  }
}
