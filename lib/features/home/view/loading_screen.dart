import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/responsive.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatelessWidget {
  final dynamic controller;
  const LoadingScreen({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeData.surface50Dark : AppThemeData.surface50,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Responsive.height(10, context)),
          Image.asset(
            'assets/icons/appLogo.png',
            width: Responsive.width(70, context),
            height: Responsive.width(45, context),
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 30),
          Constant.loader(
            context,
            loadingcolor: isDarkMode
                ? AppThemeData.grey400Dark
                : AppThemeData.grey400,
            bgColor: isDarkMode
                ? AppThemeData.grey800
                : AppThemeData.loadingBgColor,
          ),
          Text(
            'loading'.tr,
            style: TextStyle(
              color: isDarkMode
                  ? AppThemeData.grey400Dark
                  : AppThemeData.grey400,
              fontSize: 16,
              fontFamily: AppThemeData.light,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            controller.isHomePageLoading.value.toString(),
            style: const TextStyle(color: Colors.transparent, fontSize: 0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
