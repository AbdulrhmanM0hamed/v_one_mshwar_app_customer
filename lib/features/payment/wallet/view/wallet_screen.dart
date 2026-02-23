import 'dart:convert';
import 'dart:io';
import 'dart:math' as maths;
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/controller/wallet_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/model/payStackURLModel.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/model/transaction_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/model/user_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/model/xenditModel.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/view/payment_webview.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/midtrans_screen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/orangePayScreen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/payStackScreen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/wallet_sucess_screen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/xenditScreen.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/text_field.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_native/flutter_paypal_native.dart';
import 'package:flutter_paypal_native/models/custom/currency_code.dart';
import 'package:flutter_paypal_native/models/custom/environment.dart';
import 'package:flutter_paypal_native/models/custom/order_callback.dart';
import 'package:flutter_paypal_native/models/custom/purchase_unit.dart';
import 'package:flutter_paypal_native/models/custom/user_action.dart';
import 'package:flutter_paypal_native/str_helper.dart';
// import 'package:flutter_stripe/flutter_stripe.dart' as stripe1;
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:v_one_mshwar_app_customer/features/payment/payment/model/payment_setting_model.dart';
import 'MercadoPagoScreen.dart';
import 'PayFastScreen.dart';
import 'paystack_url_genrater.dart';

class WalletScreen extends StatefulWidget {
  final bool showBackButton;

  const WalletScreen({super.key, this.showBackButton = true});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final walletController = Get.put(WalletController());

  // final Razorpay razorPayController = Razorpay();

  static final GlobalKey<FormState> _walletFormKey = GlobalKey<FormState>();
  static final amountController = TextEditingController();
  bool paymentLoader = false;

  String _getUserName() {
    final user = Constant.getUserData().data;
    if (user?.nom != null && user?.prenom != null) {
      return '${user!.nom} ${user.prenom}'.toUpperCase();
    } else if (user?.nom != null) {
      return user!.nom!.toUpperCase();
    } else if (user?.prenom != null) {
      return user!.prenom!.toUpperCase();
    }
    return 'USER NAME'.tr;
  }

