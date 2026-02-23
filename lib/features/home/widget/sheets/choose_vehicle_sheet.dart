import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/driver_model.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/vehicle_category_model.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

Future<void> chooseVehicleBottomSheet(
  BuildContext context,
  VehicleCategoryModel vehicleCategoryModel,
  bool isDarkMode,
  HomeController controller,
  PaymentController paymentCtrl,
  DarkThemeProvider themeChange,
  TextEditingController passengerController, {
  required Function(
    BuildContext,
    VehicleCategoryModel,
    DriverData,
    double,
    bool,
    HomeController,
    PaymentController,
    DarkThemeProvider,
    double,
  )
  onConfirmData,
}) {
  return showModalBottomSheet(
    barrierColor: isDarkMode
        ? AppThemeData.grey800.withAlpha(200)
        : Colors.black26,
    isDismissible: true,
    isScrollControlled: true,
    context: context,
    backgroundColor: isDarkMode
        ? AppThemeData.surface50Dark
        : AppThemeData.surface50,
    builder: (context) {
      final themeChange = Provider.of<DarkThemeProvider>(context);
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
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
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Directionality.of(context) == TextDirection.rtl
                      ? Matrix4.rotationY(3.14159)
                      : Matrix4.identity(),
                  child: Icon(
                    Iconsax.arrow_left_2,
                    color: themeChange.getThem()
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Passenger count field - shown/hidden based on admin setting
                    if (Constant.passengerCountRequired != 'hidden')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFieldWidget(
                          prefix: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Iconsax.profile_2user,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey500Dark
                                  : AppThemeData.grey300Dark,
                            ),
                          ),
                          controller: passengerController,
                          hintText: 'Enter number of passengers'.tr,
                          textInputType: TextInputType.number,
                          maxLength: 2,
                        ),
                      ),
                    CustomButton(
                      btnName: "next".tr,
                      ontap: () async {
                        // Validate passenger count if required
                        if (Constant.passengerCountRequired == 'required') {
                          if (passengerController.text.isEmpty ||
                              passengerController.text == '0') {
                            ShowToastDialog.showToast(
                              "Please enter number of passengers".tr,
                            );
                            return;
                          }
                        }
                        // Set default value if hidden
                        if (Constant.passengerCountRequired == 'hidden') {
                          passengerController.text = '1';
                        }
                        if (controller.vehicleData.value.id != null) {
                          double cout = double.parse(
                            controller.ridePrice.toString(),
                          );

                          await controller
                              .getDriverDetails(
                                controller.vehicleData.value.id ?? '',
                                '${controller.departureLatLong.value.latitude}',
                                '${controller.departureLatLong.value.longitude}',
                              )
                              .then((value) {
                                if (value != null) {
                                  if (value.success == "Success") {
                                    if (value.data?.isNotEmpty == true) {
                                      Get.back();
                                      showLog(
                                        'Count${controller.vehicleData.value.id}',
                                      );
                                      onConfirmData(
                                        context,
                                        vehicleCategoryModel,
                                        value.data![0],
                                        cout,
                                        isDarkMode,
                                        controller,
                                        paymentCtrl,
                                        themeChange,
                                        cout,
                                      );
                                    } else {
                                      ShowToastDialog.showToast(
                                        "Driver not found in your area.".tr,
                                      );
                                    }
                                  } else {
                                    ShowToastDialog.showToast(
                                      "Driver not found in your area.".tr,
                                    );
                                  }
                                }
                              });
                        } else {
                          ShowToastDialog.showToast(
                            "Please select Vehicle Type".tr,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
