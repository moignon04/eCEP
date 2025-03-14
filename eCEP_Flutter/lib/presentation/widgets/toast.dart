import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

enum ToastType { success, warning, error, notification }

class ToastService extends GetxService {
  // Méthode pour afficher un toast personnalisé
  void showToast({
    required String title,
    required String message,
    required ToastType type,
    String gravity = 'top',
    Color? backgroundColor,
    Color? textColor,
    int timeInSeconds = 1,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor ?? _getBackgroundColor(type),
      colorText: textColor ?? Colors.white,
      snackPosition: _getGravity(gravity),
      duration: Duration(seconds: timeInSeconds),
      icon: _getIcon(type),
      borderRadius: 10,
      margin: const EdgeInsets.all(15),
      snackStyle: SnackStyle.FLOATING,
    );
  }

  // Retourne la couleur de fond en fonction du type de toast
  Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.error:
        return Colors.red;
      case ToastType.notification:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }


SnackPosition _getGravity(String gravity) {
    switch (gravity) {
      case 'top':
        return SnackPosition.TOP;
      case 'bottom':
        return SnackPosition.BOTTOM;
      default:
        return SnackPosition.TOP;
    }
  }
  // Retourne une icône en fonction du type de toast
  Icon _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icon(Icons.check_circle, color: Colors.white);
      case ToastType.warning:
        return Icon(Icons.warning, color: Colors.white);
      case ToastType.error:
        return Icon(Icons.error, color: Colors.white);
      case ToastType.notification:
        return Icon(Icons.notifications, color: Colors.white);
      default:
        return Icon(Icons.info, color: Colors.white);
    }
  }
}
