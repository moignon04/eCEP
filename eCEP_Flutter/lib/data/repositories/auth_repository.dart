
import 'package:client/data/providers/network/api_provider.dart';
import 'package:client/data/providers/network/apis/auth_api.dart';
import 'package:client/domain/entities/user.dart';
import 'package:client/domain/repositories/auth_repository.dart';

class AuthenticationRepositoryIml extends AuthenticationRepository {
  @override
  Future<User> signUp(String? email, String password, String fullName, String? phone, String country) async {
    try {
      // Appel à l'API pour l'inscription
      final response = await AuthAPI.register(
        email: email,
        password: password,
        fullName: fullName,
        country: country,
        phone: phone,
      ).request();

      // Extraction des données utilisateur à partir de la réponse
      return User.fromJson(response['datas']);
    } on AppException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Error during signup: $e');
    }
  }

  @override
  Future<User> login(String? email, String? phone, String password) async {
    try {
      // Appel à l'API pour la connexion
      final response = await AuthAPI.login(
        email: email,
        phone: phone,
        password: password,
      ).request();



      // Extraction des données utilisateur à partir de la réponse
      return User.fromJson(response['datas']);
    } on AppException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Error during login: $e');

    }
  }

  @override
  Future<void> logout() async {
    try {
      // Appel à l'API pour la déconnexion
      await AuthAPI.logout().request();
    } on AppException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }
}