  Future<void> _refreshAPI() async {
    walletController.getAmount();
    walletController.getTransaction();
    amountController.clear();
    // Initialize PayPal only if payment settings are available
    // initPayPal() has its own null checks, so it's safe to call
    try {
      initPayPal();
    } catch (e) {
      // PayPal initialization failed, but don't block the app
      print("PayPal initialization skipped: $e");
    }
    setRef();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<WalletController>(
      init: WalletController(),
      initState: (state) {
        // Defer API calls to avoid build phase issues
        Future.microtask(() {
          _refreshAPI();
        });
      },
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(
            title: 'Wallet'.tr,
            showBackButton: widget.showBackButton,
            onBackPressed: () => Get.back(),
            actions: [
              IconButton(
                icon: const Icon(
                  Iconsax.refresh,
                  size: 22,
                  color: Colors.white,
                ),
                onPressed: () => _refreshAPI(),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Fixed Wallet Card (Non-scrollable)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    margin: EdgeInsets.zero,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppThemeData.primary200,
                          AppThemeData.primary200.withValues(alpha: 0.8),
                          AppThemeData.primary200.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative Pattern
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Row - Wallet Icon and Logo
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Wallet Icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Iconsax.wallet_3,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Payment Network Logo (Visa style)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: CustomText(
                                      text: 'VISA'.tr,
                                      size: 16,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              // Center - Balance Section
                              Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text: 'Wallet Balance'.tr,
                                      size: 12,
                                      weight: FontWeight.w500,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    CustomText(
                                      text: Constant().amountShow(
                                        amount: walletController.walletAmount
                                            .toString(),
                                      ),
                                      size: 32,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              // Bottom Row - Cardholder Name and Top Up Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Cardholder Name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: 'CARDHOLDER'.tr,
                                          size: 10,
                                          weight: FontWeight.w500,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        CustomText(
                                          text: _getUserName(),
                                          size: 16,
                                          weight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Top Up Button (Icon Only)
                                  InkWell(
                                    onTap: () {
                                      addToWalletAmount(
                                        context,
                                        themeChange.getThem(),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Iconsax.add_circle,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed Transaction History Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Transaction History'.tr,
                        size: 20,
                        weight: FontWeight.w600,
                        color: themeChange.getThem()
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      if (controller.walletList.isNotEmpty)
                        CustomText(
                          text:
                              '${controller.walletList.length} ${'Transactions'.tr}',
                          size: 14,
                          weight: FontWeight.w500,
                          color: themeChange.getThem()
                              ? AppThemeData.grey500Dark
                              : AppThemeData.grey500,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Scrollable Transaction List
                Expanded(
                  child: controller.isLoading.value
                      ? const SizedBox()
                      : controller.walletList.isEmpty
                      ? Center(
                          child: Constant.emptyView(
                            context,
                            "Transaction not found.".tr,
                            false,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              controller.walletList.length,
                              (index) => Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index < controller.walletList.length - 1
                                      ? 12
                                      : 0,
                                ),
                                child: buildTransactionCard(
                                  context,
                                  controller.walletList[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTransactionCard(BuildContext context, TransactionData data) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isCredit = data.deductionType.toString() == "1";

    return LightBorderedCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isCredit
                  ? AppThemeData.success300.withValues(alpha: 0.1)
                  : AppThemeData.error200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Iconsax.arrow_down_2 : Iconsax.arrow_up_2,
              size: 24,
              color: isCredit ? AppThemeData.success300 : AppThemeData.error200,
            ),
          ),
          const SizedBox(width: 16),
          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: isCredit
                      ? "${"Wallet Top-up via".tr} ${data.paymentMethod}"
                      : (data.paymentMethod?.toString().toLowerCase().contains(
                                  'package',
                                ) ??
                                false
                            ? "Payment for Package".tr
                            : "Payment for Trip".tr),
                  size: 16,
                  weight: FontWeight.w600,
                  color: themeChange.getThem()
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 14,
                      color: themeChange.getThem()
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                    const SizedBox(width: 6),
                    CustomText(
                      text: data.creer.toString(),
                      size: 13,
                      weight: FontWeight.w400,
                      color: themeChange.getThem()
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: isCredit
                    ? "+${Constant().amountShow(amount: data.amount.toString())}"
                    : "-${Constant().amountShow(amount: data.amount.toString())}",
                size: 18,
                weight: FontWeight.w700,
                color: isCredit
                    ? AppThemeData.success300
                    : AppThemeData.error200,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCredit
                      ? AppThemeData.success300.withValues(alpha: 0.1)
                      : AppThemeData.error200.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomText(
                  text: isCredit ? 'Credit'.tr : 'Debit'.tr,
                  size: 11,
                  weight: FontWeight.w600,
                  color: isCredit
                      ? AppThemeData.success300
                      : AppThemeData.error200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future addToWalletAmount(BuildContext context, bool isDarkMode) {
    return showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      elevation: 5,
      useRootNavigator: true,
      // useSafeArea: true,
      // anchorPoint: Offset(900.0, 1000.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      context: context,
      backgroundColor: isDarkMode
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      builder: (context) {
        return GetX<WalletController>(
          init: WalletController(),
          initState: (controller) {
            // razorPayController.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
            // razorPayController.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
            // razorPayController.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
          },
          builder: (controller) {
            return SizedBox(
              height: Get.height / 1.2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
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
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform:
                                        Directionality.of(context) ==
                                            TextDirection.rtl
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
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Top up Amount Section
                            CustomText(
                              text: "Top up Amount".tr,
                              color: isDarkMode
                                  ? AppThemeData.grey900Dark
                                  : AppThemeData.grey900,
                              size: 18,
                              weight: FontWeight.w700,
                            ),
                            const SizedBox(height: 16),
                            Form(
                              key: _walletFormKey,
                              child: CustomTextField(
                                text: 'Enter topup amount'.tr,
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                prefixIcon: Container(
                                  margin: const EdgeInsets.only(
                                    left: 16,
                                    right: 12,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppThemeData.primary200.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CustomText(
                                    text: 'KWD',
                                    color: AppThemeData.primary200,
                                    size: 14,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Select Payment Option Section
                            CustomText(
                              text: "Select Payment Option".tr,
                              color: isDarkMode
                                  ? AppThemeData.grey900Dark
                                  : AppThemeData.grey900,
                              size: 18,
                              weight: FontWeight.w700,
                            ),
                            const SizedBox(height: 16),
                            LightBorderedCard(
                              padding: EdgeInsets.zero,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Visibility(
                                      visible:
                                          walletController
                                              .paymentSettingModel
                                              .value
                                              .uPayments
                                              ?.isEnabled ==
                                          "true", // Show KNET only if enabled by admin
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RadioListTile(
                                            activeColor:
                                                AppThemeData.primary200,
                                            tileColor: Colors.transparent,
                                            selectedTileColor:
                                                AppThemeData.secondary50,
                                            controlAffinity:
                                                ListTileControlAffinity
                                                    .trailing,
                                            value: "UPayment",
                                            groupValue: walletController
                                                .selectedRadioTile!
                                                .value,
                                            onChanged: (String? value) {
                                              walletController.upayments =
                                                  true.obs;
                                              walletController.stripe =
                                                  false.obs;
                                              walletController.razorPay =
                                                  false.obs;

                                              walletController.paypal =
                                                  false.obs;
                                              walletController.payStack =
                                                  false.obs;
                                              walletController.flutterWave =
                                                  false.obs;
                                              walletController.mercadoPago =
                                                  false.obs;
                                              walletController.payFast =
                                                  false.obs;
                                              walletController.xendit =
                                                  false.obs;
                                              walletController.orangePay =
                                                  false.obs;
                                              walletController.midtrans =
                                                  false.obs;
                                              walletController
                                                      .selectedRadioTile!
                                                      .value =
                                                  value!;
                                            },
                                            selected:
                                                walletController.stripe.value,
                                            //selectedRadioTile == "strip" ? true : false,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isDarkMode
                                                        ? AppThemeData
                                                              .grey200Dark
                                                              .withValues(
                                                                alpha: 0.3,
                                                              )
                                                        : AppThemeData.grey200
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Image.asset(
                                                    "assets/icons/upayments.jpeg",
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: CustomText(
                                                    text:
                                                        "KNET, Credit Card & Others",
                                                    color:
                                                        walletController
                                                                .selectedRadioTile!
                                                                .value ==
                                                            'UPayment'
                                                        ? AppThemeData
                                                              .primary200
                                                        : isDarkMode
                                                        ? AppThemeData
                                                              .grey900Dark
                                                        : AppThemeData.grey900,
                                                    size: 16,
                                                    weight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            //toggleable: true,
                                          ),
                                          Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: isDarkMode
                                                ? AppThemeData.grey300Dark
                                                : AppThemeData.grey300,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.strip!.isEnabled == "true" ? true : false,
                                    //   child: Column(
                                    //     crossAxisAlignment: CrossAxisAlignment.start,
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50,
                                    //         controlAffinity: ListTileControlAffinity.trailing,
                                    //         value: "Stripe",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = true.obs;
                                    //           walletController.razorPay = false.obs;

                                    //           walletController.paypal = false.obs;
                                    //           walletController.payStack = false.obs;
                                    //           walletController.flutterWave = false.obs;
                                    //           walletController.mercadoPago = false.obs;
                                    //           walletController.payFast = false.obs;
                                    //           walletController.xendit = false.obs;
                                    //           walletController.orangePay = false.obs;
                                    //           walletController.midtrans = false.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },
                                    //         selected: walletController.stripe.value,
                                    //         //selectedRadioTile == "strip" ? true : false,
                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/stripe.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text("Stripe".tr,
                                    //                 style: TextStyle(
                                    //                   color: walletController.selectedRadioTile!.value == 'Stripe'
                                    //                       ? AppThemeData.grey900
                                    //                       : isDarkMode
                                    //                           ? AppThemeData.grey900Dark
                                    //                           : AppThemeData.grey900,
                                    //                   fontSize: 16,
                                    //                   fontFamily: AppThemeData.medium,
                                    //                 )),
                                    //           ],
                                    //         ),
                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.payStack!.isEnabled == "true" ? true : false,
                                    //   child: Column(
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50, controlAffinity: ListTileControlAffinity.trailing,

                                    //         value: "PayStack",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = false.obs;
                                    //           walletController.razorPay = false.obs;

                                    //           walletController.paypal = false.obs;
                                    //           walletController.payStack = true.obs;
                                    //           walletController.flutterWave = false.obs;
                                    //           walletController.mercadoPago = false.obs;
                                    //           walletController.payFast = false.obs;
                                    //           walletController.xendit = false.obs;
                                    //           walletController.orangePay = false.obs;
                                    //           walletController.midtrans = false.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },
                                    //         selected: walletController.payStack.value,
                                    //         //selectedRadioTile == "strip" ? true : false,
                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/paystack.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text("PayStack".tr,
                                    //                 style: TextStyle(
                                    //                   color: walletController.selectedRadioTile!.value == 'PayStack'
                                    //                       ? AppThemeData.grey900
                                    //                       : isDarkMode
                                    //                           ? AppThemeData.grey900Dark
                                    //                           : AppThemeData.grey900,
                                    //                   fontSize: 16,
                                    //                   fontFamily: AppThemeData.medium,
                                    //                 )),
                                    //           ],
                                    //         ),
                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.flutterWave!.isEnabled == "true" ? true : false,
                                    //   child: Column(
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50, controlAffinity: ListTileControlAffinity.trailing,
                                    //         value: "FlutterWave",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = false.obs;
                                    //           walletController.razorPay = false.obs;

                                    //           walletController.paypal = false.obs;
                                    //           walletController.payStack = false.obs;
                                    //           walletController.flutterWave = true.obs;
                                    //           walletController.mercadoPago = false.obs;
                                    //           walletController.payFast = false.obs;
                                    //           walletController.xendit = false.obs;
                                    //           walletController.orangePay = false.obs;
                                    //           walletController.midtrans = false.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },
                                    //         selected: walletController.flutterWave.value,
                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/flutterwave.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text("FlutterWave".tr,
                                    //                 style: TextStyle(
                                    //                   color: walletController.selectedRadioTile!.value == 'FlutterWave'
                                    //                       ? AppThemeData.grey900
                                    //                       : isDarkMode
                                    //                           ? AppThemeData.grey900Dark
                                    //                           : AppThemeData.grey900,
                                    //                   fontSize: 16,
                                    //                   fontFamily: AppThemeData.medium,
                                    //                 )),
                                    //           ],
                                    //         ),
                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.razorpay!.isEnabled == "true" ? true : false,
                                    //   child: Column(
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50, controlAffinity: ListTileControlAffinity.trailing,
                                    //         value: "RazorPay",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = false.obs;
                                    //           walletController.razorPay = true.obs;

                                    //           walletController.paypal = false.obs;
                                    //           walletController.payStack = false.obs;
                                    //           walletController.flutterWave = false.obs;
                                    //           walletController.mercadoPago = false.obs;
                                    //           walletController.payFast = false.obs;
                                    //           walletController.xendit = false.obs;
                                    //           walletController.orangePay = false.obs;
                                    //           walletController.midtrans = false.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },
                                    //         selected: walletController.razorPay.value,
                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/razorpay_@3x.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text("RazorPay".tr,
                                    //                 style: TextStyle(
                                    //                   color: walletController.selectedRadioTile!.value == 'RazorPay'
                                    //                       ? AppThemeData.grey900
                                    //                       : isDarkMode
                                    //                           ? AppThemeData.grey900Dark
                                    //                           : AppThemeData.grey900,
                                    //                   fontSize: 16,
                                    //                   fontFamily: AppThemeData.medium,
                                    //                 ))
                                    //           ],
                                    //         ),
                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.payFast!.isEnabled == "true" ? true : false,
                                    //   child: Column(
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50,

                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         controlAffinity: ListTileControlAffinity.trailing,
                                    //         value: "PayFast",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = false.obs;
                                    //           walletController.razorPay = false.obs;

                                    //           walletController.paypal = false.obs;
                                    //           walletController.payStack = false.obs;
                                    //           walletController.flutterWave = false.obs;
                                    //           walletController.mercadoPago = false.obs;
                                    //           walletController.payFast = true.obs;
                                    //           walletController.xendit = false.obs;
                                    //           walletController.orangePay = false.obs;
                                    //           walletController.midtrans = false.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },
                                    //         selected: walletController.payFast.value,
                                    //         //selectedRadioTile == "strip" ? true : false,
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/payfast.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text(
                                    //               "Pay Fast".tr,
                                    //               style: TextStyle(
                                    //                 color: walletController.selectedRadioTile!.value == 'PayFast'
                                    //                     ? AppThemeData.grey900
                                    //                     : isDarkMode
                                    //                         ? AppThemeData.grey900Dark
                                    //                         : AppThemeData.grey900,
                                    //                 fontSize: 16,
                                    //                 fontFamily: AppThemeData.medium,
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),

                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.mercadopago!.isEnabled == "true" ? true : false,
                                    //   child: Column(
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50, controlAffinity: ListTileControlAffinity.trailing,
                                    //         value: "MercadoPago",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = false.obs;
                                    //           walletController.razorPay = false.obs;

                                    //           walletController.paypal = false.obs;
                                    //           walletController.payStack = false.obs;
                                    //           walletController.flutterWave = false.obs;
                                    //           walletController.mercadoPago = true.obs;
                                    //           walletController.payFast = false.obs;
                                    //           walletController.xendit = false.obs;
                                    //           walletController.orangePay = false.obs;
                                    //           walletController.midtrans = false.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },
                                    //         selected: walletController.mercadoPago.value,
                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/mercadopago.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text("Mercado Pago".tr,
                                    //                 style: TextStyle(
                                    //                   color: walletController.selectedRadioTile!.value == 'MercadoPago'
                                    //                       ? AppThemeData.grey900
                                    //                       : isDarkMode
                                    //                           ? AppThemeData.grey900Dark
                                    //                           : AppThemeData.grey900,
                                    //                   fontSize: 16,
                                    //                   fontFamily: AppThemeData.medium,
                                    //                 )),
                                    //           ],
                                    //         ),
                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.payPal!.isEnabled == "true" ? true : false,
                                    //   child: Column(
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50,

                                    //         controlAffinity: ListTileControlAffinity.trailing,
                                    //         value: "PayPal",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = false.obs;
                                    //           walletController.razorPay = false.obs;

                                    //           walletController.paypal = true.obs;
                                    //           walletController.payStack = false.obs;
                                    //           walletController.flutterWave = false.obs;
                                    //           walletController.mercadoPago = false.obs;
                                    //           walletController.payFast = false.obs;
                                    //           walletController.xendit = false.obs;
                                    //           walletController.orangePay = false.obs;
                                    //           walletController.midtrans = false.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },
                                    //         selected: walletController.paypal.value,
                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/paypal_@3x.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text("PayPal".tr,
                                    //                 style: TextStyle(
                                    //                   color: controller.selectedRadioTile?.value == 'PayPal'
                                    //                       ? AppThemeData.grey900
                                    //                       : isDarkMode
                                    //                           ? AppThemeData.grey900Dark
                                    //                           : AppThemeData.grey900,
                                    //                   fontSize: 16,
                                    //                   fontFamily: AppThemeData.medium,
                                    //                 )),
                                    //           ],
                                    //         ),
                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.xendit!.isEnabled!.toString() == "true" ? true : false,
                                    //   child: Column(
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50,
                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         controlAffinity: ListTileControlAffinity.trailing,
                                    //         value: "Xendit",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = false.obs;
                                    //           walletController.razorPay = false.obs;

                                    //           walletController.paypal = false.obs;
                                    //           walletController.payStack = false.obs;
                                    //           walletController.flutterWave = false.obs;
                                    //           walletController.mercadoPago = false.obs;
                                    //           walletController.payFast = false.obs;
                                    //           walletController.xendit = true.obs;
                                    //           walletController.orangePay = false.obs;
                                    //           walletController.midtrans = false.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },

                                    //         selected: walletController.xendit.value,
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/xendit.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text(
                                    //               "Xendit".tr,
                                    //               style: TextStyle(
                                    //                 color: controller.selectedRadioTile?.value == 'Xendit'
                                    //                     ? AppThemeData.grey900
                                    //                     : isDarkMode
                                    //                         ? AppThemeData.grey900Dark
                                    //                         : AppThemeData.grey900,
                                    //                 fontSize: 16,
                                    //                 fontFamily: AppThemeData.medium,
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.orangePay!.isEnabled!.toString() == "true" ? true : false,
                                    //   child: Column(
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50, controlAffinity: ListTileControlAffinity.trailing,

                                    //         value: "Orange Pay",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = false.obs;
                                    //           walletController.razorPay = false.obs;

                                    //           walletController.paypal = false.obs;
                                    //           walletController.payStack = false.obs;
                                    //           walletController.flutterWave = false.obs;
                                    //           walletController.mercadoPago = false.obs;
                                    //           walletController.payFast = false.obs;
                                    //           walletController.xendit = false.obs;
                                    //           walletController.orangePay = true.obs;
                                    //           walletController.midtrans = false.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },
                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         selected: walletController.orangePay.value,
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/mercadopago.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text("Orange Pay".tr,
                                    //                 style: TextStyle(
                                    //                   color: controller.selectedRadioTile?.value == 'Orange Pay'
                                    //                       ? AppThemeData.grey900
                                    //                       : isDarkMode
                                    //                           ? AppThemeData.grey900Dark
                                    //                           : AppThemeData.grey900,
                                    //                   fontSize: 16,
                                    //                   fontFamily: AppThemeData.medium,
                                    //                 )),
                                    //           ],
                                    //         ),
                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Visibility(
                                    //   visible: walletController.paymentSettingModel.value.midtrans!.isEnabled!.toString() == "true" ? true : false,
                                    //   child: Column(
                                    //     children: [
                                    //       RadioListTile(
                                    //         activeColor: AppThemeData.primary200,
                                    //         tileColor: Colors.transparent,
                                    //         selectedTileColor: AppThemeData.secondary50,
                                    //         contentPadding: const EdgeInsets.symmetric(
                                    //           horizontal: 6,
                                    //         ),
                                    //         controlAffinity: ListTileControlAffinity.trailing,
                                    //         value: "Midtrans",
                                    //         groupValue: walletController.selectedRadioTile!.value,
                                    //         onChanged: (String? value) {
                                    //           walletController.stripe = false.obs;
                                    //           walletController.razorPay = false.obs;

                                    //           walletController.paypal = false.obs;
                                    //           walletController.payStack = false.obs;
                                    //           walletController.flutterWave = false.obs;
                                    //           walletController.mercadoPago = false.obs;
                                    //           walletController.payFast = false.obs;
                                    //           walletController.xendit = false.obs;
                                    //           walletController.orangePay = false.obs;
                                    //           walletController.midtrans = true.obs;
                                    //           walletController.selectedRadioTile!.value = value!;
                                    //         },
                                    //         selected: walletController.midtrans.value,
                                    //         title: Row(
                                    //           mainAxisAlignment: MainAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                                    //               child: FittedBox(
                                    //                 fit: BoxFit.cover,
                                    //                 child: Image.asset(
                                    //                   "assets/icons/midtrans.png",
                                    //                   width: 25,
                                    //                   height: 25,
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //             const SizedBox(
                                    //               width: 20,
                                    //             ),
                                    //             Text("Midtrans".tr,
                                    //                 style: TextStyle(
                                    //                   color: controller.selectedRadioTile?.value == 'Midtrans'
                                    //                       ? AppThemeData.grey900
                                    //                       : isDarkMode
                                    //                           ? AppThemeData.grey900Dark
                                    //                           : AppThemeData.grey900,
                                    //                   fontSize: 16,
                                    //                   fontFamily: AppThemeData.medium,
                                    //                 )),
                                    //           ],
                                    //         ),
                                    //         //toggleable: true,
                                    //       ),
                                    //       Container(
                                    //         color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey300,
                                    //         height: 1,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: CustomButton(
                        btnName: 'Add Amount'.tr,
                        ontap: () async {
                          if (amountController.text.isEmpty) {
                            ShowToastDialog.showToast(
                              'Please enter topup amount'.tr,
                            );
                          } else if (walletController
                                      .selectedRadioTile
                                      ?.value ==
                                  '' ||
                              walletController
                                      .selectedRadioTile
                                      ?.value
                                      .isEmpty ==
                                  true) {
                            ShowToastDialog.showToast(
                              'Please select payment method'.tr,
                            );
                          } else if (_walletFormKey.currentState!.validate()) {
                            Get.back();
                            // showLoadingAlert(context);
                            ShowToastDialog.showLoader('Please wait!'.tr);
                            // if (walletController.selectedRadioTile!.value == "Stripe") {
                            //   stripeMakePayment(amount: amountController.text);
                            // } else
                            // if (walletController.selectedRadioTile!.value == "RazorPay") {
                            //   startRazorpayPayment();
                            // }
                            if (walletController.selectedRadioTile!.value ==
                                "PayPal") {
                              paypalPaymentSheet(
                                double.parse(amountController.text).toString(),
                              );
                              // _paypalPayment();
                            } else if (walletController
                                    .selectedRadioTile!
                                    .value ==
                                "PayStack") {
                              payStackPayment(context);
                            } else if (walletController
                                    .selectedRadioTile!
                                    .value ==
                                "FlutterWave") {
                              flutterWaveInitiatePayment(
                                context: context,
                                amount: double.parse(
                                  amountController.text,
                                ).toString(),
                                user: controller.userModel.value,
                              );
                            } else if (walletController
                                    .selectedRadioTile!
                                    .value ==
                                "PayFast") {
                              payFastPayment(context);
                            } else if (walletController
                                    .selectedRadioTile!
                                    .value ==
                                "MercadoPago") {
                              mercadoPagoMakePayment(
                                context: context,
                                amount: double.parse(
                                  amountController.text,
                                ).toString(),
                                user: controller.userModel.value,
                              );
                            } else if (walletController
                                    .selectedRadioTile!
                                    .value ==
                                "Xendit") {
                              xenditPayment(
                                context,
                                double.parse(amountController.text),
                                walletController,
                              );
                            } else if (walletController
                                    .selectedRadioTile!
                                    .value ==
                                "Orange Pay") {
                              orangeMakePayment(
                                amount: double.parse(
                                  amountController.text,
                                ).toStringAsFixed(2),
                                context: context,
                                controller: walletController,
                              );
                            } else if (walletController
                                    .selectedRadioTile!
                                    .value ==
                                "Midtrans") {
                              midtransMakePayment(
                                amount: amountController.text.toString(),
                                context: context,
                                controller: walletController,
                              );
                            } else if (walletController
                                    .selectedRadioTile!
                                    .value ==
                                "UPayment") {
                              paymentLoader = true;
                              processUPaymentsPayment(
                                amount: double.parse(
                                  amountController.text.toString(),
                                ),
                                context: context,
                                controller: HomeController(),
                              );
                            } else {
                              ShowToastDialog.showToast(
                                "Please select payment method",
                              );
                            }
                          }
                        },
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

  // upayment

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
      final walletController = Get.find<WalletController>();

      // Use PaymentController for UPayments payment
      final paymentController = Get.find<PaymentController>();
      final paymentUrl = await paymentController.processUPaymentsPaymentGeneric(
        amount: amount,
        productName: "Mshwar Wallet Top-up",
        productDescription: "Wallet top-up",
        customerExtraData: "User define data",
      );

      if (paymentUrl != null) {
        ShowToastDialog.closeLoader();
        walletController.update();
        walletController.getTransaction();
        debugPrint('Payment URL from API: $paymentUrl');

        try {
          final result = await Get.to(
            () => PaymentWebViewScreen(url: paymentUrl, title: 'Payment'.tr),
          );

          debugPrint('Payment result: $result');

          // Check if payment was cancelled/failed (WebView returns 'false' string)
          if (result == false || result == 'false' || result == null) {
            debugPrint('Payment cancelled or failed by bank');
            ShowToastDialog.showToast(
              "Payment was cancelled or declined by bank".tr,
            );
            paymentLoader = false;
          } else if (result.toString().contains('https')) {
            // Payment returned with URL - parse result
            if (Platform.isAndroid == true) {
              Uri uri = Uri.parse(result);
              final Map<String, String> paymentDetails = uri.queryParameters;
              print('Payment result: $paymentDetails');
              if (paymentDetails['result'] == 'FAILED' ||
                  paymentDetails['result'] == 'CANCELD' ||
                  paymentDetails['result'] == 'CANCELED') {
                ShowToastDialog.showToast("Oops!\nTransaction Declined 🚫".tr);
                paymentLoader = false;
              } else if (paymentDetails['result'] == 'SUCCESS' ||
                  paymentDetails['result'] == 'CAPTURED') {
                paymentLoader = false;
                await walletController.setAmount(amount.toString()).then((
                  value,
                ) {
                  if (value['success'] == 'success') {
                    walletController.getAmount();
                    walletController.getTransaction();
                    amountController.clear();
                    initPayPal();
                    setRef();
                    ShowToastDialog.showToast("Payment Successful! ✅".tr);
                  }
                });
              }
            } else if (Platform.isIOS == true) {
              getPaymentResponse(result, controller, amount);
            }
          } else {
            debugPrint('Payment failed or returned unexpected: $result');
            ShowToastDialog.showToast("Oops!\nTransaction Declined 🚫".tr);
            paymentLoader = false;
          }
        } catch (e) {
          debugPrint('Error in payment flow: $e');
          ShowToastDialog.showToast("Payment error occurred".tr);
        }
      } else {
        ShowToastDialog.showToast("Payment initialization failed".tr);
      }
    } catch (e) {
      ShowToastDialog.showToast("Payment error: ${e.toString()}".tr);
    }
  }

  Future<void> getPaymentResponse(
    url,
    HomeController controller,
    amount,
  ) async {
    try {
      final String urlString = url.toString();
      debugPrint("🔍 iOS KNET Payment - Processing URL: $urlString");

      // Decode URL in case it's URL-encoded
      final String decodedUrl = Uri.decodeFull(urlString);
      debugPrint("🔍 Decoded URL: $decodedUrl");

      // Parse URL query parameters
      final Uri uri = Uri.parse(urlString);
      final queryParams = uri.queryParameters;
      debugPrint("🔍 Query params: $queryParams");

      String? paymentResult;

      // Method 1: Check for direct result parameter
      if (queryParams.containsKey('result')) {
        paymentResult = queryParams['result']?.toUpperCase();
        debugPrint("🔍 Found direct result: $paymentResult");
      }

      // Method 2: Check for kib_return_url parameter (iOS specific for KNET)
      if (paymentResult == null && queryParams.containsKey('kib_return_url')) {
        final kibReturnUrl = queryParams['kib_return_url'];
        debugPrint("🔍 Found kib_return_url: $kibReturnUrl");
        if (kibReturnUrl != null && kibReturnUrl.isNotEmpty) {
          // Decode the kib_return_url as it might be URL-encoded
          final decodedKibUrl = Uri.decodeFull(kibReturnUrl);
          final kibUri = Uri.tryParse(decodedKibUrl);
          if (kibUri != null && kibUri.queryParameters.containsKey('result')) {
            paymentResult = kibUri.queryParameters['result']?.toUpperCase();
            debugPrint(
              "🔍 Extracted result from kib_return_url: $paymentResult",
            );
          }
        }
      }

      // Method 3: Check URL patterns in both original and decoded URLs
      if (paymentResult == null) {
        final lowerUrl = decodedUrl.toLowerCase();
        debugPrint("🔍 Checking URL patterns in: $lowerUrl");

        // Check for various success patterns
        if (lowerUrl.contains('result=captured') ||
            lowerUrl.contains('result=success') ||
            lowerUrl.contains('status=captured') ||
            lowerUrl.contains('status=success')) {
          paymentResult = 'CAPTURED';
          debugPrint("🔍 Pattern match found: CAPTURED");
        } else if (lowerUrl.contains('result=failed') ||
            lowerUrl.contains('result=canceled') ||
            lowerUrl.contains('result=cancelled') ||
            lowerUrl.contains('status=failed') ||
            lowerUrl.contains('error.com')) {
          paymentResult = 'FAILED';
          debugPrint("🔍 Pattern match found: FAILED");
        }
      }

      // Method 4: If URL is pay.upayments.com (returnUrl) and no failure detected,
      // UPayments only redirects to returnUrl on successful payment
      if (paymentResult == null &&
          (urlString.contains('pay.upayments.com') ||
              urlString.contains('upayments.com/en')) &&
          !urlString.contains('error')) {
        debugPrint(
          "🔍 UPayments return URL detected without error - treating as SUCCESS",
        );
        paymentResult = 'CAPTURED';
      }

      debugPrint("🔍 Final payment result: $paymentResult");

      // Handle payment result
      if (paymentResult == 'FAILED' ||
          paymentResult == 'CANCELD' ||
          paymentResult == 'CANCELED' ||
          paymentResult == 'NOT CAPTURED') {
        ShowToastDialog.showToast("Oops!\nTransaction Declined 🚫".tr);
        paymentLoader = false;
      } else if (paymentResult == 'SUCCESS' || paymentResult == 'CAPTURED') {
        debugPrint("✅ Payment successful, updating wallet...");
        await walletController.setAmount(amount.toString()).then((value) {
          if (value['success'] == 'success') {
            walletController.getAmount();
            walletController.getTransaction();
            amountController.clear();
            initPayPal();
            setRef();
            ShowToastDialog.showToast("Payment Successful! ✅".tr);
          }
        });
        paymentLoader = false;
      } else {
        // If we still can't determine result, log the full URL for debugging
        debugPrint("❌ Could not determine payment result from URL");
        debugPrint("❌ Full URL was: $urlString");
        ShowToastDialog.showToast("Oops!\nTransaction Declined 🚫".tr);
        paymentLoader = false;
      }
    } catch (e) {
      debugPrint("❌ Error processing payment: $e");
      ShowToastDialog.showToast("Payment error occurred".tr);
      paymentLoader = false;
    }
  }

  // Unused method - kept for potential future use
  // ignore: unused_element
  Future<void> _handlePaymentCompletion(
    Map<String, String> paymentDetails, {
    required String amount,
    required WalletController walletController,
  }) async {
    try {
      // Extract transaction ID from payment details (for future use)
      // final transactionId = paymentDetails['transaction_id'];

      // Use the existing setAmount method to update wallet
      final response = await walletController.setAmount(amount);

      if (response != null && response['success'] == "success") {
        ShowToastDialog.showToast("Payment completed successfully".tr);

        ShowToastDialog.closeLoader();
        walletController.update();
      } else {
        ShowToastDialog.showToast("Failed to update wallet balance".tr);
      }
    } catch (e) {
      ShowToastDialog.showToast(
        "Error processing payment completion: ${e.toString()}".tr,
      );
    }
  }

  ///paypal

  final _flutterPaypalNativePlugin = FlutterPaypalNative.instance;

  void initPayPal() async {
    // Check if PayPal is configured and enabled
    final payPal = walletController.paymentSettingModel.value.payPal;
    if (payPal == null ||
        payPal.isEnabled != "true" ||
        payPal.appId == null ||
        payPal.appId!.isEmpty ||
        payPal.isLive == null) {
      // PayPal is not configured or disabled, skip initialization
      return;
    }

    try {
      //set debugMode for error logging
      FlutterPaypalNative.isDebugMode = payPal.isLive.toString() == "false"
          ? true
          : false;

      //initiate payPal plugin
      await _flutterPaypalNativePlugin.init(
        //your app id !!! No Underscore!!! see readme.md for help
        returnUrl: "com.v_one_mshwar_app_customer://paypalpay",
        //client id from developer dashboard
        clientID: payPal.appId!,
        //sandbox, staging, live etc
        payPalEnvironment: payPal.isLive.toString() == "true"
            ? FPayPalEnvironment.live
            : FPayPalEnvironment.sandbox,
        //what currency do you plan to use? default is US dollars
        currencyCode: FPayPalCurrencyCode.usd,
        //action paynow?
        action: FPayPalUserAction.payNow,
      );
    } catch (e) {
      // Log error but don't crash the app
      print("PayPal initialization error: $e");
    }
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

    //call backs for payment
    _flutterPaypalNativePlugin.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onCancel: () {
          //user canceled the payment
          Get.back();
          ShowToastDialog.showToast("Payment canceled".tr);
        },
        onSuccess: (data) {
          //successfully paid
          //remove all items from queue
          // _flutterPaypalNativePlugin.removeAllPurchaseItems();

          walletController.setAmount(amountController.text).then((value) {
            if (value != null) {
              // showSnackBarAlert(
              //   message: "Payment Successful!!".tr,
              //   color: Colors.green.shade400,
              // );
              _refreshAPI();
            }
          });
          Get.back();
          Get.to(const WalletSuccessScreen());
          // transactionAPI();
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

  /// RazorPay Payment Gateway
  // startRazorpayPayment() {
  //   try {
  //     walletController.createOrderRazorPay(amount: double.parse(amountController.text).round()).then((value) {
  //       if (value != null) {
  //         CreateRazorPayOrderModel result = value;
  //         openCheckout(
  //           amount: amountController.text,
  //           orderId: result.id,
  //         );
  //       } else {
  //         Get.back();
  //         showSnackBarAlert(
  //           message: "Something went wrong, please contact admin.".tr,
  //           color: Colors.red.shade400,
  //         );
  //       }
  //     });
  //   } catch (e) {
  //     Get.back();
  //     showSnackBarAlert(
  //       message: e.toString(),
  //       color: Colors.red.shade400,
  //     );
  //   }
  // }
  //
  // void openCheckout({required amount, required orderId}) async {
  //   var options = {
  //     'key': walletController.paymentSettingModel.value.razorpay!.key,
  //     'amount': amount * 100,
  //     'name': 'Foodies',
  //     'order_id': orderId,
  //     "currency": "INR",
  //     'description': 'wallet Topup',
  //     'retry': {'enabled': true, 'max_count': 1},
  //     'send_sms_hash': true,
  //     'prefill': {'contact': "8888888888", 'email': "demo@demo.com"},
  //     'external': {
  //       'wallets': ['paytm']
  //     }
  //   };
  //
  //   try {
  //     razorPayController.open(options);
  //   } catch (e) {
  //     log('Error: $e');
  //   }
  // }
  //
  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   Get.back();
  //   walletController.setAmount(amountController.text).then((value) {
  //     if (value != null) {
  //       _refreshAPI();
  //       Get.to(const WalletSuccessScreen());
  //     }
  //   });
  // }
  //
  // void _handleExternalWaller(ExternalWalletResponse response) {
  //   Get.back();
  //   showSnackBarAlert(
  //     message: "${"Payment Processing Via".tr}\n${response.walletName!}",
  //     color: Colors.blue.shade400,
  //   );
  // }
  //
  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Get.back();
  //   showSnackBarAlert(
  //     message: "${"Payment Failed!!".tr}\n${jsonDecode(response.message!)['error']['description']}",
  //     color: Colors.red.shade400,
  //   );
  // }

  /// Stripe Payment Gateway
  Map<String, dynamic>? paymentIntentData;

  // Future<void> stripeMakePayment({required String amount}) async {
  //   try {
  //     paymentIntentData = await walletController.createStripeIntent(amount: amount);
  //     if (paymentIntentData!.containsKey("error")) {
  //       Get.back();
  //       showSnackBarAlert(
  //         message: "Something went wrong, please contact admin.".tr,
  //         color: Colors.red.shade400,
  //       );
  //     } else {
  //       await stripe1.Stripe.instance
  //           .initPaymentSheet(
  //               paymentSheetParameters: stripe1.SetupPaymentSheetParameters(
  //             paymentIntentClientSecret: paymentIntentData!['client_secret'],
  //             allowsDelayedPaymentMethods: false,
  //             googlePay: stripe1.PaymentSheetGooglePay(
  //               merchantCountryCode: 'US',
  //               testEnv: walletController.paymentSettingModel.value.strip!.isSandboxEnabled == 'true' ? true : false,
  //               currencyCode: "USD",
  //             ),
  //             style: ThemeMode.system,
  //             appearance: stripe1.PaymentSheetAppearance(
  //               colors: stripe1.PaymentSheetAppearanceColors(
  //                 primary: AppThemeData.primary200,
  //               ),
  //             ),
  //             merchantDisplayName: 'v_one_mshwar_app_customer',
  //           ))
  //           .then((value) {});
  //       displayStripePaymentSheet();
  //     }
  //   } catch (e, s) {
  //     showSnackBarAlert(
  //       message: 'exception:$e \n$s',
  //       color: Colors.red,
  //     );
  //   }
  // }

  // displayStripePaymentSheet() async {
  //   try {
  //     await stripe1.Stripe.instance.presentPaymentSheet().then((value) {
  //       Get.back();
  //       walletController.setAmount(amountController.text).then((value) {
  //         if (value != null) {
  //           _refreshAPI();
  //         }
  //       });
  //       paymentIntentData = null;
  //     });
  //   } on stripe1.StripeException catch (e) {
  //     Get.back();
  //     var lo1 = jsonEncode(e);
  //     var lo2 = jsonDecode(lo1);
  //     StripePayFailedModel lom = StripePayFailedModel.fromJson(lo2);
  //     showSnackBarAlert(
  //       message: lom.error.message,
  //       color: Colors.green,
  //     );
  //   } catch (e) {
  //     Get.back();
  //     showSnackBarAlert(
  //       message: e.toString(),
  //       color: Colors.green,
  //     );
  //   }
  // }

  ///PayStack Payment Method
  Future<void> payStackPayment(BuildContext context) async {
    var secretKey = walletController
        .paymentSettingModel
        .value
        .payStack!
        .secretKey
        .toString();
    await walletController
        .payStackURLGen(amount: amountController.text, secretKey: secretKey)
        .then((value) async {
          if (value != null) {
            PayStackUrlModel payStackModel = value;
            bool isDone = await Get.to(
              () => PayStackScreen(
                walletController: walletController,
                secretKey: secretKey,
                initialURl: payStackModel.data.authorizationUrl,
                amount: amountController.text,
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
              walletController.setAmount(amountController.text).then((
                value,
              ) async {
                if (value != null) {
                  await _refreshAPI();
                  Get.to(const WalletSuccessScreen());
                }
              });
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

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['data']['link']))!.then((
        value,
      ) async {
        if (value) {
          ShowToastDialog.showToast("Payment Successful!!");
          Get.back();
          await _refreshAPI();
          Get.to(const WalletSuccessScreen());
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

  void payFastPayment(context) {
    PayFast? payfast = walletController.paymentSettingModel.value.payFast;
    PayStackURLGen.getPayHTML(
      payFastSettingData: payfast!,
      amount: double.parse(amountController.text.toString()).round().toString(),
    ).then((String? value) async {
      bool isDone = await Get.to(
        PayFastScreen(htmlData: value!, payFastSettingData: payfast),
      );
      if (isDone) {
        Get.back();
        walletController.setAmount(amountController.text).then((value) async {
          if (value != null) {
            await _refreshAPI();
            Get.to(const WalletSuccessScreen());
          }
        });
      } else {
        Get.back();
        showSnackBarAlert(
          message: "Payment UnSuccessful!!".tr,
          color: Colors.red,
        );
      }
    });
  }

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
      "auto_return":
          "approved", // Automatically return after payment is approved
    });

    final response = await http.post(
      Uri.parse("https://api.mercadopago.com/checkout/preferences"),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Get.to(MercadoPagoScreen(initialURl: data['init_point']))!.then((
        value,
      ) async {
        if (value) {
          Get.back();
          ShowToastDialog.showToast("Payment Successful!!");
          await _refreshAPI();
          Get.to(const WalletSuccessScreen());
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
            children: [CircularProgressIndicator(), Text('Please wait!!'.tr)],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(height: 15),
                Text(
                  'Please wait!! while completing Transaction'.tr,
                  style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                ),
                SizedBox(height: 15),
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
    WalletController controller,
  ) async {
    await createXenditInvoice(amount: amount, controller: controller).then((
      model,
    ) {
      if (model.id != null) {
        Get.to(
          () => XenditScreen(
            initialURl: model.invoiceUrl ?? '',
            transId: model.id ?? '',
            apiKey: controller.paymentSettingModel.value.xendit!.key!
                .toString(),
          ),
        )!.then((value) {
          if (value == true) {
            Get.back();
            walletController.setAmount(amountController.text).then((
              value,
            ) async {
              if (value != null) {
                await _refreshAPI();
                Get.to(const WalletSuccessScreen());
              }
            });
          } else {
            Get.back();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Payment Unsuccessful!!".tr),
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
    required WalletController controller,
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
  static String accessToken = '';
  static String payToken = '';
  static String orderId = '';
  static String amount = '';

  Future<void> orangeMakePayment({
    required String amount,
    required BuildContext context,
    required WalletController controller,
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
          walletController.setAmount(amountController.text).then((value) async {
            if (value != null) {
              await _refreshAPI();
              Get.to(const WalletSuccessScreen());
            }
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment Unsuccessful!!".tr),
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
    required WalletController controller,
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

    // Handle the response

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      accessToken = responseData['access_token'];
      // ignore: use_build_context_synchronously
      return await webpayment(
        context: context,
        amountData: amount,
        currency: currency,
        orderIdData: orderId,
        controller: controller,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.".tr,
            style: TextStyle(fontSize: 17, fontFamily: 'Cairo'),
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
    required WalletController controller,
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

    // Handle the response
    if (response.statusCode == 201) {
      Get.back();
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['message'] == 'OK') {
        payToken = responseData['pay_token'];
        return responseData['payment_url'];
      } else {
        return '';
      }
    } else {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xff635bff),
          content: Text(
            "Something went wrong, please contact admin.".tr,
            style: TextStyle(fontSize: 17, fontFamily: 'Cairo'),
          ),
        ),
      );
      return '';
    }
  }

  static void reset() {
    accessToken = '';
    payToken = '';
    orderId = '';
    amount = '';
  }

  //Midtrans payment
  Future<void> midtransMakePayment({
    required String amount,
    required BuildContext context,
    required WalletController controller,
  }) async {
    await createPaymentLink(amount: amount, controller: controller).then((url) {
      if (url != '') {
        Get.to(() => MidtransScreen(initialURl: url))!.then((value) {
          if (value == true) {
            walletController.setAmount(amountController.text).then((
              value,
            ) async {
              if (value != null) {
                Get.back();

                await _refreshAPI();
                Get.to(const WalletSuccessScreen());
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Payment Unsuccessful".tr),
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
    required WalletController controller,
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
}

enum PaymentOption {
  Stripe,
  PayTM,
  RazorPay,
  PayFast,
  PayStack,
  MercadoPago,
  PayPal,
  FlutterWave,
}
