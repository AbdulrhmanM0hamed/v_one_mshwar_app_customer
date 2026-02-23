import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

/// Reusable social login button widget for Google and Apple sign-in
class SocialLoginButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SocialLoginButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDarkMode
                ? AppThemeData.grey300Dark.withValues(alpha: 0.5)
                : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              borderColor ??
              (isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey200),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(iconPath, width: 24, height: 24),
                const SizedBox(width: 12),
                Text(
                  label.tr,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: AppThemeData.medium,
                    color:
                        textColor ??
                        (isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
