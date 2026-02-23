import 'dart:convert';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/dash_board_controller.dart';
import 'package:v_one_mshwar_app_customer/features/settings/profile/controller/my_profile_controller.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/login_screen.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/my_custom_dialog.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/text_field.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/themes/button_them.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatelessWidget {
  MyProfileScreen({super.key});

  final GlobalKey<FormState> _profileKey = GlobalKey();
  final dashboardController = Get.put(DashBoardController());

  // UI tokens
  static const double _pagePadding = 16;
  static const double _cardRadius = 18;
  static const double _avatarSize = 92;
  static const double _editFab = 34;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<MyProfileController>(
      init: MyProfileController(),
      builder: (myProfileController) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            title: 'My Profile'.tr,
            showBackButton: true,
            onBackPressed: () => Get.back(),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: LightBorderedCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: buildShowDetails(
                  isTrailingShow: false,
                  textIconColor: AppThemeData.error200,
                  isDarkMode: themeChange.getThem(),
                  title: "Delete Account".tr,
                  icon: Iconsax.trash,
                  onPress: () async {
                    await MyCustomDialog.show(
                      context: context,
                      title: 'Delete Account'.tr,
                      message: 'Are you sure you want to delete account?'.tr,
                      confirmText: 'Yes'.tr,
                      cancelText: 'No'.tr,
                      confirmButtonColor: AppThemeData.primary200,
                      cancelButtonColor: Colors.red,
                      onConfirm: () {
                        myProfileController
                            .deleteAccount(
                              Preferences.getInt(Preferences.userId).toString(),
                            )
                            .then((value) {
                              if (value != null) {
                                if (value["success"] == "success") {
                                  ShowToastDialog.showToast(value['message']);
                                  Get.back();
                                  Preferences.clearSharPreference();
                                  Get.offAll(const LoginScreen());
                                }
                              }
                            });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(_pagePadding),
                    child: Form(
                      key: _profileKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 6),

                          // Avatar (أهدى وأشيك)
                          _buildProfileImage(
                            context,
                            myProfileController,
                            themeChange,
                          ),

                          const SizedBox(height: 16),

                          // Fields Card
                          LightBorderedCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        text: 'Name'.tr,
                                        controller: myProfileController
                                            .fullNameController
                                            .value,
                                        keyboardType: TextInputType.text,
                                        maxWords: 22,
                                        validationType: ValidationType.name,
                                        prefixIcon: Icon(
                                          Iconsax.user,
                                          size: 18,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey400Dark
                                              : AppThemeData.grey500,
                                        ),
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'required'.tr;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: CustomTextField(
                                        text: 'Last Name'.tr,
                                        controller: myProfileController
                                            .lastNameController
                                            .value,
                                        keyboardType: TextInputType.text,
                                        maxWords: 22,
                                        validationType: ValidationType.name,
                                        prefixIcon: Icon(
                                          Iconsax.user,
                                          size: 18,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey400Dark
                                              : AppThemeData.grey500,
                                        ),
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'required'.tr;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                CustomTextField(
                                  text: 'Enter mobile number'.tr,
                                  controller:
                                      myProfileController.phoneController.value,
                                  keyboardType: TextInputType.phone,
                                  validationType: ValidationType.phone,
                                  prefixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Iconsax.mobile,
                                        size: 18,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey400Dark
                                            : AppThemeData.grey500,
                                      ),
                                      const SizedBox(width: 8),
                                      CustomText(
                                        text: "+965",
                                        size: 14.5,
                                        weight: FontWeight.w700,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                  ),
                                  onChanged: (value) {
                                    myProfileController
                                            .phoneController
                                            .value
                                            .text =
                                        value;
                                  },
                                ),

                                const SizedBox(height: 12),

                                CustomTextField(
                                  text: 'email'.tr,
                                  controller:
                                      myProfileController.emailController.value,
                                  keyboardType: TextInputType.emailAddress,
                                  readOnly: true,
                                  validationType: ValidationType.email,
                                  prefixIcon: Icon(
                                    Iconsax.sms,
                                    size: 18,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey500,
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'email not valid'.tr;
                                    }
                                    bool emailValid = RegExp(
                                      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
                                    ).hasMatch(value);
                                    if (!emailValid) {
                                      return 'email not valid'.tr;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                ),

                // Save Button ثابت تحت
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: CustomButton(
                    btnName: 'Save Details'.tr,
                    ontap: () async {
                      FocusScope.of(context).unfocus();
                      if (_profileKey.currentState!.validate()) {
                        await myProfileController
                            .updateUser(
                              image: File(
                                myProfileController.imageData.value.path,
                              ),
                              name: myProfileController
                                  .fullNameController
                                  .value
                                  .text
                                  .trim(),
                              lname: myProfileController
                                  .lastNameController
                                  .value
                                  .text
                                  .trim(),
                              email: myProfileController
                                  .emailController
                                  .value
                                  .text
                                  .trim(),
                              phoneNum: myProfileController
                                  .phoneController
                                  .value
                                  .text
                                  .trim(),
                              password: myProfileController
                                  .currentPasswordController
                                  .value
                                  .text
                                  .trim(),
                            )
                            .then((value) {
                              if (value != null) {
                                if (value.success == "success") {
                                  Preferences.setInt(
                                    Preferences.userId,
                                    int.parse(value.data!.id.toString()),
                                  );
                                  Preferences.setString(
                                    Preferences.user,
                                    jsonEncode(value),
                                  );

                                  final DashBoardController
                                  dashboardController =
                                      Get.find<DashBoardController>();

                                  dashboardController.userModel =
                                      Constant.getUserData();
                                  dashboardController
                                          .userModel!
                                          .data!
                                          .photoPath =
                                      "${dashboardController.userModel!.data!.photoPath}?refresh=${DateTime.now().microsecondsSinceEpoch}";
                                  dashboardController.update();
                                  Get.back();
                                } else {
                                  ShowToastDialog.showToast(value.error);
                                }
                              }
                            });
                      }
                    },
                    buttonColor: AppThemeData.primary200,
                    textColor: Colors.white,
                    borderRadius: 14,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    MyProfileController controller,
    DarkThemeProvider themeChange,
  ) {
    final isDarkMode = themeChange.getThem();

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                height: _avatarSize,
                width: _avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode
                        ? AppThemeData.grey200Dark
                        : AppThemeData.grey100,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: controller.imageData.value.path.isNotEmpty
                      ? Image.file(
                          File(controller.imageData.value.path),
                          height: _avatarSize,
                          width: _avatarSize,
                          fit: BoxFit.cover,
                        )
                      : (controller.photoPath.isEmpty ||
                            controller.photoPath.toString() == 'null')
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppThemeData.primary200.withValues(alpha: 0.12),
                                AppThemeData.primary200.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Iconsax.user,
                            size: 42,
                            color: AppThemeData.primary200,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: controller.photoPath.toString(),
                          height: _avatarSize,
                          width: _avatarSize,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    value: progress.progress,
                                    color: AppThemeData.primary200,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppThemeData.primary200.withValues(
                                    alpha: 0.12,
                                  ),
                                  AppThemeData.primary200.withValues(
                                    alpha: 0.05,
                                  ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              Iconsax.user,
                              size: 42,
                              color: AppThemeData.primary200,
                            ),
                          ),
                        ),
                ),
              ),

              // Edit button
              Positioned(
                bottom: 2,
                right: 2,
                child: InkWell(
                  onTap: () => buildBottomSheet(context, controller),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: _editFab,
                    width: _editFab,
                    decoration: BoxDecoration(
                      color: AppThemeData.primary200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode
                            ? AppThemeData.surface50Dark
                            : Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeData.primary200.withValues(
                            alpha: 0.28,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.edit_2,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "Tap to change photo".tr,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? AppThemeData.grey400Dark
                  : AppThemeData.grey500,
            ),
          ),
        ],
      ),
    );
  }

  ListTile buildShowDetails({
    required String title,
    required IconData icon,
    required Function()? onPress,
    required bool isDarkMode,
    Color? textIconColor,
    bool? isTrailingShow = true,
  }) {
    return ListTile(
      onTap: onPress,
      dense: true,
      visualDensity: VisualDensity.compact,
      splashColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      leading: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: (textIconColor ?? AppThemeData.error200).withValues(
            alpha: 0.10,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (textIconColor ?? AppThemeData.error200).withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              textIconColor ??
              (isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900),
        ),
      ),
      title: CustomText(
        text: title,
        size: 15,
        weight: FontWeight.w700,
        color:
            textIconColor ??
            (isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900),
      ),
      trailing: isTrailingShow == false
          ? null
          : Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: isDarkMode
                  ? AppThemeData.grey300Dark
                  : AppThemeData.grey400,
            ),
    );
  }

  Future buildAlertChangeData(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required IconData iconData,
    required String? Function(String?) validators,
    required Function() onSubmitBtn,
  }) {
    return Get.defaultDialog(
      titlePadding: const EdgeInsets.only(top: 20),
      radius: 10,
      title: "Change Information".tr,
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      content: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldThem.boxBuildTextField(
              conext: context,
              hintText: title,
              controller: controller,
              validators: validators,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ButtonThem.buildButton(
                  context,
                  title: "Save".tr,
                  btnColor: AppThemeData.primary200,
                  txtColor: Colors.white,
                  onPress: onSubmitBtn,
                  btnWidthRatio: 0.34,
                ),
                const SizedBox(width: 12),
                ButtonThem.buildButton(
                  context,
                  title: "cancel".tr,
                  btnWidthRatio: 0.34,
                  btnColor: AppThemeData.secondary200,
                  txtColor: Colors.black,
                  onPress: () => Get.back(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future buildBottomSheet(
    BuildContext context,
    MyProfileController controller,
  ) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final isDarkMode = themeChange.getThem();

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppThemeData.surface50Dark : Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(
              color: isDarkMode
                  ? AppThemeData.grey200Dark
                  : AppThemeData.grey200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppThemeData.grey300Dark
                      : AppThemeData.grey300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Choose source".tr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _pickCard(
                      isDarkMode: isDarkMode,
                      title: "camera".tr,
                      icon: Iconsax.camera,
                      tint: AppThemeData.primary200,
                      onTap: () =>
                          pickFile(controller, source: ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pickCard(
                      isDarkMode: isDarkMode,
                      title: "gallery".tr,
                      icon: Iconsax.gallery,
                      tint: AppThemeData.secondary200,
                      onTap: () =>
                          pickFile(controller, source: ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pickCard({
    required bool isDarkMode,
    required String title,
    required IconData icon,
    required Color tint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: tint.withValues(alpha: 0.08),
          border: Border.all(color: tint.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: tint),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile(
    MyProfileController controller, {
    required ImageSource source,
  }) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      controller.imageData.value = image;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"Failed to Pick :".tr}\n $e");
    }
  }
}
