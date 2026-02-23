import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/driver_model.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/vehicle_category_model.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/payment_method_full_screen.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/pick_date_time.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Step 1: User selects Book Now or Schedule Ride
Future<void> rideTypeSelectionDialog(
  BuildContext context,
  VehicleCategoryModel vehicleCategoryModel,
  double tripPrice,
  DriverData driverData,
  bool isDarkMode,
  HomeController controller,
  double originalTripPrice,
) {
  return showModalBottomSheet(
    barrierColor: isDarkMode
        ? AppThemeData.grey800.withAlpha(200)
        : Colors.black26,
    isDismissible: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(15),
        topLeft: Radius.circular(15),
      ),
    ),
    context: context,
    backgroundColor: isDarkMode
        ? AppThemeData.surface50Dark
        : AppThemeData.surface50,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 8,
                    width: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: isDarkMode
                          ? AppThemeData.grey300Dark
                          : AppThemeData.grey300,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomText(
                  text: "choose_ride_type".tr,
                  size: 22,
                  weight: FontWeight.w600,
                  color: isDarkMode
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: "do_you_want_to_book_now_or_schedule".tr,
                  size: 14,
                  weight: FontWeight.normal,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
                const SizedBox(height: 24),
                // Book Now Button
                CustomButton(
                  btnName: "book_now".tr,
                  ontap: () {
                    Get.back();
                    // Step 2: Navigate to full screen payment method selection
                    Get.to(
                      () => PaymentMethodFullScreen(
                        vehicleCategoryModel: vehicleCategoryModel,
                        tripPrice: tripPrice,
                        driverData: driverData,
                        originalTripPrice: originalTripPrice,
                        isSchedule: false,
                        scheduleDateTime: null,
                        homeController: controller,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Schedule Ride Button
                CustomButton(
                  btnName: "schedule_ride".tr,
                  buttonColor: isDarkMode
                      ? AppThemeData.grey200Dark
                      : AppThemeData.grey200,
                  textColor: isDarkMode
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                  ontap: () async {
                    // Pick date and time first
                    DateTime? scheduleRideDateTime = await pickDateTime(
                      context,
                    );
                    if (scheduleRideDateTime == null) {
                      ShowToastDialog.showToast("please_select_date_time".tr);
                      return;
                    }
                    Get.back();
                    // Step 2: Navigate to full screen payment method selection with schedule info
                    Get.to(
                      () => PaymentMethodFullScreen(
                        vehicleCategoryModel: vehicleCategoryModel,
                        tripPrice: tripPrice,
                        driverData: driverData,
                        originalTripPrice: originalTripPrice,
                        isSchedule: true,
                        scheduleDateTime: scheduleRideDateTime,
                        homeController: controller,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}
