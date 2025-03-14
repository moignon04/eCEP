import 'package:client/app/extension/color.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SubjectProgressChart extends StatelessWidget {
  final Map<String, double> subjectScores;

  const SubjectProgressChart({
    Key? key,
    required this.subjectScores,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance par matière',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(

                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String subject = '';
                        switch (groupIndex) {
                          case 0:
                            subject = 'Mathématiques';
                            break;
                          case 1:
                            subject = 'Français';
                            break;
                          case 2:
                            subject = 'Histoire-Géo';
                            break;
                          case 3:
                            subject = 'Sciences';
                            break;
                        }
                        return BarTooltipItem(
                          '$subject\n${rod.toY.toInt()}%',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Color(0xff7589a2),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      margin: 20,
                      getTitles: (double value) {
                        switch (value.toInt()) {
                          case 0:
                            return 'Math';
                          case 1:
                            return 'Fr';
                          case 2:
                            return 'HG';
                          case 3:
                            return 'Sc';
                          default:
                            return '';
                        }
                      },
                    ),
                    leftTitles: SideTitles(showTitles: false),
                    topTitles: SideTitles(showTitles: false),
                    rightTitles: SideTitles(showTitles: false),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: [
                    _makeBarGroup(0, subjectScores['Mathématiques'] ?? 0, AppColors.mathColor),
                    _makeBarGroup(1, subjectScores['Français'] ?? 0, AppColors.frenchColor),
                    _makeBarGroup(2, subjectScores['Histoire-Géographie'] ?? 0, AppColors.historyColor),
                    _makeBarGroup(3, subjectScores['Sciences'] ?? 0, AppColors.scienceColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y,
          colors: [color],
          width: 22,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}