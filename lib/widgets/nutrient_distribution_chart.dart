import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../app_theme.dart';

class NutrientDistributionChart extends StatefulWidget {
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
  State<NutrientDistributionChart> createState() =>
      _NutrientDistributionChartState();
}

class _NutrientDistributionChartState extends State<NutrientDistributionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.protein + widget.carbs + widget.fat;

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
              'Không có dữ liệu dinh dưỡng',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate percentages
    final proteinPercentage = (widget.protein / total * 100).round();
    final carbsPercentage = (widget.carbs / total * 100).round();
    final fatPercentage = (widget.fat / total * 100).round();

    return Column(
      children: [
        // Chart
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 35,
              sections: [
                PieChartSectionData(
                  value: widget.protein,
                  title: '$proteinPercentage%',
                  color: AppTheme.secondaryColor,
                  radius: touchedIndex == 0 ? 90 : 80,
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
                  value: widget.carbs,
                  title: '$carbsPercentage%',
                  color: AppTheme.accentColor,
                  radius: touchedIndex == 1 ? 90 : 80,
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
                  value: widget.fat,
                  title: '$fatPercentage%',
                  color: Colors.purpleAccent,
                  radius: touchedIndex == 2 ? 90 : 80,
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

        // Legend with detailed information
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDetailedLegendItem('Đạm', AppTheme.secondaryColor,
                  '${widget.protein.toStringAsFixed(1)}g ($proteinPercentage%)'),
              _buildDetailedLegendItem('Tinh bột', AppTheme.accentColor,
                  '${widget.carbs.toStringAsFixed(1)}g ($carbsPercentage%)'),
              _buildDetailedLegendItem('Chất béo', Colors.purpleAccent,
                  '${widget.fat.toStringAsFixed(1)}g ($fatPercentage%)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedLegendItem(String label, Color color, String detail) {
    return Column(
      children: [
        Row(
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
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: const TextStyle(
            fontSize: 10,
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
