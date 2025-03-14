import 'exercise.dart';
import 'lesson.dart';

class Chapter {
  final int id;
  final String title;
  final int progress;
  final List<Lesson> lessons;
  final List<Exercise> exercises;

  Chapter({
    required this.id,
    required this.title,
    required this.progress,
    required this.lessons,
    required this.exercises,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
      progress: json['progress'],
      lessons: (json['lessons'] as List)
          .map((lesson) => Lesson.fromJson(lesson))
          .toList(),
      exercises: (json['exercises'] as List)
          .map((exercise) => Exercise.fromJson(exercise))
          .toList(),
    );
  }
}