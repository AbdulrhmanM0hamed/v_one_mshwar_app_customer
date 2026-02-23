import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';

class ModernDateTimePicker {
  static Future<DateTime?> show(BuildContext context) async {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final isDarkMode = themeChange.getThem();

    DateTime? result = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 5,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeOut)),
          ),
          child: ScaleTransition(
            scale: anim1.drive(
              Tween(
                begin: 0.9,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.easeOut)),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Allow all future dates
        return dateTime.isAfter(
          DateTime.now().subtract(const Duration(days: 1)),
        );
      },
      theme: isDarkMode
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppThemeData.primary200,
                secondary: AppThemeData.primary200,
                surface: AppThemeData.grey800,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: AppThemeData.grey900Dark,
              ),
              cardColor: AppThemeData.grey800,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppThemeData.primary200,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.primary200,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: AppThemeData.grey800,
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: AppThemeData.primary200,
                secondary: AppThemeData.primary200,
                surface: Colors.white,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: AppThemeData.grey900,
              ),
              cardColor: Colors.white,
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppThemeData.primary200,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.primary200,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            ),
    );

    return result;
  }
}
