import 'package:v_one_mshwar_app_customer/common/screens/botton_nav_bar.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignSuccessController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) => redirectScreen());
  }

  Future<void> redirectScreen() async {
    // Preload home screen data during the success animation
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

    // Wait at least 2 seconds for the success animation
    await Future.delayed(const Duration(seconds: 2));
    Get.offAll(BottomNavBar());
  }
}
