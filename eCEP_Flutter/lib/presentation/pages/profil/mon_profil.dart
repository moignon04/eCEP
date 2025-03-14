import 'package:client/presentation/pages/profil/location_form.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/presentation/controllers/auth/auth_controller.dart';

import 'infos_modifications_page.dart';

class MonProfil extends StatelessWidget {
   MonProfil({Key? key}) : super(key: key);
  String _pageTitle = 'Profil';
   void _onPageTapped(String newPage) {
       _pageTitle = newPage;
   }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar:AppBar(
        title: Text('profil'),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/user.png'), // Image de profil par défaut
            ),
            const SizedBox(height: 20),
            const Text(
              "Nom d'utilisateur",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),


            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Modifier mes informations de profil"),
              onTap: () {
                Get.to(InfosModifications());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text("Compte d'exploitation"),
              onTap: () {
               
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.water),
              title: const Text("Données Pluviométriques"),
              onTap: () {
                
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Adresse de livraison"),
              onTap: () {
                Get.to(LocationForm());
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Paramètres"),
              onTap: () {
              },
            ),
            const Divider(),


            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Se déconnecter"),
              onTap: () {
                Get.find<AuthController>().logout();
                Get.offAllNamed('/login');
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
