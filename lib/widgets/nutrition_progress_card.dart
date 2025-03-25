import 'package:flutter/material.dart';
import '../app_theme.dart';

class NutritionProgressCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
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

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${current.toInt()}/${target.toInt()} $unit',
                  style: Theme.of(context).textTheme.bodyMedium,
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
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}