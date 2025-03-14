import 'dart:math';

import 'package:client/app/services/local_storage.dart';
import 'package:client/data/providers/network/api_provider.dart';
import 'package:client/domain/entities/user.dart';
import 'package:client/domain/usescases/signup_use_case.dart';
import 'package:client/presentation/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AuthController extends GetxController {
    AuthController(this._loginUseCase, this._signUpUseCase, this._logoutUseCase); 

  final  SignUpUseCase _signUpUseCase;
  final  LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  final store = Get.find<LocalStorageService>();
  final toast = Get.find<ToastService>();
  var isLoggedIn = false.obs;
  var isLoading = false.obs;


  

  User? get user => store.user;


  @override
  void onInit() async {
    super.onInit();
    isLoggedIn.value = store.user != null;
  }

  signUpWith(String fullName, String email, String phone, String password, String country) async {
    try {
      isLoading.value = true;
      final user = await _signUpUseCase.execute(SignUpParams(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        country: country,

      ));
      isLoading.value = false;
      store.user = user;
      isLoggedIn.value = true;    
      isLoggedIn.refresh();
      //store.token = user.token;
      store.user = user;


      toast.showToast(
        title: 'Okay',
        message: 'Inscription réussie',
        type: ToastType.success,
      );
      Get.toNamed('/home');


    } on AppException catch (error) {
      isLoading.value = false;
      toast.showToast(
        title: 'Erreur',
        message: error.message,
        type: ToastType.error,
      );
    } catch (error) {
      isLoading.value = false;
      toast.showToast(
        title: 'Erreur',
        message: 'Erreur lors de l\'inscription',
        type: ToastType.error,
      );
    }
  }

  signInWith(String identifier, String password, {bool isEmail = true}) async {
    try {
      isLoading.value = true;
      print('signing in');
      final user = await _loginUseCase.execute(LoginParams(   
        email: isEmail ? identifier : null,
        phone: isEmail ? null : identifier,
        password: password,
      ));

      print('signed in with ${user.email}');
      isLoading.value = false;
      store.user = user;
      isLoggedIn.value = true;
      isLoggedIn.refresh();
      //store.token = user.token;
      // redirect to home
      toast.showToast(
        title: 'Okay',
        message: 'Connexion réussie',
        type: ToastType.success,
      );

      Get.toNamed('/home');
    } on AppException catch (error) {
      isLoading.value = false;
      toast.showToast(
        title: 'Erreur',
        message: error.message,
        type: ToastType.error,
      );
    } catch (error) {
      isLoading.value = false;
      toast.showToast(
        title: 'Erreur',
        message: 'Erreur lors de la connexion',
        type: ToastType.error,
      );
    }

  
  }


  logout() {
    store.user = null;
    store.token = null;
    isLoggedIn.value = false;
  }
}