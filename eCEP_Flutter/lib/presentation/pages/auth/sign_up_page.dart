import 'package:client/app/config/app_colors.dart';
import 'package:client/app/extension/color.dart';
import 'package:client/presentation/controllers/auth/auth_controller.dart';
import 'package:client/presentation/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  CountryCode selectedCountryCode = CountryCode.fromCountryCode('BF');
  final AuthController authController = Get.find<AuthController>();
  final ToastService toastService = Get.find<ToastService>();

  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  bool _obscureText = true;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Titre
                  Text(
                    "Créer un compte",
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Champ Nom complet
                  _buildTextField("Nom complet", fullNameController, TextInputType.text),
                  SizedBox(height: 20),

                  // Champ Email ou Téléphone
                  _buildPhoneField(),
                  SizedBox(height: 20),

                  _buildTextField("Email (optionnel)", emailController, TextInputType.emailAddress),


                  SizedBox(height: 10),

                  _buildPasswordField("Mot de passe", passwordController),
                  SizedBox(height: 20),

                  // Champ Confirmer le mot de passe
                  _buildPasswordField("Confirmer le mot de passe", confirmPasswordController),
                  SizedBox(height: 20),

                  // Bouton S'inscrire
                 Obx(() => GestureDetector(
  onTap: authController.isLoading.value
      ? null
      : () {
          if (formKey.currentState!.validate()) {
            if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
              toastService.showToast(
                title: 'Erreur',
                message: 'Les mots de passe ne correspondent pas.',
                type: ToastType.error,
              );
            } else {
              
              
              // Récupération et formatage du numéro
              final formattedPhone = '${selectedCountryCode.dialCode}${phoneController.text.trim()}';

              authController.signUpWith(
                fullNameController.text.trim(),
                emailController.text.trim(),
                formattedPhone,
                passwordController.text.trim(),
                selectedCountryCode.code ?? 'BF',
              );
            }
          }
        },
  child: Container(
    height: 50,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: authController.isLoading.value ? AppColors.textBlack : AppColors.primary,
    ),
    child: Center(
      child: authController.isLoading.value
          ? CircularProgressIndicator(color: AppColors.primary)
          : Text(
              "S'inscrire",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  ),
)),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Vous avez déjà un compte?",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed("/login");
                        },
                        child: Text(
                          "Se connecter",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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

  Widget _buildTextField(String hintText, TextEditingController controller, TextInputType inputType) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black26),
          border: InputBorder.none,
          prefixIcon: Icon(
            hintText == "Email (optionnel)" ? Icons.email : Icons.person,
            color: Colors.grey,
          ),
        ),
        validator: (value) {
          if (hintText == "Email (optionnel)") {
            // Ne pas valider si vide
            if (value != null && value.isNotEmpty) {
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return "Veuillez entrer un email valide.";
              }
            }
            return null;
          } else if (value == null || value.isEmpty) {
            return "Veuillez entrer votre $hintText";
          }
          return null;
        },
      ),
    );
  }


Widget _buildPhoneField() {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        // Liste déroulante pour sélectionner le pays
        CountryCodePicker(
          onChanged: (country) {
            setState(() {
              selectedCountryCode = country;
            });
          },
          initialSelection: selectedCountryCode.code,
          showCountryOnly: false,
          showOnlyCountryWhenClosed: false,
          showFlag: true,
          alignLeft: false,
          favorite: ['BF', 'CI', 'ML', 'SN'], // Exemple de pays favoris
        ),
        Expanded(
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "Numéro de téléphone",
              hintStyle: TextStyle(color: Colors.black26),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Veuillez entrer votre numéro de téléphone.";
              }
              return null;
            },
          ),
        ),
      ],
    ),
  );
}



  Widget _buildPasswordField(String hintText, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: hintText,
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
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Veuillez entrer un $hintText";
          }
          return null;
        },
      ),
    );
  }
}
