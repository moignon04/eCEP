import 'package:client/app/extension/color.dart';
import 'package:flutter/material.dart';

class TeacherBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TeacherBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMedium,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Tableau de bord',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Classe',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Cours',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
