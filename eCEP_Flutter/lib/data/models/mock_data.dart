class MockData {
  static List<Map<String, dynamic>> courses = [
    {
      'id': 1,
      'title': 'Les fractions',
      'subject': 'Mathématiques',
      'description': 'Apprendre à manipuler les fractions et à les utiliser dans des problèmes concrets.',
      'progress': 65,
      'image': 'assets/images/math.png',
      'isDownloaded': true,
      'teacherName': 'Mme Durant',
      'totalLessons': 10,
      'totalExercises': 15,
      'chapters': [
        {
          'id': 1,
          'title': 'Introduction aux fractions',
          'progress': 100,
          'lessons': [
            {
              'id': 1,
              'title': 'Qu\'est-ce qu\'une fraction?',
              'type': 'video',
              'duration': 420,
              'content': 'url_to_video',
              'isCompleted': true
            },
            {
              'id': 2,
              'title': 'Représentation graphique',
              'type': 'interactive',
              'duration': 300,
              'content': 'interactive_content',
              'isCompleted': true
            }
          ],
          'exercises': [
            {
              'id': 1,
              'title': 'Reconnaître les fractions',
              'type': 'quiz',
              'difficulty': 1,
              'points': 10,
              'isCompleted': true,
              'score': 8,
              'questions': []
            }
          ]
        },
        {
          'id': 2,
          'title': 'Addition et soustraction de fractions',
          'progress': 50,
          'lessons': [
            {
              'id': 3,
              'title': 'Fractions avec même dénominateur',
              'type': 'lecture',
              'duration': 600,
              'content': 'text_content',
              'isCompleted': true
            },
            {
              'id': 4,
              'title': 'Fractions avec dénominateurs différents',
              'type': 'video',
              'duration': 540,
              'content': 'url_to_video',
              'isCompleted': false
            }
          ],
          'exercises': [
            {
              'id': 2,
              'title': 'Addition de fractions',
              'type': 'interactive',
              'difficulty': 2,
              'points': 15,
              'isCompleted': false,
              'score': 0,
              'questions': []
            }
          ]
        }
      ]
    },
    {
      'id': 2,
      'title': 'La conjugaison des verbes',
      'subject': 'Français',
      'description': 'Maîtriser les temps simples et composés de l\'indicatif pour les verbes des trois groupes.',
      'progress': 30,
      'image': 'assets/images/french.png',
      'isDownloaded': false,
      'teacherName': 'M. Martin',
      'totalLessons': 12,
      'totalExercises': 18,
      'chapters': []
    },
    {
      'id': 3,
      'title': 'Les grandes découvertes',
      'subject': 'Histoire-Géographie',
      'description': 'Explorer les grandes découvertes du XVe au XVIe siècle et leurs conséquences sur le monde.',
      'progress': 10,
      'image': 'assets/images/history.png',
      'isDownloaded': false,
      'teacherName': 'M. Dubois',
      'totalLessons': 8,
      'totalExercises': 10,
      'chapters': []
    },
    {
      'id': 4,
      'title': 'Le corps humain',
      'subject': 'Sciences',
      'description': 'Comprendre l\'anatomie et le fonctionnement des principaux systèmes du corps humain.',
      'progress': 80,
      'image': 'assets/images/science.png',
      'isDownloaded': true,
      'teacherName': 'Mme Petit',
      'totalLessons': 15,
      'totalExercises': 12,
      'chapters': []
    },
  ];

  static List<Map<String, dynamic>> badges = [
  {
  'id': 1,
  'name': 'Math Débutant',
  'description': 'Compléter 5 exercices de mathématiques',
  'image': 'assets/badges/math_beginner.png',
  'isUnlocked': true,
  'progress': 100,
  'targetProgress': 100
},
{
'id': 2,
'name': 'Expert en Fractions',
'description': 'Obtenir 90% à tous les exercices sur les fractions',
'image': 'assets/badges/fraction_expert.png',
'isUnlocked': false,
'progress': 65,
'targetProgress': 100
},
{
'id': 3,
'name': 'Explorateur Scientifique',
'description': 'Terminer le cours sur le corps humain',
'image': 'assets/badges/science_explorer.png',
'isUnlocked': false,
'progress': 80,
'targetProgress': 100
},
    {
'id': 4,
'name': 'Lecteur Assidu',
'description': 'Lire 10 leçons différentes',
'image': 'assets/badges/avid_reader.png',
'isUnlocked': true,
'progress': 100,
'targetProgress': 100
},
{
'id': 5,
'name': 'Assiduité',
'description': 'Se connecter 7 jours de suite',
'image': 'assets/badges/streak.png',
'isUnlocked': false,
'progress': 5,
'targetProgress': 7
},
];

static Map<String, dynamic> studentProfile = {
  'id': 1,
  'firstName': 'Lucas',
  'lastName': 'Dupont',
  'email': 'lucas.d@ecole.fr',
  'avatar': 'assets/avatars/boy1.png',
  'role': 'student',
  'level': 5,
  'points': 850,
  'streakDays': 5,
  'completedCourses': 3,
  'completedExercises': 28,
  'averageScore': 78,
};
}
