import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/controller/package_controller.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/model/package_model.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/view/purchase_package_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class PackageListScreen extends StatelessWidget {
  final bool showBackButton;

  const PackageListScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.put(PackageController());
    final isDark = themeChange.getThem();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark
            ? AppThemeData.surface50Dark
            : AppThemeData.surface50,
        appBar: CustomAppBar(
          title: 'Packages'.tr,
          showBackButton: showBackButton,
          actions: [
            IconButton(
              icon: const Icon(Iconsax.refresh, color: Colors.white),
              onPressed: () {
                controller.fetchAvailablePackages();
                controller.fetchUserPackages();
              },
            ),
          ],
          bottom: TabBar(
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
              Tab(text: 'Buy Packages'.tr),
              Tab(text: 'My Packages'.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Available Packages Tab
            _buildAvailablePackagesTab(controller, themeChange),
            // My Packages Tab
            _buildMyPackagesTab(controller, themeChange),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailablePackagesTab(
    PackageController controller,
    DarkThemeProvider themeChange,
  ) {
    return Obx(() {
      if (controller.isPackagesLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.availablePackages.isEmpty) {
        return _buildEmptyState(
          'No Packages Available'.tr,
          'There are no KM packages available for purchase at the moment.'.tr,
          Iconsax.box_1,
          themeChange,
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchAvailablePackages(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.availablePackages.length,
          itemBuilder: (context, index) {
            final package = controller.availablePackages[index];
            return _buildPackageCard(package, themeChange, controller);
          },
        ),
      );
    });
  }

  Widget _buildPackageCard(
    PackageData package,
    DarkThemeProvider themeChange,
    PackageController controller,
  ) {
    final isDark = themeChange.getThem();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppThemeData.grey800 : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.to(() => PurchasePackageScreen(package: package)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: package.name ?? 'Package'.tr,
                          size: 18,
                          weight: FontWeight.bold,
                          color: isDark ? Colors.white : AppThemeData.grey900,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: package.pricePerKmDisplay,
                          size: 13,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeData.primary200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: package.formattedKm,
                      size: 14,
                      weight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              if (package.description != null &&
                  package.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                CustomText(
                  text: package.description!,
                  size: 13,
                  color: isDark
                      ? AppThemeData.grey400Dark
                      : AppThemeData.grey500,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: isDark ? AppThemeData.grey300Dark : AppThemeData.grey200,
              ),
              const SizedBox(height: 16),

              // Price display
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Total Price'.tr,
                    size: 12,
                    color: isDark
                        ? AppThemeData.grey400Dark
                        : AppThemeData.grey500,
                  ),
                  CustomText(
                    text: package.formattedPrice,
                    size: 22,
                    weight: FontWeight.bold,
                    color: AppThemeData.primary200,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Buy button
              CustomButton(
                btnName: 'Buy Now'.tr,
                textColor: Colors.white,
                ontap: () =>
                    Get.to(() => PurchasePackageScreen(package: package)),
                borderRadius: 12,
                buttonColor: AppThemeData.primary200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyPackagesTab(
    PackageController controller,
    DarkThemeProvider themeChange,
  ) {
    return Obx(() {
      if (controller.isUserPackagesLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.userPackages.isEmpty) {
        return _buildEmptyState(
          'No Packages Purchased'.tr,
          'You haven\'t purchased any KM packages yet. Buy one to save on your rides!'
              .tr,
          Iconsax.shopping_bag,
          themeChange,
        );
      }

      return Builder(
        builder: (context) => RefreshIndicator(
          onRefresh: () => controller.fetchUserPackages(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                controller.userPackages.length +
                1, // +1 for the "Buy More" card
            itemBuilder: (ctx, index) {
              // First item: Buy More card
              if (index == 0) {
                return _buildBuyMoreCard(themeChange, context);
              }
              final userPackage = controller.userPackages[index - 1];
              return _buildUserPackageCard(
                userPackage,
                themeChange,
                controller,
                context,
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildBuyMoreCard(
    DarkThemeProvider themeChange,
    BuildContext context,
  ) {
    final isDark = themeChange.getThem();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppThemeData.primary200.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppThemeData.primary200.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () => DefaultTabController.of(context).animateTo(0),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemeData.primary200.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.add_circle,
                  color: AppThemeData.primary200,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Buy More Packages'.tr,
                      size: 16,
                      weight: FontWeight.bold,
                      color: AppThemeData.primary200,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: 'You can buy the same package multiple times!'.tr,
                      size: 12,
                      color: isDark
                          ? AppThemeData.grey400Dark
                          : AppThemeData.grey500,
                    ),
                  ],
                ),
              ),
              Icon(Iconsax.arrow_right_3, color: AppThemeData.primary200),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserPackageCard(
    UserPackageData userPackage,
    DarkThemeProvider themeChange,
    PackageController controller,
    BuildContext context,
  ) {
    final isDark = themeChange.getThem();
    final isActive = userPackage.isActive;
    final isConsumed =
        userPackage.isConsumed ?? userPackage.status == 'consumed';

    Color statusColor = Colors.green;
    if (isConsumed) {
      statusColor = Colors.blue;
    } else if (!isActive) {
      statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppThemeData.grey800 : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    text: userPackage.packageName ?? 'Package'.tr,
                    size: 18,
                    weight: FontWeight.bold,
                    color: isDark ? Colors.white : AppThemeData.grey900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomText(
                    text: userPackage.statusDisplay.tr,
                    size: 12,
                    weight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // KM Stats Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                    : AppThemeData.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Available KM
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.speedometer,
                          size: 24,
                          color: AppThemeData.success300,
                        ),
                        const SizedBox(height: 6),
                        CustomText(
                          text: userPackage.remainingKm ?? '0',
                          size: 20,
                          weight: FontWeight.bold,
                          color: AppThemeData.success300,
                        ),
                        CustomText(
                          text: 'Available KM'.tr,
                          size: 11,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    height: 50,
                    width: 1,
                    color: isDark
                        ? AppThemeData.grey300Dark
                        : AppThemeData.grey300,
                  ),
                  // Used KM
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.chart,
                          size: 24,
                          color: AppThemeData.error200,
                        ),
                        const SizedBox(height: 6),
                        CustomText(
                          text: userPackage.usedKm ?? '0',
                          size: 20,
                          weight: FontWeight.bold,
                          color: AppThemeData.error200,
                        ),
                        CustomText(
                          text: 'Used KM'.tr,
                          size: 11,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    height: 50,
                    width: 1,
                    color: isDark
                        ? AppThemeData.grey300Dark
                        : AppThemeData.grey300,
                  ),
                  // Total KM
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.box_1,
                          size: 24,
                          color: AppThemeData.primary200,
                        ),
                        const SizedBox(height: 6),
                        CustomText(
                          text: userPackage.totalKm ?? '0',
                          size: 20,
                          weight: FontWeight.bold,
                          color: isDark ? Colors.white : AppThemeData.grey900,
                        ),
                        CustomText(
                          text: 'Total KM'.tr,
                          size: 11,
                          color: isDark
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: userPackage.remainingProgress,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? AppThemeData.grey300Dark
                        : AppThemeData.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppThemeData.success300,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text:
                          '${((userPackage.remainingProgress) * 100).toStringAsFixed(0)}${'% remaining'.tr}',
                      size: 11,
                      color: AppThemeData.success300,
                      weight: FontWeight.w500,
                    ),
                    CustomText(
                      text:
                          '${((userPackage.usageProgress) * 100).toStringAsFixed(0)}${'% used'.tr}',
                      size: 11,
                      color: isDark
                          ? AppThemeData.grey400Dark
                          : AppThemeData.grey500,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Details - show purchase date
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDetailChip(
                  Iconsax.calendar,
                  '${'Purchased: '.tr}${userPackage.purchasedAt ?? 'N/A'}',
                  themeChange,
                ),
              ],
            ),

            // Buy Again button for consumed packages
            if (isConsumed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Find the matching package and navigate to purchase
                    final matchingPackage = controller.availablePackages
                        .firstWhereOrNull((p) => p.id == userPackage.packageId);
                    if (matchingPackage != null) {
                      Get.to(
                        () => PurchasePackageScreen(package: matchingPackage),
                      );
                    } else {
                      // Go to Buy Packages tab
                      DefaultTabController.of(context).animateTo(0);
                    }
                  },
                  icon: Icon(Iconsax.refresh, size: 18),
                  label: Text('Buy Again'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeData.primary200,
                    side: BorderSide(color: AppThemeData.primary200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    IconData icon,
    String text,
    DarkThemeProvider themeChange, {
    bool isWarning = false,
    bool isSuccess = false,
  }) {
    final isDark = themeChange.getThem();

    Color chipColor;
    if (isWarning) {
      chipColor = Colors.orange;
    } else if (isSuccess) {
      chipColor = AppThemeData.success300;
    } else {
      chipColor = isDark ? AppThemeData.grey400Dark : AppThemeData.grey500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.orange.withValues(alpha: 0.1)
            : isSuccess
            ? AppThemeData.success300.withValues(alpha: 0.1)
            : (isDark ? AppThemeData.grey300Dark : AppThemeData.grey100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          CustomText(text: text, size: 12, color: chipColor),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    DarkThemeProvider themeChange,
  ) {
    final isDark = themeChange.getThem();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey300,
            ),
            const SizedBox(height: 16),
            CustomText(
              text: title,
              size: 20,
              weight: FontWeight.bold,
              color: isDark ? AppThemeData.grey400Dark : AppThemeData.grey500,
              align: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: subtitle,
              size: 14,
              color: isDark ? AppThemeData.grey500Dark : AppThemeData.grey500,
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
