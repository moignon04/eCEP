import 'package:client/app/extension/color.dart';
import 'package:client/data/models/lesson.dart';
import 'package:client/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LessonDetailPage extends StatelessWidget {
  final Lesson lesson = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: lesson.title,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lesson.type == 'video')
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.card,
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              ),
            SizedBox(height: 20),
            Text(
              lesson.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Durée: ${_formatDuration(lesson.duration)}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            SizedBox(height: 20),
            Text(
              lesson.content,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Marquer la leçon comme terminée
                Get.back(result: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
              child: Text(
                'Marquer comme terminé',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    return '$minutes min';
  }
}