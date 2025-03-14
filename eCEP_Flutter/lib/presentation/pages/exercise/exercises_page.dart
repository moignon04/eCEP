import 'package:client/app/extension/color.dart';
import 'package:client/presentation/controllers/exercises/exercises_controller.dart';
import 'package:client/presentation/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExercisesPage extends StatelessWidget {
  final ExercisesController controller = Get.put(ExercisesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Exercices"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              _buildSearchBar(),
              SizedBox(height: 20),
              _buildFilters(),
              SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.exercises.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 80,
                            color: AppColors.textLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun exercice trouvé',
                            style: TextStyle(
                              color: AppColors.textMedium,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Les exercices apparaîtront ici une fois que vous aurez commencé un cours.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      controller.loadExercises();
                    },
                    child: ListView.builder(
                      itemCount: controller.filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = controller.filteredExercises[index];
                        return _buildExerciseCard(exercise);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppColors.textMedium,
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) {
                controller.searchQuery.value = value;
                controller.filterExercises();
              },
              decoration: InputDecoration(
                hintText: 'Rechercher des exercices...',
                hintStyle: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filtrer par difficulté',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() => controller.showCompleted.value
                ? TextButton.icon(
              onPressed: () {
                controller.showCompleted.value = false;
                controller.filterExercises();
              },
              icon: Icon(Icons.check_circle, size: 16),
              label: Text('Masquer complétés'),
            )
                : TextButton.icon(
              onPressed: () {
                controller.showCompleted.value = true;
                controller.filterExercises();
              },
              icon: Icon(Icons.check_circle_outline, size: 16),
              label: Text('Afficher complétés'),
            ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tous', 0),
              _buildFilterChip('Facile', 1),
              _buildFilterChip('Moyen', 2),
              _buildFilterChip('Difficile', 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int difficulty) {
    return Obx(() {
      final isSelected = controller.selectedDifficulty.value == difficulty;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: FilterChip(
          selected: isSelected,
          label: Text(label),
          onSelected: (selected) {
            controller.selectedDifficulty.value = selected ? difficulty : 0;
            controller.filterExercises();
          },
          backgroundColor: Colors.white,
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textMedium,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    Color difficultyColor;
    String difficultyText;

    switch (exercise['difficulty']) {
      case 1:
        difficultyColor = Colors.green;
        difficultyText = 'Facile';
        break;
      case 2:
        difficultyColor = Colors.orange;
        difficultyText = 'Moyen';
        break;
      case 3:
        difficultyColor = Colors.red;
        difficultyText = 'Difficile';
        break;
      default:
        difficultyColor = Colors.green;
        difficultyText = 'Facile';
    }

    return Card(
        margin: EdgeInsets.only(bottom: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
    onTap: () {
    Get.toNamed('/exercise-detail', arguments: exercise);
    },
    borderRadius: BorderRadius.circular(12),
    child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Icon(
      _getExerciseTypeIcon(exercise['type']),
      color: AppColors.primary,
      size: 24,
    ),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          exercise['title'],
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: difficultyColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: difficultyColor,
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              difficultyText,
              style: TextStyle(
                color: difficultyColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
    ),
      SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${exercise['courseName']}',
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 14,
            ),
          ),
          Text(
            '${exercise['points']} points',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      if (exercise['isCompleted']) ...[
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Complété',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              'Score: ${exercise['score']}%',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ],
    ),
    ),
    ),
    );
  }

  IconData _getExerciseTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return Icons.quiz;
      case 'interactive':
        return Icons.touch_app;
      case 'problem':
        return Icons.calculate;
      default:
        return Icons.assignment;
    }
  }
}