import 'package:client/app/extension/color.dart';
import 'package:client/data/models/course.dart';
import 'package:client/presentation/controllers/courses/courses_controller.dart';
import 'package:client/presentation/widgets/app_bar_widget.dart';
import 'package:client/presentation/widgets/course_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CoursesPage extends StatelessWidget {
  final CoursesController controller = Get.put(CoursesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Cours"),
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
                  return RefreshIndicator(
                    onRefresh: () async {
                      controller.loadCourses();
                    },
                    child: ListView.builder(
                      itemCount: controller.filteredCourses.length,
                      itemBuilder: (context, index) {
                        Course course = controller.filteredCourses[index];
                        return CourseCard(
                          course: course,
                          onTap: () {
                            Get.toNamed('/course-content', arguments: course);
                          },
                        );
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
                controller.filterCourses();
              },
              decoration: InputDecoration(
                hintText: 'Rechercher des cours...',
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
        Text(
          'Filtrer par matière',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tous', null),
              _buildFilterChip('Mathématiques', 'Mathématiques'),
              _buildFilterChip('Français', 'Français'),
              _buildFilterChip('Histoire-Géographie', 'Histoire-Géographie'),
              _buildFilterChip('Sciences', 'Sciences'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? subject) {
    return Obx(() {
      final isSelected = controller.selectedSubject.value == subject;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: FilterChip(
          selected: isSelected,
          label: Text(label),
          onSelected: (selected) {
            controller.selectedSubject.value = selected ? subject : null;
            controller.filterCourses();
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
}