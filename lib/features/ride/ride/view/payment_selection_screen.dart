import 'dart:convert';
import 'dart:io';
import 'dart:math' as maths;
import 'dart:ui' as BorderType;
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/controller/wallet_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/model/payStackURLModel.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/tax_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/model/user_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/model/xenditModel.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/midtrans_screen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/orangePayScreen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/payStackScreen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/xenditScreen.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/themes/appbar_cust.dart';
import 'package:v_one_mshwar_app_customer/core/themes/button_them.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/radio_button.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:flutter_paypal_native/models/custom/currency_code.dart';
import 'package:flutter_paypal_native/models/custom/environment.dart';
import 'package:flutter_paypal_native/models/custom/order_callback.dart';
import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
import 'package:flutter_paypal_native/models/custom/user_action.dart';
import 'package:flutter_paypal_native/str_helper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:v_one_mshwar_app_customer/features/payment/payment/model/payment_setting_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/MercadoPagoScreen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/PayFastScreen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/paystack_url_genrater.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/controller/package_controller.dart';
import 'package:iconsax/iconsax.dart';

// ignore: must_be_immutable
class PaymentSelectionScreen extends StatelessWidget {
  const PaymentSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<PaymentController>(
      init: PaymentController(),
      initState: (controller) {
        initPayPal();
        setRef();
      },
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppbar(
            bgColor: AppThemeData.primary200,
            title: 'select_payment_method'.tr,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(color: AppThemeData.primary200),
                  ),
                  Expanded(
                    flex: 10,
                    child: Container(
                      color: themeChange.getThem()
                          ? AppThemeData.surface50Dark
                          : AppThemeData.surface50,
                    ),
                  ),
                ],
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // Total Amount Card (Prominent at top)
                              _buildTotalAmountCard(
                                controller,
                                themeChange.getThem(),
                              ),
                              const SizedBox(height: 20),

                              // Ride Details Section
                              _buildRideDetailsSection(
                                controller,
                                themeChange.getThem(),
                              ),
                              const SizedBox(height: 20),

                              // Package Selection Section
                              _buildPackageSelectionSection(
                                controller,
                                themeChange.getThem(),
                              ),
                              const SizedBox(height: 20),

