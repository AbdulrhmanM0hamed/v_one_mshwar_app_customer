import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/controller/forgot_password_controller.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/forgot_password_otp_screen.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/mobile_number_screen.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/widget/auth_widgets.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/text_field.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final controller = Get.put(ForgotPasswordController());
  final _formKey = GlobalKey<FormState>();
  final _emailTextEditController = TextEditingController();

  @override
  void dispose() {
    _emailTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();

    return AuthScreenLayout(
      title: 'forgot_your_password'.tr,
      subtitle: 'forgot_password_subtitle'.tr,
      bottomWidget: AuthBottomLink(
        text: 'first_time_in_mshwar'.tr,
        linkText: 'create_an_account'.tr,
        onTap: () => Get.to(
          MobileNumberScreen(isLogin: false),
          duration: const Duration(milliseconds: 400),
          transition: Transition.rightToLeft,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            CustomTextField(
              text: 'email_address'.tr,
              controller: _emailTextEditController,
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

            const SizedBox(height: 32),

            // Send Button
            CustomButton(
              btnName: 'send_reset_link'.tr,
              ontap: () => _handleSendEmail(),
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendEmail() async {
    FocusScope.of(context).unfocus();

    // Check if email is valid before making API call
    final email = _emailTextEditController.text.trim();
    if (email.isEmpty) {
      ShowToastDialog.showToast('please_enter_your_email_address'.tr);
      return;
    }

    Map<String, String> bodyParams = {'email': email, 'user_cat': "user_app"};

    final result = await controller.sendEmail(bodyParams);
    if (result == true) {
      Get.to(
        ForgotPasswordOtpScreen(email: email),
        duration: const Duration(milliseconds: 400),
        transition: Transition.rightToLeft,
      );
    }
    // Error message is already shown by controller, no need for duplicate toast
  }
}
