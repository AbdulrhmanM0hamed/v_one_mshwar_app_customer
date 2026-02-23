import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/my_custom_dialog.dart';
import 'package:v_one_mshwar_app_customer/common/widget/text_field.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';

class LocationTextField extends StatelessWidget {
  final HomeController controller;
  final String label;
  final String hintText;
  final String prefixText;
  final bool isDeparture;
  final VoidCallback? onTap;

  const LocationTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixText,
    this.isDeparture = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CustomTextField(
        ontap:
            onTap ??
            () {
              MyCustomDialog.showWithActions(
                context: context,
                title: isDeparture
                    ? "select_departure".tr
                    : "select_destination".tr,
                message: isDeparture
                    ? "choose_how_to_select_departure_location".tr
                    : "choose_how_to_select_destination_location".tr,
                actions: [
                  CustomButton(
                    btnName: "search".tr,
                    icon: Icon(
                      Iconsax.search_normal,
                      size: 18,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    fontSize: 13,
                    ontap: () async {
                      Get.back();
                      await Constant()
                          .placeSelectAPI(
                            context,
                            isDeparture
                                ? controller.departureController
                                : controller.destinationController,
                          )
                          .then((value) async {
                            if (value != null) {
                              if (isDeparture) {
                                controller.setDepartureMarker(
                                  LatLng(
                                    value.result.geometry!.location.lat,
                                    value.result.geometry!.location.lng,
                                  ),
                                );
                              } else {
                                controller.setDestinationMarker(
                                  LatLng(
                                    value.result.geometry!.location.lat,
                                    value.result.geometry!.location.lng,
                                  ),
                                );
                              }
                              if (controller.departureLatLong.value !=
                                      LatLng(0.0, 0.0) &&
                                  controller.destinationLatLong.value !=
                                      LatLng(0.0, 0.0)) {
                                await controller
                                    .getDurationDistance(
                                      controller.departureLatLong.value,
                                      controller.destinationLatLong.value,
                                    )
                                    .then((durationValue) {
                                      if (durationValue != null) {
                                        if (Constant.distanceUnit == "KM") {
                                          controller.distance.value =
                                              durationValue['rows']
                                                  .first['elements']
                                                  .first['distance']['value'] /
                                              1000.00;
                                        } else {
                                          controller.distance.value =
                                              durationValue['rows']
                                                  .first['elements']
                                                  .first['distance']['value'] /
                                              1609.34;
                                        }
                                        controller.duration.value =
                                            durationValue['rows']
                                                .first['elements']
                                                .first['duration']['text'];
                                      }
                                    });
                              }
                            }
                          });
                    },
                  ),
                  CustomButton(
                    btnName: "on_map".tr,
                    isOutlined: true,
                    icon: Icon(
                      Iconsax.location,
                      size: 18,
                      color: AppThemeData.primary200,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    fontSize: 13,
                    ontap: () {
                      Get.back();
                      if (isDeparture) {
                        controller.isSelectingStart.value = true;
                        controller.isSelectingDestination.value = false;
                        Get.snackbar(
                          "select_departure".tr,
                          "tap_on_map_to_set_departure_point".tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppThemeData.primary200,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      } else {
                        controller.isSelectingStart.value = false;
                        controller.isSelectingDestination.value = true;
                        Get.snackbar(
                          "select_destination".tr,
                          "tap_on_map_to_set_destination_point".tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppThemeData.primary200,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      }
                    },
                  ),
                ],
              );
            },
        readOnly: true,
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDeparture
                ? AppThemeData.primary200.withValues(alpha: 0.15)
                : AppThemeData.secondary200.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: CustomText(
            text: prefixText,
            color: isDeparture
                ? AppThemeData.primary200
                : AppThemeData.secondary200,
            size: 16,
            weight: FontWeight.bold,
          ),
        ),
        controller: isDeparture
            ? controller.departureController
            : controller.destinationController,
        text: hintText,
        suffixIcon: Icon(
          // RTL-aware arrow: left for Arabic/Urdu, right for English
          Get.locale?.languageCode == 'ar' || Get.locale?.languageCode == 'ur'
              ? Iconsax.arrow_left_3
              : Iconsax.arrow_right_3,
          size: 20,
          color: isDarkMode ? AppThemeData.grey400Dark : AppThemeData.grey400,
        ),
      ),
    );
  }
}
