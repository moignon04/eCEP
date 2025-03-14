import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Lesson {
  final int id;
  final String title;
  final String type;
  final int duration;
  final String content;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    required this.content,
    required this.isCompleted,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      duration: json['duration'],
      content: json['content'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  IconData get typeIcon {
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