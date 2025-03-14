import 'package:client/app/config/app_colors.dart';
import 'package:client/presentation/pages/auth/verify_code_page.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/extension/color.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController inputController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late bool isUsingEmail;
  String selectedCountryCode = "+226";

  @override
  void initState() {
    super.initState();
    isUsingEmail = true;
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  void _toggleInputMode() {
    setState(() {
      isUsingEmail = !isUsingEmail;
      inputController.clear();
    });
  }

  void _submit() {
    if (formKey.currentState!.validate()) {
      String input = inputController.text.trim();
      String type = isUsingEmail ? "email" : "contact";
      String finalInput = isUsingEmail ? input : "$selectedCountryCode $input";

      print("Envoi du code au $type : $finalInput");

      Get.to(
        VerifyCodePage(),
        arguments: {'isEmail': isUsingEmail, 'input': finalInput},
      );
    }
  }

  bool _isEmailValid(String input) {
    return GetUtils.isEmail(input.trim());
  }

  bool _isPhoneValid(String input) {
    return input.length >= 8;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mot de passe oublié"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Text(
                    "Récupération de mot de passe",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),


                  Text(
                    "Veuillez entrer votre ${isUsingEmail ? 'email' : 'contact'} pour recevoir un code de vérification.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),


                  if (!isUsingEmail)
                    Row(
                      children: [
                        CountryCodePicker(
                          onChanged: (countryCode) {
                            setState(() {
                              selectedCountryCode = countryCode.dialCode ?? "+1";
                            });
                          },
                          initialSelection: "US",
                          favorite: const ["+1", "US", "+33", "FR"],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: TextFormField(
                            controller: inputController,
                            decoration: InputDecoration(
                              hintText: "Numéro de téléphone",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Veuillez entrer un numéro de téléphone valide";
                              }
                              if (!_isPhoneValid(value)) {
                                return "Numéro de téléphone invalide";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    TextFormField(
                      controller: inputController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.grey),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer une adresse email valide";
                        }
                        if (!_isEmailValid(value)) {
                          return "Email invalide";
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),


                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Envoyer le code",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: _toggleInputMode,
                    child: Text(
                      "Utiliser ${isUsingEmail ? 'le téléphone' : "l'email"} à la place",
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
