import 'package:client/data/models/lesson.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/app/extension/color.dart';
import 'package:client/presentation/controllers/courses/course_player_controller.dart';
import 'package:client/presentation/widgets/app_bar_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CoursePlayerPage extends StatelessWidget {
  final CoursePlayerController controller = Get.put(CoursePlayerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Leçon",
        showBackButton: true,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isBookmarked.value
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: AppColors.primary,
            ),
            onPressed: () => controller.toggleBookmark(),
          )),
          IconButton(
            icon: Icon(Icons.notes_outlined, color: AppColors.textDark),
            onPressed: () => Get.toNamed('/notes', arguments: controller.lesson.value),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContentPlayer(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.lesson.value.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildLessonInfo(),
                      SizedBox(height: 20),
                      _buildContentSection(),
                      SizedBox(height: 24),
                      _buildProgressButtons(),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildContentPlayer() {
    Lesson lesson = controller.lesson.value;

    if (lesson.type.toLowerCase() == 'video') {
      return Obx(() {
        if (controller.videoController == null || !controller.isVideoInitialized.value) {
          return Container(
            height: 220,
            color: Colors.black,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          height: 220,
          child: Chewie(
            controller: controller.chewieController!,
          ),
        );
      });
    } else if (lesson.type.toLowerCase() == 'audio') {
      return Container(
        height: 120,
        padding: EdgeInsets.all(20),
        color: AppColors.darkCard,
        child: Obx(() {
          if (controller.audioController == null || !controller.isAudioInitialized.value) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: () => controller.togglePlay(),
                  ),
                  SizedBox(width: 16),
                  Text(
                    controller.formatDuration(controller.position.value),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: controller.position.value.inSeconds.toDouble(),
                      min: 0,
                      max: controller.duration.value.inSeconds.toDouble(),
                      onChanged: (value) => controller.seekTo(value.toInt()),
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.textLight.withOpacity(0.3),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    controller.formatDuration(controller.duration.value),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          );
        }),
      );
    } else {
      // Pour les leçons de type lecture ou interactif
      return Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              controller.courseColor.withOpacity(0.8),
              controller.courseColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getLessonTypeIcon(lesson.type),
                color: Colors.white,
                size: 36,
              ),
              SizedBox(width: 16),
              Text(
                lesson.type,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLessonInfo() {
    Lesson lesson = controller.lesson.value;

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: Icons.menu_book,
            title: controller.courseName,
            subtitle: "Cours",
          ),
          _buildInfoItem(
            icon: Icons.access_time,
            title: "${lesson.duration ~/ 60} min",
            subtitle: "Durée",
          ),
          _buildInfoItem(
            icon: _getLessonTypeIcon(lesson.type),
            title: lesson.type,
            subtitle: "Type",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String title, required String subtitle}) {
    return Column(
      children: [
        Icon(icon, color: controller.courseColor),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    Lesson lesson = controller.lesson.value;

    if (lesson.type.toLowerCase() == 'lecture') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contenu de la leçon",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          Text(
            lesson.content,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textDark,
              height: 1.6,
            ),
          ),
        ],
      );
    } else if (lesson.type.toLowerCase() == 'interactive') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contenu interactif",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: controller.courseColor.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 48,
                  color: controller.courseColor,
                ),
                SizedBox(height: 16),
                Text(
                  "Cette leçon contient du contenu interactif.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.launchInteractiveContent(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.courseColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Lancer l'activité interactive",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Container(); // Pour video et audio, le contenu est déjà affiché
    }
  }

  Widget _buildProgressButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.hasPreviousLesson ? () => controller.goToPreviousLesson() : null,
            icon: Icon(Icons.arrow_back),
            label: Text("Précédent"),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.completeAndContinue(),
            icon: Icon(controller.lesson.value.isCompleted ? Icons.check : Icons.arrow_forward),
            label: Text(controller.hasNextLesson ? "Suivant" : "Terminer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getLessonTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.headphones;
      case 'lecture':
        return Icons.article;
      case 'interactive':
        return Icons.touch_app;
      default:
        return Icons.description;
    }
  }
}