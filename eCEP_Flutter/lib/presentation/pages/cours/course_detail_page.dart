
import 'package:client/presentation/controllers/courses/course_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/data/models/chapter.dart';
import '/app/extension/color.dart';
import 'package:client/presentation/widgets/app_bar_widget.dart';
import 'package:client/presentation/widgets/lesson_widget.dart';
import 'package:client/presentation/widgets/exercise_widget.dart';

class CourseDetailPage extends StatelessWidget {
  final CourseDetailController controller = Get.put(CourseDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() =>
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCourseHeader(),
                        SizedBox(height: 20),
                        _buildTabs(),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildSelectedTabContent(),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      title: '',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: AppColors.textDark,
          ),
          onPressed: () {
            // Menu options
          },
        ),
      ],
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: controller.course.value.subjectColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.course.value.subject,
              style: TextStyle(
                color: controller.course.value.subjectColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            controller.course.value.title,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 8),
              Text(
                controller.course.value.teacherName,
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.menu_book_outlined,
                size: 16,
                color: AppColors.textMedium,
              ),
              SizedBox(width: 4),
              Text(
                "${controller.course.value.totalLessons} leçons",
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 16),
              Icon(
                Icons.assignment_outlined,
                size: 16,
                color: AppColors.textMedium,
              ),
              SizedBox(width: 4),
              Text(
                "${controller.course.value.totalExercises} exercices",
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: controller.toggleDescription,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description du cours',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  controller.course.value.description,
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: controller.isExpanded.value ? null : 2,
                  overflow: controller.isExpanded.value ? null : TextOverflow
                      .ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  controller.isExpanded.value ? "Voir moins" : "Voir plus",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: controller.course.value.progress / 100,
              backgroundColor: AppColors.textLight.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                  controller.course.value.subjectColor),
              minHeight: 8,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progression: ${controller.course.value.progress}%",
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (controller.course.value.progress > 0 &&
                  controller.course.value.progress < 100)
                Text(
                  "Reprendre",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Contenu'),
          _buildTabItem(1, 'Discussion'),
          _buildTabItem(2, 'Ressources'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTabIndex.value = index,
        child: Container(
          decoration: BoxDecoration(
            color: controller.selectedTabIndex.value == index
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: controller.selectedTabIndex.value == index
                    ? Colors.white
                    : AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (controller.selectedTabIndex.value) {
      case 0:
        return _buildContentTab();
      case 1:
        return _buildDiscussionTab();
      case 2:
        return _buildResourcesTab();
      default:
        return _buildContentTab();
    }
  }

  Widget _buildContentTab() {
    return controller.course.value.chapters.isEmpty
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'Aucun contenu disponible pour le moment.',
          style: TextStyle(
            color: AppColors.textMedium,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: controller.course.value.chapters.map((chapter) {
        return _buildChapterItem(chapter);
      }).toList(),
    );
  }

  Widget _buildChapterItem(Chapter chapter) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${chapter.id}',
                    style: TextStyle(
                      color: AppColors.primary,
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
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "${chapter.lessons.length} leçons",
                          style: TextStyle(
                            color: AppColors.textMedium,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "•",
                          style: TextStyle(
                            color: AppColors.textMedium,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "${chapter.exercises.length} exercices",
                          style: TextStyle(
                            color: AppColors.textMedium,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "${chapter.progress}%",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Lessons
          if (chapter.lessons.isNotEmpty) ...[
            Text(
              "Leçons",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            ...chapter.lessons.map((lesson) =>
                LessonItem(
                  lesson: lesson,
                  onTap: () {
                    // Navigation vers la leçon
                    Get.toNamed('/lesson-detail', arguments: lesson);
                  },
                )),
            SizedBox(height: 16),
          ],
          // Exercises
          if (chapter.exercises.isNotEmpty) ...[
            Text(
              "Exercices",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            ...chapter.exercises.map((exercise) =>
                ExerciseItem(
                  exercise: exercise,
                  onTap: () {
                    // Navigation vers l'exercice
                    Get.toNamed('/exercise-detail', arguments: exercise);
                  },
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscussionTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            'Discussion avec l\'enseignant et les autres élèves',
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Ouvrir la discussion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Poser une question',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_file_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            'Ressources supplémentaires pour le cours',
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          // Placeholder pour les ressources
          Container(
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
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guide des fractions.pdf',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ajouté par ${controller.course.value.teacherName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.download_outlined,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    // Télécharger la ressource
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Commencer/continuer le cours
                if (controller.course.value.chapters.isNotEmpty &&
                    controller.course.value.chapters.first.lessons.isNotEmpty) {
                  Get.toNamed('/lesson-detail',
                      arguments: controller.course.value.chapters.first.lessons.first);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                controller.course.value.progress > 0
                    ? 'Reprendre le cours'
                    : 'Commencer le cours',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 16), // Espace entre les boutons
          if (!controller.course.value.isDownloaded)
            IconButton(
              onPressed: () {
                controller.downloadCourse();
              },
              icon: Icon(
                Icons.download_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          if (controller.course.value.isDownloaded)
            IconButton(
              onPressed: () {
                // Option pour supprimer le téléchargement
                Get.snackbar(
                  'Téléchargement supprimé',
                  'Le cours a été retiré de votre appareil.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
                controller.course.update((val) {
                  val?.isDownloaded = false;
                });
              },
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}