import 'dart:io';

import 'package:client/app/services/local_storage.dart';
import 'package:client/data/providers/network/api_endpoint.dart';
import 'package:client/data/providers/network/api_request_representable.dart';
import 'package:client/data/providers/network/api_provider.dart';
import 'package:get/get.dart';

enum AuthType { login, register, logout }

class AuthAPI implements APIRequestRepresentable {
  final AuthType type;
  String? email;
  String? password;
  String? fullName;
  String? phone;
  String? country;
  final store = Get.find<LocalStorageService>();
  

  AuthAPI._({required this.type, this.email, this.password, this.fullName, this.phone, this.country});

  // Login constructor
  AuthAPI.login({String? email, String? phone, required String password})
      : this._(type: AuthType.login, email: email, phone: phone, password: password);

  // Register constructor
  AuthAPI.register({ String? email, required String password, required String fullName, String? phone, required String country})
      : this._(type: AuthType.register, email: email, password: password, fullName: fullName, phone: phone);

  // Logout constructor
  AuthAPI.logout() : this._(type: AuthType.logout);

  @override
  String get endpoint => APIEndpoint.baseURL;

  @override
  String get path {
    switch (type) {
      case AuthType.login:
        return "/auth/login";
      case AuthType.register:
        return "/auth/register";
      case AuthType.logout:
        return "/auth/logout";
      default:
        return "";
    }
  }

  @override
  HTTPMethod get method {
    switch (type) {
      case AuthType.login:
      case AuthType.register:
        return HTTPMethod.post;
      case AuthType.logout:
        return HTTPMethod.post;
      default:
        return HTTPMethod.post;
    }
  }

  @override
  Map<String, String> get headers => {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${store.token}',
      };

  @override
  Map<String, String>? get query => null;

  @override
  dynamic get body {
    switch (type) {
      case AuthType.login:
        return {
          "email": email,
          "phone": phone,
          "password": password,
        };
      case AuthType.register:
        return {
          "email": email,
          "password": password,
          "full_name": fullName,
          "phone": phone,
          "role": "client",
          "country": country,
        };
      case AuthType.logout:
        return null;
      default:
        return null;
    }
  }

  @override
  String get url => endpoint + path;

  @override
  Future request() {
    return APIProvider.instance.request(this);
  }
}
