import 'package:flutter/material.dart';
import '../../app/extension/color.dart';
import '../../data/models/badge.dart';

class BadgeWidget extends StatelessWidget {
  final ABadge badge;

  const BadgeWidget({
    Key? key,
    required this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: EdgeInsets.all(badge.isUnlocked ? 16 : 24),
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? AppColors.secondary.withOpacity(0.1)
                    : AppColors.textLight.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: badge.isUnlocked ? 1.0 : 0.4,
                    child: Image.asset(
                      badge.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (!badge.isUnlocked)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textLight.withOpacity(0.7),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                if (!badge.isUnlocked)
                  LinearProgressIndicator(
                    value: badge.progressPercentage,
                    backgroundColor: AppColors.textLight.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                if (!badge.isUnlocked)
                  SizedBox(height: 4),
                if (!badge.isUnlocked)
                  Text(
                    '${badge.progress}/${badge.targetProgress}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
