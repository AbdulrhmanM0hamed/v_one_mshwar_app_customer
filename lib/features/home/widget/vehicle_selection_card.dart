import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/vehicle_category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class VehicleSelectionCard extends StatelessWidget {
  final VehicleData vehicle;
  final HomeController controller;
  final bool isSelected;

  const VehicleSelectionCard({
    super.key,
    required this.vehicle,
    required this.controller,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();
    final vehicleName = _getLocalizedVehicleName(vehicle.libelle.toString());
    final description = _getVehicleDescription(vehicleName);

    return Expanded(
      child: InkWell(
        onTap: () {
          controller.vehicleData.value = vehicle;
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppThemeData.surface50Dark
                : AppThemeData.surface50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 1.5,
              color: isSelected
                  ? AppThemeData.primary200.withValues(alpha: 0.5)
                  : (isDarkMode
                        ? AppThemeData.grey200Dark
                        : AppThemeData.grey200),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Section: Icon and Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    CustomText(
                      text: vehicleName,
                      size: 16,
                      weight: FontWeight.w700,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                    ),
                    const SizedBox(height: 8),
                    // Description
                    CustomText(
                      text: description,
                      size: 12,
                      weight: FontWeight.w400,
                      color: isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      height: 1.5,
                    ),
                  ],
                ),
                // Bottom Section: Price and Selection Indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Selection Indicator
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppThemeData.primary200
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppThemeData.primary200
                                  : (isDarkMode
                                        ? AppThemeData.grey300Dark
                                        : AppThemeData.grey300),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        CustomText(
                          text: isSelected ? 'selected'.tr : 'tap_to_select'.tr,
                          size: 12,
                          weight: FontWeight.w500,
                          color: isDarkMode
                              ? AppThemeData.grey500Dark
                              : AppThemeData.grey500,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedVehicleName(String vehicleName) {
    final normalizedName = vehicleName.trim().toLowerCase();
    if (normalizedName == 'business') {
      return 'family'.tr; // Changed from Business to Family
    } else if (normalizedName == 'classic') {
      return 'classic'.tr;
    }
    return vehicleName;
  }

  String _getVehicleDescription(String vehicleName) {
    // Always use localized description based on vehicle type
    final normalizedName =
        vehicle.libelle?.toString().trim().toLowerCase() ?? '';

    if (normalizedName == 'business') {
      return 'family_ride_description'.tr;
    } else if (normalizedName == 'classic') {
      return 'classic_ride_description'.tr;
    }

    // Fallback to default description
    return 'reliable_transportation_service'.tr;
  }
}
