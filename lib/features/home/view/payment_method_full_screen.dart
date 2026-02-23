import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/driver_model.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/vehicle_category_model.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/price_summary_card.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/ride_payment_selection_screen.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/controller/package_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class PaymentMethodFullScreen extends StatefulWidget {
  final VehicleCategoryModel vehicleCategoryModel;
  final double tripPrice;
  final DriverData driverData;
  final double originalTripPrice;
  final bool isSchedule;
  final DateTime? scheduleDateTime;
  final HomeController homeController;

  const PaymentMethodFullScreen({
    super.key,
    required this.vehicleCategoryModel,
    required this.tripPrice,
    required this.driverData,
    required this.originalTripPrice,
    required this.isSchedule,
    this.scheduleDateTime,
    required this.homeController,
  });

  // Rename for clarity - this is actually a Review/Summary screen
  static const String routeName = '/ride-review';

  @override
  State<PaymentMethodFullScreen> createState() =>
      _PaymentMethodFullScreenState();
}

class _PaymentMethodFullScreenState extends State<PaymentMethodFullScreen> {
  final TextEditingController discountCodeController = TextEditingController();
  double currentDiscountAmount = 0.0;
  String? appliedDiscountCode;
  double currentTripPrice = 0.0;
  bool isApplyingDiscount = false;
  String discountCodeText = '';
  final PaymentController paymentCtrl = Get.find<PaymentController>();
  final HomeController controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    currentTripPrice = widget.tripPrice;
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

