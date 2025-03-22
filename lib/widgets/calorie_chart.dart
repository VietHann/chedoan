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
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16.0),
      child: Column(
        children: [
          Container(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${calories[groupIndex].toInt()} kcal\n${DateFormat.MMMd().format(dates[groupIndex])}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (context, value) => TextStyle(
                      color: _isToday(dates[value.toInt()]) 
                          ? AppTheme.primaryColor 
                          : AppTheme.secondaryTextColor,
                      fontWeight: _isToday(dates[value.toInt()]) 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                    getTitles: (value) {
                      final index = value.toInt();
                      if (index >= 0 && index < dates.length) {
                        return DateFormat('E').format(dates[index])[0];
                      }
                      return '';
                    },
                    margin: 10,
                    reservedSize: 30,
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (context, value) => const TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 10,
                    ),
                    getTitles: (value) {
                      if (value == 0) {
                        return '';
                      }
                      
                      if (value >= 1000) {
                        return '${(value / 1000).toStringAsFixed(1)}k';
                      } else {
                        return value.toInt().toString();
                      }
                    },
                    reservedSize: 45,
                    interval: _calculateInterval(),
                  ),
                  topTitles: SideTitles(showTitles: false),
                  rightTitles: SideTitles(showTitles: false),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % _calculateInterval() == 0,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                barGroups: _getBarGroups(),
              ),
            ),
          ),
          // Target line legend
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 3,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Target: ${targetCalories.toInt()} kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    if (calories.isEmpty) return targetCalories * 1.2;
    double maxCalories = calories.reduce((curr, next) => curr > next ? curr : next);
    return maxCalories > targetCalories 
        ? maxCalories * 1.2 
        : targetCalories * 1.2;
  }

  double _calculateInterval() {
    final maxY = _getMaxY();
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 2000) return 500;
    if (maxY <= 5000) return 1000;
    return 1000;
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(calories.length, (index) {
      final calorie = calories[index];
      final date = dates[index];
      final isToday = _isToday(date);
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            y: calorie,  // Phiên bản cũ sử dụng y thay vì toY
            colors: [isToday ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.6)],
            width: isToday ? 18 : 16,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              y: targetCalories,  // Phiên bản cũ sử dụng y thay vì toY
              colors: [Colors.grey[200]!],
            ),
          ),
        ],
      );
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}