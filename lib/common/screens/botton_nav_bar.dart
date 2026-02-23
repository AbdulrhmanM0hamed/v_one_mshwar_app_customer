import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/home_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/normal_rides_screen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/wallet_screen.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/view/subscription_list_screen.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/view/package_list_screen.dart';
import 'package:v_one_mshwar_app_customer/features/settings/settings/view/settings_screen.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});

  final List<Widget> _screens = [
    const HomeScreen(),
    const NewRideScreen(showBackButton: false),
    WalletScreen(showBackButton: false),
    const SubscriptionListScreen(showBackButton: false),
    const PackageListScreen(showBackButton: false),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    Get.put(BottomNavController(initialIndex: 0));

    return Scaffold(
      body: GetX<BottomNavController>(
        builder: (controller) => IndexedStack(
          index: controller.currentIndex.value,
          children: _screens,
        ),
      ),
      bottomNavigationBar: GetX<BottomNavController>(
        builder: (controller) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppThemeData.surface50Dark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDarkMode
                    ? AppThemeData.grey800Dark.withValues(alpha: 0.3)
                    : AppThemeData.grey200.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 4,
                bottom: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Iconsax.home,
                    activeIcon: Iconsax.home,
                    label: 'Home'.tr,
                    index: 0,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.updateIndex(0),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Iconsax.car,
                    activeIcon: Iconsax.car,
                    label: 'Rides'.tr,
                    index: 1,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.updateIndex(1),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Iconsax.wallet_2,
                    activeIcon: Iconsax.wallet_2,
                    label: 'Wallet'.tr,
                    index: 2,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.updateIndex(2),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Iconsax.calendar_1,
                    activeIcon: Iconsax.calendar_1,
                    label: 'Subs'.tr,
                    index: 3,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.updateIndex(3),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Iconsax.box,
                    activeIcon: Iconsax.box,
                    label: 'Pkgs'.tr,
                    index: 4,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.updateIndex(4),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Iconsax.setting_2,
                    activeIcon: Iconsax.setting_2,
                    label: 'Settings'.tr,
                    index: 5,
                    currentIndex: controller.currentIndex.value,
                    onTap: () => controller.updateIndex(5),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected
                      ? AppThemeData.primary200
                      : (isDarkMode
                            ? AppThemeData.grey400Dark
                            : AppThemeData.grey500),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Invisible bold text to reserve space
                      Opacity(
                        opacity: 0,
                        child: CustomText(
                          text: label,
                          size: 11,
                          weight: FontWeight.w600,
                          align: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // Visible text with current weight
                      CustomText(
                        text: label,
                        size: 11,
                        weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppThemeData.primary200
                            : (isDarkMode
                                  ? AppThemeData.grey400Dark
                                  : AppThemeData.grey500),
                        align: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavController extends GetxController {
  final RxInt currentIndex;

  BottomNavController({int initialIndex = 0}) : currentIndex = initialIndex.obs;

  void updateIndex(int index) {
    currentIndex.value = index;
  }
}
