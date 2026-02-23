import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class DriverNotificationPopup extends StatelessWidget {
  final String title;
  final String message;
  final String? driverName;
  final String? eta;
  final String notificationType; // 'on_way' or 'arrived'

  const DriverNotificationPopup({
    super.key,
    required this.title,
    required this.message,
    this.driverName,
    this.eta,
    required this.notificationType,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon based on notification type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: notificationType == 'arrived'
                    ? AppThemeData.success300.withValues(alpha: 0.1)
                    : AppThemeData.secondary200.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notificationType == 'arrived' ? Iconsax.location : Iconsax.car,
                size: 40,
                color: notificationType == 'arrived'
                    ? AppThemeData.success300
                    : AppThemeData.secondary200,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            CustomText(
              text: title,
              size: 22,
              weight: FontWeight.bold,
              color: isDarkMode
                  ? AppThemeData.grey900Dark
                  : AppThemeData.grey900,
              align: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Driver name (if available)
            if (driverName != null && driverName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CustomText(
                  text: driverName!,
                  size: 18,
                  weight: FontWeight.w600,
                  color: isDarkMode
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                  align: TextAlign.center,
                ),
              ),
            // Message
            CustomText(
              text: message,
              size: 16,
              weight: FontWeight.normal,
              color: isDarkMode
                  ? AppThemeData.grey500Dark
                  : AppThemeData.grey500,
              align: TextAlign.center,
            ),
            // ETA (if available and not arrived)
            if (eta != null && eta!.isNotEmpty && notificationType == 'on_way')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeData.secondary200.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 18,
                        color: AppThemeData.secondary200,
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        text: 'ETA: $eta',
                        size: 16,
                        weight: FontWeight.w600,
                        color: AppThemeData.secondary200,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // OK Button
            CustomButton(
              btnName: 'OK'.tr,
              ontap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? driverName,
    String? eta,
    required String notificationType,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => DriverNotificationPopup(
        title: title,
        message: message,
        driverName: driverName,
        eta: eta,
        notificationType: notificationType,
      ),
    );
  }
}
