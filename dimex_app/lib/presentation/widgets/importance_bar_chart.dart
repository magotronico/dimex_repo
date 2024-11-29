import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ImportanceBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        // barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 2,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(value.toInt().toString(), style: TextStyle(fontSize: 12));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                switch (value.toInt()) {
                  case 0:
                    return Text('High', style: TextStyle(color: Colors.red));
                  case 1:
                    return Text('Medium', style: TextStyle(color: Colors.orange));
                  case 2:
                    return Text('Low', style: TextStyle(color: Colors.green));
                  default:
                    return Text('');
                }
              },
              reservedSize: 60,
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 6, // High importance bar length
                color: Colors.red,
                width: 15,
                borderRadius: BorderRadius.circular(5),
                // Adding the label at the end of the bar
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 10,
                  color: Colors.red[100],
                ),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 4, // Medium importance bar length
                color: Colors.orange,
                width: 15,
                borderRadius: BorderRadius.circular(5),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 10,
                  color: Colors.orange[100],
                ),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 2, // Low importance bar length
                color: Colors.green,
                width: 15,
                borderRadius: BorderRadius.circular(5),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 10,
                  color: const Color.fromARGB(255, 182, 203, 182),
                ),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: EdgeInsets.zero,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Color.fromRGBO(255, 255, 255, 0),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
