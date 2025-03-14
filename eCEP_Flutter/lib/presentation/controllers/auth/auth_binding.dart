import 'package:client/data/repositories/auth_repository.dart';
import 'package:client/domain/usescases/signup_use_case.dart';
import 'package:client/presentation/controllers/auth/auth_controller.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpUseCase(Get.find<AuthenticationRepositoryIml>()));
    Get.lazyPut(() => LoginUseCase(Get.find<AuthenticationRepositoryIml>()));
    Get.lazyPut(() => LogoutUseCase(Get.find<AuthenticationRepositoryIml>()));
    Get.put(AuthController(Get.find(), Get.find(), Get.find()), permanent: true);
  }
}