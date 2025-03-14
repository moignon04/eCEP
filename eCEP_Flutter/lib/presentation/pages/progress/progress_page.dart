import 'package:client/app/extension/color.dart';
import 'package:client/presentation/controllers/progress/progress_controller.dart';
import 'package:client/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressPage extends StatelessWidget {
  final ProgressController controller = Get.put(ProgressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Mes progrès"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              controller.loadData();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildOverallProgress(),
                    SizedBox(height: 30),
                    _buildRecentActivities(),
                    SizedBox(height: 30),
                    _buildSubjectProgress(),
                    SizedBox(height: 30),
                    _buildAchievements(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOverallProgress() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progression globale',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressCircle(
                  value: controller.profile['completedCourses'] / controller.totalCourses,
                  label: 'Cours',
                  centerText: '${controller.profile['completedCourses']}/${controller.totalCourses}',
                  color: AppColors.primary,
                ),
                _buildProgressCircle(
                  value: controller.profile['completedExercises'] / controller.totalExercises,
                  label: 'Exercices',
                  centerText: '${controller.profile['completedExercises']}/${controller.totalExercises}',
                  color: AppColors.secondary,
                ),
                _buildProgressCircle(
                  value: controller.profile['averageScore'] / 100,
                  label: 'Score moyen',
                  centerText: '${controller.profile['averageScore']}%',
                  color: AppColors.primaryVariant,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Niveau ${controller.profile['level']}',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: (controller.profile['points'] % 1000) / 1000,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.profile['points'] % 1000} / 1000 points',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Total: ${controller.profile['points']} points',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle({
    required double value,
    required String label,
    required String centerText,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 8,
              ),
              Center(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: Text(
                    centerText,
                    key: ValueKey(centerText),
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMedium,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activités récentes',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.recentActivities.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = controller.recentActivities[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getActivityColor(activity['type']).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getActivityIcon(activity['type']),
                    color: _getActivityColor(activity['type']),
                  ),
                ),
                title: Text(activity['title']),
                subtitle: Text(activity['description']),
                trailing: Text(
                  activity['timeAgo'],
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progression par matière',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ...controller.subjectProgress.map((subject) => _buildSubjectProgressItem(subject)),
      ],
    );
  }

  Widget _buildSubjectProgressItem(Map<String, dynamic> subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getSubjectColor(subject['name']).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    subject['name'][0],
                    style: TextStyle(
                      color: _getSubjectColor(subject['name']),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                subject['name'],
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Text(
                '${subject['progress']}%',
                style: TextStyle(
                  color: _getSubjectColor(subject['name']),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: subject['progress'] / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_getSubjectColor(subject['name'])),
              minHeight: 8,
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${subject['completedLessons']} leçons terminées',
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 12,
                ),
              ),
              Text(
                '${subject['completedExercises']} exercices terminés',
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes réussites',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAchievementItem(
                      icon: Icons.emoji_events,
                      value: controller.achievements['totalBadges'].toString(),
                      label: 'Badges',
                      color: Colors.amber,
                    ),
                    _buildAchievementItem(
                      icon: Icons.psychology,
                      value: controller.achievements['averageScore'].toString() + '%',
                      label: 'Score moyen',
                      color: Colors.blue,
                    ),
                    _buildAchievementItem(
                      icon: Icons.timer,
                      value: controller.achievements['totalHours'].toString() + 'h',
                      label: 'Temps d\'étude',
                      color: Colors.purple,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAchievementItem(
                      icon: Icons.local_fire_department,
                      value: controller.achievements['streakDays'].toString(),
                      label: 'Jours consécutifs',
                      color: Colors.orange,
                    ),
                    _buildAchievementItem(
                      icon: Icons.assignment_turned_in,
                      value: controller.achievements['exercisesCompleted'].toString(),
                      label: 'Exercices terminés',
                      color: Colors.green,
                    ),
                    _buildAchievementItem(
                      icon: Icons.star,
                      value: controller.achievements['highestStreak'].toString(),
                      label: 'Meilleure série',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Derniers badges obtenus',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.recentBadges.length,
                    itemBuilder: (context, index) {
                      final badge = controller.recentBadges[index];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 80,
                        margin: EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                image: DecorationImage(
                                  image: AssetImage(badge['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: badge['isUnlocked']
                                  ? Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 24,
                              )
                                  : null,
                            ),
                            SizedBox(height: 8),
                            Text(
                              badge['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMedium,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'cours':
        return AppColors.primary;
      case 'exercice':
        return AppColors.secondary;
      case 'badge':
        return AppColors.primaryVariant;
      default:
        return AppColors.textDark;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cours':
        return Icons.menu_book_rounded;
      case 'exercice':
        return Icons.assignment_rounded;
      case 'badge':
        return Icons.emoji_events_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathématiques':
        return AppColors.mathColor;
      case 'français':
        return AppColors.frenchColor;
      case 'histoire-géographie':
        return AppColors.historyColor;
      case 'sciences':
        return AppColors.scienceColor;
      default:
        return AppColors.primary;
    }
  }
}