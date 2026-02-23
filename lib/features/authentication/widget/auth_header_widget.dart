import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

/// Reusable authentication header widget with consistent styling
class AuthHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AuthHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBackButton)
            IconButton(
              onPressed: onBackPressed ?? () => Get.back(),
              icon: const Icon(
                Iconsax.arrow_left_2,
                color: Colors.white,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          if (showBackButton) const SizedBox(height: 20),
          Text(
            title.tr,
            style: const TextStyle(
              fontSize: 32,
              fontFamily: AppThemeData.bold,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle.tr,
            style: TextStyle(
              fontSize: 15,
              fontFamily: AppThemeData.regular,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
