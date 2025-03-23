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
                  const Icon(
                    Icons.water_drop,
                    color: Colors.blue,
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
                  Text(
                    '$percentComplete%',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amount display
              Text(
                '${currentLiters.toStringAsFixed(1)} / ${targetLiters.toStringAsFixed(1)} L',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Water progress bar
              LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
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
      ),
      child: Text(label),
    );
  }
}