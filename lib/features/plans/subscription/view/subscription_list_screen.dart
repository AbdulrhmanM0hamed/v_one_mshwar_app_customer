import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/controller/subscription_controller.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/model/subscription_model.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/view/create_subscription_screen.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/view/subscription_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class SubscriptionListScreen extends StatelessWidget {
  final bool showBackButton;

  const SubscriptionListScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.put(SubscriptionController());

    return Scaffold(
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      appBar: CustomAppBar(
        title: 'Subscriptions'.tr,
        showBackButton: showBackButton,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.white),
            onPressed: () => controller.fetchUserSubscriptions(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isSettingsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.isSubscriptionAvailable.value) {
          return _buildUnavailableView(context, themeChange);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchUserSubscriptions();
          },
          child: controller.isListLoading.value
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              : controller.subscriptionsList.isEmpty
              ? _buildEmptyState(context, themeChange)
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subscriptions Section
                        _buildSectionTitle('your_subscriptions', themeChange),
                        const SizedBox(height: 12),
                        _buildSubscriptionsList(controller, themeChange),
                      ],
                    ),
                  ),
                ),
        );
      }),
      floatingActionButton: Obx(
        () => controller.isSubscriptionAvailable.value
            ? FloatingActionButton(
                onPressed: () => Get.to(() => const CreateSubscriptionScreen()),
                backgroundColor: AppThemeData.primary200,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : const SizedBox(),
      ),
    );
  }

  Widget _buildSectionTitle(String title, DarkThemeProvider themeChange) {
    return CustomText(
      text: title.tr,
      size: 20,
      weight: FontWeight.bold,
      color: themeChange.getThem() ? Colors.white : Colors.black87,
    );
  }

  Widget _buildSubscriptionsList(
    SubscriptionController controller,
    DarkThemeProvider themeChange,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.subscriptionsList.length,
      itemBuilder: (context, index) {
        final subscription = controller.subscriptionsList[index];
        return _buildSubscriptionCard(subscription, themeChange);
      },
    );
  }

  Widget _buildSubscriptionCard(
    SubscriptionData subscription,
    DarkThemeProvider themeChange,
  ) {
    return LightBorderedCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Get.to(
          () => SubscriptionDetailScreen(subscriptionId: subscription.id!),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildStatusBadge(subscription.status ?? ''),
                    const SizedBox(width: 8),
                    _buildPaymentBadge(subscription.paymentStatus ?? ''),
                  ],
                ),
                CustomText(
                  text: subscription.tripTypeDisplay,
                  size: 12,
                  weight: FontWeight.w600,
                  color: AppThemeData.primary200,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Route
            Row(
              children: [
                Column(
                  children: [
                    Icon(Icons.home, color: Colors.green, size: 20),
                    Container(
                      width: 2,
                      height: 20,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    Icon(Icons.location_on, color: Colors.red, size: 20),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: subscription.homeAddress ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        size: 14,
                        color: themeChange.getThem()
                            ? Colors.white
                            : Colors.black87,
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        text: subscription.destinationAddress ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat(
                  'Distance'.tr,
                  '${subscription.distanceKm} ${'KM'.tr}',
                  themeChange,
                ),
                _buildStat(
                  'Trips'.tr,
                  '${subscription.completedTrips}/${subscription.totalTrips}',
                  themeChange,
                ),
                _buildStat(
                  'Price'.tr,
                  '${subscription.totalPrice} ${'KWD'.tr}',
                  themeChange,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date range
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppThemeData.primary200.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppThemeData.primary200,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    text: '${subscription.startDate} → ${subscription.endDate}',
                    size: 13,
                    weight: FontWeight.w500,
                    color: AppThemeData.primary200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, DarkThemeProvider themeChange) {
    return Column(
      children: [
        CustomText(
          text: value,
          size: 16,
          weight: FontWeight.bold,
          color: themeChange.getThem() ? Colors.white : Colors.black87,
        ),
        const SizedBox(height: 2),
        CustomText(
          text: label.tr,
          size: 12,
          color: themeChange.getThem() ? Colors.white60 : Colors.black54,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'active':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        displayText = 'ACTIVE'.tr;
        break;
      case 'pending':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        displayText = 'PENDING PAYMENT'.tr;
        break;
      case 'pending_approval':
        bgColor = Colors.amber.withValues(alpha: 0.1);
        textColor = Colors.amber.shade700;
        displayText = 'PENDING APPROVAL'.tr;
        break;
      case 'rejected':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        displayText = 'REJECTED'.tr;
        break;
      case 'completed':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        displayText = 'COMPLETED'.tr;
        break;
      case 'cancelled':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        displayText = 'CANCELLED'.tr;
        break;
      case 'scheduled':
        bgColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        displayText = 'SCHEDULED'.tr;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        displayText = status.toUpperCase().tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomText(
        text: displayText,
        size: 11,
        weight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildPaymentBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'paid':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        label = 'PAID'.tr;
        break;
      case 'pending':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        label = 'UNPAID'.tr;
        break;
      case 'refunded':
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        label = 'REFUNDED'.tr;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        label = status.toUpperCase().tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomText(
        text: label,
        size: 11,
        weight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DarkThemeProvider themeChange) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(
              text: 'No Subscriptions Yet'.tr,
              size: 20,
              weight: FontWeight.bold,
              color: themeChange.getThem() ? Colors.white70 : Colors.black54,
              align: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              text:
                  'Create your first ride subscription for regular commutes'.tr,
              align: TextAlign.center,
              size: 14,
              color: themeChange.getThem() ? Colors.white54 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailableView(
    BuildContext context,
    DarkThemeProvider themeChange,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80,
              color: Colors.orange.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            CustomText(
              text: 'Subscriptions Not Available'.tr,
              size: 20,
              weight: FontWeight.bold,
              color: themeChange.getThem() ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(height: 8),
            CustomText(
              text:
                  'Subscription service is not available at the moment. Please check back later.'
                      .tr,
              align: TextAlign.center,
              size: 14,
              color: themeChange.getThem() ? Colors.white54 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}
