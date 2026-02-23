import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/text_field.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/dash_board_controller.dart';
import 'package:v_one_mshwar_app_customer/features/settings/profile/controller/my_profile_controller.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _passwordKey = GlobalKey();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final dashboardController = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return GetX<MyProfileController>(
      init: MyProfileController(),
      builder: (myProfileController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Change Password'.tr,
            showBackButton: true,
            onBackPressed: () => Get.back(),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _passwordKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          LightBorderedCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                // Current Password Field
                                CustomTextField(
                                  text: 'Current Password'.tr,
                                  controller: myProfileController
                                      .currentPasswordController
                                      .value,
                                  obscureText: !_isCurrentPasswordVisible,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.next,
                                  validationType: ValidationType.required,
                                  prefixIcon: Icon(
                                    Iconsax.lock,
                                    size: 18,
                                    color: isDarkMode
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey500,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isCurrentPasswordVisible
                                          ? Iconsax.eye
                                          : Iconsax.eye_slash,
                                      size: 18,
                                      color: isDarkMode
                                          ? AppThemeData.grey400Dark
                                          : AppThemeData.grey500,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isCurrentPasswordVisible =
                                            !_isCurrentPasswordVisible;
                                      });
                                    },
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "required".tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                // New Password Field
                                CustomTextField(
                                  text: 'New Password'.tr,
                                  controller: myProfileController
                                      .newPasswordController
                                      .value,
                                  obscureText: !_isNewPasswordVisible,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.next,
                                  validationType: ValidationType.password,
                                  minPasswordLength: 6,
                                  prefixIcon: Icon(
                                    Iconsax.lock,
                                    size: 18,
                                    color: isDarkMode
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey500,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isNewPasswordVisible
                                          ? Iconsax.eye
                                          : Iconsax.eye_slash,
                                      size: 18,
                                      color: isDarkMode
                                          ? AppThemeData.grey400Dark
                                          : AppThemeData.grey500,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isNewPasswordVisible =
                                            !_isNewPasswordVisible;
                                      });
                                    },
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "required".tr;
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters'
                                          .tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                // Confirm Password Field
                                CustomTextField(
                                  text: 'Confirm Password'.tr,
                                  controller: myProfileController
                                      .confirmPasswordController
                                      .value,
                                  obscureText: !_isConfirmPasswordVisible,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  validationType:
                                      ValidationType.confirmPassword,
                                  passwordController: myProfileController
                                      .newPasswordController
                                      .value,
                                  prefixIcon: Icon(
                                    Iconsax.lock,
                                    size: 18,
                                    color: isDarkMode
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey500,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Iconsax.eye
                                          : Iconsax.eye_slash,
                                      size: 18,
                                      color: isDarkMode
                                          ? AppThemeData.grey400Dark
                                          : AppThemeData.grey500,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "required".tr;
                                    }
                                    if (value !=
                                        myProfileController
                                            .newPasswordController
                                            .value
                                            .text) {
                                      return "Password Field do not match  !!"
                                          .tr;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                // Save Password Button - Fixed at bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: CustomButton(
                    btnName: 'Save Password'.tr,
                    ontap: () {
                      if (_passwordKey.currentState!.validate()) {
                        myProfileController
                            .updatePassword({
                              "id_user": myProfileController.userId.value
                                  .toString(),
                              "anc_mdp": myProfileController
                                  .currentPasswordController
                                  .value
                                  .text,
                              "new_mdp": myProfileController
                                  .newPasswordController
                                  .value
                                  .text,
                              "user_cat": "user_app",
                            })
                            .then((value) {
                              if (value != null) {
                                myProfileController
                                    .currentPasswordController
                                    .value
                                    .clear();
                                myProfileController.newPasswordController.value
                                    .clear();
                                myProfileController
                                    .confirmPasswordController
                                    .value
                                    .clear();
                                Get.back();
                                ShowToastDialog.showToast(
                                  'Password Updated!!'.tr,
                                );
                              } else {
                                ShowToastDialog.showToast(
                                  'something_went_wrong'.tr,
                                );
                              }
                            });
                      }
                    },
                    buttonColor: AppThemeData.primary200,
                    textColor: Colors.white,
                    borderRadius: 14,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
