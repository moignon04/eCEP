import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF3D5CFF);
  static const Color primaryLight = Color(0xFF738AFF);
  static const Color primaryDark = Color(0xFF0033CC);
  static const Color textBlack =  Color.fromARGB(186, 0, 0, 0);

  // Couleurs secondaires
  static const Color secondary = Color(0xFFFF8A00);
  static const Color secondaryLight = Color(0xFFFFAC4B);
  static const Color secondaryDark = Color(0xFFE57C00);
  static  Color primaryVariant = hexToColor("#00796B");

  // Couleurs pour les matières
  static const Color mathColor = Color(0xFF3D5CFF);
  static const Color frenchColor = Color(0xFFFF5252);
  static const Color historyColor = Color(0xFFFFC107);
  static const Color scienceColor = Color(0xFF16C79A);

  // Couleurs neutres
  static const Color background = Color(0xFFF9FAFC);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF2E3A59);
  static const Color textMedium = Color(0xFF7D8FAB);
  static const Color textLight = Color(0xFFB0BAC9);

  // Couleurs feedback
  static const Color success = Color(0xFF16C79A);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF3D5CFF);

  // Couleurs dark mode
  static const Color darkBackground = Color(0xFF1E1F28);
  static const Color darkCard = Color(0xFF2D2E3A);
}
 Color hexToColor(String code) {
return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}