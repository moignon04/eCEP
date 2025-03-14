// lib/presentation/pages/teacher/dashboard_page.dart
import 'package:client/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../app/extension/color.dart';
import '../../widgets/teacher/teacher_bottom_nav.dart';
import '../../widgets/teacher/class_stats_card.dart';
import '../../widgets/teacher/subject_performance_card.dart';
import '../../widgets/teacher/progress_chart.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({Key? key}) : super(key: key);

  @override
  _TeacherDashboardPageState createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  int _currentIndex = 0;

  // Mock data for teacher dashboard
  final User teacher = User(
    id: 101,
    firstName: 'Marie',
    lastName: 'Durant',
    email: 'marie.durant@ecole.fr',
    avatar: 'assets/avatars/teacher1.png',
    role: 'teacher',
  );

  // Mock class statistics
  final Map<String, dynamic> classStats = {
    'totalStudents': 28,
    'averageScore': 75.3,
    'completedExercises': 420,
    'studentsToReview': 5,
  };

  // Mock data for subject performances
  final List<Map<String, dynamic>> subjectPerformances = [
    {
      'subject': 'Mathématiques',
      'averageScore': 72.5,
      'completedExercises': 120,
      'color': AppColors.mathColor,
    },
    {
      'subject': 'Français',
      'averageScore': 80.2,
      'completedExercises': 105,
      'color': AppColors.frenchColor,
    },
    {
      'subject': 'Histoire-Géographie',
      'averageScore': 68.7,
      'completedExercises': 85,
      'color': AppColors.historyColor,
    },
    {
      'subject': 'Sciences',
      'averageScore': 77.9,
      'completedExercises': 110,
      'color': AppColors.scienceColor,
    },
  ];

  // Mock data for chart
  final Map<String, double> subjectScores = {
    'Mathématiques': 72.5,
    'Français': 80.2,
    'Histoire-Géographie': 68.7,
    'Sciences': 77.9,
  };

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${teacher.firstName}',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              today,
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage(teacher.avatar),
            radius: 18,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques de la classe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ClassStatsCard(
                  title: 'Élèves',
                  value: classStats['totalStudents'].toString(),
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
                ClassStatsCard(
                  title: 'Note moyenne',
                  value: '${classStats['averageScore']}%',
                  icon: Icons.assessment,
                  color: AppColors.success,
                ),
                ClassStatsCard(
                  title: 'Exercices terminés',
                  value: classStats['completedExercises'].toString(),
                  icon: Icons.assignment_turned_in,
                  color: AppColors.secondary,
                ),
                ClassStatsCard(
                  title: 'À revoir',
                  value: classStats['studentsToReview'].toString(),
                  icon: Icons.warning,
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance par matière',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClassProgressPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Voir la classe',
                    style: TextStyle(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SubjectProgressChart(
              subjectScores: subjectScores,
            ),
            const SizedBox(height: 24),
            Text(
              'Détails par matière',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjectPerformances.length,
              itemBuilder: (context, index) {
                final subject = subjectPerformances[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SubjectPerformanceCard(
                    subject: subject['subject'],
                    averageScore: subject['averageScore'],
                    completedExercises: subject['completedExercises'],
                    color: subject['color'],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: TeacherBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Navigation logic would go here
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ClassProgressPage(),
              ),
            );
          }
        },
      ),
    );
  }
}