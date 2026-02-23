import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/dash_board_controller.dart';
import 'package:v_one_mshwar_app_customer/features/settings/localization/controller/localization_controller.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/login_screen.dart';
import 'package:v_one_mshwar_app_customer/features/splash/splash_screen.dart';
import 'package:v_one_mshwar_app_customer/service/localization_service.dart';
import 'package:v_one_mshwar_app_customer/core/themes/button_them.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class LocalizationScreens extends StatelessWidget {
  final String intentType;

  const LocalizationScreens({super.key, required this.intentType});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LocalizationController>(
      init: LocalizationController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'change_language'.tr,
            actions: intentType != "dashBoard"
                ? [
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        final langCode = controller.selectedLanguage.value;
                        LocalizationService().changeLocale(langCode);
                        Preferences.setString(
                          Preferences.languageCodeKey,
                          langCode,
                        );
                        if (intentType == "dashBoard") {
                          ShowToastDialog.showToast(
                            "language_change_successfully".tr,
                          );
                          Get.forceAppUpdate();
                        } else {
                          Get.offAll(
                            const LoginScreen(),
                            transition: Transition.rightToLeft,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: CustomText(
                          text: 'skip'.tr,
                          size: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: AppThemeData.secondary200,
                          color: AppThemeData.secondary200,
                        ),
                      ),
                    ),
                  ]
                : null,
          ),
          backgroundColor: themeChange.getThem()
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'select_language'.tr,
                        size: 20,
                        weight: FontWeight.w600,
                        color: themeChange.getThem()
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                        text: 'choose_language_desc'.tr,
                        size: 13,
                        color: themeChange.getThem()
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Language List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.languageList.length,
                    itemBuilder: (context, index) {
                      return Obx(
                        () => _buildLanguageCard(
                          context,
                          controller.languageList[index],
                          controller.selectedLanguage.value ==
                              controller.languageList[index].code,
                          () {
                            controller.selectedLanguage.value = controller
                                .languageList[index]
                                .code
                                .toString();
                            showLog(
                              'Selected Language: ${controller.languageList[index].language} (${controller.selectedLanguage.value})',
                            );
                          },
                          themeChange.getThem(),
                        ),
                      );
                    },
                  ),
                ),
                // Skip Description (only for onboarding)
                if (intentType != "dashBoard")
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: CustomText(
                      text: 'skip_desc'.tr,
                      align: TextAlign.center,
                      size: 12,
                      weight: FontWeight.w400,
                      color: themeChange.getThem()
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ButtonThem.buildButton(
                context,
                title: intentType == "dashBoard" ? 'save'.tr : 'continue'.tr,
                btnHeight: 50,
                radius: 12,
                onPress: () async {
                  final langCode = controller.selectedLanguage.value;
                  await Preferences.setString(
                    Preferences.languageCodeKey,
                    langCode,
                  );
                  LocalizationService().changeLocale(langCode);
                  if (intentType == "dashBoard") {
                    ShowToastDialog.showToast(
                      "language_change_successfully".tr,
                    );
                    // Refresh drawer items with new language
                    if (Get.isRegistered<DashBoardController>()) {
                      Get.find<DashBoardController>().getDrawerItems();
                    }
                    // Restart app to apply RTL/LTR changes properly
                    Get.offAll(const SplashScreen());
                  } else {
                    Get.offAll(const LoginScreen());
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build modern language card
  Widget _buildLanguageCard(
    BuildContext context,
    dynamic languageData,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppThemeData.primary200.withValues(alpha: 0.1)
                  : isDarkMode
                  ? AppThemeData.grey800Dark
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppThemeData.primary200
                    : isDarkMode
                    ? AppThemeData.grey800Dark.withValues(alpha: 0.3)
                    : AppThemeData.grey200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppThemeData.primary200.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Flag with better styling
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDarkMode
                          ? AppThemeData.grey800Dark
                          : AppThemeData.grey200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: CachedNetworkImage(
                      imageUrl: languageData.flag.toString(),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDarkMode
                            ? AppThemeData.grey800Dark
                            : AppThemeData.grey100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDarkMode
                            ? AppThemeData.grey800Dark
                            : AppThemeData.grey100,
                        child: Icon(
                          Iconsax.flag,
                          color: isDarkMode
                              ? AppThemeData.grey500Dark
                              : AppThemeData.grey400,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Language Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: languageData.language.toString(),
                        size: 16,
                        weight: FontWeight.w600,
                        color: isSelected
                            ? AppThemeData.primary200
                            : isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      const SizedBox(height: 3),
                      CustomText(
                        text: _getLanguageNativeName(languageData.code),
                        size: 12,
                        color: isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Selection Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppThemeData.primary200
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppThemeData.primary200
                          : isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get native language name
  String _getLanguageNativeName(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'ur':
        return 'اردو';
      default:
        return '';
    }
  }
}
