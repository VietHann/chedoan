import 'package:flutter/material.dart';

import '../app_theme.dart';

class NutritionProgressCard extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final Color progressColor;
  final String unit;
  final bool isCompact;

  const NutritionProgressCard({
    Key? key,
    required this.title,
    required this.current,
    required this.target,
    required this.progressColor,
    required this.unit,
    this.isCompact = false,
  }) : super(key: key);

  double get _progressValue {
    if (target == 0) return 0.0;
    final value = current / target;
    return value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$current/$target $unit',
                  style: TextStyle(
                    fontSize: isCompact ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isCompact ? 8 : 12),
            
            // Progress bar
            LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: isCompact ? 6 : 8,
              borderRadius: BorderRadius.circular(isCompact ? 3 : 4),
            ),
            
            if (!isCompact) ...[
              const SizedBox(height: 8),
              
              // Progress percentage
              Text(
                '${(_progressValue * 100).toInt()}% of daily goal',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
