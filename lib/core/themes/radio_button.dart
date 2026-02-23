import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class RadioButtonCustom extends StatelessWidget {
  final String name;
  final String? subName;
  final String groupValue;
  final bool isSelected;
  final Function(String?) onClick;
  final bool isEnabled;
  final String image;

  const RadioButtonCustom({
    super.key,
    required this.image,
    required this.name,
    this.subName,
    required this.groupValue,
    required this.isSelected,
    required this.onClick,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: isEnabled ? () => onClick(name) : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode
                      ? AppThemeData.primary200.withValues(alpha: 0.15)
                      : AppThemeData.primary50)
                : (isDarkMode ? AppThemeData.surface50Dark : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppThemeData.primary200
                  : (isDarkMode
                        ? AppThemeData.grey300Dark
                        : AppThemeData.grey200),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppThemeData.primary200.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeData.primary200.withValues(alpha: 0.1)
                      : (isDarkMode
                            ? AppThemeData.grey200Dark.withValues(alpha: 0.3)
                            : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  width: 32,
                  height: 32,
                ),
              ),

              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: name.tr,
                      color: isSelected
                          ? AppThemeData.primary200
                          : (isDarkMode
                                ? AppThemeData.grey900Dark
                                : AppThemeData.grey900),
                      size: 16,
                      weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    if (subName != null) ...[
                      const SizedBox(height: 4),
                      CustomText(
                        text: subName?.tr ?? '',
                        color: isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500,
                        size: 13,
                        weight: FontWeight.normal,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Radio Button
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppThemeData.primary200
                        : (isDarkMode
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey400),
                    width: 2,
                  ),
                  color: isSelected
                      ? AppThemeData.primary200
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
