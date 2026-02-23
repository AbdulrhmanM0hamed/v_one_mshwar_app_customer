import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/constant/size_box.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/controller/otp_controller.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/controller/phone_number_controller.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/login_screen.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/widget/auth_widgets.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

class MobileNumberScreen extends StatefulWidget {
  final bool? isLogin;

  const MobileNumberScreen({super.key, this.isLogin});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen>
    with SingleTickerProviderStateMixin {
  final PhoneNumberController controller = Get.put(PhoneNumberController());
  final OTPController otpCtrl = Get.put(OTPController());

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    AppThemeData.primary200,
                    AppThemeData.primary200.withValues(alpha: 0.8),
                  ]
                : [
                    AppThemeData.primary200,
                    AppThemeData.primary200.withValues(alpha: 0.9),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Animated Background Circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Main Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      context.sizedBoxHeight(0.03),
                      // Header Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () => Get.back(),
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft,
                                ),
                                const SizedBox(height: 20),
                                CustomText(
                                  text: widget.isLogin == true
                                      ? 'log_in_with_mobile'.tr
                                      : 'sign_up_with_mobile'.tr,
                                  size: 32,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                                const SizedBox(height: 12),
                                CustomText(
                                  text: widget.isLogin == true
                                      ? 'mobile_login_subtitle'.tr
                                      : 'mobile_signup_subtitle'.tr,
                                  size: 15,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Form Card
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppThemeData.surface50Dark
                                  : AppThemeData.surface50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Drag Handle
                                    Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? AppThemeData.grey300Dark
                                              : AppThemeData.grey300,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Phone Number Field
                                    PhoneInputWidget(
                                      controller: controller.phoneNumber.value,
                                      onChanged: (value) {
                                        controller.phoneNumber.value.text =
                                            value;
                                      },
                                    ),

                                    const SizedBox(height: 32),

                                    // Send OTP Button
                                    CustomButton(
                                      btnName: 'send_otp'.tr,
                                      ontap: () => _handleSendOTP(),
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
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

                                    // Email Login Button
                                    CustomButton(
                                      btnName: 'email_address'.tr,
                                      ontap: () {
                                        FocusScope.of(context).unfocus();
                                        Get.back();
                                      },
                                      isOutlined: true,
                                      icon: Icon(
                                        Iconsax.sms,
                                        color: AppThemeData.primary200,
                                        size: 22,
                                      ),
                                    ),

                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Sign Up/Login Link - Bottom Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppThemeData.surface50Dark
                              : AppThemeData.surface50,
                          border: Border(
                            top: BorderSide(
                              color: isDarkMode
                                  ? AppThemeData.grey300Dark.withValues(
                                      alpha: 0.3,
                                    )
                                  : AppThemeData.grey300.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Center(
                          child: widget.isLogin == true
                              ? Text.rich(
                                  TextSpan(
                                    text: 'first_time_in_mshwar'.tr,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Cairo',
                                      color: isDarkMode
                                          ? AppThemeData.grey500Dark
                                          : AppThemeData.grey800,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: ' '),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => Get.offAll(
                                            MobileNumberScreen(isLogin: false),
                                            duration: const Duration(
                                              milliseconds: 400,
                                            ),
                                            transition: Transition.rightToLeft,
                                          ),
                                        text: 'create_an_account'.tr,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                          color: AppThemeData.primary200,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text.rich(
                                  TextSpan(
                                    text: 'already_book_rides'.tr,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Cairo',
                                      color: isDarkMode
                                          ? AppThemeData.grey500Dark
                                          : AppThemeData.grey800,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: ' '),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => Get.offAll(
                                            const LoginScreen(),
                                            duration: const Duration(
                                              milliseconds: 400,
                                            ),
                                            transition: Transition.rightToLeft,
                                          ),
                                        text: 'login'.tr,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                          color: AppThemeData.primary200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendOTP() async {
    FocusScope.of(context).unfocus();

    final phoneNumber = controller.phoneNumber.value.text.trim();

    // Validate phone number
    if (phoneNumber.isEmpty) {
      ShowToastDialog.showToast('please_enter_mobile_number'.tr);
      return;
    }

    if (phoneNumber.length != 8) {
      ShowToastDialog.showToast('kuwait_number_must_be_8_digits'.tr);
      return;
    }

    // Check if number starts with valid prefix
    // Mobile: 5 (STC), 6 (Ooredoo), 9 (Zain), 41 (Virgin Mobile)
    // Landline: 2
    // Test: 999 (for testing purposes - use OTP: 123456)
    final kuwaitPhoneRegex = RegExp(r'^(41\d{6}|[5692]\d{7}|999\d{5})$');
    if (!kuwaitPhoneRegex.hasMatch(phoneNumber)) {
      ShowToastDialog.showToast('invalid_kuwait_phone_number'.tr);
      return;
    }

    // If validation passes, send OTP
    ShowToastDialog.showLoader('code_sending'.tr);
    otpCtrl.otpController.value.clear();
    controller.SendOTPApiMethod({'mobile': '965$phoneNumber'});
  }
}
