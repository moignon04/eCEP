import 'choice.dart';

class Question {
  final int id;
  final String text;
  final String type;
  final List<Choice> choices;
  final String correctAnswer;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.choices,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      choices: json['choices'] != null
          ? (json['choices'] as List).map((c) => Choice.fromJson(c)).toList()
          : [],
      correctAnswer: json['correctAnswer'],
    );
  }
}