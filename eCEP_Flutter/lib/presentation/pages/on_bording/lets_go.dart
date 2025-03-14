import 'package:client/app/extension/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';





class AlloYouriScreen extends StatelessWidget {
  // add key 

  const AlloYouriScreen({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFB0A99F), // Approximate background color

        ),
        child: SafeArea(
          child: Column(
            children: [
             
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Image.network("https://images.pexels.com/photos/95215/pexels-photo-95215.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2", fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: Text("C'est parti", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              backgroundColor: AppColors.primary,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              // Navigate to the login page
                              Get.toNamed("/login");
                            },
                          ),
                         const  SizedBox(height: 10),
                          OutlinedButton.icon(
                            icon: Icon(Icons.email_outlined, color: AppColors.secondary),
                            label: const Text('Continuer avec Google', style: TextStyle(color: Colors.black, fontSize: 16)),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () {},
                          ),
                       
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'En cliquant, je reconnais avoir pris connaissance des conditions générales d\'utilisation du _______ et les accepter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}