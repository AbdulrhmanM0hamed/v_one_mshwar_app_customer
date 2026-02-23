import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: isDarkTheme
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      primaryColor: isDarkTheme
          ? AppThemeData.grey900Dark
          : AppThemeData.grey900,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      // Set Cairo as default font for the entire app
      fontFamily: 'Cairo',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Cairo'),
        displayMedium: TextStyle(fontFamily: 'Cairo'),
        displaySmall: TextStyle(fontFamily: 'Cairo'),
        headlineLarge: TextStyle(fontFamily: 'Cairo'),
        headlineMedium: TextStyle(fontFamily: 'Cairo'),
        headlineSmall: TextStyle(fontFamily: 'Cairo'),
        titleLarge: TextStyle(fontFamily: 'Cairo'),
        titleMedium: TextStyle(fontFamily: 'Cairo'),
        titleSmall: TextStyle(fontFamily: 'Cairo'),
        bodyLarge: TextStyle(fontFamily: 'Cairo'),
        bodyMedium: TextStyle(fontFamily: 'Cairo'),
        bodySmall: TextStyle(fontFamily: 'Cairo'),
        labelLarge: TextStyle(fontFamily: 'Cairo'),
        labelMedium: TextStyle(fontFamily: 'Cairo'),
        labelSmall: TextStyle(fontFamily: 'Cairo'),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: isDarkTheme
            ? AppThemeData.surface50Dark
            : AppThemeData.surface50,
        dialTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
