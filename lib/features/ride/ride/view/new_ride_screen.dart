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
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/trip_history_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(controller, themeChange.getThem()),
          const SizedBox(height: 12),
          Expanded(
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.filteredRideList.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(Get.context!).size.height * 0.6,
                      child: Constant.emptyView(
                        Get.context!,
                        controller.selectedFilter.value == 'all'
                            ? "You don't have any ride booked.".tr
                            : "${"No".tr} ${controller.selectedFilter.value.tr} ${"rides found.".tr}",
                        controller.selectedFilter.value == 'all',
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.filteredRideList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: NewRideScreen.newRideWidgets(
                          controller,
                          context,
                          controller.filteredRideList[index],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledRidesTab(
    ScheduledRideController controller,
    DarkThemeProvider themeChange,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Filter Tabs
          _buildScheduledFilterTabs(controller, themeChange.getThem()),
          const SizedBox(height: 12),
          Expanded(
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.filteredRideList.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(Get.context!).size.height * 0.6,
                      child: Constant.emptyView(
                        Get.context!,
                        controller.selectedFilter.value == 'all'
                            ? "You don't have any scheduled rides.".tr
                            : "${'No'.tr} ${controller.selectedFilter.value.tr} ${'rides found.'.tr}",
                        controller.selectedFilter.value == 'all',
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.filteredRideList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: scheduledRideWidget(
                          controller,
                          context,
                          controller.filteredRideList[index],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(NewRideController controller, bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: NewRideController.filterOptions.map((filter) {
          final isSelected = controller.selectedFilter.value == filter;
          final displayName = _getFilterDisplayName(filter);

          final count = controller.getStatusCount(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => controller.setFilter(filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
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

  Widget _buildScheduledFilterTabs(
    ScheduledRideController controller,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ScheduledRideController.filterOptions.map((filter) {
          final isSelected = controller.selectedFilter.value == filter;
          final displayName = _getFilterDisplayName(filter);

          final count = controller.getStatusCount(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => controller.setFilter(filter),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
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
            // Compact Header with Status
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: _formatDate(data.creer.toString()),
                          size: 13,
                          weight: FontWeight.w500,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                        const SizedBox(height: 6),
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
                  ),
                  _buildModernStatusBadge(data.statut ?? ''),
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

            // Compact Distance and Price Section - Clean Design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Distance
                  Expanded(
                    child: _buildCompactInfoItem(
                      icon: Iconsax.routing,
                      label: 'Distance'.tr,
                      value:
                          "${double.parse(data.distance.toString()).toStringAsFixed(int.parse(Constant.decimal!))} ${data.distanceUnit ?? 'KM'.tr}",
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: isDark
                        ? AppThemeData.grey300Dark.withValues(alpha: 0.2)
                        : AppThemeData.grey300.withValues(alpha: 0.3),
                  ),
                  // Price
                  Expanded(
                    child: _buildCompactInfoItem(
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
                      btnName: 'Add Complaint'.tr,
                      isOutlined: true,
                      outlineColor: AppThemeData.primary200,
                      textColor: AppThemeData.primary200,
                      borderRadius: 12,
                      ontap: () async {
                        Get.to(
                          AddComplaintScreen(),
                          arguments: {"data": data, "ride_type": "ride"},
                        )!.then((value) {
                          controller.getNewRide();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Pay Now / Paid Button
                    CustomButton(
                      btnName: data.statutPaiement == "yes"
                          ? "Paid".tr
                          : "Pay Now".tr,
                      buttonColor: data.statutPaiement == "yes"
                          ? AppThemeData.info200
                          : AppThemeData.primary200,
                      textColor: Colors.white,
                      borderRadius: 12,
                      icon: Icon(
                        data.statutPaiement == "yes"
                            ? Iconsax.tick_circle
                            : Iconsax.card,
                        size: 20,
                        color: Colors.white,
                      ),
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

  // Compact Info Item Helper (Distance/Price)
  static Widget _buildCompactInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool isPrice = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isPrice
              ? AppThemeData.primary200
              : (isDark ? AppThemeData.grey400Dark : AppThemeData.grey500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: label,
                size: 11,
                weight: FontWeight.w500,
                color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey500,
              ),
              const SizedBox(height: 2),
              CustomText(
                text: value,
                size: 15,
                weight: isPrice ? FontWeight.w700 : FontWeight.w600,
                color: isPrice
                    ? AppThemeData.primary200
                    : (isDark
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900),
              ),
            ],
          ),
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
