import 'package:client/app/middleware/auth_middleware.dart';
import 'package:client/app/middleware/guest_middleware.dart';
import 'package:client/app/middleware/onboarding_middleware.dart';
import 'package:client/presentation/controllers/auth/auth_binding.dart';
import 'package:client/presentation/controllers/courses/course_content_controller.dart';
import 'package:client/presentation/controllers/home/home_binding.dart';
import 'package:client/presentation/pages/auth/login_page.dart';
import 'package:client/presentation/pages/auth/sign_up_page.dart';
import 'package:client/presentation/pages/cours/course_detail_page.dart';
import 'package:client/presentation/pages/exercise/exercise_detail_page.dart';
import 'package:client/presentation/pages/home.dart';
import 'package:client/presentation/pages/home_page.dart';
import 'package:client/presentation/pages/lesson/lesson_detail_page.dart';
import 'package:client/presentation/pages/on_bording/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/services/local_storage.dart';
import 'pages/cours/course_content_page.dart';

class App extends StatelessWidget {
  final store = Get.find<LocalStorageService>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      //initialRoute: "/home", // Utilise initialRoute
      home: NavigationMenu(),
      initialBinding: AuthBinding(),
      getPages: [
        GetPage(
          name: "/onboarding",
          page: () => OnboardingScreen(), // Assure-toi que cette page existe
          middlewares: [OnboardingMiddleware()],
        ),

        // Route pour la page d'accueil
        GetPage(
          name: "/home",
          page: () => NavigationMenu(),
          middlewares: [AuthMiddleware()],
        ),

        // Route pour la page de connexion
        GetPage(
          name: "/login",
          page: () => LoginPage(),
          middlewares: [GuestMiddleware()],
          binding: AuthBinding(),
        ),

        // Route pour la page d'inscription
        GetPage(
          name: "/signUp",
          page: () => SignUpPage(),
        ),

        // Route pour le contenu du cours
        GetPage(
          name: '/course-content',
          page: () => CourseContentPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => CourseContentController());
          }),
        ),


      ],
    );
  }
}