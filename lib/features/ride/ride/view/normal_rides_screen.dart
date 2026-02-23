import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/controller/new_ride_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/controller/scheduled_ride_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/complaint/view/add_complaint_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/payment_selection_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/ride_details.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NewRideScreen extends StatefulWidget {
  final bool showBackButton;

  const NewRideScreen({super.key, this.showBackButton = true});

  @override
  State<NewRideScreen> createState() => _NewRideScreenState();

  // Public static method to access newRideWidgets from other files
  static Widget newRideWidgets(
    NewRideController controller,
    BuildContext context,
    RideData data,
  ) {
    return _NewRideScreenState.newRideWidgets(controller, context, data);
  }
}

class _NewRideScreenState extends State<NewRideScreen>
    with SingleTickerProviderStateMixin {
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

  late TabController _tabController;
  final normalRidesController = Get.put(NewRideController());
  final scheduledRidesController = Get.put(ScheduledRideController());

  // Search controllers
  final TextEditingController _normalSearchController = TextEditingController();
  final TextEditingController _scheduledSearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _normalSearchController.dispose();
    _scheduledSearchController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    if (_tabController.index == 0) {
      normalRidesController.getNewRide();
    } else {
      scheduledRidesController.getScheduledRides();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    return WillPopScope(
      onWillPop: () async {
        if (widget.showBackButton) Get.back();
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppThemeData.surface50Dark
            : AppThemeData.surface50,
        appBar: CustomAppBar(
          title: 'All Rides'.tr,
          showBackButton: widget.showBackButton,
          onBackPressed: widget.showBackButton ? () => Get.back() : null,
          actions: [
            IconButton(
              icon: const Icon(Iconsax.refresh, color: Colors.white, size: 22),
              onPressed: _handleRefresh,
              tooltip: 'Refresh'.tr,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 1.0,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
            tabs: [
              Tab(text: 'Normal'.tr),
              Tab(text: 'Scheduled'.tr),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Normal Rides Tab
            _buildNormalRidesTab(normalRidesController, themeChange),
            // Scheduled Rides Tab
            _buildScheduledRidesTab(scheduledRidesController, themeChange),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalRidesTab(
    NewRideController controller,
    DarkThemeProvider themeChange,
  ) {
    final isDark = themeChange.getThem();
    return RefreshIndicator(
      onRefresh: () => controller.getNewRide(forceRefresh: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(controller, isDark),
            const SizedBox(height: 12),
            // Filter Tabs
            _buildFilterTabs(controller, isDark),
            Expanded(child: _buildRideListContent(controller, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(NewRideController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey800Dark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemeData.grey300Dark : AppThemeData.grey200,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _normalSearchController,
            onChanged: (value) {
              controller.setSearchQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'Search by location, driver, or ride ID...'.tr,
              hintStyle: TextStyle(
                color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey400,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
              prefixIcon: Icon(
                Iconsax.search_normal,
                color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey400,
                size: 20,
              ),
              suffixIcon: Obx(
                () => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Iconsax.close_circle,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey400,
                          size: 20,
                        ),
                        onPressed: () {
                          _normalSearchController.clear();
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
              color: isDark ? AppThemeData.grey900Dark : AppThemeData.grey900,
              fontSize: 14,
              fontFamily: 'Cairo',
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
                color: isDark ? AppThemeData.grey500Dark : AppThemeData.grey500,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: CustomText(
                  text:
                      'Search by: Pickup, Destination, Driver Name, or Ride ID'
                          .tr,
                  size: 11,
                  color: isDark
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

  Widget _buildRideListContent(NewRideController controller, bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildSkeletonLoader(isDark);
      }

      if (controller.hasError.value) {
        return _buildErrorState(controller, isDark);
      }

      final filteredList = controller.filteredRideList;

      if (filteredList.isEmpty) {
        return _buildEmptyState(controller, isDark);
      }

      return ListView.builder(
        itemCount: filteredList.length,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: NewRideScreen.newRideWidgets(
              controller,
              context,
              filteredList[index],
            ),
          );
        },
      );
    });
  }

  Widget _buildSkeletonLoader(bool isDark) {
    return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSkeletonCard(isDark),
        );
      },
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey800Dark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemeData.grey300Dark : AppThemeData.grey200,
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
                  color: isDark
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
                  color: isDark
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
              color: isDark ? AppThemeData.grey300Dark : AppThemeData.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 10,
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.grey300Dark : AppThemeData.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(NewRideController controller, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64, color: AppThemeData.error200),
            const SizedBox(height: 16),
            CustomText(
              text: 'Error Loading Rides'.tr,
              size: 18,
              weight: FontWeight.w600,
              color: isDark ? AppThemeData.grey900Dark : AppThemeData.grey900,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: controller.errorMessage.value,
              size: 14,
              color: isDark ? AppThemeData.grey500Dark : AppThemeData.grey500,
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

  Widget _buildEmptyState(NewRideController controller, bool isDark) {
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
                    : Iconsax.car,
                size: 64,
                color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey400,
              ),
              const SizedBox(height: 16),
              CustomText(
                text: controller.searchQuery.value.isNotEmpty
                    ? 'No rides found'.tr
                    : controller.selectedFilter.value == 'all'
                    ? "You don't have any ride booked.".tr
                    : "${"No".tr} ${controller.selectedFilter.value.tr} ${"rides found.".tr}",
                size: 16,
                weight: FontWeight.w600,
                color: isDark ? AppThemeData.grey900Dark : AppThemeData.grey900,
              ),
              if (controller.searchQuery.value.isNotEmpty) ...[
                const SizedBox(height: 8),
                CustomText(
                  text: 'Try a different search term'.tr,
                  size: 14,
                  color: isDark
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

  Widget _buildScheduledRidesTab(
    ScheduledRideController controller,
    DarkThemeProvider themeChange,
  ) {
    final isDark = themeChange.getThem();
    return RefreshIndicator(
      onRefresh: () => controller.getScheduledRides(forceRefresh: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            // Search Bar
            _buildScheduledSearchBar(controller, isDark),
            const SizedBox(height: 12),
            // Filter Tabs
            _buildScheduledFilterTabs(controller, isDark),
            const SizedBox(height: 12),
            Expanded(child: _buildScheduledRideListContent(controller, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledSearchBar(
    ScheduledRideController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey800Dark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppThemeData.grey300Dark : AppThemeData.grey200,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _scheduledSearchController,
            onChanged: (value) {
              controller.setSearchQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'Search by location, date, time, or ride ID...'.tr,
              hintStyle: TextStyle(
                color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey400,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
              prefixIcon: Icon(
                Iconsax.search_normal,
                color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey400,
                size: 20,
              ),
              suffixIcon: Obx(
                () => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Iconsax.close_circle,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey400,
                          size: 20,
                        ),
                        onPressed: () {
                          _scheduledSearchController.clear();
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
              color: isDark ? AppThemeData.grey900Dark : AppThemeData.grey900,
              fontSize: 14,
              fontFamily: 'Cairo',
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
                color: isDark ? AppThemeData.grey500Dark : AppThemeData.grey500,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: CustomText(
                  text: 'Search by: Pickup, Destination, Date, Time, or Ride ID'
                      .tr,
                  size: 11,
                  color: isDark
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

  Widget _buildScheduledRideListContent(
    ScheduledRideController controller,
    bool isDark,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildSkeletonLoader(isDark);
      }

      if (controller.hasError.value) {
        return _buildScheduledErrorState(controller, isDark);
      }

      final filteredList = controller.filteredRideList;

      if (filteredList.isEmpty) {
        return _buildScheduledEmptyState(controller, isDark);
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

  Widget _buildScheduledErrorState(
    ScheduledRideController controller,
    bool isDark,
  ) {
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
              color: isDark ? AppThemeData.grey900Dark : AppThemeData.grey900,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: controller.errorMessage.value,
              size: 14,
              color: isDark ? AppThemeData.grey500Dark : AppThemeData.grey500,
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

  Widget _buildScheduledEmptyState(
    ScheduledRideController controller,
    bool isDark,
  ) {
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
                color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey400,
              ),
              const SizedBox(height: 16),
              CustomText(
                text: controller.searchQuery.value.isNotEmpty
                    ? 'No scheduled rides found'.tr
                    : controller.selectedFilter.value == 'all'
                    ? "You don't have any scheduled rides.".tr
                    : "${'No'.tr} ${controller.selectedFilter.value.tr} ${'rides found.'.tr}",
                size: 16,
                weight: FontWeight.w600,
                color: isDark ? AppThemeData.grey900Dark : AppThemeData.grey900,
              ),
              if (controller.searchQuery.value.isNotEmpty) ...[
                const SizedBox(height: 8),
                CustomText(
                  text: 'Try a different search term'.tr,
                  size: 14,
                  color: isDark
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

  Widget _buildFilterTabs(NewRideController controller, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 4),
            ...NewRideController.filterOptions.map((filter) {
              final isSelected = controller.selectedFilter.value == filter;
              final displayName = _getFilterDisplayName(filter);
              final count = controller.getStatusCount(filter);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.setFilter(filter),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppThemeData.primary200
                            : isDarkMode
                            ? AppThemeData.grey800Dark.withValues(alpha: 0.5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppThemeData.primary200
                              : isDarkMode
                              ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                              : AppThemeData.grey200,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppThemeData.primary200.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            text: displayName,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : isDarkMode
                                ? AppThemeData.grey300Dark
                                : AppThemeData.grey800,
                            weight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : isDarkMode
                                    ? AppThemeData.grey300Dark.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppThemeData.grey100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomText(
                                text: count.toString(),
                                size: 12,
                                color: isSelected
                                    ? Colors.white
                                    : isDarkMode
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey500,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledFilterTabs(
    ScheduledRideController controller,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 4),
            ...ScheduledRideController.filterOptions.map((filter) {
              final isSelected = controller.selectedFilter.value == filter;
              final displayName = _getFilterDisplayName(filter);
              final count = controller.getStatusCount(filter);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.setFilter(filter),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppThemeData.primary200
                            : isDarkMode
                            ? AppThemeData.grey800Dark.withValues(alpha: 0.5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppThemeData.primary200
                              : isDarkMode
                              ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                              : AppThemeData.grey200,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppThemeData.primary200.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            text: displayName,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : isDarkMode
                                ? AppThemeData.grey300Dark
                                : AppThemeData.grey800,
                            weight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : isDarkMode
                                    ? AppThemeData.grey300Dark.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppThemeData.grey100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomText(
                                text: count.toString(),
                                size: 12,
                                color: isSelected
                                    ? Colors.white
                                    : isDarkMode
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey500,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  static Widget newRideWidgets(
    NewRideController controller,
    BuildContext context,
    RideData data,
  ) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    return InkWell(
      onTap: () async {
        await Get.to(TripHistoryScreen(), arguments: data)?.then((v) {
          controller.getNewRide();
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: LightBorderedCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header with Status and Driver Info
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.grey800Dark.withValues(alpha: 0.3)
                    : AppThemeData.grey100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.calendar,
                                  size: 14,
                                  color: isDark
                                      ? AppThemeData.grey400Dark
                                      : AppThemeData.grey500,
                                ),
                                const SizedBox(width: 6),
                                CustomText(
                                  text: _formatDate(data.creer.toString()),
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: isDark
                                      ? AppThemeData.grey400Dark
                                      : AppThemeData.grey500,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.hashtag,
                                  size: 16,
                                  color: isDark
                                      ? AppThemeData.grey500Dark
                                      : AppThemeData.grey500,
                                ),
                                const SizedBox(width: 6),
                                CustomText(
                                  text: '${'Trip #'.tr}${data.id ?? ''}',
                                  size: 16,
                                  weight: FontWeight.w700,
                                  color: isDark
                                      ? AppThemeData.grey900Dark
                                      : AppThemeData.grey900,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModernStatusBadge(data.statut ?? ''),
                          const SizedBox(width: 8),
                          Icon(
                            Iconsax.arrow_right_3,
                            size: 18,
                            color: isDark
                                ? AppThemeData.grey400Dark
                                : AppThemeData.grey500,
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Driver Info (if available)
                  if (data.prenomConducteur != null &&
                      data.prenomConducteur != 'null' &&
                      data.prenomConducteur!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Iconsax.user,
                          size: 14,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: CustomText(
                            text:
                                '${data.prenomConducteur ?? ''} ${data.nomConducteur ?? ''}',
                            size: 13,
                            weight: FontWeight.w500,
                            color: isDark
                                ? AppThemeData.grey500Dark
                                : AppThemeData.grey500,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AppThemeData.grey200Dark.withValues(alpha: 0.3)
                  : AppThemeData.grey200.withValues(alpha: 0.5),
            ),

            const SizedBox(height: 16),

            // Locations Section - Cleaner Design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Pickup Location
                  _buildMinimalLocationRow(
                    icon: Iconsax.location,
                    iconColor: AppThemeData.success300,
                    address: data.departName.toString(),
                    isDark: isDark,
                    isFirst: true,
                    onTap: () async {
                      final availableMaps = await MapLauncher.installedMaps;
                      await availableMaps.first.showMarker(
                        coords: Coords(
                          double.parse(data.latitudeDepart.toString()),
                          double.parse(data.longitudeDepart.toString()),
                        ),
                        title: data.departName.toString(),
                      );
                    },
                  ),
                  // Stops
                  ...data.stops!.asMap().entries.map((entry) {
                    int index = entry.key;
                    return _buildMinimalLocationRow(
                      icon: Iconsax.location,
                      iconColor: AppThemeData.primary200,
                      address: entry.value.location.toString(),
                      isDark: isDark,
                      stopLabel: '${'Stop '.tr}${index + 1}',
                    );
                  }),
                  // Dropoff Location
                  _buildMinimalLocationRow(
                    icon: Iconsax.location5,
                    iconColor: AppThemeData.warning200,
                    address: data.destinationName.toString(),
                    isDark: isDark,
                    isLast: true,
                    onTap: () async {
                      final availableMaps = await MapLauncher.installedMaps;
                      await availableMaps.first.showMarker(
                        coords: Coords(
                          double.parse(data.latitudeArrivee.toString()),
                          double.parse(data.longitudeArrivee.toString()),
                        ),
                        title: data.destinationName.toString(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // OTP Section (if applicable)
            if (data.statut == "confirmed" &&
                Constant.rideOtp.toString().toLowerCase() ==
                    'yes'.toLowerCase() &&
                data.rideType != 'driver')
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeData.primary200.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppThemeData.primary200.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.lock,
                        size: 16,
                        color: AppThemeData.primary200,
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        text: 'OTP: '.tr,
                        size: 13,
                        weight: FontWeight.w500,
                        color: AppThemeData.primary200,
                      ),
                      CustomText(
                        text: data.otp.toString(),
                        size: 15,
                        weight: FontWeight.w700,
                        color: AppThemeData.primary200,
                        letterSpacing: 1.5,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Enhanced Distance, Duration and Price Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.grey800Dark.withValues(alpha: 0.3)
                    : AppThemeData.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppThemeData.grey300Dark.withValues(alpha: 0.2)
                      : AppThemeData.grey200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Distance
                  Expanded(
                    child: _buildEnhancedInfoItem(
                      icon: Iconsax.routing_2,
                      label: 'Distance'.tr,
                      value:
                          "${double.parse(data.distance.toString()).toStringAsFixed(int.parse(Constant.decimal!))} ${data.distanceUnit ?? 'KM'.tr}",
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: isDark
                        ? AppThemeData.grey300Dark.withValues(alpha: 0.2)
                        : AppThemeData.grey300.withValues(alpha: 0.3),
                  ),
                  // Duration (if available)
                  if (data.duree != null &&
                      data.duree != 'null' &&
                      data.duree!.isNotEmpty)
                    Expanded(
                      child: _buildEnhancedInfoItem(
                        icon: Iconsax.clock,
                        label: 'Duration'.tr,
                        value: data.duree.toString(),
                        isDark: isDark,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (data.duree != null &&
                      data.duree != 'null' &&
                      data.duree!.isNotEmpty) ...[
                    Container(
                      width: 1,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: isDark
                          ? AppThemeData.grey300Dark.withValues(alpha: 0.2)
                          : AppThemeData.grey300.withValues(alpha: 0.3),
                    ),
                  ],
                  // Price
                  Expanded(
                    child: _buildEnhancedInfoItem(
                      icon: Iconsax.wallet_3,
                      label: 'Price'.tr,
                      value: Constant().amountShow(
                        amount: data.montant.toString(),
                      ),
                      isDark: isDark,
                      isPrice: true,
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            if (data.statut == "completed") ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Add Complaint Button
                    CustomButton(
                      ontap: () async {
                        Get.to(
                          AddComplaintScreen(),
                          arguments: {"data": data, "ride_type": "ride"},
                        )!.then((value) {
                          controller.getNewRide();
                        });
                      },
                      btnName: 'Add Complaint'.tr,
                      textColor: Colors.white,
                      buttonColor: AppThemeData.primary200,
                    ),
                    const SizedBox(height: 12),

                    // Pay Now / Paid Button
                    CustomButton(
                      ontap: () async {
                        if (data.statutPaiement == "yes") {
                          controller.getNewRide();
                        } else {
                          Get.to(
                            PaymentSelectionScreen(),
                            arguments: {"rideData": data},
                          );
                        }
                      },
                      btnName: data.statutPaiement == "yes"
                          ? "Paid".tr
                          : "Pay Now".tr,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Format Date Helper
  static String _formatDate(String dateString) {
    try {
      return DateFormat(
        'MMM dd, yyyy • hh:mm a',
      ).format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  // Modern Status Badge
  static Widget _buildModernStatusBadge(String status) {
    Color bgColor;
    Color txtColor;
    String title;

    switch (status.toLowerCase()) {
      case "new":
        bgColor = AppThemeData.primary200;
        txtColor = Colors.white;
        title = 'new'.tr;
        break;
      case "on ride":
        bgColor = AppThemeData.primary200;
        txtColor = Colors.white;
        title = 'active'.tr;
        break;
      case "confirmed":
        bgColor = AppThemeData.info200;
        txtColor = Colors.white;
        title = 'confirmed'.tr;
        break;
      case "completed":
        bgColor = AppThemeData.success300;
        txtColor = Colors.white;
        title = 'completed'.tr;
        break;
      case "pending":
        bgColor = AppThemeData.warning200;
        txtColor = Colors.white;
        title = 'pending'.tr;
        break;
      default:
        bgColor = AppThemeData.error200;
        txtColor = Colors.white;
        title = status.capitalizeFirst ?? status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomText(
        text: title,
        size: 11,
        weight: FontWeight.w700,
        color: txtColor,
        letterSpacing: 0.5,
      ),
    );
  }

  // Enhanced Info Item Helper (Better visual design)
  static Widget _buildEnhancedInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool isPrice = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrice
                  ? AppThemeData.primary200
                  : (isDark ? AppThemeData.grey400Dark : AppThemeData.grey500),
            ),
            const SizedBox(width: 6),
            CustomText(
              text: label,
              size: 11,
              weight: FontWeight.w500,
              color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey500,
            ),
          ],
        ),
        const SizedBox(height: 6),
        CustomText(
          text: value,
          size: 15,
          weight: isPrice ? FontWeight.w700 : FontWeight.w600,
          color: isPrice
              ? AppThemeData.primary200
              : (isDark ? AppThemeData.grey900Dark : AppThemeData.grey900),
        ),
      ],
    );
  }

  // Minimal Location Row Helper
  static Widget _buildMinimalLocationRow({
    required IconData icon,
    required Color iconColor,
    required String address,
    required bool isDark,
    bool isFirst = false,
    bool isLast = false,
    String? stopLabel,
    VoidCallback? onTap,
  }) {
    Widget locationWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon with connecting line
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 8,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                      : AppThemeData.grey300.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                      : AppThemeData.grey300.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stopLabel != null) ...[
                CustomText(
                  text: stopLabel,
                  size: 10,
                  weight: FontWeight.w600,
                  color: isDark
                      ? AppThemeData.grey400Dark
                      : AppThemeData.grey500,
                  letterSpacing: 0.5,
                ),
                const SizedBox(height: 2),
              ],
              CustomText(
                text: address,
                size: 14,
                weight: FontWeight.w500,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                color: isDark ? AppThemeData.grey900Dark : AppThemeData.grey900,
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: locationWidget,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: locationWidget,
    );
  }

  Widget statusTile({required String title, Color? bgColor, Color? txtColor}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: bgColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: CustomText(
        text: title.tr,
        size: 12,
        weight: FontWeight.w600,
        color: txtColor ?? Colors.white,
      ),
    );
  }

  Widget scheduledRideWidget(
    ScheduledRideController controller,
    BuildContext context,
    RideData data,
  ) {
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
        // Use the same ride widget
        NewRideScreen.newRideWidgets(
          Get.find<NewRideController>(),
          context,
          data,
        ),
      ],
    );
  }
}
