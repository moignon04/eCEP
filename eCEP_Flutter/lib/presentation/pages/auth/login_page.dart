
import 'package:client/presentation/pages/auth/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart'; // Package pour les indicatifs
import 'package:client/presentation/controllers/auth/auth_controller.dart';
import 'package:client/presentation/widgets/toast.dart';

import '../../../app/extension/color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController authController = Get.find<AuthController>();
  final ToastService toastService = Get.find<ToastService>();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController contactController; // Contrôleur pour le champ contact
  late ScrollController scrollController;
  final formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool isUsingEmail = false; // Par défaut, afficher le champ Contact
  String selectedCountryCode = "+226"; // Indicatif par défaut

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    contactController = TextEditingController();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    contactController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Heureux de vous", style: TextStyle(color: AppColors.textBlack, fontSize: 40, fontWeight: FontWeight.bold)),
                  Text("revoir", style: TextStyle(color: AppColors.textBlack, fontSize: 40, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Connectez pour continuer", style: TextStyle(color: AppColors.textBlack, fontSize: 20)),
                  SizedBox(height: 20),

                  // Champ Contact ou Email
                  if (!isUsingEmail)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // Picker des indicatifs pays
                          CountryCodePicker(
                            onChanged: (countryCode) {
                              setState(() {
                                selectedCountryCode = countryCode.dialCode!;
                              });
                            },
                            initialSelection: "BF",
                            favorite: ['BF', 'CI', 'ML', 'SN'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: contactController,
                              decoration: InputDecoration(
                                hintText: "Numéro de téléphone",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                fillColor: Colors.transparent,
                                filled: true,
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Veuillez entrer un numéro de contact valide";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
                          fillColor: Colors.transparent,
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez entrer une adresse email";
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return "Veuillez entrer une adresse email valide";
                          }
                          return null;
                        },
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isUsingEmail = !isUsingEmail;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(isUsingEmail ? "Utiliser un numéro de contact" : "Utiliser un email", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    )
                  ),
                  SizedBox(height: 20),

                  // Champ Mot de passe
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: "Mot de passe",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        fillColor: Colors.transparent,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un mot de passe";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 15),

                  GestureDetector(
                    onTap: (){
                      Get.to(ForgotPasswordPage());
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("Mot de passe oublié?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 15),

                  SizedBox(height: 50),


                  // Bouton Connexion
                  Obx(() => GestureDetector(
                    onTap: authController.isLoading.value
                        ? null
                        : () {
                      if (formKey.currentState!.validate()) {
                        final identifier = isUsingEmail
                            ? emailController.text.trim()
                            : "$selectedCountryCode${contactController.text.trim()}";
                            print(identifier);
                        authController.signInWith(identifier, passwordController.text.trim(), isEmail: isUsingEmail);
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: authController.isLoading.value
                            ? Colors.blue
                            : AppColors.primary,
                      ),
                      child: Center(
                        child: authController.isLoading.value
                            ? CircularProgressIndicator(color: AppColors.primary)
                            : Text(
                          "Connexion",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: 20),

                  // S'inscrire
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Vous n'avez pas de compte?", style: TextStyle(color: Colors.black, fontSize: 16)),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed("/signUp");
                        },
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
