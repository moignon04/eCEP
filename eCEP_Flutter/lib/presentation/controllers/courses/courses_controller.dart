import 'package:get/get.dart';
import '../../../data/models/course.dart';
import '../../../data/models/mock_data.dart';

class CoursesController extends GetxController {
  final RxList<Course> courses = <Course>[].obs;
  final RxList<Course> filteredCourses = <Course>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final Rx<String?> selectedSubject = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  void loadCourses() async {
    isLoading.value = true;
    try {
      // Simuler un appel API avec un délai
      await Future.delayed(Duration(milliseconds: 500));

      // Charger les données mock
      final coursesData = MockData.courses.map((courseData) => Course.fromJson(courseData)).toList();
      courses.value = coursesData;
      filterCourses();
    } catch (e) {
      print('Erreur lors du chargement des cours: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterCourses() {
    filteredCourses.value = courses.where((course) {
      // Filtrer par recherche
      final matchesSearch = searchQuery.isEmpty ||
          course.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          course.description.toLowerCase().contains(searchQuery.value.toLowerCase());

      // Filtrer par matière
      final matchesSubject = selectedSubject.value == null || course.subject == selectedSubject.value;

      return matchesSearch && matchesSubject;
    }).toList();
  }
}