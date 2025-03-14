import 'package:client/presentation/controllers/courses/course_content_controller.dart';
import 'package:client/presentation/pages/cours/course_content_page.dart';
import 'package:get/get.dart';

class CourseContentBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CourseContentController());
  }
}