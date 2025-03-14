import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';
import '../../app/extension/color.dart';

class ExerciseItem extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseItem({
    Key? key,
    required this.exercise,
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
                    color: exercise.isCompleted
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    exercise.isCompleted ? Icons.task_alt : Icons.assignment_outlined,
                    color: exercise.isCompleted ? AppColors.success : AppColors.secondary,
                    size: 22,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Row(
                            children: List.generate(
                              exercise.difficulty,
                                  (index) => Icon(
                                Icons.star,
                                color: AppColors.secondary,
                                size: 12,
                              ),
                            )..addAll(
                              List.generate(
                                3 - exercise.difficulty,
                                    (index) => Icon(
                                  Icons.star_border,
                                  color: AppColors.textLight,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  color: AppColors.secondary,
                                  size: 10,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${exercise.points} pts',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (exercise.isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${exercise.score}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.secondary,
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
}