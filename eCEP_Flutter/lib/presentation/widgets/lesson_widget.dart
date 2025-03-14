import 'package:flutter/material.dart';
import '../../data/models/lesson.dart';
import '../../app/extension/color.dart';

class LessonItem extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonItem({
    Key? key,
    required this.lesson,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 8,
    offset: Offset(0, 2),
    ),
    ],
    ),
    child: Material(
    color: Colors.transparent,
    child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
    children: [
    Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: lesson.isCompleted
    ? AppColors.success.withOpacity(0.1)
        : AppColors.primary.withOpacity(0.1),
    shape: BoxShape.circle,
    ),
    child: Icon(
    lesson.typeIcon,
    color: lesson.isCompleted ? AppColors.success : AppColors.primary,
    size: 22,
    ),
    ),
    SizedBox(width: 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    lesson.title,
    style: TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    ),
    ),
    SizedBox(height: 4),
    Row(
    children: [
    Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
    color: _getTypeColor(lesson.type).withOpacity(0.1),
    borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
    lesson.type,
    style: TextStyle(
    fontSize: 10,
    color: _getTypeColor(lesson.type),
    fontWeight: FontWeight.w500,
    ),
    ),
    ),
    SizedBox(width: 12),
    Icon(
    Icons.access_time_rounded,
    color: AppColors.textLight,
    size: 12,
    ),
    SizedBox(width: 4),
    Text(
    _formatDuration(lesson.duration),
    style: TextStyle(
    fontSize: 12,
    color: AppColors.textMedium,
    ),
    ),
    ],
    ),
      ],
    ),
    ),
        Spacer(),
        if (lesson.isCompleted)
      Icon(
      Icons.check_circle,
      color: AppColors.success,
      size: 22,
    )
    else
    Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: AppColors.primary.withOpacity(0.1),
    shape: BoxShape.circle,
    ),
    child: Icon(
    Icons.play_arrow_rounded,
    color: AppColors.primary,
    size: 14,
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Color(0xFF3D5CFF);
      case 'audio':
        return Color(0xFFFF5252);
      case 'lecture':
        return Color(0xFF16C79A);
      case 'interactive':
        return Color(0xFFFF8A00);
      default:
        return AppColors.primary;
    }
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    return '$minutes min';
  }
}