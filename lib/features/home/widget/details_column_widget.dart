import 'package:flutter/material.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';

class DetailsColumnWidget extends StatelessWidget {
  final String title;
  final String value;
  final bool isDarkMode;
  final bool isBold;

  const DetailsColumnWidget({
    super.key,
    required this.title,
    required this.value,
    required this.isDarkMode,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          text: title,
          align: TextAlign.center,
          maxLines: 1,
          size: 17,
          weight: isBold ? FontWeight.w700 : FontWeight.w600,
          color: AppThemeData.secondary200,
        ),
        CustomText(
          text: value,
          align: TextAlign.center,
          size: 12,
          weight: FontWeight.normal,
          color: isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900,
        ),
      ],
    );
  }
}
