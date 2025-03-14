import 'package:client/app/extension/color.dart';
import 'package:client/data/models/chapter.dart';
import 'package:client/data/models/course.dart';
import 'package:client/data/models/exercise.dart';
import 'package:client/data/models/lesson.dart';
import 'package:client/data/models/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseContentController extends GetxController {
  final course = Course(
    id: 0,
    title: '',
    subject: '',
    description: '',
    progress: 0,
    image: '',
    isDownloaded: false,
    chapters: [],
    teacherName: '',
    totalLessons: 0,
    totalExercises: 0,
  ).obs;

  final isLoading = true.obs;
  final expandedChapters = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourseData();
  }

  void fetchCourseData() {
    // Dans une application réelle, vous feriez un appel API ici
    // Pour cet exemple, nous utilisons les données mockées
    try {
      if (Get.arguments != null) {
        course.value = Get.arguments;
      } else {
        // Utiliser les données mockées comme fallback
        final mockCourse = Course.fromJson(MockData.courses[0]);
        course.value = mockCourse;
      }

      // Initialiser l'état d'expansion des chapitres (tous fermés par défaut)
      for (int i = 0; i < course.value.chapters.length; i++) {
        expandedChapters[i] = false;
      }
    } catch (e) {
      print('Erreur lors du chargement du cours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleChapter(int index) {
    expandedChapters[index] = !(expandedChapters[index] ?? false);
  }

  int calculateTotalDuration() {
    int totalMinutes = 0;
    for (Chapter chapter in course.value.chapters) {
      for (Lesson lesson in chapter.lessons) {
        totalMinutes += lesson.duration ~/ 60;
      }
    }
    return totalMinutes;
  }

  void openLesson(Lesson lesson) {
    // Trouver le chapitre et l'index de la leçon
    Chapter currentChapter = course.value.chapters.firstWhere(
          (chapter) => chapter.lessons.any((l) => l.id == lesson.id),
    );
    int lessonIndex = currentChapter.lessons.indexWhere((l) => l.id == lesson.id);

    // Déterminer s'il y a une leçon précédente/suivante
    bool hasPrevious = lessonIndex > 0;
    bool hasNext = lessonIndex < currentChapter.lessons.length - 1;

    Get.toNamed('/course-player', arguments: {
      'lesson': lesson,
      'courseName': course.value.title,
      'courseColor': course.value.subjectColor,
      'hasPrevious': hasPrevious,
      'hasNext': hasNext,
      'chapterId': currentChapter.id,
    })?.then((result) {
      if (result != null) {
        // Gérer le résultat de la navigation (next, previous, completed)
        if (result == 'next' && hasNext) {
          openLesson(currentChapter.lessons[lessonIndex + 1]);
        } else if (result == 'previous' && hasPrevious) {
          openLesson(currentChapter.lessons[lessonIndex - 1]);
        } else {
          // Mettre à jour le cours si nécessaire
          fetchCourseData();
        }
      }
    });
  }

  void openExercise(Exercise exercise) {
    Get.toNamed('/exercise', arguments: {
      'exercise': exercise,
      'courseColor': course.value.subjectColor,
    });
  }

  void shareCourse() {
    // Implémenter le partage du cours
    Get.snackbar(
      'Partage',
      'Partage du cours "${course.value.title}" en cours...',
      backgroundColor: Colors.white,
      colorText: AppColors.textDark,
    );
  }

  void downloadCourse() {
    // Implémenter le téléchargement du cours
    Get.snackbar(
      'Téléchargement',
      'Téléchargement du cours "${course.value.title}" en cours...',
      backgroundColor: Colors.white,
      colorText: AppColors.textDark,
    );

    // Simuler le téléchargement (dans une vraie application, vous auriez un service de téléchargement)
    Future.delayed(Duration(seconds: 3), () {
      final updatedCourse = Course(
        id: course.value.id,
        title: course.value.title,
        subject: course.value.subject,
        description: course.value.description,
        progress: course.value.progress,
        image: course.value.image,
        isDownloaded: true,
        chapters: course.value.chapters,
        teacherName: course.value.teacherName,
        totalLessons: course.value.totalLessons,
        totalExercises: course.value.totalExercises,
      );
      course.value = updatedCourse;

      Get.snackbar(
        'Téléchargement terminé',
        'Le cours "${course.value.title}" est maintenant disponible hors ligne',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    });
  }
}