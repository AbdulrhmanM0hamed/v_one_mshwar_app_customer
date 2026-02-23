import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/radio_button.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/driver_model.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/vehicle_category_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/common/widget/modern_datetime_picker.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class RidePaymentSelectionScreen extends StatefulWidget {
  final VehicleCategoryModel vehicleCategoryModel;
  final double tripPrice;
  final double originalTripPrice;
  final DriverData driverData;
  final bool isSchedule;
  final DateTime? scheduleDateTime;
  final String? discountCode;
  final double? discountAmount;
  final HomeController homeController;

  const RidePaymentSelectionScreen({
    super.key,
    required this.vehicleCategoryModel,
    required this.tripPrice,
    required this.originalTripPrice,
    required this.driverData,
    required this.isSchedule,
    this.scheduleDateTime,
    this.discountCode,
    this.discountAmount,
    required this.homeController,
  });

  @override
  State<RidePaymentSelectionScreen> createState() =>
      _RidePaymentSelectionScreenState();
}

class _RidePaymentSelectionScreenState
    extends State<RidePaymentSelectionScreen> {
  final PaymentController paymentCtrl = Get.find<PaymentController>();
  final HomeController controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _initializeWalletAmount();
  }

  Future<void> _initializeWalletAmount() async {
    try {
      if (paymentCtrl.walletAmount.value == "0.0" ||
          paymentCtrl.walletAmount.value == "0" ||
          paymentCtrl.walletAmount.value.isEmpty) {
        await paymentCtrl.getAmount();
      }
    } catch (e) {
      await paymentCtrl.getAmount();
    }
  }

  void _handlePaymentMethodSelection({
    required String value,
    required String method,
    required String paymentId,
  }) {
    // Update HomeController boolean flags FIRST for instant UI update
    controller.cash.value = (method == 'cash');
    controller.wallet.value = (method == 'wallet');
    controller.uPayments.value = (method == 'upayments');

    // Use controller method to select payment method
    final result = paymentCtrl.selectPaymentMethod(
      method: method,
      paymentId: paymentId,
    );

    // Update HomeController payment method type and ID
    controller.paymentMethodType.value = result['paymentMethodType'] ?? value;
    controller.paymentMethodId.value = result['paymentMethodId'] ?? paymentId;
  }

  Future<void> _handleBookRide() async {
    // Check if package is selected
    final isPackageSelected =
        controller.usePackage.value &&
        controller.selectedUserPackage.value != null;

    // If package is selected and tripPrice is 0, no payment needed
    // If package is selected and tripPrice > 0, payment method is required for extra amount
    // If no package, payment method is always required
    if (!isPackageSelected || widget.tripPrice > 0) {
      // Validate payment method is selected
      // For UPayments, paymentMethodId might be empty but paymentMethodType should be set
      if (controller.paymentMethodType.value == 'select_method' ||
          (controller.paymentMethodId.value.isEmpty &&
              controller.paymentMethodType.value !=
                  'knet_credit_card_others')) {
        ShowToastDialog.showToast('please_select_payment_method'.tr);
        return;
      }
    }

    DateTime? finalScheduleDateTime = widget.scheduleDateTime;

    // If scheduling but no date/time selected, prompt user
    if (widget.isSchedule && finalScheduleDateTime == null) {
      finalScheduleDateTime = await ModernDateTimePicker.show(context);
      if (finalScheduleDateTime == null) {
        ShowToastDialog.showToast('please_select_date_time'.tr);
        return;
      }
    }

    // Use controller method to process booking
    await controller.processRideBooking(
      driverData: widget.driverData,
      tripPrice: widget.tripPrice,
      isSchedule: widget.isSchedule,
      scheduleDateTime: finalScheduleDateTime,
      discountCode: widget.discountCode,
      discountAmount: widget.discountAmount,
      context: context,
    );
  }

  Widget _buildPaymentMethodSection(bool isDarkMode) {
    // Wrap in Obx to make it reactive - updates instantly when payment method changes
    return Obx(
      () => LightBorderedCard(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            // Cash - Only show if enabled by admin
            if (controller.paymentSettingModel.value.cash != null &&
                controller.paymentSettingModel.value.cash?.isEnabled == "true")
              RadioButtonCustom(
                image: "assets/icons/cash.png",
                name: 'cash'.tr,
                groupValue: controller.paymentMethodType.value,
                isEnabled: true,
                isSelected: controller.cash.value,
                onClick: (String? value) {
                  _handlePaymentMethodSelection(
                    value: value!,
                    method: 'cash',
                    paymentId:
                        controller
                            .paymentSettingModel
                            .value
                            .cash
                            ?.idPaymentMethod
                            .toString() ??
                        '',
                  );
                },
              ),
            // Wallet - Only show if enabled by admin
            if (controller.paymentSettingModel.value.myWallet != null &&
                controller.paymentSettingModel.value.myWallet?.isEnabled ==
                    "true") ...[
              Divider(
                height: 1,
                thickness: 1,
                color: isDarkMode
                    ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                    : AppThemeData.grey300.withValues(alpha: 0.3),
              ),
              RadioButtonCustom(
                subName: Constant().amountShow(
                  amount:
                      (paymentCtrl.walletAmount.value.isEmpty ||
                          paymentCtrl.walletAmount.value == "0" ||
                          paymentCtrl.walletAmount.value == "0.0")
                      ? "0.0"
                      : paymentCtrl.walletAmount.value,
                ),
                image: "assets/icons/walltet_icons.png",
                name: 'wallet'.tr,
                groupValue: controller.paymentMethodType.value,
                isEnabled: true,
                isSelected: controller.wallet.value,
                onClick: (String? value) {
                  _handlePaymentMethodSelection(
                    value: value!,
                    method: 'wallet',
                    paymentId:
                        controller
                            .paymentSettingModel
                            .value
                            .myWallet
                            ?.idPaymentMethod
                            .toString() ??
                        '',
                  );
                },
              ),
            ],
            // KNET (UPayments) - Only show if enabled by admin
            if (controller.paymentSettingModel.value.uPayments != null &&
                controller.paymentSettingModel.value.uPayments?.isEnabled ==
                    "true") ...[
              Divider(
                height: 1,
                thickness: 1,
                color: isDarkMode
                    ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                    : AppThemeData.grey300.withValues(alpha: 0.3),
              ),
              RadioButtonCustom(
                isEnabled: true,
                name: 'knet_credit_card_others'.tr,
                image: "assets/icons/upayments.jpeg",
                isSelected: controller.uPayments.value,
                groupValue: controller.paymentMethodType.value,
                onClick: (String? value) {
                  _handlePaymentMethodSelection(
                    value: value!,
                    method: 'upayments',
                    paymentId:
                        controller
                            .paymentSettingModel
                            .value
                            .uPayments
                            ?.idPaymentMethod
                            .toString() ??
                        '8', // Default UPayments ID if not set in payment settings
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      appBar: CustomAppBar(
        title: 'select_payment_method'.tr,
        showBackButton: true,
        onBackPressed: () {
          Get.back();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Price Summary at top
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: LightBorderedCard(
                margin: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'total_amount'.tr,
                          size: 13,
                          weight: FontWeight.w500,
                          color: isDarkMode
                              ? AppThemeData.grey500Dark
                              : AppThemeData.grey500,
                        ),
                        const SizedBox(height: 6),
                        CustomText(
                          text: Constant().amountShow(
                            amount: widget.tripPrice.toStringAsFixed(2),
                          ),
                          size: 24,
                          weight: FontWeight.w800,
                          color: AppThemeData.primary200,
                        ),
                      ],
                    ),
                    if (widget.discountAmount != null &&
                        widget.discountAmount! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeData.success300.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppThemeData.success300.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.ticket_discount,
                                  size: 14,
                                  color: AppThemeData.success300,
                                ),
                                const SizedBox(width: 4),
                                CustomText(
                                  text: 'discount'.tr,
                                  size: 11,
                                  weight: FontWeight.w500,
                                  color: AppThemeData.success300,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            CustomText(
                              text: Constant().amountShow(
                                amount: widget.discountAmount!.toStringAsFixed(
                                  2,
                                ),
                              ),
                              size: 14,
                              weight: FontWeight.w700,
                              color: AppThemeData.success300,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Payment Methods
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'choose_payment_method'.tr,
                      size: 18,
                      weight: FontWeight.w600,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethodSection(isDarkMode),
                  ],
                ),
              ),
            ),
            // Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppThemeData.surface50Dark
                    : AppThemeData.surface50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Obx(() {
                  final paymentController = Get.find<PaymentController>();
                  return paymentController.paymentLoader != true
                      ? CustomButton(
                          btnName: widget.isSchedule
                              ? "${'schedule_ride'.tr} ${Constant().amountShow(amount: widget.tripPrice.toStringAsFixed(2))}"
                              : "${'confirm_pay'.tr} ${Constant().amountShow(amount: widget.tripPrice.toStringAsFixed(2))}",
                          ontap: () => _handleBookRide(),
                        )
                      : const Center(child: CircularProgressIndicator());
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
