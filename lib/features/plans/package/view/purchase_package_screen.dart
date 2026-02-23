import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/payment_method_selection.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/controller/package_controller.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/model/package_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/view/payment_webview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class PurchasePackageScreen extends StatelessWidget {
  final PackageData package;

  const PurchasePackageScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.find<PackageController>();
    final isDark = themeChange.getThem();

    return Scaffold(
      backgroundColor: isDark
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      appBar: CustomAppBar(title: 'Purchase Package'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Package Details Card
            Card(
              color: isDark ? AppThemeData.grey800 : Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Package Icon & Name
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppThemeData.primary200.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.gas_station,
                        color: AppThemeData.primary200,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      text: package.name ?? 'Package'.tr,
                      size: 24,
                      weight: FontWeight.bold,
                      color: isDark ? Colors.white : AppThemeData.grey900,
                    ),
                    if (package.description != null &&
                        package.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      CustomText(
                        text: package.description!,
                        size: 14,
                        color: isDark
                            ? AppThemeData.grey400Dark
                            : AppThemeData.grey500,
                        align: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Details Grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppThemeData.grey300Dark
                            : AppThemeData.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Total Kilometers'.tr,
                            package.formattedKm,
                            Iconsax.ruler,
                            themeChange,
                          ),
                          Divider(
                            height: 24,
                            color: isDark
                                ? AppThemeData.grey300Dark
                                : AppThemeData.grey200,
                          ),
                          _buildDetailRow(
                            'Price per KM'.tr,
                            package.pricePerKmDisplay,
                            Iconsax.money,
                            themeChange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Price Summary Card
            Card(
              color: isDark ? AppThemeData.grey800 : Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Price Summary'.tr,
                      size: 18,
                      weight: FontWeight.bold,
                      color: isDark ? Colors.white : AppThemeData.grey900,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text:
                              '${package.totalKm ?? '0'} KM × ${package.pricePerKm ?? '0'} KWD',
                          size: 14,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                        CustomText(
                          text: package.formattedPrice,
                          size: 14,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                      ],
                    ),
                    Divider(
                      height: 24,
                      color: isDark
                          ? AppThemeData.grey300Dark
                          : AppThemeData.grey200,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: 'Total Amount'.tr,
                          size: 18,
                          weight: FontWeight.bold,
                          color: isDark ? Colors.white : AppThemeData.grey900,
                        ),
                        CustomText(
                          text: package.formattedPrice,
                          size: 24,
                          weight: FontWeight.bold,
                          color: AppThemeData.primary200,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Purchase Button
            CustomButton(
              btnName: 'Proceed to Payment'.tr,
              ontap: () => _showPaymentSelection(context, controller),
              icon: Icon(Iconsax.shopping_cart, color: Colors.white, size: 20),
              borderRadius: 14,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    DarkThemeProvider themeChange, {
    Color? valueColor,
  }) {
    final isDark = themeChange.getThem();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (valueColor ?? AppThemeData.primary200).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: valueColor ?? AppThemeData.primary200,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomText(
            text: label,
            size: 14,
            color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey500,
          ),
        ),
        CustomText(
          text: value,
          size: 14,
          weight: FontWeight.bold,
          color: valueColor ?? (isDark ? Colors.white : AppThemeData.grey900),
        ),
      ],
    );
  }

  /// Show payment selection and process payment
  Future<void> _showPaymentSelection(
    BuildContext context,
    PackageController controller,
  ) async {
    final totalAmount = double.tryParse(package.totalPrice ?? '0') ?? 0.0;
    if (totalAmount <= 0) {
      ShowToastDialog.showToast('Invalid package price'.tr);
      return;
    }

    // Show payment selection - only Wallet and KNET
    final selectedMethod = await PaymentMethodSelection.show(
      context: context,
      totalAmount: totalAmount,
      totalAmountLabel: 'Package Price'.tr,
      subtitle: '${package.totalKm} KM',
      currency: 'KWD',
      allowedMethods: ['wallet', 'upayments'], // Only Wallet and KNET
      excludeCash: true,
    );

    if (selectedMethod == null) return;

    // Process payment based on selected method
    if (selectedMethod.id == 'wallet') {
      await _processWalletPayment(context, controller, totalAmount);
    } else if (selectedMethod.id == 'upayments') {
      await _processKnetPayment(context, controller, totalAmount);
    }
  }

  /// Process Wallet Payment
  Future<void> _processWalletPayment(
    BuildContext context,
    PackageController controller,
    double amount,
  ) async {
    // Check wallet balance first
    final balance = await controller.getWalletBalance();
    if (balance < amount) {
      ShowToastDialog.showToast(
        '${'Insufficient wallet balance. You have'.tr} ${balance.toStringAsFixed(3)} KWD ${'but need'.tr} ${amount.toStringAsFixed(3)} KWD',
      );
      return;
    }

    // First create the user package with pending payment
    final userPackage = await controller.purchasePackage(package.id!, 'wallet');
    if (userPackage == null) {
      ShowToastDialog.showToast('Failed to initiate purchase'.tr);
      return;
    }

    // Process wallet payment
    final paymentResult = await controller.payWithWallet(
      userPackage.id!,
      amount,
    );

    if (paymentResult != null) {
      // Success - controller already shows toast
      controller.fetchUserPackages(); // Refresh the list
      Get.back(result: true);
    } else {
      // Cancel the pending package if payment failed (silent mode - we already showed error in controller)
      await controller.cancelPackage(userPackage.id!, silent: true);
    }
  }

  /// Process KNET Payment via UPayments
  Future<void> _processKnetPayment(
    BuildContext context,
    PackageController controller,
    double amount,
  ) async {
    // First create the user package with pending payment
    final userPackage = await controller.purchasePackage(
      package.id!,
      'upayments',
    );
    if (userPackage == null) {
      ShowToastDialog.showToast('Failed to initiate purchase'.tr);
      return;
    }

    // Get payment URL from UPayments
    final paymentUrl = await controller.processUPaymentsPayment(
      userPackageId: userPackage.id!,
      amount: amount,
      packageName: package.name ?? 'Package'.tr,
    );

    if (paymentUrl == null) {
      // Cancel the pending package if we couldn't get payment URL
      ShowToastDialog.showToast('Failed to initiate payment'.tr);
      await controller.cancelPackage(userPackage.id!, silent: true);
      return;
    }

    // Open payment webview
    final result = await Get.to(
      () => PaymentWebViewScreen(url: paymentUrl, title: 'Package Payment'.tr),
    );

    // Handle payment result
    if (result == null || result == false || result == 'false') {
      ShowToastDialog.showToast('Payment was cancelled or declined by bank'.tr);
      await controller.cancelPackage(userPackage.id!, silent: true);
      return;
    }

    if (result is String && result.contains('https')) {
      // Parse result URL
      final String urlString = result;
      final String decodedUrl = Uri.decodeFull(urlString);
      Uri uri = Uri.parse(urlString);
      final Map<String, String> queryParams = uri.queryParameters;

      String? paymentResult;
      String? transactionId = queryParams['transaction_id'];

      // Method 1: Check for direct result parameter
      if (queryParams.containsKey('result')) {
        paymentResult = queryParams['result']?.toUpperCase();
      }

      // Method 2: Check for kib_return_url parameter (iOS specific for KNET)
      if (paymentResult == null && queryParams.containsKey('kib_return_url')) {
        final kibReturnUrl = queryParams['kib_return_url'];
        if (kibReturnUrl != null && kibReturnUrl.isNotEmpty) {
          final decodedKibUrl = Uri.decodeFull(kibReturnUrl);
          final kibUri = Uri.tryParse(decodedKibUrl);
          if (kibUri != null) {
            paymentResult = kibUri.queryParameters['result']?.toUpperCase();
            transactionId ??= kibUri.queryParameters['transaction_id'];
          }
        }
      }

      // Method 3: Check URL patterns in decoded URL
      if (paymentResult == null) {
        final lowerUrl = decodedUrl.toLowerCase();
        if (lowerUrl.contains('result=captured') ||
            lowerUrl.contains('result=success') ||
            lowerUrl.contains('status=captured')) {
          paymentResult = 'CAPTURED';
        } else if (lowerUrl.contains('result=failed') ||
            lowerUrl.contains('result=canceled') ||
            lowerUrl.contains('error.com')) {
          paymentResult = 'FAILED';
        }
      }

      // Method 4: UPayments returnUrl detection (success redirect)
      if (paymentResult == null &&
          (urlString.contains('pay.upayments.com') ||
              urlString.contains('upayments.com/en')) &&
          !urlString.contains('error')) {
        paymentResult = 'CAPTURED';
      }

      if (paymentResult == 'SUCCESS' || paymentResult == 'CAPTURED') {
        // Payment successful - confirm package
        final confirmed = await controller.confirmPayment(
          userPackage.id!,
          transactionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'upayments',
        );

        if (confirmed) {
          // Success - controller already shows toast
          controller.fetchUserPackages(); // Refresh the list
          Get.back(result: true);
        }
      } else {
        ShowToastDialog.showToast('Payment was cancelled or failed'.tr);
        // Cancel the pending package (silent mode)
        await controller.cancelPackage(userPackage.id!, silent: true);
      }
    }
  }
}
