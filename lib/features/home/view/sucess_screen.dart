import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/screens/botton_nav_bar.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/responsive.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/common/widget/StarRating.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class RideBookingSuccessScreen extends StatelessWidget {
  final String? distance;
  final String? distanceUnit;
  final String? driverName;
  final String? driverPhoto;
  final String? driverRating;
  final String? driverPhone;
  final String? driverNumberPlate;

  const RideBookingSuccessScreen({
    super.key,
    this.distance,
    this.distanceUnit,
    this.driverName,
    this.driverPhoto,
    this.driverRating,
    this.driverPhone,
    this.driverNumberPlate,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      appBar: CustomAppBar(
        title: 'booking_confirmed'.tr,
        onBackPressed: () {
          // Navigate to BottomNavBar with Rides tab (index 1)
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => BottomNavBar(initialIndex: 1)),
            (route) => false,
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: Responsive.height(5, context)),

              // Success Icon/Animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppThemeData.success50.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Iconsax.tick_circle,
                    size: 80,
                    color: AppThemeData.success300,
                  ),
                ),
              ),

              SizedBox(height: Responsive.height(3, context)),

              // Title
              CustomText(
                text: 'booking_confirmed_exclamation'.tr,
                color: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
                size: 24,
                weight: FontWeight.w600,
                align: TextAlign.center,
              ),

              SizedBox(height: Responsive.height(1.5, context)),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomText(
                  text: 'ride_successfully_booked_message'.tr,
                  align: TextAlign.center,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                  size: 14,
                  weight: FontWeight.normal,
                ),
              ),

              SizedBox(height: Responsive.height(4, context)),

              // Driver & Ride Details Card
              if (driverName != null || distance != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppThemeData.grey800 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? AppThemeData.grey300Dark
                          : AppThemeData.grey200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driver Section
                      if (driverName != null) ...[
                        Row(
                          children: [
                            // Driver Photo
                            if (driverPhoto != null &&
                                driverPhoto!.isNotEmpty &&
                                driverPhoto != 'null')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: driverPhoto!,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  placeholder: (context, url) => Container(
                                    width: 60,
                                    height: 60,
                                    color: AppThemeData.grey200,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: AppThemeData.grey200,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Iconsax.user,
                                          color: AppThemeData.grey500,
                                          size: 30,
                                        ),
                                      ),
                                ),
                              )
                            else
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppThemeData.grey200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Iconsax.user,
                                  color: AppThemeData.grey500,
                                  size: 30,
                                ),
                              ),

                            const SizedBox(width: 16),

                            // Driver Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: driverName!,
                                    size: 18,
                                    weight: FontWeight.w600,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                  ),
                                  if (driverRating != null) ...[
                                    const SizedBox(height: 6),
                                    StarRating(
                                      size: 14,
                                      rating:
                                          double.tryParse(
                                            driverRating ?? '0',
                                          ) ??
                                          0.0,
                                      color: AppThemeData.warning200,
                                    ),
                                  ],
                                  if (driverNumberPlate != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Iconsax.car,
                                          size: 14,
                                          color: isDarkMode
                                              ? AppThemeData.grey500Dark
                                              : AppThemeData.grey500,
                                        ),
                                        const SizedBox(width: 6),
                                        CustomText(
                                          text: driverNumberPlate!,
                                          size: 13,
                                          weight: FontWeight.w500,
                                          color: isDarkMode
                                              ? AppThemeData.grey500Dark
                                              : AppThemeData.grey500,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (distance != null) ...[
                          const SizedBox(height: 20),
                          Divider(
                            color: isDarkMode
                                ? AppThemeData.grey300Dark
                                : AppThemeData.grey200,
                            height: 1,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],

                      // Distance Section
                      if (distance != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppThemeData.success50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Iconsax.routing,
                                    size: 20,
                                    color: AppThemeData.success300,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CustomText(
                                  text: 'distance'.tr,
                                  size: 15,
                                  weight: FontWeight.w500,
                                  color: isDarkMode
                                      ? AppThemeData.grey900Dark
                                      : AppThemeData.grey900,
                                ),
                              ],
                            ),
                            CustomText(
                              text:
                                  '${double.parse(distance ?? '0').toStringAsFixed(2)} ${distanceUnit ?? Constant.distanceUnit}',
                              size: 15,
                              weight: FontWeight.w600,
                              color: AppThemeData.success300,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

              SizedBox(height: Responsive.height(5, context)),

              // Track Ride Button
              CustomButton(
                btnName: 'track_ride'.tr,
                textColor: Colors.white,
                fontSize: 16,
                borderRadius: 12,
                ontap: () {
                  // Navigate to BottomNavBar with Rides tab (index 1)
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => BottomNavBar(initialIndex: 1),
                    ),
                    (route) => false,
                  );
                },
              ),

              SizedBox(height: Responsive.height(2, context)),

              // Secondary Action Button
              CustomButton(
                btnName: 'back_to_home'.tr,
                isOutlined: true,
                outlineColor: isDarkMode
                    ? AppThemeData.grey300Dark
                    : AppThemeData.grey300,
                textColor: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
                fontSize: 16,
                borderRadius: 12,
                borderWidth: 1.5,
                ontap: () {
                  // Navigate to BottomNavBar with Home tab (index 0)
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => BottomNavBar(initialIndex: 0),
                    ),
                    (route) => false,
                  );
                },
              ),

              SizedBox(height: Responsive.height(3, context)),
            ],
          ),
        ),
      ),
    );
  }
}
