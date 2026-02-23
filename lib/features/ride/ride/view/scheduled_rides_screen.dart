import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/controller/scheduled_ride_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/controller/new_ride_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/normal_rides_screen.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ScheduledRidesScreen extends StatefulWidget {
  const ScheduledRidesScreen({super.key});

  @override
  State<ScheduledRidesScreen> createState() => _ScheduledRidesScreenState();
}

class _ScheduledRidesScreenState extends State<ScheduledRidesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper function to get localized filter display name
  String _getFilterDisplayName(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        return 'all'.tr;
      case 'new':
        return 'new'.tr;
      case 'confirmed':
        return 'confirmed'.tr;
      case 'on ride':
      case 'onride':
        return 'on_ride'.tr;
      case 'completed':
        return 'completed'.tr;
      case 'rejected':
        return 'rejected'.tr;
      case 'cancelled':
        return 'cancelled'.tr;
      case 'pending':
        return 'pending'.tr;
      case 'scheduled':
        return 'scheduled'.tr;
      default:
        return filter.capitalizeFirst ?? filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.put(ScheduledRideController());

    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Scheduled Rides'.tr,
          showBackButton: true,
          onBackPressed: () => Get.back(),
        ),
        body: RefreshIndicator(
          onRefresh: () => controller.getScheduledRides(forceRefresh: true),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // Search Bar
                _buildSearchBar(controller, themeChange.getThem()),
                const SizedBox(height: 12),
                // Filter Tabs
                _buildFilterTabs(controller, themeChange.getThem()),
                Expanded(
                  child: _buildRideListContent(
                    controller,
                    themeChange.getThem(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ScheduledRideController controller, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppThemeData.grey800Dark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? AppThemeData.grey300Dark
                  : AppThemeData.grey200,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              controller.setSearchQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'Search by location, date, time, or ride ID...'.tr,
              hintStyle: TextStyle(
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Iconsax.search_normal,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
                size: 20,
              ),
              suffixIcon: Obx(
                () => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Iconsax.close_circle,
                          color: isDarkMode
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey400,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          controller.setSearchQuery('');
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              color: isDarkMode
                  ? AppThemeData.grey900Dark
                  : AppThemeData.grey900,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Icon(
                Iconsax.info_circle,
                size: 12,
                color: isDarkMode
                    ? AppThemeData.grey500Dark
                    : AppThemeData.grey500,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: CustomText(
                  text: 'Search by: Pickup, Destination, Date, Time, or Ride ID'
                      .tr,
                  size: 11,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRideListContent(
    ScheduledRideController controller,
    bool isDarkMode,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildSkeletonLoader(isDarkMode);
      }

      if (controller.hasError.value) {
        return _buildErrorState(controller, isDarkMode);
      }

      final filteredList = controller.filteredRideList;

      if (filteredList.isEmpty) {
        return _buildEmptyState(controller, isDarkMode);
      }

      return ListView.builder(
        itemCount: filteredList.length,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: scheduledRideWidget(
              controller,
              context,
              filteredList[index],
            ),
          );
        },
      );
    });
  }

  Widget _buildSkeletonLoader(bool isDarkMode) {
    return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSkeletonCard(isDarkMode),
        );
      },
    );
  }

  Widget _buildSkeletonCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeData.grey800Dark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppThemeData.grey300Dark : AppThemeData.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppThemeData.grey300Dark
                      : AppThemeData.grey200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppThemeData.grey300Dark
                      : AppThemeData.grey200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemeData.grey300Dark
                  : AppThemeData.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 10,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemeData.grey300Dark
                  : AppThemeData.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ScheduledRideController controller, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64, color: AppThemeData.error200),
            const SizedBox(height: 16),
            CustomText(
              text: 'Error Loading Scheduled Rides'.tr,
              size: 18,
              weight: FontWeight.w600,
              color: isDarkMode
                  ? AppThemeData.grey900Dark
                  : AppThemeData.grey900,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: controller.errorMessage.value,
              size: 14,
              color: isDarkMode
                  ? AppThemeData.grey500Dark
                  : AppThemeData.grey500,
              align: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              btnName: 'Retry'.tr,
              buttonColor: AppThemeData.primary200,
              textColor: Colors.white,
              borderRadius: 12,
              ontap: () => controller.retry(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ScheduledRideController controller, bool isDarkMode) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(Get.context!).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.searchQuery.value.isNotEmpty
                    ? Iconsax.search_normal_1
                    : Iconsax.calendar_1,
                size: 64,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey400,
              ),
              const SizedBox(height: 16),
              CustomText(
                text: controller.searchQuery.value.isNotEmpty
                    ? 'No scheduled rides found'.tr
                    : controller.selectedFilter.value == 'all'
                    ? "You don't have any scheduled rides.".tr
                    : "${'No'.tr} ${_getFilterDisplayName(controller.selectedFilter.value)} ${'rides found.'.tr}",
                size: 16,
                weight: FontWeight.w600,
                color: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
              ),
              if (controller.searchQuery.value.isNotEmpty) ...[
                const SizedBox(height: 8),
                CustomText(
                  text: 'Try a different search term'.tr,
                  size: 14,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(ScheduledRideController controller, bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ScheduledRideController.filterOptions.map((filter) {
          final isSelected = controller.selectedFilter.value == filter;
          final displayName = _getFilterDisplayName(filter);
          final count = controller.getStatusCount(filter);
          final icon = _getScheduledFilterIcon(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => controller.setFilter(filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeData.primary200
                      : isDarkMode
                      ? AppThemeData.grey800
                      : AppThemeData.grey100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppThemeData.primary200
                        : isDarkMode
                        ? AppThemeData.grey300Dark
                        : AppThemeData.grey300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : isDarkMode
                          ? AppThemeData.grey400Dark
                          : AppThemeData.grey500,
                    ),
                    const SizedBox(width: 6),
                    CustomText(
                      text: displayName,
                      size: 13,
                      color: isSelected
                          ? Colors.white
                          : isDarkMode
                          ? AppThemeData.grey300Dark
                          : AppThemeData.grey800,
                      weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : isDarkMode
                              ? AppThemeData.grey300Dark
                              : AppThemeData.grey200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomText(
                          text: count.toString(),
                          size: 11,
                          color: isSelected
                              ? Colors.white
                              : isDarkMode
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey400,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getScheduledFilterIcon(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        return Iconsax.document;
      case 'pending':
        return Iconsax.clock;
      case 'new':
        return Iconsax.star;
      case 'confirmed':
        return Iconsax.tick_circle;
      case 'on ride':
        return Iconsax.car;
      case 'completed':
        return Iconsax.tick_square;
      default:
        return Iconsax.document;
    }
  }

  Widget scheduledRideWidget(
    ScheduledRideController controller,
    BuildContext context,
    RideData data,
  ) {
    final newRideController = Get.put(NewRideController());

    // Parse scheduled date and time
    String scheduledDate = '';
    String scheduledTime = '';
    if (data.rideDate != null && data.rideTime != null) {
      try {
        DateTime scheduledDateObj = DateTime.parse(data.rideDate.toString());
        List<String> timeParts = data.rideTime.toString().split(':');
        if (timeParts.length >= 2) {
          scheduledDate = DateFormat('MMM dd, yyyy').format(scheduledDateObj);
          scheduledTime = DateFormat(
            'hh:mm a',
          ).format(DateFormat('HH:mm:ss').parse(data.rideTime.toString()));
        }
      } catch (e) {
        scheduledDate = data.rideDate?.toString() ?? 'n_a'.tr;
        scheduledTime = data.rideTime?.toString() ?? 'n_a'.tr;
      }
    }

    // Use the same widget from NewRideScreen but wrap it with schedule info
    return Column(
      children: [
        // Schedule Badge Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppThemeData.primary200.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppThemeData.primary200.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppThemeData.primary200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.calendar_1, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    CustomText(
                      text: 'SCHEDULED'.tr,
                      size: 11,
                      weight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (scheduledDate.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar_1,
                            size: 14,
                            color: AppThemeData.primary200,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: CustomText(
                              text: scheduledDate,
                              size: 13,
                              weight: FontWeight.w600,
                              color: AppThemeData.primary200,
                            ),
                          ),
                        ],
                      ),
                    if (scheduledTime.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.clock,
                              size: 14,
                              color: AppThemeData.primary200,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: CustomText(
                                text: scheduledTime,
                                size: 13,
                                weight: FontWeight.w600,
                                color: AppThemeData.primary200,
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
        // Use the same ride widget from NewRideScreen
        NewRideScreen.newRideWidgets(newRideController, context, data),
      ],
    );
  }
}
