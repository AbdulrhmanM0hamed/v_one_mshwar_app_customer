import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/sheets/choose_vehicle_sheet.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/driver_model.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/vehicle_category_model.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/driver_details_card.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/sheets/ride_type_dialog.dart';

Future conformDataBottomSheet(
  BuildContext context,
  VehicleCategoryModel vehicleCategoryModel,
  DriverData driverModel,
  double tripPrice,
  bool isDarkMode,
  HomeController controller,
  PaymentController paymentCtrl,
  themeChange,
  double originalTripPrice,
  TextEditingController passengerController,
) {
  // State variables that persist across StatefulBuilder rebuilds
  double discountPrice = tripPrice;
  int clickIndex = -1;

  showLog("🚖 DEBUG tripPrice: $tripPrice, discountPrice: $discountPrice");

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
      return StatefulBuilder(
        builder: (context, setState) {
          return Obx(
            () => SingleChildScrollView(
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
                  IconButton(
                    onPressed: () {
                      Get.back();
                      chooseVehicleBottomSheet(
                        context,
                        vehicleCategoryModel,
                        isDarkMode,
                        controller,
                        paymentCtrl,
                        themeChange,
                        passengerController,
                        onConfirmData:
                            (
                              BuildContext ctx,
                              VehicleCategoryModel vcm,
                              DriverData dm,
                              double tp,
                              bool isDark,
                              HomeController ctrl,
                              PaymentController payCtrl,
                              DarkThemeProvider theme,
                              double originalPrice,
                            ) {
                              return conformDataBottomSheet(
                                ctx,
                                vcm,
                                dm,
                                tp,
                                isDark,
                                ctrl,
                                payCtrl,
                                theme,
                                originalPrice,
                                passengerController,
                              );
                            },
                      );
                    },
                    icon: Transform(
                      alignment: Alignment.center,
                      transform: Directionality.of(context) == TextDirection.rtl
                          ? Matrix4.rotationY(3.14159)
                          : Matrix4.identity(),
                      child: Icon(
                        Iconsax.arrow_left_2,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Destination display
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: isDarkMode
                                  ? AppThemeData.grey300Dark
                                  : AppThemeData.grey300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.location,
                                    color: AppThemeData.success300,
                                  ),
                                  const SizedBox(width: 8),
                                  CustomText(
                                    text: 'Destination'.tr,
                                    size: 16,
                                    weight: FontWeight.w600,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CustomText(
                                text:
                                    controller
                                        .destinationController
                                        .text
                                        .isNotEmpty
                                    ? controller.destinationController.text
                                    : 'Where you want to go?'.tr,
                                size: 14,
                                weight: FontWeight.normal,
                                color: isDarkMode
                                    ? AppThemeData.grey500Dark
                                    : AppThemeData.grey500,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Hide driver photo if admin toggle is disabled (DriverDetailsCard handles the rest)
                        if (Constant.showDriverInfoBeforePayment == "yes") ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child:
                                (driverModel.photo != null &&
                                    driverModel.photo.toString().isNotEmpty &&
                                    driverModel.photo.toString() != 'null')
                                ? CachedNetworkImage(
                                    imageUrl: driverModel.photo.toString(),
                                    fit: BoxFit.cover,
                                    height: 110,
                                    width: 110,
                                    placeholder: (context, url) =>
                                        Constant.loader(context),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                          "assets/icons/appLogo.png",
                                          fit: BoxFit.cover,
                                          height: 110,
                                          width: 110,
                                        ),
                                  )
                                : Image.asset(
                                    "assets/icons/appLogo.png",
                                    fit: BoxFit.cover,
                                    height: 110,
                                    width: 110,
                                  ),
                          ),
                          const SizedBox(height: 10),
                        ] else ...[
                          // Show masked/placeholder info instead
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDarkMode
                                  ? AppThemeData.grey200Dark
                                  : AppThemeData.grey200,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: isDarkMode
                                  ? AppThemeData.grey400Dark
                                  : AppThemeData.grey400,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            text:
                                'Driver information will be shown after payment'
                                    .tr,
                            align: TextAlign.center,
                            size: 14,
                            weight: FontWeight.normal,
                            color: isDarkMode
                                ? AppThemeData.grey500Dark
                                : AppThemeData.grey500,
                            fontStyle: FontStyle.italic,
                          ),
                          const SizedBox(height: 10),
                        ],
                        // Vehicle Type and Description
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: isDarkMode
                                  ? AppThemeData.grey300Dark
                                  : AppThemeData.grey300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: "Vehicle Type".tr,
                                    size: 16,
                                    weight: FontWeight.normal,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                  ),
                                  CustomText(
                                    text: _getLocalizedVehicleName(
                                      controller.vehicleData.value.libelle
                                              ?.toString() ??
                                          '',
                                    ),
                                    size: 16,
                                    weight: FontWeight.w500,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              CustomText(
                                text:
                                    controller.vehicleData.value.libelle
                                            ?.toString()
                                            .toLowerCase() ==
                                        'business'
                                    ? 'family_ride_description'.tr
                                    : controller.vehicleData.value.libelle
                                              ?.toString()
                                              .toLowerCase() ==
                                          'classic'
                                    ? 'classic_ride_description'.tr
                                    : 'reliable_transportation_service'.tr,
                                size: 12,
                                weight: FontWeight.normal,
                                color: isDarkMode
                                    ? AppThemeData.grey500Dark
                                    : AppThemeData.grey500,
                              ),
                            ],
                          ),
                        ),
                        DriverDetailsCard(
                          driverModel: driverModel,
                          duration: controller.duration.value,
                          tripPrice: discountPrice.toString(),
                          isDarkMode: isDarkMode,
                        ),
                        paymentCtrl.coupanCodeList.isEmpty
                            ? const SizedBox()
                            : Container(
                                width: Get.width,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppThemeData.surface50Dark
                                      : AppThemeData.surface50,
                                  border: Border.all(
                                    color: isDarkMode
                                        ? AppThemeData.grey200Dark
                                        : AppThemeData.grey200,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(0.0),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 20,
                                ),
                                child: SizedBox(
                                  height: 130,
                                  child: ListView.builder(
                                    itemCount:
                                        paymentCtrl.coupanCodeList.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (clickIndex == -1) {
                                            if (paymentCtrl
                                                    .coupanCodeList[index]
                                                    .type ==
                                                "Percentage") {
                                              setState(() {
                                                double amountToReduce =
                                                    (int.parse(
                                                          paymentCtrl
                                                              .coupanCodeList[index]
                                                              .discount
                                                              .toString(),
                                                        ) /
                                                        100) *
                                                    discountPrice;
                                                discountPrice =
                                                    discountPrice -
                                                    amountToReduce;
                                                clickIndex = index;
                                                ShowToastDialog.showToast(
                                                  "A coupon is applied.",
                                                );
                                              });
                                            } else {
                                              if (double.parse(
                                                    discountPrice.toString(),
                                                  ) <
                                                  double.parse(
                                                    paymentCtrl
                                                        .coupanCodeList[index]
                                                        .discount
                                                        .toString(),
                                                  )) {
                                                ShowToastDialog.showToast(
                                                  "A coupon will be applied when the subtotal amount is greater than the coupon amount.",
                                                );
                                              } else {
                                                setState(() {
                                                  discountPrice =
                                                      double.parse(
                                                        discountPrice
                                                            .toString(),
                                                      ) -
                                                      double.parse(
                                                        paymentCtrl
                                                            .coupanCodeList[index]
                                                            .discount
                                                            .toString(),
                                                      );
                                                  clickIndex = index;
                                                  ShowToastDialog.showToast(
                                                    "A coupon is applied.",
                                                  );
                                                });
                                              }
                                            }
                                          } else if (clickIndex != index) {
                                            setState(() {
                                              discountPrice = tripPrice;
                                              clickIndex = -1;
                                            });
                                            if (paymentCtrl
                                                    .coupanCodeList[index]
                                                    .type ==
                                                "Percentage") {
                                              setState(() {
                                                double amountToReduce =
                                                    (int.parse(
                                                          paymentCtrl
                                                              .coupanCodeList[index]
                                                              .discount
                                                              .toString(),
                                                        ) /
                                                        100) *
                                                    discountPrice;
                                                discountPrice =
                                                    discountPrice -
                                                    amountToReduce;
                                                clickIndex = index;
                                                ShowToastDialog.showToast(
                                                  "A coupon is applied.",
                                                );
                                              });
                                            } else {
                                              if (double.parse(
                                                    discountPrice.toString(),
                                                  ) <
                                                  double.parse(
                                                    paymentCtrl
                                                        .coupanCodeList[index]
                                                        .discount
                                                        .toString(),
                                                  )) {
                                                ShowToastDialog.showToast(
                                                  "A coupon will be applied when the subtotal amount is greater than the coupon amount.",
                                                );
                                              } else {
                                                setState(() {
                                                  discountPrice =
                                                      double.parse(
                                                        discountPrice
                                                            .toString(),
                                                      ) -
                                                      double.parse(
                                                        paymentCtrl
                                                            .coupanCodeList[index]
                                                            .discount
                                                            .toString(),
                                                      );
                                                  clickIndex = index;
                                                  ShowToastDialog.showToast(
                                                    "A coupon is applied.",
                                                  );
                                                });
                                              }
                                            }
                                          } else {
                                            setState(() {
                                              discountPrice = tripPrice;
                                              clickIndex = -1;
                                              ShowToastDialog.showToast(
                                                'coupon_code_removed'.tr,
                                              );
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: Get.width / 1.2,
                                          margin: EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: themeChange.getThem()
                                                  ? Colors.white
                                                  : Colors.black,
                                              width: 0.3,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 15,
                                                      ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: clickIndex == index
                                                          ? Colors.grey
                                                          : Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(30),
                                                          ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Image.asset(
                                                        'assets/icons/promocode.png',
                                                        width: 40,
                                                        height: 40,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 35,
                                                        ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: CustomText(
                                                                text: paymentCtrl
                                                                    .coupanCodeList[index]
                                                                    .discription
                                                                    .toString(),
                                                                color:
                                                                    themeChange
                                                                        .getThem()
                                                                    ? Colors
                                                                          .white
                                                                    : Colors
                                                                          .black,
                                                                size: 12,
                                                                weight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    1,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 3,
                                                            ),
                                                            CustomText(
                                                              text:
                                                                  clickIndex ==
                                                                      index
                                                                  ? 'remove_code'
                                                                        .tr
                                                                  : 'apply_code'
                                                                        .tr,
                                                              weight: FontWeight
                                                                  .w600,
                                                              color: Colors.red,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                FlutterClipboard.copy(
                                                                  paymentCtrl
                                                                      .coupanCodeList[index]
                                                                      .code
                                                                      .toString(),
                                                                ).then((value) {
                                                                  ShowToastDialog.showToast(
                                                                    'coupon_code_copied'
                                                                        .tr,
                                                                  );
                                                                });
                                                              },
                                                              child: Container(
                                                                color: Colors
                                                                    .black
                                                                    .withValues(
                                                                      alpha:
                                                                          0.05,
                                                                    ),
                                                                child: DottedBorder(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          5,
                                                                    ),
                                                                    child: CustomText(
                                                                      text: paymentCtrl
                                                                          .coupanCodeList[index]
                                                                          .code
                                                                          .toString(),
                                                                      size: 12,
                                                                      color:
                                                                          themeChange
                                                                              .getThem()
                                                                          ? Colors.white
                                                                          : Colors.black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: CustomText(
                                                                text:
                                                                    "${"Valid till".tr} ${paymentCtrl.coupanCodeList[index].expireAt}",
                                                                size: 12,
                                                                color:
                                                                    themeChange
                                                                        .getThem()
                                                                    ? Colors
                                                                          .white
                                                                    : Colors
                                                                          .black,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CustomButton(
                            btnName: "Continue".tr,
                            ontap: () async {
                              var amount = await Constant().getAmount();
                              if (amount != null) {
                                controller.walletAmount.value = amount;
                                paymentCtrl.walletAmount.value = amount;
                              } else {
                                await paymentCtrl.getAmount();
                              }
                              Get.back();
                              controller.paymentSettingModel.value =
                                  Constant.getPaymentSetting();
                              // Step 1: User chooses Book Now or Schedule Ride
                              rideTypeSelectionDialog(
                                context,
                                vehicleCategoryModel,
                                discountPrice == 0.0
                                    ? double.tryParse(
                                            tripPrice.toStringAsFixed(3),
                                          ) ??
                                          0.0
                                    : discountPrice,
                                driverModel,
                                isDarkMode,
                                controller,
                                originalTripPrice,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

String _getLocalizedVehicleName(String vehicleName) {
  final normalizedName = vehicleName.trim().toLowerCase();
  if (normalizedName == 'business') {
    return 'family'.tr;
  } else if (normalizedName == 'classic') {
    return 'classic'.tr;
  }
  return vehicleName;
}
