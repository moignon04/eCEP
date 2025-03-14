//import 'package:client/app/services/local_storage.dart';
import 'package:client/app/utils/dependencies.dart';
import 'package:client/presentation/app.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/services/local_storage.dart';
void main() async {
  DependencyCreator.init();
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
 // Get.put(CartController());

  runApp(App());
}

initServices() async {
  print('starting services ...');
  await Get.putAsync(() => LocalStorageService().init());
  print('All services started...');
}