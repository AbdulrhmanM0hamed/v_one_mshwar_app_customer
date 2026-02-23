import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/controller/subscription_controller.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/model/subscription_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/view/payment_webview.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  final controller = Get.find<SubscriptionController>();
  final paymentController = Get.find<PaymentController>();
  SubscriptionData? subscription;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final data = await controller.getSubscriptionDetails(widget.subscriptionId);
    setState(() {
      subscription = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      appBar: CustomAppBar(
        title: 'Subscription Details'.tr,
        actions: [
          if (subscription != null &&
              subscription!.status != 'cancelled' &&
              subscription!.status != 'completed')
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'cancel') {
                  _showCancelDialog(context, themeChange);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      const Icon(Icons.cancel, color: Colors.red),
                      const SizedBox(width: 8),
                      CustomText(text: 'Cancel Subscription'.tr, size: 14),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subscription == null
          ? _buildErrorState(themeChange)
          : RefreshIndicator(
              onRefresh: _loadDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Status Header
                    _buildStatusHeader(themeChange),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trip Info Card
                          _buildTripInfoCard(themeChange),
                          const SizedBox(height: 16),

                          // Schedule Card
                          _buildScheduleCard(themeChange),
                          const SizedBox(height: 16),

                          // Price Card
                          _buildPriceCard(themeChange),
                          const SizedBox(height: 16),

                          // Driver Card
                          if (subscription!.driver != null)
                            _buildDriverCard(themeChange),

                          // Rides List
                          if (subscription!.rides != null &&
                              subscription!.rides!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildRidesList(themeChange),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton:
          subscription != null &&
              subscription!.status == 'pending' &&
              subscription!.paymentStatus == 'pending'
          ? FloatingActionButton.extended(
              onPressed: () => _showPaymentOptions(context, themeChange),
              backgroundColor: AppThemeData.primary200,
              icon: const Icon(Icons.payment, color: Colors.white),
              label: CustomText(
                text: 'Pay Now'.tr,
                color: Colors.white,
                size: 16,
                weight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  void _showPaymentOptions(
    BuildContext context,
    DarkThemeProvider themeChange,
  ) async {
    final controller = Get.find<SubscriptionController>();
    final totalAmount = double.tryParse(subscription!.totalPrice ?? '0') ?? 0.0;

    // Get wallet balance first
    final balance = await controller.getWalletBalance();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.grey800 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: 'select_payment_method'.tr,
              size: 18,
              weight: FontWeight.bold,
              color: themeChange.getThem() ? Colors.white : Colors.black87,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.account_balance_wallet,
                color: Colors.green,
              ),
              title: CustomText(text: 'Wallet'.tr),
              subtitle: CustomText(
                text:
                    '${'Balance: '.tr}${balance.toStringAsFixed(3)}${' KWD'.tr}',
                size: 12,
              ),
              onTap: () async {
                Navigator.pop(context);
                final balance = await controller.getWalletBalance();
                if (balance < totalAmount) {
                  ShowToastDialog.showToast(
                    '${'Insufficient wallet balance. You have '.tr}${balance.toStringAsFixed(3)}${' KWD but need '.tr}${totalAmount.toStringAsFixed(3)}${' KWD'.tr}',
                  );
                  return;
                }
                final result = await controller.processWalletPayment(
                  subscriptionId: subscription!.id!,
                  amount: totalAmount,
                );
                if (result != null) {
                  ShowToastDialog.showToast('Payment successful!'.tr);
                  _loadDetails();
                }
              },
            ),
            // KNET (UPayments) - Only show if enabled by admin
            if (paymentController.paymentSettingModel.value.uPayments != null &&
                paymentController
                        .paymentSettingModel
                        .value
                        .uPayments
                        ?.isEnabled ==
                    "true")
              ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.blue),
                title: CustomText(text: 'KNET (UPayments)'.tr),
                onTap: () async {
                  Navigator.pop(context);
                  final paymentUrl = await controller.processUPaymentsPayment(
                    subscriptionId: subscription!.id!,
                    amount: totalAmount,
                    homeAddress: subscription!.homeAddress ?? '',
                    destinationAddress: subscription!.destinationAddress ?? '',
                  );
                  if (paymentUrl != null) {
                    // Open payment webview
                    final result = await Get.to(
                      () => PaymentWebViewScreen(
                        url: paymentUrl,
                        title: 'Subscription Payment'.tr,
                      ),
                    );
                    if (result != null &&
                        result != false &&
                        result != 'false') {
                      ShowToastDialog.showToast('Payment successful!'.tr);
                      _loadDetails();
                    }
                  }
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(DarkThemeProvider themeChange) {
    Color bgColor;
    Color textColor;
    String statusText = subscription!.statusDisplay;
    IconData statusIcon;

    switch (subscription!.status) {
      case 'active':
        bgColor = Colors.green;
        textColor = Colors.white;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        bgColor = Colors.orange;
        textColor = Colors.white;
        statusIcon = Icons.hourglass_top;
        break;
      case 'pending_approval':
        bgColor = Colors.amber.shade700;
        textColor = Colors.white;
        statusIcon = Icons.pending_actions;
        break;
      case 'rejected':
        bgColor = Colors.red;
        textColor = Colors.white;
        statusIcon = Icons.cancel;
        break;
      case 'completed':
        bgColor = Colors.blue;
        textColor = Colors.white;
        statusIcon = Icons.done_all;
        break;
      case 'cancelled':
        bgColor = Colors.red;
        textColor = Colors.white;
        statusIcon = Icons.cancel;
        break;
      default:
        bgColor = Colors.grey;
        textColor = Colors.white;
        statusIcon = Icons.info;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: bgColor,
      child: Column(
        children: [
          Icon(statusIcon, size: 48, color: textColor),
          const SizedBox(height: 8),
          CustomText(
            text: statusText.tr,
            size: 20,
            weight: FontWeight.bold,
            color: textColor,
          ),
          if (subscription!.status == 'pending_approval') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomText(
                text: 'Waiting for admin approval'.tr,
                color: Colors.white,
                size: 12,
              ),
            ),
          ],
          if (subscription!.status == 'pending' &&
              subscription!.paymentStatus == 'pending') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomText(
                text: 'Payment Pending'.tr,
                color: Colors.white,
                size: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripInfoCard(DarkThemeProvider themeChange) {
    return LightBorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, color: AppThemeData.primary200),
              const SizedBox(width: 8),
              CustomText(
                text: 'Trip Information'.tr,
                size: 16,
                weight: FontWeight.bold,
                color: themeChange.getThem() ? Colors.white : Colors.black87,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppThemeData.primary200.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomText(
                  text: subscription!.tripTypeDisplay,
                  size: 12,
                  weight: FontWeight.bold,
                  color: AppThemeData.primary200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Home
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.home, color: Colors.green, size: 24),
                  Container(
                    width: 2,
                    height: 30,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const Icon(Icons.location_on, color: Colors.red, size: 24),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Home'.tr,
                      size: 12,
                      color: themeChange.getThem()
                          ? Colors.white54
                          : Colors.black45,
                    ),
                    CustomText(
                      text: subscription!.homeAddress ?? '',
                      size: 14,
                      color: themeChange.getThem()
                          ? Colors.white
                          : Colors.black87,
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      text: 'Destination'.tr,
                      size: 12,
                      color: themeChange.getThem()
                          ? Colors.white54
                          : Colors.black45,
                    ),
                    CustomText(
                      text: subscription!.destinationAddress ?? '',
                      size: 14,
                      color: themeChange.getThem()
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Distance
          Row(
            children: [
              Icon(
                Icons.straighten,
                size: 20,
                color: themeChange.getThem() ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(width: 8),
              CustomText(
                text:
                    '${'Distance: '.tr}${subscription!.distanceKm} ${'KM'.tr}',
                size: 14,
                weight: FontWeight.w600,
                color: themeChange.getThem() ? Colors.white : Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(DarkThemeProvider themeChange) {
    return LightBorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppThemeData.primary200),
              const SizedBox(width: 8),
              CustomText(
                text: 'Schedule'.tr,
                size: 16,
                weight: FontWeight.bold,
                color: themeChange.getThem() ? Colors.white : Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Range
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Start Date'.tr,
                  subscription!.startDate ?? '',
                  Icons.play_arrow,
                  themeChange,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'End Date'.tr,
                  subscription!.endDate ?? '',
                  Icons.stop,
                  themeChange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Working Days
          CustomText(
            text: 'Working Days'.tr,
            size: 12,
            color: themeChange.getThem() ? Colors.white54 : Colors.black45,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: subscription!.workingDaysNames
                .map(
                  (day) => Chip(
                    label: Text(
                      day,
                      style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                    ),
                    backgroundColor: AppThemeData.primary200.withValues(
                      alpha: 0.1,
                    ),
                    labelStyle: TextStyle(
                      color: AppThemeData.primary200,
                      fontFamily: 'Cairo',
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          // Pickup Times
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'First Pickup Time'.tr,
                  subscription!.morningPickupTime ?? '',
                  Icons.wb_sunny,
                  themeChange,
                ),
              ),
              if (subscription!.tripType == 'two_way')
                Expanded(
                  child: _buildInfoItem(
                    'Return Pickup Time'.tr,
                    subscription!.returnPickupTime ?? '',
                    Icons.nights_stay,
                    themeChange,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(DarkThemeProvider themeChange) {
    return LightBorderedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: AppThemeData.primary200),
              const SizedBox(width: 8),
              CustomText(
                text: 'Price Details'.tr,
                size: 16,
                weight: FontWeight.bold,
                color: themeChange.getThem() ? Colors.white : Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceRow(
            'KM Price'.tr,
            '${subscription!.subscriptionKmPrice} ${'KWD'.tr}/${'KM'.tr}',
            themeChange,
          ),
          _buildPriceRow(
            'Single Trip'.tr,
            '${subscription!.singleTripPrice} ${'KWD'.tr}',
            themeChange,
          ),
          _buildPriceRow(
            'Total Trips'.tr,
            subscription!.totalTrips ?? '0',
            themeChange,
          ),
          _buildPriceRow(
            'Completed'.tr,
            subscription!.completedTrips ?? '0',
            themeChange,
          ),
          _buildPriceRow(
            'Remaining'.tr,
            subscription!.remainingTrips ?? '0',
            themeChange,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'Total Price'.tr,
                size: 18,
                weight: FontWeight.bold,
                color: themeChange.getThem() ? Colors.white : Colors.black87,
              ),
              CustomText(
                text: '${subscription!.totalPrice} ${'KWD'.tr}',
                size: 24,
                weight: FontWeight.bold,
                color: AppThemeData.primary200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(DarkThemeProvider themeChange) {
    return LightBorderedCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppThemeData.primary200.withValues(alpha: 0.1),
            child:
                subscription!.driver!.photo != null &&
                    subscription!.driver!.photo!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      subscription!.driver!.photo!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.person, size: 30, color: AppThemeData.primary200),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Assigned Driver'.tr,
                  size: 12,
                  color: themeChange.getThem()
                      ? Colors.white54
                      : Colors.black45,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: subscription!.driver!.name ?? '',
                  size: 16,
                  weight: FontWeight.bold,
                  color: themeChange.getThem() ? Colors.white : Colors.black87,
                ),
                CustomText(
                  text: subscription!.driver!.phone ?? '',
                  size: 14,
                  color: themeChange.getThem()
                      ? Colors.white70
                      : Colors.black54,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.phone, color: AppThemeData.primary200),
            onPressed: () {
              // TODO: Call driver
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRidesList(DarkThemeProvider themeChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text:
              '${'Upcoming Rides ('.tr}${subscription!.rides!.length}${')'.tr}',
          size: 18,
          weight: FontWeight.bold,
          color: themeChange.getThem() ? Colors.white : Colors.black87,
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subscription!.rides!.length,
          itemBuilder: (context, index) {
            final ride = subscription!.rides![index];
            return LightBorderedCard(
              margin: const EdgeInsets.only(bottom: 12),
              borderRadius: 12,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeData.primary200.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: CustomText(
                          text: ride.rideDate != null
                              ? DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.parse(ride.rideDate!))
                              : '',
                          size: 12,
                          weight: FontWeight.bold,
                          color: AppThemeData.primary200,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        ride.rideDirection == 'to_destination'
                            ? Icons.arrow_forward
                            : Icons.arrow_back,
                        size: 16,
                        color: AppThemeData.primary200,
                      ),
                      const SizedBox(width: 4),
                      CustomText(
                        text: ride.scheduledPickupTime ?? '',
                        size: 14,
                        weight: FontWeight.bold,
                        color: themeChange.getThem()
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: ride.pickupAddress ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    size: 13,
                    color: themeChange.getThem()
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            ride.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomText(
                          text: ride.statusDisplay,
                          size: 11,
                          weight: FontWeight.bold,
                          color: _getStatusColor(ride.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    DarkThemeProvider themeChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label.tr,
          size: 12,
          color: themeChange.getThem() ? Colors.white54 : Colors.black45,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: AppThemeData.primary200),
            const SizedBox(width: 4),
            CustomText(
              text: value,
              size: 14,
              weight: FontWeight.w600,
              color: themeChange.getThem() ? Colors.white : Colors.black87,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    DarkThemeProvider themeChange,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label.tr,
            size: 14,
            color: themeChange.getThem() ? Colors.white70 : Colors.black54,
          ),
          CustomText(
            text: value,
            size: 14,
            weight: FontWeight.w600,
            color: themeChange.getThem() ? Colors.white : Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(DarkThemeProvider themeChange) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          CustomText(
            text: 'Failed to load subscription'.tr,
            size: 16,
            color: themeChange.getThem() ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(height: 16),
          CustomButton(
            btnName: 'Retry'.tr,
            ontap: _loadDetails,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, DarkThemeProvider themeChange) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Subscription'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to cancel this subscription? This action cannot be undone.'
                  .tr,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for cancellation'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Keep It'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                return;
              }
              Navigator.pop(context);
              final success = await controller.cancelSubscription(
                subscription!.id!,
                reasonController.text,
              );
              if (success) {
                Get.back();
              }
            },
            child: Text(
              'Yes, Cancel'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
