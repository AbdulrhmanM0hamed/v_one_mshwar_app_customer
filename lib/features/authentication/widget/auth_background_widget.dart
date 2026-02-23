import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Reusable authentication background widget with gradient and decorative circles
class AuthBackgroundWidget extends StatelessWidget {
  final Widget child;
  final bool showTopCircle;
  final bool showBottomCircle;

  const AuthBackgroundWidget({
    super.key,
    required this.child,
    this.showTopCircle = true,
    this.showBottomCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  AppThemeData.primary200,
                  AppThemeData.primary200.withValues(alpha: 0.8),
                ]
              : [
                  AppThemeData.primary200,
                  AppThemeData.primary200.withValues(alpha: 0.9),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Animated Background Circles
          if (showTopCircle)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          if (showBottomCircle)
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          // Main content
          child,
        ],
      ),
    );
  }
}
