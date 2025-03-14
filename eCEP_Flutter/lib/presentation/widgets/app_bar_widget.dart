import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/extension/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget> actions;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.actions = const [],
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.card,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
        onPressed: () => Get.back(),
      )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
