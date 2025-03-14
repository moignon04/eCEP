

import 'package:client/data/repositories/auth_repository.dart';
import 'package:client/presentation/widgets/toast.dart';
import 'package:get/get.dart';

class DependencyCreator {
  static init() {
    Get.lazyPut(() => AuthenticationRepositoryIml());
    Get.lazyPut(() => ToastService());
  }
}         