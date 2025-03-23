import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';

class CalorieChart extends StatelessWidget {
  final List<double> calories;
  final List<DateTime> dates;
  final double targetCalories;

  const CalorieChart({
    Key? key,
    required this.calories,
    required this.dates,
    required this.targetCalories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < dates.length) {
                  return Text(
                    DateFormat.E().format(dates[value.toInt()]).substring(0, 1),
                    style: const TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  );
                }
                return const Text('');
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 500,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: calories.length - 1.0,
        minY: 0,
        maxY: _calculateMaxY(),
        lineBarsData: [
          // Đường mục tiêu
          LineChartBarData(
            spots: List.generate(
              calories.length,
              (index) => FlSpot(index.toDouble(), targetCalories),
            ),
            isCurved: false,
            color: AppTheme.primaryColor.withOpacity(0.3),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            dashArray: [5, 5], // Tạo đường đứt nét
          ),
          // Đường calo thực tế
          LineChartBarData(
            spots: List.generate(
              calories.length,
              (index) => FlSpot(index.toDouble(), calories[index]),
            ),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppTheme.primaryColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY() {
    double maxCalories =
        calories.reduce((curr, next) => curr > next ? curr : next);
    double maxValue =
        maxCalories > targetCalories ? maxCalories : targetCalories;
    return maxValue * 1.2; // Thêm 20% khoảng trống phía trên
  }
}
