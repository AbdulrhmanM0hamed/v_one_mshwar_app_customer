import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/common/widget/StarRating.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/driver_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DriverDetailsCard extends StatelessWidget {
  final DriverData driverModel;
  final String duration;
  final String tripPrice;
  final bool isDarkMode;

  const DriverDetailsCard({
    super.key,
    required this.driverModel,
    required this.duration,
    required this.tripPrice,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Check if driver info should be hidden before payment
    final bool showDriverInfo = Constant.showDriverInfoBeforePayment == "yes";

    return Column(
      children: [
        // Hide driver photo and name if admin toggle is disabled
        if (showDriverInfo) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child:
                (driverModel.photo != null &&
                    driverModel.photo.toString().isNotEmpty &&
                    driverModel.photo.toString() != 'null')
                ? CachedNetworkImage(
                    imageUrl: driverModel.photo.toString(),
                    fit: BoxFit.cover,
                    height: 110,
                    width: 110,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/icons/appLogo.png",
                      fit: BoxFit.cover,
                      height: 110,
                      width: 110,
                    ),
                  )
                : Image.asset(
                    "assets/icons/appLogo.png",
                    fit: BoxFit.cover,
                    height: 110,
                    width: 110,
                  ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: '${driverModel.prenom ?? ''} ${driverModel.nom ?? ''}',
                size: 18,
                weight: FontWeight.w600,
                color: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: StarRating(
                  size: 20,
                  rating: double.parse(driverModel.moyenne.toString()),
                  color: AppThemeData.warning200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ] else ...[
          // Show masked/placeholder info instead
          Container(
            height: 110,
            width: 110,
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
          const SizedBox(height: 10),
          CustomText(
            text: 'Driver information will be shown after payment'.tr,
            align: TextAlign.center,
            size: 14,
            weight: FontWeight.normal,
            fontStyle: FontStyle.italic,
            color: isDarkMode ? AppThemeData.grey500Dark : AppThemeData.grey500,
          ),
          const SizedBox(height: 10),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetails(
                  title: driverModel.totalCompletedRide.toString(),
                  value: 'Total Trips'.tr,
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDetails(
                  title: Constant().amountShow(amount: tripPrice),
                  value: 'Trip Price'.tr,
                  isDarkMode: isDarkMode,
                  isBold: true, // Make price bold
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: isDarkMode
                  ? AppThemeData.grey300Dark
                  : AppThemeData.grey300,
            ),
          ),
          child: Column(
            children: [
              // Hide Cab Details and Driver Contact if admin toggle is disabled
              if (showDriverInfo) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "Cab Details".tr,
                        size: 16,
                        weight: FontWeight.normal,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      CustomText(
                        text: "${driverModel.numberplate}",
                        size: 16,
                        weight: FontWeight.w500,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                    ],
                  ),
                ),
                Container(
                  color: isDarkMode
                      ? AppThemeData.grey300Dark
                      : AppThemeData.grey300,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "Driver's Contact No.".tr,
                        size: 16,
                        weight: FontWeight.normal,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomText(
                            text: "${driverModel.phone}",
                            size: 16,
                            weight: FontWeight.w500,
                            color: isDarkMode
                                ? AppThemeData.grey900Dark
                                : AppThemeData.grey900,
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              Constant.makePhoneCall(
                                driverModel.phone.toString(),
                              );
                            },
                            child: Icon(
                              Iconsax.call,
                              color: AppThemeData.secondary200,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Show masked info instead
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "Cab Details".tr,
                        size: 16,
                        weight: FontWeight.normal,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      CustomText(
                        text: "*****",
                        size: 16,
                        weight: FontWeight.w500,
                        color: isDarkMode
                            ? AppThemeData.grey400Dark
                            : AppThemeData.grey400,
                      ),
                    ],
                  ),
                ),
                Container(
                  color: isDarkMode
                      ? AppThemeData.grey300Dark
                      : AppThemeData.grey300,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "Driver's Contact No.".tr,
                        size: 16,
                        weight: FontWeight.normal,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      CustomText(
                        text: "*****",
                        size: 16,
                        weight: FontWeight.w500,
                        color: isDarkMode
                            ? AppThemeData.grey400Dark
                            : AppThemeData.grey400,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Column _buildDetails({
    required String title,
    required String value,
    required bool isDarkMode,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          text: title,
          align: TextAlign.center,
          maxLines: 1,
          size: 17,
          weight: isBold ? FontWeight.w700 : FontWeight.w600,
          color: AppThemeData.secondary200,
        ),
        CustomText(
          text: value,
          align: TextAlign.center,
          size: 12,
          weight: FontWeight.normal,
          color: isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900,
        ),
      ],
    );
  }
}
