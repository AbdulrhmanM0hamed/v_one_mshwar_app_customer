import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/common/widget/StarRating.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DriverInfoBottomSheet extends StatelessWidget {
  final RideData rideData;
  final String? driverStatus; // 'online', 'en-route', 'arrived', 'offline'
  final bool isDarkMode;

  const DriverInfoBottomSheet({
    super.key,
    required this.rideData,
    this.driverStatus,
    required this.isDarkMode,
  });

  Color _getStatusColor() {
    switch (driverStatus?.toLowerCase()) {
      case 'online':
        return AppThemeData.success300;
      case 'en-route':
        return AppThemeData.secondary200;
      case 'arrived':
        return AppThemeData.warning200;
      case 'offline':
        return AppThemeData.grey400;
      default:
        return AppThemeData.success300;
    }
  }

  String _getStatusText() {
    switch (driverStatus?.toLowerCase()) {
      case 'online':
        return 'Online'.tr;
      case 'en-route':
        return 'En Route'.tr;
      case 'arrived':
        return 'Arrived'.tr;
      case 'offline':
        return 'Offline'.tr;
      default:
        return 'Online'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showDriverInfo = Constant.showDriverInfoBeforePayment == "yes";

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeData.surface50Dark : AppThemeData.surface50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemeData.grey400Dark
                  : AppThemeData.grey400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Driver Photo
                if (showDriverInfo) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child:
                        (rideData.photoPath != null &&
                            rideData.photoPath!.isNotEmpty &&
                            rideData.photoPath != 'null')
                        ? CachedNetworkImage(
                            imageUrl: rideData.photoPath!,
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/icons/appLogo.png",
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            ),
                          )
                        : Image.asset(
                            "assets/icons/appLogo.png",
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                          ),
                  ),
                  const SizedBox(height: 12),
                  // Driver Name and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            CustomText(
                              text:
                                  '${rideData.prenomConducteur ?? ''} ${rideData.nomConducteur ?? ''}',
                              size: 20,
                              weight: FontWeight.w600,
                              align: TextAlign.center,
                              color: isDarkMode
                                  ? AppThemeData.grey900Dark
                                  : AppThemeData.grey900,
                            ),
                            const SizedBox(height: 4),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  CustomText(
                                    text: _getStatusText(),
                                    size: 12,
                                    weight: FontWeight.w500,
                                    color: _getStatusColor(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  StarRating(
                    size: 20,
                    rating:
                        rideData.moyenne != "null" &&
                            rideData.moyenne != null &&
                            rideData.moyenne!.isNotEmpty
                        ? double.parse(rideData.moyenne.toString())
                        : 0.0,
                    color: AppThemeData.warning200,
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode
                          ? AppThemeData.grey200Dark
                          : AppThemeData.grey200,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: isDarkMode
                          ? AppThemeData.grey400Dark
                          : AppThemeData.grey400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomText(
                    text: 'Driver information will be shown after payment'.tr,
                    align: TextAlign.center,
                    size: 14,
                    weight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode
                        ? AppThemeData.grey500Dark
                        : AppThemeData.grey500,
                  ),
                ],
                // Driver Contact and Car Details
                if (showDriverInfo) ...[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: isDarkMode
                            ? AppThemeData.grey300Dark
                            : AppThemeData.grey300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Phone Number
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.call,
                                    size: 20,
                                    color: AppThemeData.secondary200,
                                  ),
                                  const SizedBox(width: 10),
                                  CustomText(
                                    text: "Driver's Contact".tr,
                                    size: 16,
                                    weight: FontWeight.normal,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  CustomText(
                                    text: rideData.driverPhone ?? '',
                                    size: 16,
                                    weight: FontWeight.w500,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      Constant.makePhoneCall(
                                        rideData.driverPhone ?? '',
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppThemeData.secondary200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Iconsax.call,
                                        size: 16,
                                        color: AppThemeData.surface50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Container(
                          color: isDarkMode
                              ? AppThemeData.grey300Dark
                              : AppThemeData.grey300,
                          height: 1,
                        ),
                        // Car Details
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.car,
                                    size: 20,
                                    color: AppThemeData.secondary200,
                                  ),
                                  const SizedBox(width: 10),
                                  CustomText(
                                    text: "Car Details".tr,
                                    size: 16,
                                    weight: FontWeight.normal,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                  ),
                                ],
                              ),
                              CustomText(
                                text:
                                    "${rideData.brand ?? ''} ${rideData.model ?? ''}",
                                size: 16,
                                weight: FontWeight.w500,
                                color: isDarkMode
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                              ),
                            ],
                          ),
                        ),
                        // Divider
                        Container(
                          color: isDarkMode
                              ? AppThemeData.grey300Dark
                              : AppThemeData.grey300,
                          height: 1,
                        ),
                        // License Plate
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: "License Plate".tr,
                                size: 16,
                                weight: FontWeight.normal,
                                color: isDarkMode
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                              ),
                              CustomText(
                                text: rideData.numberplate ?? '',
                                size: 16,
                                weight: FontWeight.w600,
                                color: AppThemeData.secondary200,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeData.secondary200,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: CustomText(
                      text: "Close".tr,
                      size: 16,
                      weight: FontWeight.w600,
                      color: AppThemeData.surface50,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
