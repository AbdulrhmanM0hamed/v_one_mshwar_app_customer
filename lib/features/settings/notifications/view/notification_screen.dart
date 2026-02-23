import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/settings/notifications/controller/notification_controller.dart';
import 'package:v_one_mshwar_app_customer/features/settings/notifications/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final isDarkMode = themeChange.getThem();

    return GetX<NotificationController>(
      init: NotificationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          appBar: CustomAppBar(
            title: 'Notifications'.tr,
            showBackButton: true,
            actions: [
              IconButton(
                onPressed: () => controller.refreshNotifications(),
                icon: Icon(Iconsax.refresh, color: Colors.white, size: 22),
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppThemeData.primary200,
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return _buildErrorState(controller, isDarkMode);
            }

            if (controller.notifications.isEmpty) {
              return _buildEmptyState(isDarkMode);
            }

            return RefreshIndicator(
              onRefresh: () => controller.refreshNotifications(),
              color: AppThemeData.primary200,
              child: Column(
                children: [
                  // Category filter chips
                  if (controller.availableCategories.length > 1)
                    _buildCategoryFilters(controller, isDarkMode),
                  // Notifications list
                  Expanded(
                    child: Obx(() {
                      final filtered = controller.filteredNotifications;
                      if (filtered.isEmpty) {
                        return Center(
                          child: CustomText(
                            text:
                                'No ${controller.selectedCategory.value == 'all' ? '' : controller.selectedCategory.value} notifications',
                            size: 14,
                            color: isDarkMode
                                ? AppThemeData.grey500Dark
                                : AppThemeData.grey500,
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final notification = filtered[index];
                          return _buildNotificationCard(
                            notification,
                            isDarkMode,
                            context,
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemeData.grey200Dark.withOpacity(0.3)
                  : AppThemeData.grey200.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.notification,
              size: 48,
              color: isDarkMode
                  ? AppThemeData.grey500Dark
                  : AppThemeData.grey500,
            ),
          ),
          const SizedBox(height: 24),
          CustomText(
            text: 'No Notifications'.tr,
            size: 18,
            weight: FontWeight.w600,
            color: isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: 'You have no notifications yet'.tr,
            size: 14,
            color: isDarkMode ? AppThemeData.grey500Dark : AppThemeData.grey500,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(NotificationController controller, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.warning_2, size: 48, color: Colors.red),
          ),
          const SizedBox(height: 24),
          CustomText(
            text: 'Something went wrong'.tr,
            size: 18,
            weight: FontWeight.w600,
            color: isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: CustomText(
              text: controller.errorMessage.value,
              size: 14,
              color: isDarkMode
                  ? AppThemeData.grey500Dark
                  : AppThemeData.grey500,
              align: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.refreshNotifications(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeData.primary200,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Iconsax.refresh, size: 20),
            label: CustomText(
              text: 'Retry'.tr,
              size: 14,
              weight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    bool isDarkMode,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeData.grey800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () =>
              _showNotificationDetail(notification, isDarkMode, context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type-based icon with category color
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notification.typeIcon,
                    color: notification.categoryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text: notification.title,
                                    size: 15,
                                    weight: FontWeight.w600,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Category badge
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: notification.categoryColor
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: CustomText(
                                    text: notification.categoryLabel,
                                    size: 10,
                                    weight: FontWeight.w500,
                                    color: notification.categoryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          CustomText(
                            text: notification.formattedDate,
                            size: 12,
                            color: isDarkMode
                                ? AppThemeData.grey500Dark
                                : AppThemeData.grey500,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                        text: notification.message,
                        size: 13,
                        color: isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(
    NotificationModel notification,
    bool isDarkMode,
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppThemeData.grey800 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppThemeData.grey400Dark
                      : AppThemeData.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notification.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.typeIcon,
                    color: notification.categoryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: notification.title,
                        size: 18,
                        weight: FontWeight.w600,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        text: notification.formattedDate,
                        size: 13,
                        color: isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(
              color: isDarkMode
                  ? AppThemeData.grey300Dark
                  : AppThemeData.grey200,
            ),
            const SizedBox(height: 20),
            CustomText(
              text: notification.message,
              size: 15,
              color: isDarkMode
                  ? AppThemeData.grey500Dark
                  : AppThemeData.grey500,
              height: 1.5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.primary200,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: CustomText(
                  text: 'Close'.tr,
                  size: 15,
                  weight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(
    NotificationController controller,
    bool isDarkMode,
  ) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.availableCategories.length,
        itemBuilder: (context, index) {
          final category = controller.availableCategories[index];
          final isSelected = controller.selectedCategory.value == category;

          // Get category color
          Color categoryColor = Colors.grey;
          String label = 'All';
          if (category != 'all') {
            // Create a dummy notification to get color
            final dummy = NotificationModel(
              id: 0,
              title: '',
              message: '',
              type: category,
              status: '',
              isRead: false,
              fromId: 0,
              createdAt: '',
              updatedAt: '',
              timeAgo: '',
            );
            categoryColor = dummy.categoryColor;
            label = dummy.categoryLabel;
          }

          return Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: controller.selectedCategory.value == category,
                label: Text(label),
                onSelected: (selected) {
                  controller.setCategory(category);
                },
                selectedColor: categoryColor.withValues(alpha: 0.2),
                checkmarkColor: categoryColor,
                labelStyle: TextStyle(
                  color: isSelected
                      ? categoryColor
                      : (isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: isSelected
                      ? categoryColor
                      : (isDarkMode
                            ? AppThemeData.grey300Dark
                            : AppThemeData.grey300),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
