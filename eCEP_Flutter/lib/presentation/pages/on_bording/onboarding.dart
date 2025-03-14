import 'package:client/app/extension/color.dart';
import 'package:client/app/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onboarding/onboarding.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  final store = Get.find<LocalStorageService>();

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Onboarding(
        swipeableBody: [
          buildPage(
            'Des produits vous aidans a ameliorer votre productivité',
            'Des engrais, des pesticides, des semences de qualité pour une meilleure production. Commandez en ligne et faites vous livrer chez vous.',
            'assets/mais.png',
          ),
          Center(child: Text('Découvrez les fonctionnalités.')),
          Center(child: Text('Profitez de l\'expérience.')),
        ],
        startIndex: 0,
        onPageChanges: (netDragDistance, pagesLength, currentIndex, slideDirection) {
          print("Page actuelle: $currentIndex, Direction: $slideDirection");
        },
        buildHeader: (context, netDragDistance, pagesLength, currentIndex, setIndex, slideDirection) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Action pour le bouton Skip
                  },
                  child: Text('Skip', style: TextStyle(color: Colors.white)),
                ),
                Row(
                  children: List.generate(
                    pagesLength,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentIndex == index ? Colors.blue : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    store.onboardingCompleted = true;
                   Get.toNamed('/login');
                  },
                  child: Text('Se connecter', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          );
        },
        buildFooter: (context, netDragDistance, pagesLength, currentIndex, setIndex, slideDirection) {
          return SizedBox.shrink(); // Pas de footer nécessaire ici
        },
        animationInMilliseconds: 300,
      ),
    );
  }

  Widget buildPage(String title, String description, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 300),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Page d'accueil")),
      body: Center(child: Text("Bienvenue à l'accueil!")),
    );
  }
}