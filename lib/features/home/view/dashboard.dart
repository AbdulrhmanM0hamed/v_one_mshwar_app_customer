import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/my_custom_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/login_screen.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/dash_board_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/home_screen.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/responsive.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  DateTime backPress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashBoardController());
    controller.getDrawerItems();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final timeGap = DateTime.now().difference(backPress);
        final cantExit = timeGap >= const Duration(seconds: 2);
        backPress = DateTime.now();

        if (cantExit) {
          var snack = SnackBar(
            content: Text(
              'press_back_again_to_exit'.tr,
              style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black,
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
        } else {
          // Exit the app
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(body: const HomeScreen()),
    );
  }
}

IconData _getIconData(String iconName) {
  switch (iconName) {
    case 'ic_home':
      return Iconsax.home;
    case 'ic_parcel':
      return Iconsax.car;
    case 'ic_rent':
      return Iconsax.heart;
    case 'ic_wallet':
      return Iconsax.wallet_2;
    case 'ic_car':
      return Iconsax.box_1;
    case 'ic_subscription':
      return Iconsax.calendar_tick;
    case 'ic_package':
      return Iconsax.box;
    case 'ic_calendar':
      return Iconsax.calendar_1;
    case 'ic_profile':
      return Iconsax.user;
    case 'ic_lock':
      return Iconsax.lock;
    case 'ic_refer':
      return Iconsax.people;
    case 'ic_language':
      return Iconsax.language_square;
    case 'ic_terms':
      return Iconsax.document_text;
    case 'ic_privacy':
      return Iconsax.shield_tick;
    case 'ic_dark':
      return Iconsax.moon;
    case 'ic_star':
    case 'ic_star_line':
      return Iconsax.star;
    case 'ic_logout':
      return Iconsax.logout;
    default:
      return Iconsax.home; // default
  }
}

