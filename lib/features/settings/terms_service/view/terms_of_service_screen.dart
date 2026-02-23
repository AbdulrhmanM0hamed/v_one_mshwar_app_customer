import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/features/settings/terms_service/controller/terms_of_service_controller.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return GetX<TermsOfServiceController>(
      init: TermsOfServiceController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          appBar: CustomAppBar(
            title: 'Terms & Conditions'.tr,
            showBackButton: true,
            onBackPressed: () => Get.back(),
          ),
          body: SafeArea(
            child: controller.data.value.isEmpty
                ? _buildLoadingState(isDarkMode)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Header Card
                        LightBorderedCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(20),
                          backgroundColor: AppThemeData.primary200.withValues(
                            alpha: 0.1,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppThemeData.primary200.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Iconsax.document_text,
                                  size: 28,
                                  color: AppThemeData.primary200,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: 'Terms of Service'.tr,
                                      size: 18,
                                      weight: FontWeight.w600,
                                      color: isDarkMode
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                    ),
                                    const SizedBox(height: 4),
                                    CustomText(
                                      text:
                                          'Please read our terms carefully'.tr,
                                      size: 13,
                                      color: isDarkMode
                                          ? AppThemeData.grey400Dark
                                          : AppThemeData.grey500,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Content Card
                        LightBorderedCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(20),
                          child: Html(
                            data: controller.data.value,
                            style: {
                              "body": Style(
                                fontSize: FontSize(15),
                                lineHeight: LineHeight(1.6),
                                color: isDarkMode
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey500,
                                fontFamily: 'Cairo',
                              ),
                              "h1": Style(
                                fontSize: FontSize(24),
                                fontWeight: FontWeight.w700,
                                color: isDarkMode
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                                margin: Margins.only(top: 20, bottom: 12),
                              ),
                              "h2": Style(
                                fontSize: FontSize(20),
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                                margin: Margins.only(top: 16, bottom: 8),
                              ),
                              "h3": Style(
                                fontSize: FontSize(18),
                                fontWeight: FontWeight.w600,
                                color: AppThemeData.primary200,
                                margin: Margins.only(top: 14, bottom: 8),
                              ),
                              "p": Style(
                                fontSize: FontSize(15),
                                margin: Margins.only(bottom: 12),
                              ),
                              "ul": Style(
                                margin: Margins.only(left: 16, bottom: 12),
                              ),
                              "li": Style(
                                fontSize: FontSize(15),
                                margin: Margins.only(bottom: 8),
                              ),
                              "strong": Style(
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                              ),
                              "a": Style(
                                color: AppThemeData.primary200,
                                textDecoration: TextDecoration.underline,
                              ),
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Constant.loader(Get.context!),
          const SizedBox(height: 16),
          CustomText(
            text: 'Loading Terms & Conditions...'.tr,
            size: 14,
            color: isDarkMode ? AppThemeData.grey400Dark : AppThemeData.grey500,
          ),
        ],
      ),
    );
  }
}
