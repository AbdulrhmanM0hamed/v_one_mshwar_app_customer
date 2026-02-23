import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/sheets/ride_type_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:developer';

Future tripOptionBottomSheet(
  BuildContext context,
  bool isDarkMode,
  HomeController controller,
  PaymentController paymentCtrl,
  DarkThemeProvider themeChange,
) {
  final passengerController = TextEditingController(text: "1");
  double discountPrice = 0.0;

  // Initialize price controller text before showing bottom sheet
  controller.priceController.text =
      '${'ride_price_colon'.tr}${Constant().amountShow(amount: controller.ridePrice.toString())}';

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
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [],
                        ),
                        Column(
                          children: [
                            TextFieldWidget(
                              isReadOnly: true,
                              prefix: IconButton(
                                onPressed: () {},
                                icon: CircleAvatar(
                                  maxRadius: 14,
                                  backgroundColor: AppThemeData.primary200,
                                  child: CustomText(
                                    text: '\$',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              controller: controller.priceController,
                              hintText: 'Ride Price'.tr,
                            ),
                            ReorderableListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: <Widget>[
                                for (
                                  int index = 0;
                                  index < controller.multiStopListNew.length;
                                  index += 1
                                )
                                  Container(
                                    key: ValueKey(
                                      controller.multiStopListNew[index],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: TextFieldWidget(
                                                isReadOnly: true,
                                                onTap: () async {},
                                                prefix: IconButton(
                                                  onPressed: () {},
                                                  icon: CustomText(
                                                    text: String.fromCharCode(
                                                      index + 65,
                                                    ),
                                                    size: 16,
                                                    weight: FontWeight.normal,
                                                    color: isDarkMode
                                                        ? AppThemeData
                                                              .grey500Dark
                                                        : AppThemeData.grey500,
                                                  ),
                                                ),
                                                hintText:
                                                    "Where do you want to stop?"
                                                        .tr,
                                                controller: controller
                                                    .multiStopListNew[index]
                                                    .editingController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          color: isDarkMode
                                              ? AppThemeData.grey300Dark
                                              : AppThemeData.grey300,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final AddStopModel item = controller
                                    .multiStopListNew
                                    .removeAt(oldIndex);
                                controller.multiStopListNew.insert(
                                  newIndex,
                                  item,
                                );
                              },
                            ),
                          ],
                        ),
                        // Passenger count field - shown/hidden based on admin setting
                        Builder(
                          builder: (context) {
                            // Debug: Check constant value
                            log(
                              "🔍 PassengerCountRequired in tripOptionBottomSheet: ${Constant.passengerCountRequired}",
                            );
                            if (Constant.passengerCountRequired != 'hidden') {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 16.0,
                                  bottom: 8.0,
                                ),
                                child: TextFieldWidget(
                                  prefix: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Iconsax.profile_2user,
                                      color: isDarkMode
                                          ? AppThemeData.grey500Dark
                                          : AppThemeData.grey300Dark,
                                    ),
                                  ),
                                  controller: passengerController,
                                  hintText: 'Enter number of passengers'.tr,
                                  textInputType: TextInputType.number,
                                  maxLength: 2,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: CustomButton(
                            btnName: "select_payment_method".tr,
                            ontap: () async {
                              // Validate passenger count if required
                              if (Constant.passengerCountRequired ==
                                  'required') {
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

                              final rootContext = Get.context;
                              final cout = double.parse(
                                controller.ridePrice.toString(),
                              );

                              // Use controller method to handle payment method selection
                              final driverData = await controller
                                  .handlePaymentMethodSelection(
                                    context: context,
                                    tripPrice: cout,
                                    discountPrice: discountPrice,
                                  );

                              if (driverData != null) {
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );

                                final dialogContext =
                                    rootContext ?? Get.context;
                                if (dialogContext != null) {
                                  // Step 1: User chooses Book Now or Schedule Ride
                                  rideTypeSelectionDialog(
                                    dialogContext,
                                    controller.vehicleCategoryModel.value,
                                    discountPrice == 0.0
                                        ? double.tryParse(
                                                cout.toStringAsFixed(3),
                                              ) ??
                                              0.0
                                        : discountPrice,
                                    driverData,
                                    isDarkMode,
                                    controller,
                                    cout,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
