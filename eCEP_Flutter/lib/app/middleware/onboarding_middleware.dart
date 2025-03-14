import 'package:client/app/services/local_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class OnboardingMiddleware extends GetMiddleware {
   final store = Get.find<LocalStorageService>();


  @override
  RouteSettings? redirect(String? route) {
    bool? isOnboardingDone = store.onboardingCompleted;
    // Si le token n'est pas présent, rediriger vers la page de connexion
   
    // Permet d'accéder à la page si le token existe
    if (isOnboardingDone) {
      return RouteSettings(name: '/login');
    }
  }
}
