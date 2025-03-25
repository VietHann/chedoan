import 'package:flutter/material.dart';

import '../app_theme.dart';

class NutritionProgressCard extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final Color progressColor;
  final String unit;
  final bool isCompact;
  final bool smallSize;

  const NutritionProgressCard({
    Key? key,
    required this.title,
    required this.current,
    required this.target,
    required this.progressColor,
    required this.unit,
    this.isCompact = false,
    this.smallSize = false,
  }) : super(key: key);

  double get _progressValue {
    if (target == 0) return 0.0;
    final value = current / target;
    return value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(smallSize ? 8.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: smallSize ? 14 : null,
                      ),
                ),
                Text(
                  '$current/$target $unit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: smallSize ? 12 : null,
                      ),
                ),
              ],
            ),
            if (!isCompact) const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: progressColor,
                minHeight: isCompact ? 4 : 8,
              ),
            ),
            if (!isCompact)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '$percentage% mục tiêu hàng ngày',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: smallSize ? 10 : null,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
