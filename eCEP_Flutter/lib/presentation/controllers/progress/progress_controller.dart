import 'package:client/data/models/mock_data.dart';
import 'package:get/get.dart';


class ProgressController extends GetxController {
  // Données de l'utilisateur
  final RxMap<String, dynamic> profile = <String, dynamic>{}.obs;

  // Activités récentes
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;

  // Progression par matière
  final RxList<Map<String, dynamic>> subjectProgress = <Map<String, dynamic>>[].obs;

  // Réussites et badges
  final RxMap<String, dynamic> achievements = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> recentBadges = <Map<String, dynamic>>[].obs;

  // État de chargement
  final RxBool isLoading = true.obs;

  // Nombre total de cours et d'exercices
  final int totalCourses = 10; // Exemple, à adapter selon les données réelles
  final int totalExercises = 50; // Exemple, à adapter selon les données réelles

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Méthode pour charger les données
  void loadData() async {
    isLoading.value = true;

    // Simuler un chargement asynchrone
    await Future.delayed(Duration(seconds: 1));

    // Charger les données factices
    profile.value = MockData.studentProfile;

    // Activités récentes
    recentActivities.value = [
      {
        'type': 'Cours',
        'title': 'Les fractions',
        'description': 'Cours terminé avec succès',
        'timeAgo': 'Il y a 2 heures',
      },
      {
        'type': 'Exercice',
        'title': 'Addition de fractions',
        'description': 'Exercice réussi avec un score de 90%',
        'timeAgo': 'Il y a 1 jour',
      },
      {
        'type': 'Badge',
        'title': 'Math Débutant',
        'description': 'Badge débloqué',
        'timeAgo': 'Il y a 3 jours',
      },
    ];

    // Progression par matière
    subjectProgress.value = [
      {
        'name': 'Mathématiques',
        'progress': 65,
        'completedLessons': 8,
        'completedExercises': 12,
      },
      {
        'name': 'Français',
        'progress': 30,
        'completedLessons': 4,
        'completedExercises': 6,
      },
      {
        'name': 'Histoire-Géographie',
        'progress': 10,
        'completedLessons': 2,
        'completedExercises': 3,
      },
      {
        'name': 'Sciences',
        'progress': 80,
        'completedLessons': 10,
        'completedExercises': 15,
      },
    ];

    // Réussites et badges
    achievements.value = {
      'totalBadges': 3,
      'averageScore': 78,
      'totalHours': 25,
      'streakDays': 5,
      'exercisesCompleted': 28,
      'highestStreak': 7,
    };

    recentBadges.value = MockData.badges
        .where((badge) => badge['isUnlocked'])
        .map((badge) => {
      'name': badge['name'],
      'image': badge['image'],
      'isUnlocked': badge['isUnlocked'],
    })
        .toList();

    isLoading.value = false;
  }
}