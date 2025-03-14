import 'package:get/get.dart';
import '../../../data/models/course.dart';
import '../../../data/models/mock_data.dart';

class ExercisesController extends GetxController {
  final RxList<Map<String, dynamic>> exercises = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredExercises = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedDifficulty = 0.obs; // 0 = All, 1-3 = difficulté
  final RxBool showCompleted = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadExercises();
  }

  void loadExercises() async {
    isLoading.value = true;
    try {
      // Simuler un appel API avec un délai
      await Future.delayed(Duration(milliseconds: 500));

      // Extraire les exercices de tous les cours
      final List<Map<String, dynamic>> allExercises = [];

      for (var courseData in MockData.courses) {
        final String courseName = courseData['title'];
        final String courseSubject = courseData['subject'];

        for (var chapter in courseData['chapters'] ?? []) {
          for (var exercise in chapter['exercises'] ?? []) {
            // Ajouter des informations supplémentaires à l'exercice
            exercise['courseName'] = courseName;
            exercise['courseSubject'] = courseSubject;
            exercise['chapterName'] = chapter['title'];

            allExercises.add(exercise);
          }
        }
      }

      exercises.value = allExercises;
      filterExercises();
    } catch (e) {
      print('Erreur lors du chargement des exercices: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterExercises() {
    filteredExercises.value = exercises.where((exercise) {
      // Filtrer par recherche
      final matchesSearch = searchQuery.isEmpty ||
          exercise['title'].toLowerCase().contains(searchQuery.value.toLowerCase());

      // Filtrer par difficulté
      final matchesDifficulty = selectedDifficulty.value == 0 ||
          exercise['difficulty'] == selectedDifficulty.value;

      // Filtrer par statut de complétion
      final matchesCompletion = showCompleted.value || !exercise['isCompleted'];

      return matchesSearch && matchesDifficulty && matchesCompletion;
    }).toList();
  }
}