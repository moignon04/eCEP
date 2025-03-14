import 'package:flutter/material.dart';

class InfosModifications extends StatefulWidget {
  @override
  _InfosModificationsState createState() => _InfosModificationsState();
}

class _InfosModificationsState extends State<InfosModifications> {
  final emailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final localite1Controller = TextEditingController();
  final localite2Controller = TextEditingController();
  final adresse1Controller = TextEditingController();
  final adresse2Controller = TextEditingController();

  bool passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    confirmPasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    localite1Controller.dispose();
    localite2Controller.dispose();
    adresse1Controller.dispose();
    adresse2Controller.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    setState(() {
      passwordsMatch = newPasswordController.text == confirmPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mes informations'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildTextField(emailController, 'Nouvel Email', Icons.email),
            const SizedBox(height: 10),
            _buildTextField(oldPasswordController, 'Ancien mot de passe', Icons.lock, obscureText: true),
            const SizedBox(height: 10),
            _buildTextField(newPasswordController, 'Nouveau mot de passe', Icons.lock, obscureText: true),
            const SizedBox(height: 10),
            _buildTextField(confirmPasswordController, 'Confirmer le mot de passe', Icons.lock, obscureText: true),
            const SizedBox(height: 5),
            _buildPasswordMatchIndicator(),
            const SizedBox(height: 20),
            _buildTextField(localite1Controller, 'Localité 1', Icons.location_on),
            const SizedBox(height: 10),
            _buildTextField(localite2Controller, 'Localité 2', Icons.location_on),
            const SizedBox(height: 10),
            _buildTextField(adresse1Controller, 'Adresse 1', Icons.home),
            const SizedBox(height: 10),
            _buildTextField(adresse2Controller, 'Adresse 2', Icons.home),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateInputs,
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordMatchIndicator() {
    return Row(
      children: [
        Icon(
          passwordsMatch ? Icons.check_circle : Icons.error,
          color: passwordsMatch ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 10),
        Text(
          passwordsMatch ? 'Les mots de passe correspondent' : 'Les mots de passe ne correspondent pas',
          style: TextStyle(color: passwordsMatch ? Colors.green : Colors.red),
        ),
      ],
    );
  }

  void _validateInputs() {
    if (emailController.text.isEmpty ||
        oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        localite1Controller.text.isEmpty ||
        localite2Controller.text.isEmpty ||
        adresse1Controller.text.isEmpty ||
        adresse2Controller.text.isEmpty) {
      _showSnackBar('Tous les champs doivent être remplis', Colors.red);
      return;
    }

    if (!passwordsMatch) {
      _showSnackBar('Les mots de passe ne correspondent pas', Colors.red);
      return;
    }

    _showSnackBar('Informations mises à jour avec succès', Colors.green);
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: color);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