  @override
  void dispose() {
    discountCodeController.dispose();
    super.dispose();
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
        title: 'review_your_ride'.tr,
        showBackButton: true,
        onBackPressed: () {
          // Reset trip price when going back
          Get.back();
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Price Summary Card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: PriceSummaryCard(
                tripPrice: currentTripPrice,
                isDarkMode: isDarkMode,
                discountAmount: currentDiscountAmount,
                originalPrice: widget.originalTripPrice,
                isPackageSelected: controller.usePackage.value,
              ),
            ),
            const SizedBox(height: 24),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Ride Details Section (Always shown)
                    _buildRideDetailsSection(isDarkMode),
                    const SizedBox(height: 16),

                    // 2. Package KM Section (If available)
                    _buildPackageKmSection(isDarkMode),

                    // 3. Discount Code Section (If available)
                    if (paymentCtrl.coupanCodeList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDiscountCodeSection(isDarkMode),
                    ],

                    // 4. Continue Button at the end
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      child: CustomButton(
                        btnName:
                            "${'continue_to_payment'.tr} ${Constant().amountShow(amount: currentTripPrice.toStringAsFixed(2))}",
                        ontap: () => _navigateToPaymentScreen(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideDetailsSection(bool isDarkMode) {
    return LightBorderedCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.route_square,
                size: 20,
                color: AppThemeData.primary200,
              ),
              const SizedBox(width: 8),
              CustomText(
                text: 'ride_details'.tr,
                size: 16,
                weight: FontWeight.w700,
                color: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pickup Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppThemeData.success300.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Iconsax.location,
                    size: 20,
                    color: AppThemeData.success300,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'pick_up_location'.tr,
                      size: 12,
                      color: isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: controller.departureController.text.isNotEmpty
                          ? controller.departureController.text
                          : 'not_set'.tr,
                      size: 14,
                      weight: FontWeight.w500,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppThemeData.error200.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Iconsax.location,
                    size: 20,
                    color: AppThemeData.error200,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'destination'.tr,
                      size: 12,
                      color: isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: controller.destinationController.text.isNotEmpty
                          ? controller.destinationController.text
                          : 'not_set'.tr,
                      size: 14,
                      weight: FontWeight.w500,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: isDarkMode
                ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                : AppThemeData.grey300.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          // Distance, Duration, Vehicle Type
          Row(
            children: [
              // Distance
              Expanded(
                child: _buildDetailItem(
                  icon: Iconsax.routing,
                  label: 'distance'.tr,
                  value: controller.distance.value > 0
                      ? "${controller.distance.value.toStringAsFixed(1)} ${Constant.distanceUnit ?? 'KM'}"
                      : 'n_a'.tr,
                  iconColor: AppThemeData.primary200,
                  isDarkMode: isDarkMode,
                ),
              ),
              // Duration
              Expanded(
                child: _buildDetailItem(
                  icon: Iconsax.clock,
                  label: 'duration'.tr,
                  value: controller.duration.value.isNotEmpty
                      ? controller.duration.value
                      : 'n_a'.tr,
                  iconColor: AppThemeData.warning200,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Vehicle Type
              Expanded(
                child: _buildDetailItem(
                  icon: Iconsax.car,
                  label: 'vehicle_type'.tr,
                  value: _getLocalizedVehicleName(
                    controller.vehicleData.value.libelle?.toString() ?? '',
                  ),
                  iconColor: AppThemeData.info200,
                  isDarkMode: isDarkMode,
                ),
              ),
              // Trip Category (if available)
              if (controller.tripOptionCategory.value.isNotEmpty &&
                  controller.tripOptionCategory.value != "General")
                Expanded(
                  child: _buildDetailItem(
                    icon: Iconsax.tag,
                    label: 'category'.tr,
                    value: controller.tripOptionCategory.value,
                    iconColor: AppThemeData.secondary200,
                    isDarkMode: isDarkMode,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: label,
                size: 11,
                color: isDarkMode
                    ? AppThemeData.grey500Dark
                    : AppThemeData.grey500,
              ),
              const SizedBox(height: 2),
              CustomText(
                text: value,
                size: 13,
                weight: FontWeight.w600,
                color: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageKmSection(bool isDarkMode) {
    final rideDistance = controller.distance.value;

    // Calculate extra amount if package is selected
    double? extraAmountToPay;
    if (controller.selectedUserPackage.value != null) {
      // When package is used: User pays ONLY zone charges (zone in + zone out)
      // KM fare is completely covered by package
      extraAmountToPay = controller.zoneFare.value;
      if (extraAmountToPay < 0) extraAmountToPay = 0.0;
    }

    final packageController = Get.put(PackageController());

    return FutureBuilder(
      future: packageController.fetchUsablePackages(),
      builder: (context, snapshot) {
        return Obx(() {
          final usablePackages = packageController.usablePackages
              .where(
                (pkg) =>
                    pkg.isUsable == true &&
                    (double.tryParse(pkg.remainingKm ?? '0') ?? 0) > 0,
              )
              .toList();

          if (usablePackages.isEmpty) {
            return const SizedBox.shrink();
          }

          return LightBorderedCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppThemeData.success300.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Iconsax.box_tick,
                        size: 22,
                        color: AppThemeData.success300,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'use_package_km'.tr,
                            size: 16,
                            weight: FontWeight.w700,
                            color: AppThemeData.success300,
                          ),
                          const SizedBox(height: 2),
                          CustomText(
                            text:
                                extraAmountToPay != null && extraAmountToPay > 0
                                ? 'pay_extra_for_zone_charges'.tr
                                : 'no_payment_deduct_from_package'.tr,
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
                const SizedBox(height: 16),
                // List packages
                ...usablePackages.map((pkg) {
                  final remainingKm =
                      double.tryParse(pkg.remainingKm ?? '0') ?? 0;
                  final kmToDeduct = rideDistance > remainingKm
                      ? remainingKm
                      : rideDistance;
                  final kmAfterRide = remainingKm - kmToDeduct;
                  final isSelected =
                      controller.selectedUserPackage.value?.id == pkg.id;

                  // Calculate extra amount and savings if this package is selected
                  double? extraAmountToPayLocal;
                  double? savingsAmount;

                  if (isSelected) {
                    final actualKmFare =
                        controller.kmFare.value; // Actual KM fare from system

                    // Calculate savings: actual KM fare (package covers KM fare completely)
                    savingsAmount = actualKmFare;

                    // When package is used: User pays ONLY zone charges (zone in + zone out)
                    // KM fare is completely covered by package
                    extraAmountToPayLocal = controller.zoneFare.value;
                    if (extraAmountToPayLocal < 0) extraAmountToPayLocal = 0.0;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (remainingKm < rideDistance) {
                        ShowToastDialog.showToast(
                          '${'not_enough_km_in_package'.tr} ${rideDistance.toStringAsFixed(1)} KM',
                        );
                        return;
                      }
                      setState(() {
                        if (isSelected) {
                          // Deselect package
                          controller.usePackage = false.obs;
                          controller.selectedUserPackage.value = null;
                          controller.packageKmToUse.value = 0.0;
                          currentDiscountAmount = 0.0;
                          currentTripPrice = widget.originalTripPrice;
                        } else {
                          // Select package
                          controller.usePackage = true.obs;
                          controller.selectedUserPackage.value = pkg;
                          controller.packageKmToUse.value = rideDistance;

                          // When package is used: User pays ONLY zone charges (zone in + zone out)
                          // KM fare is completely covered by package
                          final extraAmount = controller.zoneFare.value.clamp(
                            0.0,
                            double.infinity,
                          );
                          currentTripPrice = extraAmount > 0
                              ? double.parse(extraAmount.toStringAsFixed(2))
                              : 0.0;
                          currentDiscountAmount =
                              widget.originalTripPrice - currentTripPrice;

                          // Clear payment methods when package is selected
                          controller.cash.value = false;
                          controller.wallet.value = false;
                          controller.uPayments.value = false;
                          controller.paymentMethodType.value = "select_method";
                          controller.paymentMethodId.value = "";

                          // Also clear PaymentController flags
                          paymentCtrl.cash.value = false;
                          paymentCtrl.wallet.value = false;
                          paymentCtrl.upayments.value = false;
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppThemeData.success300.withValues(alpha: 0.15)
                            : (isDarkMode
                                  ? AppThemeData.grey800
                                  : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppThemeData.success300
                              : (isDarkMode
                                    ? AppThemeData.grey300Dark.withValues(
                                        alpha: 0.3,
                                      )
                                    : AppThemeData.grey300),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Checkbox
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppThemeData.success300
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppThemeData.success300
                                        : AppThemeData.grey400,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: pkg.packageName ?? 'package'.tr,
                                      size: 15,
                                      weight: FontWeight.w600,
                                      color: isDarkMode
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                    ),
                                    const SizedBox(height: 4),
                                    CustomText(
                                      text:
                                          "${remainingKm.toStringAsFixed(0)} ${'km_available'.tr}",
                                      size: 13,
                                      color: AppThemeData.success300,
                                      weight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                              // KM deduction info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomText(
                                    text:
                                        "-${kmToDeduct.toStringAsFixed(1)} KM",
                                    size: 16,
                                    weight: FontWeight.w700,
                                    color: isSelected
                                        ? AppThemeData.success300
                                        : AppThemeData.grey500,
                                  ),
                                  CustomText(
                                    text:
                                        "${kmAfterRide.toStringAsFixed(1)} ${'km_left'.tr}",
                                    size: 12,
                                    color: isDarkMode
                                        ? AppThemeData.grey500Dark
                                        : AppThemeData.grey500,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (isSelected &&
                              savingsAmount != null &&
                              savingsAmount > 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppThemeData.success300.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppThemeData.success300.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Iconsax.ticket_discount,
                                    size: 16,
                                    color: AppThemeData.success300,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CustomText(
                                      text:
                                          "${'you_save'.tr}: ${Constant().amountShow(amount: savingsAmount.toStringAsFixed(2))}",
                                      size: 13,
                                      weight: FontWeight.w600,
                                      color: AppThemeData.success300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildDiscountCodeSection(bool isDarkMode) {
    return LightBorderedCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.ticket_discount,
                size: 20,
                color: isDarkMode
                    ? AppThemeData.primary200
                    : AppThemeData.primary200,
              ),
              const SizedBox(width: 8),
              CustomText(
                text: 'have_discount_code'.tr,
                size: 16,
                weight: FontWeight.w600,
                color: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  key: ValueKey(
                    'discount_code_field_${appliedDiscountCode ?? 'empty'}',
                  ),
                  hintText: 'enter_discount_code'.tr,
                  controller: discountCodeController,
                  isReadOnly: appliedDiscountCode != null,
                  enabled: appliedDiscountCode == null,
                  textColor: isDarkMode
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                  hintColor: isDarkMode
                      ? AppThemeData.grey400Dark
                      : AppThemeData.grey400,
                  onChanged: appliedDiscountCode == null
                      ? (value) {
                          discountCodeText = value ?? '';
                          return value;
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              if (appliedDiscountCode == null)
                InkWell(
                  onTap: isApplyingDiscount
                      ? null
                      : () async {
                          if (discountCodeController.text.trim().isEmpty) {
                            ShowToastDialog.showToast(
                              'please_enter_discount_code'.tr,
                            );
                            return;
                          }
                          setState(() {
                            isApplyingDiscount = true;
                          });

                          // Use controller method to apply discount
                          final discountAmt = await paymentCtrl
                              .applyDiscountCode(
                                code: discountCodeController.text
                                    .trim()
                                    .toUpperCase(),
                                originalAmount: widget.originalTripPrice,
                              );

                          setState(() {
                            isApplyingDiscount = false;
                          });

                          if (discountAmt != null) {
                            setState(() {
                              appliedDiscountCode = discountCodeController.text
                                  .trim()
                                  .toUpperCase();
                              currentDiscountAmount = discountAmt;
                              currentTripPrice =
                                  widget.originalTripPrice - discountAmt;
                            });
                            ShowToastDialog.showToast(
                              'discount_code_applied_successfully'.tr,
                            );
                          } else {
                            setState(() {
                              appliedDiscountCode = null;
                              currentDiscountAmount = 0.0;
                              currentTripPrice = widget.originalTripPrice;
                            });
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeData.primary200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isApplyingDiscount
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : CustomText(
                            text: 'apply'.tr,
                            size: 14,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                  ),
                )
              else
                InkWell(
                  onTap: () {
                    // Use controller method to remove discount
                    paymentCtrl.removeDiscountCode();
                    setState(() {
                      appliedDiscountCode = null;
                      currentDiscountAmount = 0.0;
                      currentTripPrice = widget.originalTripPrice;
                      discountCodeController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(Icons.close, size: 20, color: Colors.red[700]),
                  ),
                ),
            ],
          ),
          if (appliedDiscountCode != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: CustomText(
                      text: '${'code_applied'.tr} $appliedDiscountCode',
                      size: 12,
                      weight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToPaymentScreen() {
    // Navigate to separate payment selection screen
    // Pass all necessary data for booking
    Get.to(
      () => RidePaymentSelectionScreen(
        vehicleCategoryModel: widget.vehicleCategoryModel,
        tripPrice: currentTripPrice,
        originalTripPrice: widget.originalTripPrice,
        driverData: widget.driverData,
        isSchedule: widget.isSchedule,
        scheduleDateTime: widget.scheduleDateTime,
        discountCode: appliedDiscountCode,
        discountAmount: currentDiscountAmount > 0
            ? currentDiscountAmount
            : null,
        homeController: widget.homeController,
      ),
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
}
