import 'package:client/app/extension/color.dart';
import 'package:client/data/models/exercise.dart';
import 'package:client/data/models/question.dart';

import 'package:client/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ExerciseDetailPage extends StatelessWidget {
  final Exercise exercise = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: exercise.title,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppColors.secondary,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Difficulté: ${exercise.difficulty}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ...exercise.questions.map((question) {
              return _buildQuestionItem(question);
            }).toList(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Soumettre l'exercice
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
                'Soumettre l\'exercice',
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

  Widget _buildQuestionItem(Question question) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 10),
          ...question.choices.map((choice) {
            return RadioListTile(
              title: Text(choice.text),
              value: choice.id,
              groupValue: null, // À gérer avec un état
              onChanged: (value) {
                // Gérer la sélection
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}