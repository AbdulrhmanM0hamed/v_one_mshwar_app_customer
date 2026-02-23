import 'dart:convert';
import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/text_field.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/controller/sign_up_controller.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/login_screen.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/signup_success_screen.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/widget/auth_widgets.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Helper method to get icon with consistent styling
  Icon _buildIcon(IconData icon, bool isDarkMode) {
    return Icon(
      icon,
      color: isDarkMode ? AppThemeData.grey400Dark : AppThemeData.grey400,
      size: 22,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();
    final controller = Get.put(SignUpController());

    // Strip country code (965 or +965) from phone number if present
    String phoneArg = Get.arguments?['phoneNumber'] ?? "";
    if (phoneArg.startsWith('+965')) {
      phoneArg = phoneArg.substring(4);
    } else if (phoneArg.startsWith('965')) {
      phoneArg = phoneArg.substring(3);
    }
    if (phoneArg.isNotEmpty) {
      controller.phoneNumber.value.text = phoneArg;
    }

    return AuthScreenLayout(
      title: 'create_your_account'.tr,
      subtitle: 'signup_subtitle'.tr,
      bottomWidget: AuthBottomLink(
        text: 'already_have_an_account'.tr,
        linkText: 'log_in'.tr,
        onTap: () => Get.offAll(
          const LoginScreen(),
          duration: const Duration(milliseconds: 400),
          transition: Transition.rightToLeft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Fields Row
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  text: 'first_name'.tr,
                  controller: controller.firstNameController.value,
                  keyboardType: TextInputType.name,
                  validationType: ValidationType.name,
                  prefixIcon: _buildIcon(Iconsax.user, isDarkMode),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  text: 'last_name'.tr,
                  controller: controller.lastNameController.value,
                  keyboardType: TextInputType.name,
                  validationType: ValidationType.name,
                  prefixIcon: _buildIcon(Iconsax.user, isDarkMode),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Phone Number Field (Read-only since already verified)
          PhoneInputWidget(
            controller: controller.phoneNumber.value,
            readOnly: true,
            onChanged: (value) {
              controller.phoneNumber.value.text = value;
            },
          ),

          const SizedBox(height: 16),

          // Email Field
          CustomTextField(
            text: 'email_address'.tr,
            controller: controller.emailController.value,
            keyboardType: TextInputType.emailAddress,
            validationType: ValidationType.email,
            readOnly:
                controller.loginType.value == "google" ||
                controller.loginType.value == "apple",
            prefixIcon: _buildIcon(Iconsax.sms, isDarkMode),
          ),

          // Password Fields (only if not social login)
          if (controller.loginType.value != "google" &&
              controller.loginType.value != "apple") ...[
            const SizedBox(height: 16),

            // Password Field
            CustomTextField(
              text: 'password'.tr,
              controller: controller.passwordController.value,
              keyboardType: TextInputType.text,
              obscureText: !_isPasswordVisible,
              validationType: ValidationType.password,
              prefixIcon: _buildIcon(Iconsax.lock, isDarkMode),
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

            // Confirm Password Field
            CustomTextField(
              text: 'confirm_password'.tr,
              controller: controller.conformPasswordController.value,
              keyboardType: TextInputType.text,
              obscureText: !_isConfirmPasswordVisible,
              validationType: ValidationType.confirmPassword,
              passwordController: controller.passwordController.value,
              prefixIcon: _buildIcon(Iconsax.lock, isDarkMode),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey400,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Sign Up Button
          CustomButton(
            btnName: 'sign_up'.tr,
            ontap: () => _handleSignUp(controller),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleSignUp(SignUpController controller) async {
    FocusScope.of(context).unfocus();

    // Validate First Name
    if (controller.firstNameController.value.text.trim().isEmpty) {
      ShowToastDialog.showToast('first_name_required'.tr);
      return;
    }

    // Validate Last Name
    if (controller.lastNameController.value.text.trim().isEmpty) {
      ShowToastDialog.showToast('last_name_required'.tr);
      return;
    }

    // Phone number is already OTP-verified, no need to validate again
    final phoneNumber = controller.phoneNumber.value.text.trim();

    // Validate Email
    final email = controller.emailController.value.text.trim();
    if (email.isEmpty) {
      ShowToastDialog.showToast('email_required'.tr);
      return;
    }

    bool emailValid = RegExp(
      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
    ).hasMatch(email);
    if (!emailValid) {
      ShowToastDialog.showToast('please_enter_valid_email'.tr);
      return;
    }

    // Validate Password (only for non-social login)
    if (controller.loginType.value != "google" &&
        controller.loginType.value != "apple") {
      if (controller.passwordController.value.text.length < 6) {
        ShowToastDialog.showToast('password_must_be_at_least_6'.tr);
        return;
      }

      if (controller.passwordController.value.text !=
          controller.conformPasswordController.value.text) {
        ShowToastDialog.showToast('passwords_do_not_match'.tr);
        return;
      }
    }

    Map<String, String> bodyParams = {
      'firstname': controller.firstNameController.value.text.trim(),
      'lastname': controller.lastNameController.value.text.trim(),
      'phone': '965$phoneNumber',
      'email': email,
      'password': controller.passwordController.value.text,
      'login_type': controller.loginType.value,
      'tonotify': 'yes',
      'account_type': 'customer',
    };

    await controller.signUp(bodyParams).then((value) {
      if (value != null) {
        if (value.success == "success") {
          Preferences.setInt(
            Preferences.userId,
            int.parse(value.data!.id.toString()),
          );
          Preferences.setString(Preferences.user, jsonEncode(value));
          Preferences.setBoolean(Preferences.isLogin, true);
          controller.phoneNumber.value.clear();

          Get.offAll(const SignUpSuccessScreen());
        } else {
          ShowToastDialog.showToast(value.error);
        }
      }
    });
  }
}
