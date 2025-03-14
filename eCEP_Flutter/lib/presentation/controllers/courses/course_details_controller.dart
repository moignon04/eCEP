import 'package:client/app/extension/color.dart';
import 'package:client/data/models/course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseDetailController extends GetxController {
  final Rx<Course> course = Course(
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

  final RxInt selectedTabIndex = 0.obs;
  final RxBool isExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Course) {
      course.value = Get.arguments;
    }
  }

  void toggleDescription() {
    isExpanded.value = !isExpanded.value;
  }

  void downloadCourse() {
    // Simuler le téléchargement
    Get.snackbar(
      'Téléchargement',
      'Le cours "${course.value.title}" est en cours de téléchargement',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    // Dans un vrai cas, on téléchargerait le cours et on mettrait à jour le statut
    Future.delayed(Duration(seconds: 2), () {
      course.update((val) {
        val?.isDownloaded = true;
      });

      Get.snackbar(
        'Téléchargement terminé',
        'Le cours "${course.value.title}" est maintenant disponible hors ligne',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    });
  }
}
