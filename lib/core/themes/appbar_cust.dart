import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onClick;
  final Color? bgColor;
  final Color? textColor;
  final List<Widget>? actions;
  final double? elevation;
  final Widget? leading;
  final bool isLeadingIcon;

  const CustomAppbar({
    super.key,
    required this.title,
    this.onClick,
    this.bgColor,
    this.actions,
    this.elevation,
    this.isLeadingIcon = false,
    this.leading,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return AppBar(
      backgroundColor:
          bgColor ??
          (themeChange.getThem()
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50),
      elevation: elevation ?? 0,
      centerTitle: false,
      titleSpacing: 4,
      title: Text(
        title, // Localization if using GetX
        style: TextStyle(
          fontSize: 18,
          fontFamily: AppThemeData.medium,
          color:
              textColor ??
              (!themeChange.getThem()
                  ? AppThemeData.grey900Dark
                  : AppThemeData.grey900),
        ),
      ),
      leading: isLeadingIcon == true
          ? leading
          : (leading == null)
          ? IconButton(
              onPressed: onClick ?? () => Get.back(),
              icon: Icon(
                Icons.arrow_back_ios,
                color:
                    textColor ??
                    (!themeChange.getThem()
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900),
              ),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
