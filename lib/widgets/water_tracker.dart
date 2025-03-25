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
    final currentLiters = currentIntake / 1000.0;
    final targetLiters = targetIntake / 1000.0;
    final percentComplete = (_progressValue * 100).toInt();

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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Lượng nước',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$percentComplete%',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amount display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentLiters.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Text(
                    ' / ',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  Text(
                    '${targetLiters.toStringAsFixed(1)} L',
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Water progress bar with wave effect
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    // Progress indicator
                    FractionallySizedBox(
                      widthFactor: _progressValue,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF5DADE2),
                              Colors.blue,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _buildWavePattern(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick add buttons with improved styling
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
        elevation: 1,
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

  // Simulating a wave pattern with circles
  Widget _buildWavePattern() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                20,
                (index) => Container(
                  width: 4,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
