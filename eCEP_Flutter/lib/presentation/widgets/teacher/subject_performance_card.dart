import 'package:client/app/extension/color.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SubjectPerformanceCard extends StatelessWidget {
  final String subject;
  final double averageScore;
  final int completedExercises;
  final Color color;

  const SubjectPerformanceCard({
    Key? key,
    required this.subject,
    required this.averageScore,
    required this.completedExercises,
    required this.color,
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
              subject,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 30.0,
                  lineWidth: 5.0,
                  percent: averageScore / 100,
                  center: Text(
                    '${averageScore.toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  progressColor: color,
                  backgroundColor: color.withOpacity(0.2),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note moyenne',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedExercises exercices terminés',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}