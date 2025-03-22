import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../app_theme.dart';

class NutrientDistributionChart extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;

  const NutrientDistributionChart({
    Key? key,
    required this.protein,
    required this.carbs,
    required this.fat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;
    
    // If all values are 0, show an empty chart with a message
    if (total <= 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: AppTheme.secondaryTextColor,
            ),
            SizedBox(height: 8),
            Text(
              'No nutrition data available',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate percentages
    final proteinPercentage = protein / total * 100;
    final carbsPercentage = carbs / total * 100;
    final fatPercentage = fat / total * 100;

    return Column(
      children: [
        // Chart
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 35,
              sections: [
                PieChartSectionData(
                  value: protein,
                  title: '${proteinPercentage.toStringAsFixed(0)}%',
                  color: AppTheme.secondaryColor,
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  badgeWidget: _Badge(
                    'P',
                    AppTheme.secondaryColor,
                  ),
                  badgePositionPercentageOffset: .98,
                ),
                PieChartSectionData(
                  value: carbs,
                  title: '${carbsPercentage.toStringAsFixed(0)}%',
                  color: AppTheme.accentColor,
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  badgeWidget: _Badge(
                    'C',
                    AppTheme.accentColor,
                  ),
                  badgePositionPercentageOffset: .98,
                ),
                PieChartSectionData(
                  value: fat,
                  title: '${fatPercentage.toStringAsFixed(0)}%',
                  color: Colors.purpleAccent,
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  badgeWidget: _Badge(
                    'F',
                    Colors.purpleAccent,
                  ),
                  badgePositionPercentageOffset: .98,
                ),
              ],
            ),
          ),
        ),
        
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Protein', AppTheme.secondaryColor, '${protein.toStringAsFixed(1)}g'),
            const SizedBox(width: 16),
            _buildLegendItem('Carbs', AppTheme.accentColor, '${carbs.toStringAsFixed(1)}g'),
            const SizedBox(width: 16),
            _buildLegendItem('Fat', Colors.purpleAccent, '${fat.toStringAsFixed(1)}g'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String amount) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $amount',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
