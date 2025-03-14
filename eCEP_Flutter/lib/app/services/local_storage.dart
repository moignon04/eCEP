import 'dart:convert';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '';
import '../../domain/entities/user.dart';

enum _Key {
  user,
  cart,
  quartier,
  ville,
  pays,
  comptesExploitation,
  donneesPluviometriques,
}



class LocalStorageService extends GetxService {
  SharedPreferences? _sharedPreferences;


  Future<LocalStorageService> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }

  // Gestion de l'onboarding
  bool get onboardingCompleted =>
      _sharedPreferences?.getBool('onboardingCompleted') ?? false;

  set onboardingCompleted(bool value) {
    _sharedPreferences?.setBool('onboardingCompleted', value);
  }

  // Gestion de l'utilisateur
  User? get user {
    final rawJson = _sharedPreferences?.getString(_Key.user.toString());
    if (rawJson == null) {
      return null;
    }
    Map<String, dynamic> map = jsonDecode(rawJson);
    return User.fromJson(map);
  }

  set user(User? value) {
    if (value != null) {
      _sharedPreferences?.setString(
          _Key.user.toString(), json.encode(value.toJson()));
    } else {
      _sharedPreferences?.remove(_Key.user.toString());
    }
  }

  // Gestion du token
  String? get token => _sharedPreferences?.getString('token');

  set token(String? value) {
    if (value != null) {
      _sharedPreferences?.setString('token', value);
    } else {
      _sharedPreferences?.remove('token');
    }
  }

  // Gestion du panier
  List<Map<String, dynamic>> get cart {
    final rawJson = _sharedPreferences?.getString(_Key.cart.toString());
    if (rawJson == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(rawJson));
  }

  set cart(List<Map<String, dynamic>> value) {
    _sharedPreferences?.setString(_Key.cart.toString(), json.encode(value));
  }

  // --- Gestion de la localisation ---
  String get quartier =>
      _sharedPreferences?.getString(_Key.quartier.toString()) ?? 'Inconnu';

  set quartier(String value) {
    _sharedPreferences?.setString(_Key.quartier.toString(), value);
  }

  String get ville =>
      _sharedPreferences?.getString(_Key.ville.toString()) ?? 'Inconnu';

  set ville(String value) {
    _sharedPreferences?.setString(_Key.ville.toString(), value);
  }

  String get pays =>
      _sharedPreferences?.getString(_Key.pays.toString()) ?? 'Inconnu';

  set pays(String value) {
    _sharedPreferences?.setString(_Key.pays.toString(), value);
  }


}
