import 'package:client/data/models/chapter.dart';
import 'package:client/data/models/course.dart';
import 'package:client/data/models/exercise.dart';
import 'package:client/data/models/lesson.dart';
import 'package:client/presentation/controllers/courses/course_content_controller.dart';
import 'package:client/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/app/extension/color.dart';
import 'package:percent_indicator/percent_indicator.dart';
class CourseContentPage extends StatelessWidget {
  final CourseContentController controller = Get.put(CourseContentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Contenu du cours",
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.textDark),
            onPressed: () => controller.shareCourse(),
          ),
          Obx(() =>
              IconButton(
                icon: Icon(
                  controller.course.value.isDownloaded
                      ? Icons.file_download_done
                      : Icons.file_download_outlined,
                  color: controller.course.value.isDownloaded ? AppColors
                      .success : AppColors.textDark,
                ),
                onPressed: () =>
                controller.course.value.isDownloaded
                    ? Get.toNamed('/course-download-manager',
                    arguments: controller.course.value)
                    : controller.downloadCourse(),
              )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          Course course = controller.course.value;

          return Column(
            children: [
              _buildCourseHeader(course),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressSection(course),
                      SizedBox(height: 24),
                      _buildChaptersSection(course),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      //bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildCourseHeader(Course course) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [course.subjectColor.withOpacity(0.8), course.subjectColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              course.subject,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            course.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Par ${course.teacherName}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Course course) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Votre progression",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          LinearPercentIndicator(
            percent: course.progress / 100,
            lineHeight: 12,
            backgroundColor: AppColors.background,
            progressColor: course.subjectColor,
            barRadius: Radius.circular(6),
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressItem(
                icon: Icons.menu_book_outlined,
                value: "${course.totalLessons}",
                label: "Leçons",
              ),
              _buildProgressItem(
                icon: Icons.extension_outlined,
                value: "${course.totalExercises}",
                label: "Exercices",
              ),
              _buildProgressItem(
                icon: Icons.schedule_outlined,
                value: "${controller.calculateTotalDuration()} min",
                label: "Durée totale",
              ),
              _buildProgressItem(
                icon: Icons.percent_outlined,
                value: "${course.progress}%",
                label: "Complété",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      {required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textMedium, size: 20),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontSize: 14,
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

  Widget _buildChaptersSection(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chapitres",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: course.chapters.length,
          itemBuilder: (context, index) {
            Chapter chapter = course.chapters[index];
            return _buildChapterItem(chapter, index);
          },
        ),
      ],
    );
  }

  Widget _buildChapterItem(Chapter chapter, int index) {
    return Obx(() {
      bool isExpanded = controller.expandedChapters[index] ?? false;

      return Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.toggleChapter(index),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
                bottom: isExpanded ? Radius.zero : Radius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: controller.course.value.subjectColor.withOpacity(
                            0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            color: controller.course.value.subjectColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${chapter.lessons.length} leçons · ${chapter
                                .exercises.length} exercices",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      children: [
                        Text(
                          "${chapter.progress}%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: controller.course.value.subjectColor,
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons
                              .keyboard_arrow_down,
                          color: AppColors.textMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(height: 1, thickness: 1, color: AppColors.background),
              _buildLessonsList(chapter.lessons),
              if (chapter.exercises.isNotEmpty) _buildExercisesList(
                  chapter.exercises),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildLessonsList(List<Lesson> lessons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Leçons",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, thickness: 1, color: AppColors.background),
          itemBuilder: (context, index) {
            Lesson lesson = lessons[index];
            return InkWell(
              onTap: () => controller.openLesson(lesson),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      lesson.typeIcon,
                      color: controller.course.value.subjectColor,
                      size: 20,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${lesson.duration ~/ 60} min · ${lesson.type}",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    lesson.isCompleted
                        ? Icon(
                        Icons.check_circle, color: AppColors.success, size: 20)
                        : Icon(
                        Icons.play_circle_outline, color: AppColors.primary,
                        size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExercisesList(List<Exercise> exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Exercices",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: exercises.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, thickness: 1, color: AppColors.background),
          itemBuilder: (context, index) {
            Exercise exercise = exercises[index];
            return InkWell(
              onTap: () => controller.openExercise(exercise),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getExerciseTypeIcon(exercise.type),
                      color: controller.course.value.subjectColor,
                      size: 20,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${exercise.points} points · ${_getDifficultyText(
                                exercise.difficulty)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    exercise.isCompleted
                        ? Row(
                      children: [
                        Text(
                          "${exercise.score}%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.check_circle, color: AppColors.success,
                            size: 20),
                      ],
                    )
                        : Icon(
                        Icons.extension_outlined, color: AppColors.primary,
                        size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  IconData _getExerciseTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return Icons.quiz;
      case 'interactive':
        return Icons.touch_app;
      case 'assignment':
        return Icons.assignment;
      default:
        return Icons.extension;
    }
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return "Facile";
      case 2:
        return "Moyen";
      case 3:
        return "Difficile";
      default:
        return "Moyen";
    }
  }
}