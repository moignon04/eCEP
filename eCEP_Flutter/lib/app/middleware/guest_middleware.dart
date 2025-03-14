import 'package:client/app/services/local_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class GuestMiddleware extends GetMiddleware {
   final store = Get.find<LocalStorageService>();


  @override
  RouteSettings? redirect(String? route) {
    String? token = store.token;
    // Si le token n'est pas présent, rediriger vers la page de connexion
    if (token != null) {
      return RouteSettings(name: '/home');
    }
  }
}