                              // Coupon/Promo Code Section
                              buildListPromoCode(
                                controller,
                                themeChange.getThem(),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.surface50Dark
                                      : AppThemeData.surface50,
                                  border: Border.all(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey200Dark
                                        : AppThemeData.grey200,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/promo_code.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                text: "Promo Code".tr,
                                                size: 16,
                                                weight: FontWeight.w600,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey900Dark
                                                    : AppThemeData.grey900,
                                              ),
                                              CustomText(
                                                text: "Apply promo code".tr,
                                                size: 12,
                                                weight: FontWeight.normal,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey400Dark
                                                    : AppThemeData.grey500,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // controller.couponCodeController =
                                          //     TextEditingController();
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            isDismissible: true,
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            enableDrag: true,
                                            builder: (BuildContext context) =>
                                                couponCodeSheet(
                                                  context,
                                                  controller,
                                                ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 2,
                                                offset: const Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            'assets/images/add_payment.png',
                                            width: 36,
                                            height: 36,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.surface50Dark
                                        : AppThemeData.surface50,
                                    border: Border.all(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey300Dark
                                          : AppThemeData.grey300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: CustomText(
                                                text: "Sub Total".tr,
                                                size: 16,
                                                weight: FontWeight.normal,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey900Dark
                                                    : AppThemeData.grey900,
                                              ),
                                            ),
                                            CustomText(
                                              text: Constant().amountShow(
                                                amount: controller
                                                    .data
                                                    .value
                                                    .montant
                                                    .toString(),
                                              ),
                                              size: 16,
                                              weight: FontWeight.w500,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey500Dark
                                                  : AppThemeData.grey500,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey300Dark
                                            : AppThemeData.grey300,
                                        height: 1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: CustomText(
                                                text: "Discount".tr,
                                                size: 16,
                                                weight: FontWeight.normal,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey900Dark
                                                    : AppThemeData.grey900,
                                              ),
                                            ),
                                            CustomText(
                                              text:
                                                  '(-${Constant().amountShow(amount: controller.discountAmount.toString())})',
                                              letterSpacing: 1.0,
                                              size: 16,
                                              color: Colors.red,
                                              weight: FontWeight.w500,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey300Dark
                                            : AppThemeData.grey300,
                                        height: 1,
                                      ),
                                      Visibility(
                                        visible: controller
                                            .selectedPromoCode
                                            .value
                                            .isNotEmpty,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText(
                                                text:
                                                    "${"Promo Code :".tr} ${controller.selectedPromoCode.value}",
                                                size: 16,
                                                weight: FontWeight.normal,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey900Dark
                                                    : AppThemeData.grey900,
                                              ),
                                              CustomText(
                                                text:
                                                    '(${controller.selectedPromoValue.value})',
                                                size: 16,
                                                weight: FontWeight.w500,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey500Dark
                                                    : AppThemeData.grey500,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: controller
                                            .selectedPromoCode
                                            .value
                                            .isNotEmpty,
                                        child: Container(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey300Dark
                                              : AppThemeData.grey300,
                                          height: 1,
                                        ),
                                      ),
                                      ListView.builder(
                                        itemCount: Constant.taxList.length,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          TaxModel taxModel =
                                              Constant.taxList[index];
                                          return Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    CustomText(
                                                      text:
                                                          '${taxModel.libelle.toString()} (${taxModel.type == "Fixed" ? Constant().amountShow(amount: taxModel.value) : "${taxModel.value}%"})',
                                                      size: 16,
                                                      weight: FontWeight.normal,
                                                      color:
                                                          themeChange.getThem()
                                                          ? AppThemeData
                                                                .grey900Dark
                                                          : AppThemeData
                                                                .grey900,
                                                    ),
                                                    CustomText(
                                                      text: Constant()
                                                          .amountShow(
                                                            amount: controller
                                                                .calculateTax(
                                                                  taxModel:
                                                                      taxModel,
                                                                )
                                                                .toString(),
                                                          ),
                                                      size: 16,
                                                      weight: FontWeight.w500,
                                                      color:
                                                          themeChange.getThem()
                                                          ? AppThemeData
                                                                .grey500Dark
                                                          : AppThemeData
                                                                .grey500,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300Dark
                                                    : AppThemeData.grey300,
                                                height: 1,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      Visibility(
                                        visible: controller.tipAmount.value == 0
                                            ? false
                                            : true,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 16,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomText(
                                                      text: "Driver Tip".tr,
                                                      size: 16,
                                                      weight: FontWeight.normal,
                                                      color:
                                                          themeChange.getThem()
                                                          ? AppThemeData
                                                                .grey900Dark
                                                          : AppThemeData
                                                                .grey900,
                                                    ),
                                                  ),
                                                  CustomText(
                                                    text: Constant().amountShow(
                                                      amount: controller
                                                          .tipAmount
                                                          .value
                                                          .toString(),
                                                    ),
                                                    size: 16,
                                                    weight: FontWeight.w500,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData
                                                              .grey500Dark
                                                        : AppThemeData.grey500,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey300Dark
                                                  : AppThemeData.grey300,
                                              height: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            CustomText(
                                              text: "Total".tr,
                                              size: 16,
                                              weight: FontWeight.normal,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey900Dark
                                                  : AppThemeData.grey900,
                                            ),
                                            const SizedBox(width: 10),
                                            CustomText(
                                              text: Constant().amountShow(
                                                amount: controller
                                                    .getTotalAmount()
                                                    .toString(),
                                              ),
                                              size: 16,
                                              weight: FontWeight.w500,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey500Dark
                                                  : AppThemeData.grey500,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey300Dark
                                            : AppThemeData.grey300,
                                        height: 1,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: CustomText(
                                                text: "Tip to Driver".tr,
                                                align: TextAlign.left,
                                                size: 16,
                                                weight: FontWeight.normal,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey900Dark
                                                    : AppThemeData.grey900,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (controller
                                                                .tipAmount
                                                                .value ==
                                                            5) {
                                                          controller
                                                                  .tipAmount
                                                                  .value =
                                                              0;
                                                        } else {
                                                          controller
                                                                  .tipAmount
                                                                  .value =
                                                              5;
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              controller
                                                                      .tipAmount
                                                                      .value ==
                                                                  5
                                                              ? AppThemeData
                                                                    .primary200
                                                              : Colors.white,
                                                          border: Border.all(
                                                            color:
                                                                controller
                                                                        .tipAmount
                                                                        .value ==
                                                                    5
                                                                ? Colors
                                                                      .transparent
                                                                : Colors.black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.20,
                                                                      ),
                                                          ),
                                                          boxShadow: <BoxShadow>[
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                              blurRadius: 2,
                                                              offset:
                                                                  const Offset(
                                                                    2,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child: CustomText(
                                                            text: Constant()
                                                                .amountShow(
                                                                  amount: '5',
                                                                ),
                                                            size: 12,
                                                            color:
                                                                controller
                                                                        .tipAmount
                                                                        .value ==
                                                                    5
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (controller
                                                                .tipAmount
                                                                .value ==
                                                            10) {
                                                          controller
                                                                  .tipAmount
                                                                  .value =
                                                              0;
                                                        } else {
                                                          controller
                                                                  .tipAmount
                                                                  .value =
                                                              10;
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              controller
                                                                      .tipAmount
                                                                      .value ==
                                                                  10
                                                              ? AppThemeData
                                                                    .primary200
                                                              : Colors.white,
                                                          border: Border.all(
                                                            color:
                                                                controller
                                                                        .tipAmount
                                                                        .value ==
                                                                    10
                                                                ? Colors
                                                                      .transparent
                                                                : Colors.black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.20,
                                                                      ),
                                                          ),
                                                          boxShadow: <BoxShadow>[
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                              blurRadius: 2,
                                                              offset:
                                                                  const Offset(
                                                                    2,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child: CustomText(
                                                            text: Constant()
                                                                .amountShow(
                                                                  amount: '10',
                                                                ),
                                                            size: 12,
                                                            color:
                                                                controller
                                                                        .tipAmount
                                                                        .value ==
                                                                    10
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (controller
                                                                .tipAmount
                                                                .value ==
                                                            15) {
                                                          controller
                                                                  .tipAmount
                                                                  .value =
                                                              0;
                                                        } else {
                                                          controller
                                                                  .tipAmount
                                                                  .value =
                                                              15;
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              controller
                                                                      .tipAmount
                                                                      .value ==
                                                                  15
                                                              ? AppThemeData
                                                                    .primary200
                                                              : Colors.white,
                                                          border: Border.all(
                                                            color:
                                                                controller
                                                                        .tipAmount
                                                                        .value ==
                                                                    15
                                                                ? Colors
                                                                      .transparent
                                                                : Colors.black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.20,
                                                                      ),
                                                          ),
                                                          boxShadow: <BoxShadow>[
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                              blurRadius: 2,
                                                              offset:
                                                                  const Offset(
                                                                    2,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child: CustomText(
                                                            text: Constant()
                                                                .amountShow(
                                                                  amount: '15',
                                                                ),
                                                            size: 12,
                                                            color:
                                                                controller
                                                                        .tipAmount
                                                                        .value ==
                                                                    15
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (controller
                                                                .tipAmount
                                                                .value ==
                                                            20) {
                                                          controller
                                                                  .tipAmount
                                                                  .value =
                                                              0;
                                                        } else {
                                                          controller
                                                                  .tipAmount
                                                                  .value =
                                                              20;
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              controller
                                                                      .tipAmount
                                                                      .value ==
                                                                  20
                                                              ? AppThemeData
                                                                    .primary200
                                                              : Colors.white,
                                                          border: Border.all(
                                                            color:
                                                                controller
                                                                        .tipAmount
                                                                        .value ==
                                                                    20
                                                                ? Colors
                                                                      .transparent
                                                                : Colors.black
                                                                      .withValues(
                                                                        alpha:
                                                                            0.20,
                                                                      ),
                                                          ),
                                                          boxShadow: <BoxShadow>[
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                              blurRadius: 2,
                                                              offset:
                                                                  const Offset(
                                                                    2,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child: CustomText(
                                                            text: Constant()
                                                                .amountShow(
                                                                  amount: '20',
                                                                ),
                                                            size: 12,
                                                            color:
                                                                controller
                                                                        .tipAmount
                                                                        .value ==
                                                                    20
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        tipAmountBottomSheet(
                                                          context,
                                                          themeChange.getThem(),
                                                          controller,
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.black
                                                                .withValues(
                                                                  alpha: 0.20,
                                                                ),
                                                          ),
                                                          boxShadow: <BoxShadow>[
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                              blurRadius: 2,
                                                              offset:
                                                                  const Offset(
                                                                    2,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                          child: CustomText(
                                                            text: "Other".tr,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: "Select Payment Option".tr,
                                    size: 16,
                                    weight: FontWeight.w500,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: [
                                  // Cash - Only show if enabled by admin
                                  if (controller
                                          .paymentSettingModel
                                          .value
                                          .cash
                                          ?.isEnabled ==
                                      "true")
                                    RadioButtonCustom(
                                      image: "assets/icons/cash.png",
                                      name: "Cash",
                                      groupValue:
                                          controller.selectedRadioTile.value,
                                      isEnabled: true,
                                      isSelected:
                                          controller.selectedRadioTile.value ==
                                          "Cash",
                                      onClick: (String? value) {
                                        controller.stripe = false.obs;
                                        controller.wallet = false.obs;
                                        controller.cash = true.obs;
                                        controller.razorPay = false.obs;

                                        controller.paypal = false.obs;
                                        controller.payStack = false.obs;
                                        controller.flutterWave = false.obs;
                                        controller.mercadoPago = false.obs;
                                        controller.payFast = false.obs;
                                        controller.xendit = false.obs;
                                        controller.midtrans = false.obs;
                                        controller.orangePay = false.obs;
                                        controller.selectedRadioTile.value =
                                            value!;
                                        controller.paymentMethodId.value =
                                            controller
                                                .paymentSettingModel
                                                .value
                                                .cash!
                                                .idPaymentMethod
                                                .toString();
                                      },
                                    ),
                                  // Wallet - Only show if enabled by admin
                                  if (controller
                                          .paymentSettingModel
                                          .value
                                          .myWallet
                                          ?.isEnabled ==
                                      "true")
                                    RadioButtonCustom(
                                      subName: Constant().amountShow(
                                        amount: controller.walletAmount.value,
                                      ),
                                      image: "assets/icons/walltet_icons.png",
                                      name: "Wallet",
                                      groupValue:
                                          controller.selectedRadioTile.value,
                                      isEnabled: true,
                                      isSelected:
                                          controller.selectedRadioTile.value ==
                                          "Wallet",
                                      onClick: (String? value) {
                                        controller.stripe = false.obs;
                                        if (double.parse(
                                              controller.walletAmount
                                                  .toString(),
                                            ) >=
                                            controller.getTotalAmount()) {
                                          controller.wallet = true.obs;
                                          controller.selectedRadioTile.value =
                                              value!;
                                          controller.paymentMethodId =
                                              controller
                                                  .paymentSettingModel
                                                  .value
                                                  .myWallet!
                                                  .idPaymentMethod
                                                  .toString()
                                                  .obs;
                                        } else {
                                          controller.wallet = false.obs;
                                        }

                                        controller.cash = false.obs;
                                        controller.razorPay = false.obs;

                                        controller.paypal = false.obs;
                                        controller.payStack = false.obs;
                                        controller.flutterWave = false.obs;
                                        controller.mercadoPago = false.obs;
                                        controller.payFast = false.obs;
                                        controller.xendit = false.obs;
                                        controller.midtrans = false.obs;
                                        controller.orangePay = false.obs;
                                      },
                                    ),
                                  // KNET (UPayments) - Only show if enabled by admin
                                  if (controller
                                              .paymentSettingModel
                                              .value
                                              .uPayments !=
                                          null &&
                                      controller
                                              .paymentSettingModel
                                              .value
                                              .uPayments
                                              ?.isEnabled ==
                                          "true")
                                    RadioButtonCustom(
                                      image: "assets/icons/upayments.jpeg",
                                      name: 'KNET, Credit Card & Others',
                                      groupValue:
                                          controller.selectedRadioTile.value,
                                      isEnabled: true,
                                      isSelected:
                                          controller.selectedRadioTile.value ==
                                          "KNET, Credit Card & Others",
                                      onClick: (String? value) {
                                        controller.upayments = true.obs;
                                        controller.stripe = false.obs;
                                        controller.wallet = false.obs;
                                        controller.cash = false.obs;
                                        controller.razorPay = false.obs;

                                        controller.paypal = false.obs;
                                        controller.payStack = false.obs;
                                        controller.flutterWave = false.obs;
                                        controller.mercadoPago = false.obs;
                                        controller.payFast = false.obs;
                                        controller.xendit = false.obs;
                                        controller.midtrans = false.obs;
                                        controller.orangePay = false.obs;
                                        controller.selectedRadioTile.value =
                                            value!;
                                        controller.paymentMethodId.value =
                                            controller
                                                .paymentSettingModel
                                                .value
                                                .uPayments
                                                ?.idPaymentMethod
                                                .toString() ??
                                            '8';
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 10,
                                ),
                                child: ButtonThem.buildButton(
                                  context,
                                  title:
                                      "Pay ${Constant().amountShow(amount: controller.getTotalAmount().toString())}"
                                          .tr,
                                  onPress: () {
                                    if (controller.selectedRadioTile.value ==
                                        "Wallet") {
                                      if (double.parse(
                                            controller.walletAmount.toString(),
                                          ) >=
                                          controller.getTotalAmount()) {
                                        Get.back();
                                        List taxList = [];

                                        for (var v in Constant.taxList) {
                                          taxList.add(v.toJson());
                                        }
                                        Map<String, dynamic> bodyParams = {
                                          'id_ride': controller.data.value.id
                                              .toString(),
                                          'id_driver': controller
                                              .data
                                              .value
                                              .idConducteur
                                              .toString(),
                                          'id_user_app': controller
                                              .data
                                              .value
                                              .idUserApp
                                              .toString(),
                                          'amount': controller
                                              .subTotalAmount
                                              .value
                                              .toString(),
                                          'paymethod': controller
                                              .selectedRadioTile
                                              .value,
                                          'discount': controller
                                              .discountAmount
                                              .value
                                              .toString(),
                                          'discount_code':
                                              controller
                                                  .selectedPromoCode
                                                  .value
                                                  .isNotEmpty
                                              ? controller
                                                    .selectedPromoCode
                                                    .value
                                              : null,
                                          'tip': controller.tipAmount.value
                                              .toString(),
                                          'tax': taxList,
                                          'transaction_id': DateTime.now()
                                              .microsecondsSinceEpoch
                                              .toString(),
                                          'commission': Preferences.getString(
                                            Preferences.admincommission,
                                          ),
                                          'payment_status': "success",
                                        };
                                        controller
                                            .walletDebitAmountRequest(
                                              bodyParams,
                                            )
                                            .then((value) {
                                              if (value != null) {
                                                ShowToastDialog.showToast(
                                                  "Payment successfully completed",
                                                );
                                                Get.back(result: true);
                                                Get.back();
                                              } else {
                                                ShowToastDialog.closeLoader();
                                              }
                                            });
                                      } else {
                                        ShowToastDialog.showToast(
                                          "Insufficient wallet balance",
                                        );
                                      }
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "Cash") {
                                      Get.back();
                                      List taxList = [];

                                      for (var v in Constant.taxList) {
                                        taxList.add(v.toJson());
                                      }
                                      Map<String, dynamic> bodyParams = {
                                        'id_ride': controller.data.value.id
                                            .toString(),
                                        'id_driver': controller
                                            .data
                                            .value
                                            .idConducteur
                                            .toString(),
                                        'id_user_app': controller
                                            .data
                                            .value
                                            .idUserApp
                                            .toString(),
                                        'amount': controller
                                            .subTotalAmount
                                            .value
                                            .toString(),
                                        'paymethod':
                                            controller.selectedRadioTile.value,
                                        'discount': controller
                                            .discountAmount
                                            .value
                                            .toString(),
                                        'discount_code':
                                            controller
                                                .selectedPromoCode
                                                .value
                                                .isNotEmpty
                                            ? controller.selectedPromoCode.value
                                            : null,
                                        'tip': controller.tipAmount.value
                                            .toString(),
                                        'tax': taxList,
                                        'transaction_id': DateTime.now()
                                            .microsecondsSinceEpoch
                                            .toString(),
                                        'commission': Preferences.getString(
                                          Preferences.admincommission,
                                        ),
                                        'payment_status': "success",
                                      };
                                      controller
                                          .cashPaymentRequest(bodyParams)
                                          .then((value) {
                                            if (value != null) {
                                              ShowToastDialog.showToast(
                                                "Payment successfully completed",
                                              );
                                              Get.back(result: true);
                                              Get.back();
                                            } else {
                                              ShowToastDialog.closeLoader();
                                            }
                                          });
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "PayPal") {
                                      showLoadingAlert(context);
                                      paypalPaymentSheet(
                                        double.parse(
                                          controller
                                              .getTotalAmount()
                                              .toString(),
                                        ).toString(),
                                      );
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "PayStack") {
                                      showLoadingAlert(context);
                                      payStackPayment(
                                        context,
                                        controller
                                            .getTotalAmount()
                                            .toStringAsFixed(2),
                                      );
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "PayFast") {
                                      showLoadingAlert(context);
                                      payFastPayment(
                                        context,
                                        controller.getTotalAmount().toString(),
                                      );
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "FlutterWave") {
                                      showLoadingAlert(context);
                                      flutterWaveInitiatePayment(
                                        context: context,
                                        amount: controller
                                            .getTotalAmount()
                                            .toString(),
                                        user: controller.userModel.value,
                                      );
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "MercadoPago") {
                                      showLoadingAlert(context);
                                      mercadoPagoMakePayment(
                                        context: context,
                                        amount: controller
                                            .getTotalAmount()
                                            .toString(),
                                        user: controller.userModel.value,
                                      );
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "Xendit") {
                                      showLoadingAlert(context);
                                      xenditPayment(
                                        context,
                                        double.parse(
                                          controller
                                              .getTotalAmount()
                                              .toString(),
                                        ),
                                        controller,
                                      );
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "Orange Pay") {
                                      showLoadingAlert(context);
                                      orangeMakePayment(
                                        amount: controller
                                            .getTotalAmount()
                                            .toStringAsFixed(2),
                                        context: context,
                                        controller: controller,
                                      );
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "Midtrans") {
                                      showLoadingAlert(context);
                                      midtransMakePayment(
                                        amount: controller
                                            .getTotalAmount()
                                            .toString(),
                                        context: context,
                                        controller: controller,
                                      );
                                    } else if (controller
                                            .selectedRadioTile
                                            .value ==
                                        "KNET, Credit Card & Others") {
                                      showLoadingAlert(context);
                                      processUPaymentsPayment(
                                        amount: double.parse(
                                          controller
                                              .getTotalAmount()
                                              .toString(),
                                        ),
                                        context: context,
                                        controller: HomeController(),
                                      );
                                    }
                                  },
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
            ],
          ),
        );
      },
    );
  }
}

/// Build Total Amount Card (Prominent display at top)
Widget _buildTotalAmountCard(PaymentController controller, bool isDarkMode) {
  return Obx(() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeData.primary200.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppThemeData.primary200.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Total Amount".tr,
                size: 14,
                color: isDarkMode
                    ? AppThemeData.grey500Dark
                    : AppThemeData.grey500,
              ),
              const SizedBox(height: 4),
              CustomText(
                text: Constant().amountShow(
                  amount: controller.getTotalAmount().toString(),
                ),
                size: 24,
                weight: FontWeight.bold,
                color: AppThemeData.primary200,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppThemeData.primary200.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Iconsax.card, color: AppThemeData.primary200, size: 24),
          ),
        ],
      ),
    );
  });
}

/// Build Ride Details Section
Widget _buildRideDetailsSection(PaymentController controller, bool isDarkMode) {
  return Obx(() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeData.surface50Dark : AppThemeData.surface50,
        border: Border.all(
          color: isDarkMode ? AppThemeData.grey200Dark : AppThemeData.grey200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "Ride Details".tr,
            size: 18,
            weight: FontWeight.bold,
            color: isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Iconsax.location, size: 16, color: AppThemeData.primary200),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  text:
                      controller.data.value.departName ?? "Pickup Location".tr,
                  size: 14,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Iconsax.location5, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: CustomText(
                  text:
                      controller.data.value.destinationName ?? "Destination".tr,
                  size: 14,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
              ),
            ],
          ),
          if (controller.data.value.distance != null &&
              controller.data.value.distance!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.route_square,
                  size: 16,
                  color: AppThemeData.primary200,
                ),
                const SizedBox(width: 8),
                CustomText(
                  text:
                      "${controller.data.value.distance} ${controller.data.value.distanceUnit ?? 'KM'.tr}",
                  size: 14,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
              ],
            ),
          ],
          if (controller.data.value.duree != null &&
              controller.data.value.duree!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Iconsax.clock, size: 16, color: AppThemeData.primary200),
                const SizedBox(width: 8),
                CustomText(
                  text: "${controller.data.value.duree} ${"minutes".tr}",
                  size: 14,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
              ],
            ),
          ],
          if (controller.data.value.montant != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.dollar_circle,
                  size: 16,
                  color: AppThemeData.primary200,
                ),
                const SizedBox(width: 8),
                CustomText(
                  text:
                      "${"Base Fare".tr}: ${Constant().amountShow(amount: controller.data.value.montant.toString())}",
                  size: 14,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  });
}

/// Build Package Selection Section
Widget _buildPackageSelectionSection(
  PaymentController controller,
  bool isDarkMode,
) {
  // Get PackageController (initialize if not exists)
  PackageController packageController;
  try {
    packageController = Get.find<PackageController>();
  } catch (e) {
    packageController = Get.put(PackageController());
  }

  return Obx(() {
    // Fetch usable packages if not already loaded
    if (packageController.usablePackages.isEmpty &&
        !packageController.isUsableLoading.value) {
      packageController.fetchUsablePackages();
    }

    if (packageController.isUsableLoading.value) {
      return Container(
        width: Get.width,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            CustomText(
              text: "Loading packages...".tr,
              size: 14,
              color: isDarkMode
                  ? AppThemeData.grey900Dark
                  : AppThemeData.grey900,
            ),
          ],
        ),
      );
    }

    if (packageController.usablePackages.isEmpty) {
      return const SizedBox.shrink(); // No packages available - hide section
    }

    final rideDistance =
        double.tryParse(controller.data.value.distance ?? '0') ?? 0.0;

    return Container(
      width: Get.width,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Iconsax.box, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Use Package KM".tr,
                        size: 16,
                        weight: FontWeight.bold,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      CustomText(
                        text: "No payment - just deduct from your package".tr,
                        size: 12,
                        color: isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...packageController.usablePackages.map((pkg) {
            final remainingKm = double.tryParse(pkg.remainingKm ?? '0') ?? 0.0;
            final canUsePackage = remainingKm >= rideDistance;
            final kmToDeduct = rideDistance;
            final remainingAfterDeduction = remainingKm - kmToDeduct;

            return Obx(() {
              final isSelected = controller.selectedPackageId.value == pkg.id;

              return GestureDetector(
                onTap: () {
                  if (canUsePackage) {
                    controller.selectedPackageId.value = isSelected
                        ? null
                        : pkg.id;
                    controller.packageKmToDeduct.value = isSelected
                        ? 0.0
                        : kmToDeduct;
                    // Still require payment method for any extra amount
                  } else {
                    ShowToastDialog.showToast(
                      "${'Insufficient KM in package. Available:'.tr} $remainingKm ${'KM'.tr}",
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: pkg.id ?? '',
                        groupValue: controller.selectedPackageId.value ?? '',
                        onChanged: canUsePackage
                            ? (value) {
                                controller.selectedPackageId.value = value;
                                controller.packageKmToDeduct.value = kmToDeduct;
                              }
                            : null,
                        activeColor: Colors.green,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: pkg.packageName ?? 'Package',
                              size: 14,
                              weight: FontWeight.w600,
                              color: isDarkMode
                                  ? AppThemeData.grey900Dark
                                  : AppThemeData.grey900,
                            ),
                            CustomText(
                              text:
                                  "${remainingKm.toStringAsFixed(1)} ${'KM'.tr} ${'available'.tr}",
                              size: 12,
                              color: Colors.green.shade700,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isSelected) ...[
                            CustomText(
                              text:
                                  "-${kmToDeduct.toStringAsFixed(1)} ${'KM'.tr}",
                              size: 16,
                              weight: FontWeight.bold,
                              color: Colors.red,
                            ),
                            CustomText(
                              text:
                                  "${remainingAfterDeduction.toStringAsFixed(1)} ${'KM'.tr} ${'left'.tr}",
                              size: 12,
                              color: isDarkMode
                                  ? AppThemeData.grey500Dark
                                  : AppThemeData.grey500,
                            ),
                          ] else ...[
                            CustomText(
                              text: "${remainingKm.toStringAsFixed(1)} KM",
                              size: 14,
                              color: isDarkMode
                                  ? AppThemeData.grey500Dark
                                  : AppThemeData.grey500,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          }).toList(),
        ],
      ),
    );
  });
}

Widget buildListPromoCode(PaymentController controller, bool isDarkMode) {
  return controller.coupanCodeList.isEmpty
      ? const SizedBox()
      : Container(
          width: Get.width,
          padding: const EdgeInsets.all(10),
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
            borderRadius: const BorderRadius.all(Radius.circular(0.0)),
          ),
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: controller.coupanCodeList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    controller.selectedPromoCode.value = controller
                        .coupanCodeList[index]
                        .code
                        .toString();
                    controller.selectedPromoValue.value =
                        controller.coupanCodeList[index].type == "Percentage"
                        ? "${controller.coupanCodeList[index].discount}%"
                        : Constant().amountShow(
                            amount: controller.coupanCodeList[index].discount
                                .toString(),
                          );
                    if (controller.coupanCodeList[index].type == "Percentage") {
                      var amount =
                          double.parse(
                            controller.coupanCodeList[index].discount
                                .toString(),
                          ) /
                          100;
                      if ((controller.subTotalAmount.value *
                              double.parse(amount.toString())) <
                          controller.subTotalAmount.value) {
                        controller.discountAmount.value =
                            controller.subTotalAmount.value *
                            double.parse(amount.toString());
                        controller.taxAmount.value = 0.0;
                        for (var i = 0; i < Constant.taxList.length; i++) {
                          if (Constant.taxList[i].statut == 'yes') {
                            if (Constant.taxList[i].type == "Fixed") {
                              controller.taxAmount.value += double.parse(
                                Constant.taxList[i].value.toString(),
                              );
                            } else {
                              controller.taxAmount.value +=
                                  ((controller.subTotalAmount.value -
                                          controller.discountAmount.value) *
                                      double.parse(
                                        Constant.taxList[i].value!.toString(),
                                      )) /
                                  100;
                            }
                          }
                        }
                      } else {
                        ShowToastDialog.showToast(
                          "A coupon will be applied when the subtotal amount is greater than the coupon amount.",
                        );
                      }
                    } else {
                      if (double.parse(
                            controller.coupanCodeList[index].discount
                                .toString(),
                          ) <
                          controller.subTotalAmount.value) {
                        controller.discountAmount.value = double.parse(
                          controller.coupanCodeList[index].discount.toString(),
                        );
                        controller.taxAmount.value = 0.0;
                        for (var i = 0; i < Constant.taxList.length; i++) {
                          if (Constant.taxList[i].statut == 'yes') {
                            if (Constant.taxList[i].type == "Fixed") {
                              controller.taxAmount.value += double.parse(
                                Constant.taxList[i].value.toString(),
                              );
                            } else {
                              controller.taxAmount.value +=
                                  ((controller.subTotalAmount.value -
                                          controller.discountAmount.value) *
                                      double.parse(
                                        Constant.taxList[i].value!.toString(),
                                      )) /
                                  100;
                            }
                          }
                        }
                      } else {
                        ShowToastDialog.showToast(
                          "A coupon will be applied when the subtotal amount is greater than the coupon amount.",
                        );
                      }
                    }
                  },
                  child: Container(
                    width: Get.width / 1.2,
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/promo_bg.png'),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                              padding: const EdgeInsets.only(left: 35),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: controller
                                        .coupanCodeList[index]
                                        .discription
                                        .toString(),
                                    color: Colors.black,
                                    size: 16,
                                    weight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          FlutterClipboard.copy(
                                            controller
                                                .coupanCodeList[index]
                                                .code
                                                .toString(),
                                          ).then((value) {
                                            final SnackBar snackBar = SnackBar(
                                              content: CustomText(
                                                text: "Coupon Code Copied".tr,
                                                align: TextAlign.center,
                                                color: Colors.white,
                                              ),
                                              backgroundColor: Colors.black38,
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(snackBar);
                                            // return Navigator.pop(context);
                                          });
                                        },
                                        child: Container(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          child: DottedBorder(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 5,
                                                  ),
                                              child: CustomText(
                                                text: controller
                                                    .coupanCodeList[index]
                                                    .code
                                                    .toString(),
                                                size: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: CustomText(
                                          text:
                                              "${"Valid till".tr} ${controller.coupanCodeList[index].expireAt}",
                                          size: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
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
        );
}

Container couponCodeSheet(context, PaymentController controller) {
  return Container(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).size.height / 4.3,
      left: 25,
      right: 25,
    ),
    height: MediaQuery.of(context).size.height * 0.92,
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border.all(style: BorderStyle.none),
    ),
    child: Column(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 0.3),
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),

            // radius: 20,
            child: const Center(
              child: Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 30),
                    child: const Image(
                      image: AssetImage('assets/images/promo_code.png'),
                      width: 100,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: CustomText(
                      text: 'Redeem Your Coupons'.tr,
                      size: 16,
                      weight: FontWeight.w600,
                      color: const Color(0XFF2A2A2A),
                    ),
                  ),
                  CustomText(
                    text: 'Get the discount on all over the budget'.tr,
                    size: 14,
                    weight: FontWeight.normal,
                    color: const Color(0XFF9091A4),
                    letterSpacing: 0.5,
                    height: 2,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                    ),
                    // height: 120,
                    child: DottedBorder(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 20,
                          ),
                          color: const Color(0XFFF1F4F7),
                          alignment: Alignment.center,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            controller: controller.couponCodeController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Write Coupon Code'.tr,
                              hintStyle: const TextStyle(
                                color: Color(0XFF9091A4),
                              ),
                              labelStyle: const TextStyle(
                                color: Color(0XFF333333),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 15,
                        ),
                        backgroundColor: AppThemeData.primary200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (controller.couponCodeController.text.isNotEmpty) {
                          final code = controller.couponCodeController.text
                              .trim();
                          // Validate discount code via API
                          final validationResult = await controller
                              .validateDiscountCode(
                                code,
                                controller.subTotalAmount.value,
                              );

                          if (validationResult != null) {
                            controller.selectedPromoCode.value = code;
                            controller.discountAmount.value = double.parse(
                              validationResult['discount_amount'].toString(),
                            );
                            controller.selectedPromoValue.value =
                                validationResult['discount_type'] ==
                                    "Percentage"
                                ? "${validationResult['discount_value']}%"
                                : Constant().amountShow(
                                    amount: validationResult['discount_value']
                                        .toString(),
                                  );

                            // Recalculate tax after discount
                            controller.taxAmount.value = 0.0;
                            for (var i = 0; i < Constant.taxList.length; i++) {
                              if (Constant.taxList[i].statut == 'yes') {
                                if (Constant.taxList[i].type == "Fixed") {
                                  controller.taxAmount.value += double.parse(
                                    Constant.taxList[i].value.toString(),
                                  );
                                } else {
                                  controller.taxAmount.value +=
                                      ((controller.subTotalAmount.value -
                                              controller.discountAmount.value) *
                                          double.parse(
                                            Constant.taxList[i].value!
                                                .toString(),
                                          )) /
                                      100;
                                }
                              }
                            }
                            Navigator.pop(context);
                            ShowToastDialog.showToast(
                              "Discount code applied successfully!",
                            );
                          } else {
                            // Fallback to local validation if API fails
                            bool found = false;
                            for (var element in controller.coupanCodeList) {
                              if (element.code!.trim() == code) {
                                found = true;
                                controller.selectedPromoCode.value = code;
                                controller.selectedPromoValue.value =
                                    element.type == "Percentage"
                                    ? "${element.discount}%"
                                    : Constant().amountShow(
                                        amount: element.discount.toString(),
                                      );
                                if (element.type == "Percentage") {
                                  var amount =
                                      double.parse(
                                        element.discount.toString(),
                                      ) /
                                      100;
                                  if ((controller.subTotalAmount.value *
                                          double.parse(amount.toString())) <
                                      controller.subTotalAmount.value) {
                                    controller.discountAmount.value =
                                        controller.subTotalAmount.value *
                                        double.parse(amount.toString());
                                    controller.taxAmount.value = 0.0;
                                    for (
                                      var i = 0;
                                      i < Constant.taxList.length;
                                      i++
                                    ) {
                                      if (Constant.taxList[i].statut == 'yes') {
                                        if (Constant.taxList[i].type ==
                                            "Fixed") {
                                          controller.taxAmount.value +=
                                              double.parse(
                                                Constant.taxList[i].value
                                                    .toString(),
                                              );
                                        } else {
                                          controller.taxAmount.value +=
                                              ((controller
                                                          .subTotalAmount
                                                          .value -
                                                      controller
                                                          .discountAmount
                                                          .value) *
                                                  double.parse(
                                                    Constant.taxList[i].value!
                                                        .toString(),
                                                  )) /
                                              100;
                                        }
                                      }
                                    }
                                    Navigator.pop(context);
                                  } else {
                                    ShowToastDialog.showToast(
                                      "A coupon will be applied when the subtotal amount is greater than the coupon amount.",
                                    );
                                    Navigator.pop(context);
                                  }
                                } else {
                                  if (double.parse(
                                        element.discount.toString(),
                                      ) <
                                      controller.subTotalAmount.value) {
                                    controller.discountAmount.value =
                                        double.parse(
                                          element.discount.toString(),
                                        );
                                    controller.taxAmount.value = 0.0;
                                    for (
                                      var i = 0;
                                      i < Constant.taxList.length;
                                      i++
                                    ) {
                                      if (Constant.taxList[i].statut == 'yes') {
                                        if (Constant.taxList[i].type ==
                                            "Fixed") {
                                          controller.taxAmount.value +=
                                              double.parse(
                                                Constant.taxList[i].value
                                                    .toString(),
                                              );
                                        } else {
                                          controller.taxAmount.value +=
                                              ((controller
                                                          .subTotalAmount
                                                          .value -
                                                      controller
                                                          .discountAmount
                                                          .value) *
                                                  double.parse(
                                                    Constant.taxList[i].value!
                                                        .toString(),
                                                  )) /
                                              100;
                                        }
                                      }
                                    }
                                    Navigator.pop(context);
                                  } else {
                                    ShowToastDialog.showToast(
                                      "A coupon will be applied when the subtotal amount is greater than the coupon amount.",
                                    );
                                    Navigator.pop(context);
                                  }
                                }
                                break;
                              }
                            }
                            if (!found) {
                              ShowToastDialog.showToast(
                                "Invalid discount code",
                              );
                            }
                          }
                        } else {
                          ShowToastDialog.showToast("Enter Promo Code");
                        }
                      },
                      child: CustomText(
                        text: 'REDEEM NOW'.tr,
                        color: Colors.white,
                        weight: FontWeight.w500,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        //buildcouponItem(snapshot)
        //  listData(snapshot)
      ],
    ),
  );
}

Future tipAmountBottomSheet(
  BuildContext context,
  bool isDarkMode,
  PaymentController controller,
) {
  return showModalBottomSheet(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: isDarkMode
        ? AppThemeData.surface50Dark
        : AppThemeData.surface50,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomText(
                      text: "Enter Tip option".tr,
                      size: 18,
                      weight: FontWeight.w600,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                    ),
                  ),
                  TextFieldWidget(
                    hintText: 'Enter Tip'.tr,
                    controller: controller.tripAmountTextFieldController,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: ButtonThem.buildBorderButton(
                            context,
                            btnHeight: 50,
                            title: "cancel".tr,
                            txtColor: AppThemeData.primary200,
                            onPress: () {
                              Get.back();
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: ButtonThem.buildButton(
                            context,
                            btnHeight: 50,
                            title: "Add".tr,
                            onPress: () async {
                              controller.tipAmount.value = double.parse(
                                controller.tripAmountTextFieldController.text,
                              );
                              Get.back();
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

String generateRandomId(int length) {
  final random = maths.Random();
  const chars = '0123456789';
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}

Future<void> processUPaymentsPayment({
  required double amount,
  required BuildContext context,
  required HomeController controller,
}) async {
  try {
    // Use PaymentController for UPayments payment
    final paymentController = Get.find<PaymentController>();
    final paymentUrl = await paymentController.processUPaymentsPaymentGeneric(
      amount: amount,
      productName: "Mshwar Taxi Booking",
      productDescription:
          "Taxi booking from ${controller.departureController.text} to ${controller.destinationController.text}",
      customerExtraData: "Taxi Booking",
    );

    if (paymentUrl != null) {
      // Launch payment URL
      if (await canLaunch(paymentUrl)) {
        await launch(paymentUrl);
        transactionAPI();
      } else {
        ShowToastDialog.showToast("Couldn't launch payment page".tr);
      }
    } else {
      ShowToastDialog.showToast("Payment initialization failed".tr);
    }
  } catch (e) {
    ShowToastDialog.showToast("Payment error: ${e.toString()}".tr);
  }
}

String strToDouble(String value) {
  bool isDouble = double.tryParse(value) == null;
  if (!isDouble) {
    String val = double.parse(
      value,
    ).toStringAsFixed(int.parse(Constant.decimal ?? "2"));
    return val;
  }
  return '0.0';
}

void transactionAPI() {
  paymentController.transactionAmountRequest().then((value) {
    if (value != null) {
      ShowToastDialog.showToast("Payment successfully completed".tr);
      Get.back(result: true);
      Get.back(result: true);
    } else {
      ShowToastDialog.closeLoader();
    }
  });
}

final walletController = Get.put(WalletController());
final paymentController = Get.put(PaymentController());

Map<String, dynamic>? paymentIntentData;

///paypal
final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

void initPayPal() async {
  //set debugMode for error logging
  FlutterPaypalNative.isDebugMode =
      walletController.paymentSettingModel.value.payPal!.isLive.toString() ==
          "false"
      ? true
      : false;

  //initiate payPal plugin
  await _flutterPaypalNativePlugin.init(
    //your app id !!! No Underscore!!! see readme.md for help
    returnUrl: "com.v_one_mshwar_app_customer://paypalpay",
    //client id from developer dashboard
    clientID: walletController.paymentSettingModel.value.payPal!.appId!,
    //sandbox, staging, live etc
    payPalEnvironment:
        walletController.paymentSettingModel.value.payPal!.isLive.toString() ==
            "true"
        ? FPayPalEnvironment.live
        : FPayPalEnvironment.sandbox,
    //what currency do you plan to use? default is US dollars
    currencyCode: FPayPalCurrencyCode.usd,
    //action paynow?
    action: FPayPalUserAction.payNow,
  );

  //call backs for payment
  _flutterPaypalNativePlugin.setPayPalOrderCallback(
    callback: FPayPalOrderCallback(
      onCancel: () {
        //user canceled the payment
        Get.back();
        ShowToastDialog.showToast("Payment canceled");
      },
      onSuccess: (data) {
        //successfully paid
        //remove all items from queue
        // _flutterPaypalNativePlugin.removeAllPurchaseItems();
        Get.back();
        ShowToastDialog.showToast("Payment Successful!!");
        transactionAPI();
        // walletTopUp();
      },
      onError: (data) {
        //an error occured
        Get.back();
        ShowToastDialog.showToast("${"error:".tr} ${data.reason}");
      },
      onShippingChange: (data) {
        //the user updated the shipping address
        Get.back();
        ShowToastDialog.showToast(
          "${"shipping change:".tr} ${data.shippingChangeAddress?.adminArea1 ?? ""}",
        );
      },
    ),
  );
}

void paypalPaymentSheet(String amount) {
  //add 1 item to cart. Max is 4!
  if (_flutterPaypalNativePlugin.canAddMorePurchaseUnit) {
    _flutterPaypalNativePlugin.addPurchaseUnit(
      FPayPalPurchaseUnit(
        // random prices
        amount: double.parse(amount),

        ///please use your own algorithm for referenceId. Maybe ProductID?
        referenceId: FPayPalStrHelper.getRandomString(16),
      ),
    );
  }
  // initPayPal();
  _flutterPaypalNativePlugin.makeOrder(action: FPayPalUserAction.payNow);
}

///PayStack Payment Method
Future<void> payStackPayment(BuildContext context, String amount) async {
  var secretKey = walletController.paymentSettingModel.value.payStack!.secretKey
      .toString();
  await walletController
      .payStackURLGen(amount: amount, secretKey: secretKey)
      .then((value) async {
        if (value != null) {
          PayStackUrlModel payStackModel = value;
          bool isDone = await Get.to(
            () => PayStackScreen(
              walletController: walletController,
              secretKey: secretKey,
              initialURl: payStackModel.data.authorizationUrl,
              amount: amount,
              reference: payStackModel.data.reference,
              callBackUrl: walletController
                  .paymentSettingModel
                  .value
                  .payStack!
                  .callbackUrl
                  .toString(),
            ),
          );
          Get.back();

          if (isDone) {
            Get.back();
            transactionAPI();
          } else {
            showSnackBarAlert(
              message: "Payment UnSuccessful!!".tr,
              color: Colors.red,
            );
          }
        } else {
          showSnackBarAlert(
            message: "Error while transaction!".tr,
            color: Colors.red,
          );
        }
      });
}

String? _ref;

void setRef() {
  maths.Random numRef = maths.Random();
  int year = DateTime.now().year;
  int refNumber = numRef.nextInt(20000);
  if (Platform.isAndroid) {
    _ref = "AndroidRef$year$refNumber";
  } else if (Platform.isIOS) {
    _ref = "IOSRef$year$refNumber";
  }
}

///FlutterWave Payment Method
Future<Null> flutterWaveInitiatePayment({
  required BuildContext context,
  required String amount,
  required UserModel user,
}) async {
  final url = Uri.parse('https://api.flutterwave.com/v3/payments');
  final headers = {
    'Authorization':
        'Bearer ${walletController.paymentSettingModel.value.flutterWave?.secretKey}',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "tx_ref": _ref,
    "amount": amount,
    "currency": "NGN",
    "redirect_url": "${API.baseUrl}payment/success",
    "payment_options": "ussd, card, barter, payattitude",
    "customer": {
      "email": user.data?.email.toString(),
      "phonenumber": user.data?.phone, // Add a real phone number
      "name":
          '${user.data?.prenom} ${user.data?.nom}', // Add a real customer name
    },
    "customizations": {
      "title": "Payment for Services",
      "description": "Payment for XYZ services",
    },
  });

  final response = await http.post(url, headers: headers, body: body);

  showLog("API :: URL :: $url");
  showLog("API :: Request Body :: $body");
  showLog(
    "API :: Request Header :: ${{'Authorization': 'Bearer ${walletController.paymentSettingModel.value.flutterWave?.secretKey}', 'Content-Type': 'application/json'}.toString()} ",
  );
  showLog("API :: responseStatus :: ${response.statusCode} ");
  showLog("API :: responseBody :: ${response.body} ");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    Get.to(MercadoPagoScreen(initialURl: data['data']['link']))!.then((value) {
      if (value) {
        ShowToastDialog.showToast("Payment Successful!!");
        Get.back();
        transactionAPI();
      } else {
        ShowToastDialog.showToast("Payment UnSuccessful!!");
      }
    });
  } else {
    print('Payment initialization failed: ${response.body}');
    return null;
  }
}

///payFast

void payFastPayment(context, amount) {
  PayFast? payfast = walletController.paymentSettingModel.value.payFast;
  PayStackURLGen.getPayHTML(
    payFastSettingData: payfast!,
    amount: double.parse(amount.toString()).round().toString(),
  ).then((String? value) async {
    bool isDone = await Get.to(
      PayFastScreen(htmlData: value!, payFastSettingData: payfast),
    );
    if (isDone) {
      Get.back();
      transactionAPI();
    } else {
      Get.back();
      showSnackBarAlert(message: "No Response!".tr, color: Colors.red);
    }
  });
}

///MercadoPago Payment Method

Future<Null> mercadoPagoMakePayment({
  required BuildContext context,
  required String amount,
  required UserModel user,
}) async {
  final headers = {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "items": [
      {
        "title": "Test",
        "description": "Test Payment",
        "quantity": 1,
        "currency_id": "USD", // or your preferred currency
        "unit_price": double.parse(amount),
      },
    ],
    "payer": {"email": user.data?.email ?? ''},
    "back_urls": {
      "failure": "${API.baseUrl}payment/failure",
      "pending": "${API.baseUrl}payment/pending",
      "success": "${API.baseUrl}payment/success",
    },
    "auto_return": "approved", // Automatically return after payment is approved
  });

  final response = await http.post(
    Uri.parse("https://api.mercadopago.com/checkout/preferences"),
    headers: headers,
    body: body,
  );
  showLog("API :: URL :: https://api.mercadopago.com/checkout/preferences");
  showLog("API :: Request Body :: ${jsonEncode(body)} ");
  showLog("API :: Response Status :: ${response.statusCode} ");
  showLog("API :: Response Body :: ${response.body} ");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    Get.to(MercadoPagoScreen(initialURl: data['init_point']))!.then((value) {
      if (value) {
        Get.back();
        ShowToastDialog.showToast("Payment Successful!!");
        transactionAPI();
      } else {
        ShowToastDialog.showToast("Payment UnSuccessful!!");
      }
    });
  } else {
    print('Error creating preference: ${response.body}');
    return null;
  }
}

Future<void> showLoadingAlert(BuildContext context) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const CircularProgressIndicator(),
            CustomText(text: 'Please wait!!'.tr),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const SizedBox(height: 15),
              CustomText(
                text: 'Please wait!! while completing Transaction'.tr,
                size: 16,
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      );
    },
  );
}

//XenditPayment
Future<void> xenditPayment(
  context,
  amount,
  PaymentController controller,
) async {
  await createXenditInvoice(amount: amount, controller: controller).then((
    model,
  ) {
    if (model.id != null) {
      Get.to(
        () => XenditScreen(
          initialURl: model.invoiceUrl ?? '',
          transId: model.id ?? '',
          apiKey: controller.paymentSettingModel.value.xendit!.key!.toString(),
        ),
      )!.then((value) {
        if (value == true) {
          Get.back();
          transactionAPI();
        } else {
          Get.back();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: "Payment Unsuccessful!!".tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  });
}

Future<XenditModel> createXenditInvoice({
  required var amount,
  required PaymentController controller,
}) async {
  const url = 'https://api.xendit.co/v2/invoices';
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': generateBasicAuthHeader(
      controller.paymentSettingModel.value.xendit!.key!.toString(),
    ),
    // 'Cookie': '__cf_bm=yERkrx3xDITyFGiou0bbKY1bi7xEwovHNwxV1vCNbVc-1724155511-1.0.1.1-jekyYQmPCwY6vIJ524K0V6_CEw6O.dAwOmQnHtwmaXO_MfTrdnmZMka0KZvjukQgXu5B.K_6FJm47SGOPeWviQ',
  };

  final body = jsonEncode({
    'external_id': DateTime.now().millisecondsSinceEpoch.toString(),
    'amount': amount,
    'payer_email': 'customer@domain.com',
    'description': 'Test - VA Successful invoice payment',
    'currency': 'IDR', //IDR, PHP, THB, VND, MYR
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    showLog("API :: URL :: $url");
    showLog("API :: Request Body :: ${jsonEncode(body)}");
    showLog("API :: Request Header :: ${headers.toString()} ");
    showLog("API :: responseStatus :: ${response.statusCode} ");
    showLog("API :: responseBody :: ${response.body} ");

    if (response.statusCode == 200 || response.statusCode == 201) {
      XenditModel model = XenditModel.fromJson(jsonDecode(response.body));
      Get.back();
      return model;
    } else {
      Get.back();
      return XenditModel();
    }
  } catch (e) {
    Get.back();
    return XenditModel();
  }
}

String generateBasicAuthHeader(String apiKey) {
  String credentials = '$apiKey:';
  String base64Encoded = base64Encode(utf8.encode(credentials));
  return 'Basic $base64Encoded';
}

//Orangepay payment
String accessToken = '';
String payToken = '';
String orderId = '';
String amount = '';

Future<void> orangeMakePayment({
  required String amount,
  required BuildContext context,
  required PaymentController controller,
}) async {
  reset();

  var paymentURL = await fetchToken(
    context: context,
    orderId: DateTime.now().millisecondsSinceEpoch.toString(),
    amount: amount,
    currency: 'USD',
    controller: controller,
  );

  if (paymentURL.toString() != '') {
    Get.to(
      () => OrangeMoneyScreen(
        initialURl: paymentURL,
        accessToken: accessToken,
        amount: amount,
        orangePay: controller.paymentSettingModel.value.orangePay!,
        orderId: orderId,
        payToken: payToken,
      ),
    )!.then((value) {
      if (value == true) {
        Get.back();
        transactionAPI();
      }
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(text: "Payment Unsuccessful!!".tr),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future fetchToken({
  required String orderId,
  required String currency,
  required BuildContext context,
  required String amount,
  required PaymentController controller,
}) async {
  String apiUrl = 'https://api.orange.com/oauth/v3/token';
  Map<String, String> requestBody = {'grant_type': 'client_credentials'};

  var response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Authorization':
          "Basic ${controller.paymentSettingModel.value.orangePay!.key!}",
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    },
    body: requestBody,
  );

  showLog("API :: URL :: $apiUrl");
  showLog("API :: Request Body :: ${jsonEncode(requestBody)}");
  showLog(
    "API :: Request Header :: ${{'Authorization': "Basic ${controller.paymentSettingModel.value.orangePay!.key!}", 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json'}.toString()} ",
  );
  showLog("API :: responseStatus :: ${response.statusCode} ");
  showLog("API :: responseBody :: ${response.body} ");

  if (response.statusCode == 200) {
    Map<String, dynamic> responseData = jsonDecode(response.body);

    accessToken = responseData['access_token'];
    // ignore: use_build_context_synchronously
    Get.back();
    return await webpayment(
      context: context,
      amountData: amount,
      currency: currency,
      orderIdData: orderId,
      controller: controller,
    );
  } else {
    Get.back();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xff635bff),
        content: CustomText(
          text: "Something went wrong, please contact admin.".tr,
          size: 17,
        ),
      ),
    );

    return '';
  }
}

Future webpayment({
  required String orderIdData,
  required BuildContext context,
  required String currency,
  required String amountData,
  required PaymentController controller,
}) async {
  orderId = orderIdData;
  amount = amountData;
  String apiUrl =
      controller.paymentSettingModel.value.orangePay!.isSandboxEnabled! ==
          "true"
      ? 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment'
      : 'https://api.orange.com/orange-money-webpay/cm/v1/webpayment';
  Map<String, String> requestBody = {
    "merchant_key":
        controller.paymentSettingModel.value.orangePay!.merchantKey ?? '',
    "currency":
        controller.paymentSettingModel.value.orangePay!.isSandboxEnabled ==
            "true"
        ? "OUV"
        : currency,
    "order_id": orderId,
    "amount": amount,
    "reference": 'Y-Note Test',
    "lang": "en",
    "return_url": controller.paymentSettingModel.value.orangePay!.returnUrl!
        .toString(),
    "cancel_url": controller.paymentSettingModel.value.orangePay!.cancelUrl!
        .toString(),
    "notif_url": controller.paymentSettingModel.value.orangePay!.notifUrl!
        .toString(),
  };

  var response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: json.encode(requestBody),
  );

  showLog("API :: URL :: $apiUrl");
  showLog("API :: Request Body :: ${jsonEncode(requestBody)}");
  showLog(
    "API :: Request Header :: ${{'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json', 'Accept': 'application/json'}.toString()} ",
  );
  showLog("API :: responseStatus :: ${response.statusCode} ");
  showLog("API :: responseBody :: ${response.body} ");
  if (response.statusCode == 201) {
    Map<String, dynamic> responseData = jsonDecode(response.body);
    if (responseData['message'] == 'OK') {
      payToken = responseData['pay_token'];
      return responseData['payment_url'];
    } else {
      return '';
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xff635bff),
        content: CustomText(
          text: "Something went wrong, please contact admin.".tr,
          size: 17,
        ),
      ),
    );
    return '';
  }
}

void reset() {
  accessToken = '';
  payToken = '';
  orderId = '';
  amount = '';
}

//Midtrans payment
Future<void> midtransMakePayment({
  required String amount,
  required BuildContext context,
  required PaymentController controller,
}) async {
  await createPaymentLink(amount: amount, controller: controller).then((url) {
    if (url != '') {
      Get.to(() => MidtransScreen(initialURl: url))!.then((value) {
        if (value == true) {
          transactionAPI();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(text: "Payment Unsuccessful!!".tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  });
}

Future<String> createPaymentLink({
  required var amount,
  required PaymentController controller,
}) async {
  var ordersId = DateTime.now().millisecondsSinceEpoch.toString();
  final url = Uri.parse(
    controller.paymentSettingModel.value.midtrans!.isSandboxEnabled!
                .toString() ==
            "true"
        ? 'https://api.sandbox.midtrans.com/v1/payment-links'
        : 'https://api.midtrans.com/v1/payment-links',
  );

  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(
        controller.paymentSettingModel.value.midtrans!.key!,
      ),
    },
    body: jsonEncode({
      'transaction_details': {
        'order_id': ordersId,
        'gross_amount': double.parse(amount.toString()).toInt(),
      },
      'usage_limit': 2,
      "callbacks": {
        "finish": "https://www.google.com?merchant_order_id=$ordersId",
      },
    }),
  );
  showLog("API :: URL :: $url");
  showLog(
    "API :: Request Body :: ${jsonEncode({
      'transaction_details': {'order_id': ordersId, 'gross_amount': double.parse(amount.toString()).toInt()},
      'usage_limit': 2,
      "callbacks": {"finish": "https://www.google.com?merchant_order_id=$ordersId"},
    })}",
  );
  showLog(
    "API :: Request Header :: ${{'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': generateBasicAuthHeader(controller.paymentSettingModel.value.midtrans!.key!)}.toString()} ",
  );
  showLog("API :: responseStatus :: ${response.statusCode} ");
  showLog("API :: responseBody :: ${response.body} ");

  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseData = jsonDecode(response.body);
    Get.back();
    print('Payment link created: ${responseData['payment_url']}');
    return responseData['payment_url'];
  } else {
    Get.back();
    return '';
  }
}

SnackbarController showSnackBarAlert({
  required String message,
  Color color = Colors.green,
}) {
  return Get.showSnackbar(
    GetSnackBar(
      isDismissible: true,
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 8),
    ),
  );
}
