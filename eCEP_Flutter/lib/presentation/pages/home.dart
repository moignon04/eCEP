import 'package:client/app/services/local_storage.dart';
import 'package:client/domain/entities/user.dart';
import 'package:client/presentation/pages/cours/courses_page.dart';
import 'package:client/presentation/pages/exercise/exercises_page.dart';
import 'package:client/presentation/pages/home_page.dart';
//import 'package:client/presentation/widgets/main_drawer.dart';
//import 'package:client/presentation/pages/profil/mon_profil.dart';
import 'package:client/presentation/pages/progress/progress_page.dart';
import 'package:client/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;
  String _pageTitle = 'Accueil';
  //final CartController cartController = Get.put(CartController());


  final store = Get.find<LocalStorageService>();



  final List<Widget> _pages = [
     HomePage(),
     CoursesPage(), // Page des cours
    ExercisesPage(), // Page des exercices
    ProgressPage(), // Page des progrès
  ];

  void _onPageTapped(String newPage) {
    setState(() {
      _pageTitle = newPage; // Mise à jour du titre
    });
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //MainDrawer mainDrawer = MainDrawer(pageName: _pageTitle);
    return Scaffold(
      //appBar: mainDrawer.buildAppBar(),
      //drawer: mainDrawer.buildDrawer(context, _onPageTapped),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    bottomNavigationBar: CustomBottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: _onItemTapped,
    ),);
  }
}

