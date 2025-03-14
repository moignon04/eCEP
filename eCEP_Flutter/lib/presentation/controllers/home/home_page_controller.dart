import 'package:client/app/extension/color.dart';
import 'package:client/data/models/badge.dart';
import 'package:client/data/models/course.dart';
import 'package:client/data/models/mock_data.dart';

import 'package:get/get.dart';
class HomeController extends GetxController {
  final RxList<Course> courses = <Course>[].obs;
  final RxList<ABadge> badges = <ABadge>[].obs;
  final RxMap<String, dynamic> profile = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    // Charger les cours
    courses.value = MockData.courses.map((data) => Course.fromJson(data)).toList();

    // Charger les badges
    badges.value = MockData.badges.map((data) => ABadge.fromJson(data)).toList();

    // Charger le profil
    profile.value = MockData.studentProfile;
  }
}