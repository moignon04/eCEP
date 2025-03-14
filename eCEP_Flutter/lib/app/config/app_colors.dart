import 'package:client/app/extension/color.dart';
import 'package:flutter/material.dart';

class OldAppColors {

  const OldAppColors._();
  static  Color primary = hexToColor("##1F9E75");
  static  Color primaryVariant = hexToColor("#00796B");
  static  Color secondary = hexToColor("#F9AA33");
  static Color secondaryVariant = hexToColor("#F9AA33");
  static const onSecondaryVariant = Color(0xFFFFAE45);
  static const Color textBlack =  Color.fromARGB(186, 0, 0, 0);
  static const Color bgBlack =  Color.fromARGB(255, 0, 0, 0);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);



  // to rgba
  static Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }


  
}