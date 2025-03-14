import 'dart:ui';

import '../../app/extension/color.dart';
import 'chapter.dart';

class Course {
  final int id;
  final String title;
  final String subject;
  final String description;
  final int progress;
  final String image;
  late final bool isDownloaded;
  final List<Chapter> chapters;
  final String teacherName;
  final int totalLessons;
  final int totalExercises;

  Course({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.progress,
    required this.image,
    required this.isDownloaded,
    required this.chapters,
    required this.teacherName,
    required this.totalLessons,
    required this.totalExercises,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      description: json['description'],
      progress: json['progress'],
      image: json['image'],
      isDownloaded: json['isDownloaded'] ?? false,
      chapters: (json['chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList(),
      teacherName: json['teacherName'],
      totalLessons: json['totalLessons'],
      totalExercises: json['totalExercises'],
    );
  }

  Color get subjectColor {
    switch (subject.toLowerCase()) {
      case 'mathématiques':
        return AppColors.mathColor;
      case 'français':
        return AppColors.frenchColor;
      case 'histoire-géographie':
        return AppColors.historyColor;
      case 'sciences':
        return AppColors.scienceColor;
      default:
        return AppColors.primary;
    }
  }
}