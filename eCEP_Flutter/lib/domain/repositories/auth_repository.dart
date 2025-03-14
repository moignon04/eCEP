

import 'package:client/domain/entities/user.dart';

abstract class AuthenticationRepository {
  Future<User> signUp(String? email, String password, String fullName, String? phone, String country);
  Future<User> login(String? email, String? phone, String password);
  Future<void> logout();
}