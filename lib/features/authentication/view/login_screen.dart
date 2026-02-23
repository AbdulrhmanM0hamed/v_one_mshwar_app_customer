import 'dart:convert';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/controller/login_conroller.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/forgot_password.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/mobile_number_screen.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/widget/auth_widgets.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/common/screens/botton_nav_bar.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/common/widget/permission_dialog.dart';
import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/text_field.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      PermissionStatus location = await Location().hasPermission();
      if (PermissionStatus.granted != location && mounted) {
        showDialogPermission(context);
      }
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();

    final controller = Get.put(LoginController());

    return AuthScreenLayout(
      title: 'welcome_back'.tr,
      subtitle: 'login_subtitle'.tr,
      showBackButton: false,
      bottomWidget: AuthBottomLink(
        text: 'first_time_in_mshwar'.tr,
        linkText: 'create_an_account'.tr,
        onTap: () => Get.to(
          MobileNumberScreen(isLogin: false),
          duration: const Duration(milliseconds: 400),
          transition: Transition.rightToLeft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          CustomTextField(
            text: 'email_address'.tr,
            controller: controller.phoneController.value,
            keyboardType: TextInputType.emailAddress,
            validationType: ValidationType.email,
            prefixIcon: Icon(
              Iconsax.sms,
              color: isDarkMode
                  ? AppThemeData.grey400Dark
                  : AppThemeData.grey400,
              size: 22,
            ),
          ),

          const SizedBox(height: 16),

          // Password Field
          CustomTextField(
            text: 'enter_password'.tr,
            controller: controller.passwordController.value,
            keyboardType: TextInputType.text,
            obscureText: !_isPasswordVisible,
            validationType: ValidationType.password,
            prefixIcon: Icon(
              Iconsax.lock,
              color: isDarkMode
                  ? AppThemeData.grey400Dark
                  : AppThemeData.grey400,
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                color: isDarkMode
                    ? AppThemeData.grey500Dark
                    : AppThemeData.grey400,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Get.to(
                  const ForgotPasswordScreen(),
                  duration: const Duration(milliseconds: 400),
                  transition: Transition.rightToLeft,
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomText(
                  text: 'forgot_password'.tr,
                  size: 14,
                  color: AppThemeData.primary200,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Login Button
          CustomButton(
            btnName: 'login'.tr,
            ontap: () => _handleLogin(controller),
          ),

          const SizedBox(height: 32),

          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDarkMode
                      ? AppThemeData.grey300Dark
                      : AppThemeData.grey300,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomText(
                  text: 'or_continue_with'.tr,
                  size: 13,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDarkMode
                      ? AppThemeData.grey300Dark
                      : AppThemeData.grey300,
                  thickness: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Mobile Number Button
          CustomButton(
            btnName: 'mobile_number'.tr,
            ontap: () {
              Get.to(
                MobileNumberScreen(isLogin: true),
                duration: const Duration(milliseconds: 400),
                transition: Transition.rightToLeft,
              );
            },
            isOutlined: true,
            icon: Icon(
              Iconsax.mobile,
              color: AppThemeData.primary200,
              size: 22,
            ),
          ),

          if (!Platform.isIOS && !Platform.isAndroid) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    btnName: 'google'.tr,
                    ontap: () {
                      controller.loginWithGoogle();
                    },
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    btnName: 'apple'.tr,
                    ontap: () {
                      controller.loginWithApple();
                    },
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleLogin(LoginController controller) async {
    if (controller.phoneController.value.text.isEmpty) {
      ShowToastDialog.showToast('please_enter_email_address'.tr);
      return;
    }

    if (controller.passwordController.value.text.isEmpty) {
      ShowToastDialog.showToast('please_enter_password'.tr);
      return;
    }

    FocusScope.of(context).unfocus();

    Map<String, String> bodyParams = {
      'email': controller.phoneController.value.text.trim(),
      'mdp': controller.passwordController.value.text,
      'user_cat': "customer",
    };

    final value = await controller.loginAPI(bodyParams);
    if (value != null) {
      if (value.success == "Success") {
        Preferences.setInt(
          Preferences.userId,
          int.parse(value.data!.id.toString()),
        );
        Preferences.setString(Preferences.user, jsonEncode(value));
        controller.phoneController.value.clear();
        controller.passwordController.value.clear();
        Preferences.setBoolean(Preferences.isLogin, true);

        // Preload home screen data before navigating
        ShowToastDialog.showLoader('loading'.tr);
        try {
          // Delete existing controller if any and create fresh one
          if (Get.isRegistered<HomeController>()) {
            Get.delete<HomeController>(force: true);
          }
          final homeController = Get.put(HomeController(), permanent: true);
          await homeController.setInitData(forceInit: true);
        } catch (e) {
          debugPrint('Error preloading home data: $e');
        }
        ShowToastDialog.closeLoader();

        Get.offAll(
          BottomNavBar(),
          duration: const Duration(milliseconds: 400),
          transition: Transition.rightToLeft,
        );
      } else {
        ShowToastDialog.showToast(value.error);
      }
    }
  }

  void showDialogPermission(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LocationPermissionDisclosureDialog(),
    );
  }
}
