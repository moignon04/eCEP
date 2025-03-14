
import 'package:client/app/core/usescases/no_params_usescase.dart';
import 'package:client/app/core/usescases/params_usescase.dart';
import 'package:client/domain/entities/user.dart';
import 'package:client/domain/repositories/auth_repository.dart';


// Objet contenant les paramètres nécessaires pour l'inscription
class SignUpParams {
  final String? email;
  final String password;
  final String fullName;
  final String? phone;
  final String country;

  SignUpParams({
    this.email,
    required this.password,
    required this.fullName,
    this.phone,
    required this.country,
  });
}

class LoginParams {
  final String? email;
  final String? phone;
  final String password;

  LoginParams({
    this.email,
    this.phone,
    required this.password,
  });
}

// UseCase pour l'inscription
class SignUpUseCase extends ParamsUseCase<User, SignUpParams> {
  final AuthenticationRepository _repo;

  SignUpUseCase(this._repo);

  @override
  Future<User> execute(SignUpParams params) {
    // Appel du dépôt pour l'inscription en utilisant les paramètres
    return _repo.signUp(
      params.email,
      params.password,
      params.fullName,
      params.phone,
      params.country,
    );
  }
}



// UseCase pour la connexion

class LoginUseCase extends ParamsUseCase<User, LoginParams> {
  final AuthenticationRepository _repo;

  LoginUseCase(this._repo);

  @override
  Future<User> execute(LoginParams params) {
    // Appel du dépôt pour la connexion en utilisant les paramètres
    return _repo.login(
      params.email,
      params.phone,
      params.password,
    );
  }
}


// UseCase pour la déconnexion
class LogoutUseCase extends NoParamUseCase<void> {
  final AuthenticationRepository _repo;

  LogoutUseCase(this._repo);

  @override
  Future<void> execute() {
    // Appel du dépôt pour la déconnexion
    return _repo.logout();
  }
}




