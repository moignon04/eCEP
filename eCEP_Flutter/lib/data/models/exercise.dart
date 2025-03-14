import 'package:client/data/models/question.dart';

class Exercise {
  final int id;
  final String title;
  final String type;
  final int difficulty;
  final int points;
  final bool isCompleted;
  final int score;
  final List<Question> questions;

  Exercise({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    required this.points,
    required this.isCompleted,
    required this.score,
    required this.questions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      difficulty: json['difficulty'],
      points: json['points'],
      isCompleted: json['isCompleted'] ?? false,
      score: json['score'] ?? 0,
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => Question.fromJson(q)).toList()
          : [],
    );
  }
}