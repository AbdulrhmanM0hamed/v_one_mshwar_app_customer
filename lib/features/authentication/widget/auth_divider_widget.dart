import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

/// Reusable divider widget with text for authentication screens
class AuthDividerWidget extends StatelessWidget {
  final String text;

  const AuthDividerWidget({super.key, this.text = "or continue with"});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomText(
            text: text.tr,
            size: 13,
            color: isDarkMode ? AppThemeData.grey500Dark : AppThemeData.grey500,
          ),
        ),
        Expanded(
          child: Divider(
            color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
