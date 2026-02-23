import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/controller/forgot_password_controller.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/login_screen.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/widget/auth_widgets.dart';
import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/text_field.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:iconsax/iconsax.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String? email;
  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final controller = Get.put(ForgotPasswordController());
  final _formKey = GlobalKey<FormState>();

  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();

    return AuthScreenLayout(
      title: 'reset_your_password'.tr,
      subtitle: 'reset_password_subtitle'.tr,
      bottomWidget: Center(
        child: CustomText(
          text: 'check_email_for_otp'.tr,
          size: 14,
          color: isDarkMode ? AppThemeData.grey500Dark : AppThemeData.grey500,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                    : AppThemeData.grey100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? AppThemeData.grey300Dark
                      : AppThemeData.grey200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.sms, color: AppThemeData.primary200, size: 20),
                  const SizedBox(width: 12),
                  CustomText(
                    text: widget.email ?? '',
                    size: 16,
                    color: isDarkMode
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // OTP Input
            OtpInputWidget(controller: _otpController, length: 4),

            const SizedBox(height: 24),

            // Password Field
            CustomTextField(
              text: 'new_password'.tr,
              controller: _passwordController,
              keyboardType: TextInputType.text,
              obscureText: !_isPasswordVisible,
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
              validator: (String? value) {
                if (value == null || value.length < 6) {
                  return 'password_must_be_at_least_6_characters'.tr;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Confirm Password Field
            CustomTextField(
              text: 'confirm_password'.tr,
              controller: _confirmPasswordController,
              keyboardType: TextInputType.text,
              obscureText: !_isConfirmPasswordVisible,
              prefixIcon: Icon(
                Iconsax.lock,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
                size: 22,
              ),
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
              validator: (String? value) {
                if (_passwordController.text != value) {
                  return 'passwords_do_not_match_validation'.tr;
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Reset Password Button
            CustomButton(
              btnName: 'reset_password'.tr,
              ontap: () => _handleResetPassword(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (_otpController.text.trim().length < 4) {
        ShowToastDialog.showToast('please_enter_complete_otp'.tr);
        return;
      }

      Map<String, String> bodyParams = {
        'email': widget.email.toString(),
        'otp': _otpController.text.trim(),
        'new_password': _passwordController.text.trim(),
        'confirm_password': _passwordController.text.trim(),
        'user_cat': "user_app",
      };

      controller.resetPassword(bodyParams).then((value) {
        if (value != null) {
          if (value == true) {
            Get.offAll(
              const LoginScreen(),
              duration: const Duration(milliseconds: 400),
              transition: Transition.rightToLeft,
            );
            ShowToastDialog.showToast('password_changed_successfully'.tr);
          } else {
            ShowToastDialog.showToast('please_try_again_later'.tr);
          }
        }
      });
    }
  }
}