Drawer buildAppDrawer(BuildContext context, DashBoardController controller) {
  final themeChange = Provider.of<DarkThemeProvider>(context);
  final isDarkMode = themeChange.getThem();

  var drawerOptions = <Widget>[];
  bool isFirstItem = true;

  for (var i = 0; i < controller.drawerItems.length; i++) {
    var d = controller.drawerItems[i];

    final bool isFirstItemInSection =
        d.section != null &&
        (i == 0 || controller.drawerItems[i - 1].section != d.section);

    // Add section header if this is the first item with this section
    if (isFirstItemInSection) {
      drawerOptions.add(
        Padding(
          padding: EdgeInsets.only(
            top: isFirstItem ? 8 : 14, // تقليل كبير من 12 و 20
            bottom: 4, // تقليل من 6 إلى 4
            left: 14, // تقليل من 16 إلى 14
            right: 14,
          ),
          child: CustomText(
            text: d.section ?? '',
            isPrimary: true,
            size: 10, // تقليل من 11 إلى 10
            weight: FontWeight.w600,
            letterSpacing: 0.8, // تقليل من 1.0 إلى 0.8
          ),
        ),
      );
      isFirstItem = false;
    } else if (i == 0 && d.section == null) {
      // First item without section (Home)
      isFirstItem = false;
    }

    final bool isSelected = controller.selectedDrawerIndex.value == i;
    final bool isLogout =
        controller.drawerItems[i].title ==
        controller.drawerItems[controller.drawerItems.length - 1].title;

    // Add menu item with modern card design
    drawerOptions.add(
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 1.5,
        ), // تقليل كبير في المسافات
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Show confirmation dialog for logout
              if (isLogout) {
                _showLogoutDialog(context);
              } else {
                controller.onSelectItem(i);
              }
            },
            borderRadius: BorderRadius.circular(10), // تقليل من 12 إلى 10
            splashColor: AppThemeData.primary200.withValues(alpha: 0.1),
            highlightColor: AppThemeData.primary200.withValues(alpha: 0.05),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected
                    ? AppThemeData.primary200.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppThemeData.primary200.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ), // تقليل أكثر
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5), // تقليل من 6 إلى 5
                    decoration: BoxDecoration(
                      color: isLogout
                          ? AppThemeData.error200.withValues(alpha: 0.1)
                          : isSelected
                          ? AppThemeData.primary200.withValues(alpha: 0.15)
                          : (isDarkMode
                                ? AppThemeData.grey800Dark.withValues(
                                    alpha: 0.5,
                                  )
                                : AppThemeData.grey100.withValues(alpha: 0.8)),
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // تقليل من 10 إلى 8
                    ),
                    child: Icon(
                      _getIconData(d.icon),
                      size: 18, // تقليل من 20 إلى 18
                      color: isLogout
                          ? AppThemeData.error200
                          : isSelected
                          ? AppThemeData.primary200
                          : (isDarkMode
                                ? AppThemeData.grey400Dark
                                : AppThemeData.grey800),
                    ),
                  ),
                  const SizedBox(width: 10), // تقليل من 12 إلى 10
                  Expanded(
                    child: CustomText(
                      text: d.title,
                      isError: isLogout,
                      isPrimary: isSelected && !isLogout,
                      size: 13, // تقليل من 14 إلى 13
                      weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  d.isSwitch == null
                      ? Icon(
                          // ضبط اتجاه السهم حسب اللغة
                          Directionality.of(context) == TextDirection.rtl
                              ? Iconsax.arrow_left_3
                              : Iconsax.arrow_right_3,
                          size: 15, // تقليل من 16 إلى 15
                          color: isSelected
                              ? AppThemeData.primary200
                              : (isDarkMode
                                    ? AppThemeData.grey500Dark
                                    : AppThemeData.grey400),
                        )
                      : Transform.scale(
                          scale: 0.75, // تقليل من 0.8 إلى 0.75
                          child: Switch(
                            trackOutlineColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  Set<WidgetState> states,
                                ) {
                                  return Colors.transparent;
                                }),
                            inactiveTrackColor: isDarkMode
                                ? AppThemeData.grey800
                                : AppThemeData.grey200,
                            activeTrackColor: AppThemeData.primary200,
                            thumbColor: WidgetStateProperty.resolveWith<Color>((
                              Set<WidgetState> states,
                            ) {
                              return Colors.white;
                            }),
                            value: isDarkMode,
                            onChanged: (value) =>
                                (themeChange.darkTheme = value == true ? 0 : 1),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  return Drawer(
    width: Responsive.width(68, context), // تقليل أكثر من 75% إلى 68%
    backgroundColor: isDarkMode
        ? AppThemeData.surface50Dark
        : AppThemeData.surface50,
    child: Column(
      children: [
        // Modern Header with Gradient - تقليل الحجم أكثر
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemeData.primary200,
                AppThemeData.primary200.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 14,
              ), // تقليل أكثر
              child: Column(
                children: [
                  // Logo with modern container - تقليل الحجم أكثر
                  Container(
                    padding: const EdgeInsets.all(8), // تقليل من 10 إلى 8
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14), // تقليل
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/icons/appLogo.png",
                      height: 42, // تقليل من 50 إلى 42
                      width: 42,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10), // تقليل من 12 إلى 10
                  // User Name
                  CustomText(
                    text:
                        "${controller.userModel?.data?.prenom ?? ''} ${controller.userModel?.data?.nom ?? ''}",
                    color: Colors.white,
                    size: 16, // تقليل من 18 إلى 16
                    weight: FontWeight.bold,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 3), // تقليل من 4 إلى 3
                  // User Email with icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.sms,
                        size: 11, // تقليل من 12 إلى 11
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: CustomText(
                          text: controller.userModel?.data?.email ?? '',
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 11, // تقليل من 12 إلى 11
                          align: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Menu Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 2, bottom: 12), // تقليل أكثر
            children: drawerOptions,
          ),
        ),
      ],
    ),
  );
}

/// Show logout confirmation dialog
void _showLogoutDialog(BuildContext context) {
  Get.back(); // Close the drawer first
  MyCustomDialog.show(
    context: context,
    title: 'log_out'.tr,
    message: 'are_you_sure_logout'.tr,
    confirmText: 'log_out'.tr,
    cancelText: 'cancel'.tr,
    confirmButtonColor: AppThemeData.error200,
    onConfirm: () {
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Get.offAll(() => const LoginScreen());
    },
  );
}

class DrawerItem {
  String? title;
  String? icon;
  String? section;
  bool? isSwitch;

  DrawerItem(this.title, this.icon, {this.section, this.isSwitch});
}
