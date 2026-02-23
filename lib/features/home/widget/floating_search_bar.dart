import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Floating search bar widget that appears over the map
/// Uses Google Places API for location search
class FloatingSearchBar extends StatefulWidget {
  final HomeController controller;
  final bool isDarkMode;
  final VoidCallback? onMenuTap;

  const FloatingSearchBar({
    super.key,
    required this.controller,
    required this.isDarkMode,
    this.onMenuTap,
  });

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Column(
          children: [
            // Main search bar
            Hero(
              tag: 'search_bar',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? AppThemeData.surface50Dark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search input - now opens Google Places directly
                      InkWell(
                        onTap: () async {
                          // Open Google Places search directly
                          await _openGooglePlacesSearch();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              // Menu icon button
                              GestureDetector(
                                onTap: widget.onMenuTap,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppThemeData.primary200.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Iconsax.menu,
                                    size: 20,
                                    color: AppThemeData.primary200,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Search text
                              Expanded(
                                child: ValueListenableBuilder(
                                  valueListenable:
                                      widget.controller.destinationController,
                                  builder: (context, value, child) {
                                    final hasDestination =
                                        value.text.isNotEmpty;
                                    return Text(
                                      hasDestination
                                          ? value.text
                                          : 'search_destination'.tr,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: hasDestination
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: hasDestination
                                            ? (widget.isDarkMode
                                                  ? AppThemeData.grey900Dark
                                                  : AppThemeData.grey900)
                                            : (widget.isDarkMode
                                                  ? AppThemeData.grey400Dark
                                                  : AppThemeData.grey400),
                                        fontFamily: 'Cairo',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ),
                              // Current location button
                              IconButton(
                                onPressed: () async {
                                  await widget.controller.getCurrentLocation(
                                    true,
                                  );
                                  // Animate to current location
                                  if (widget
                                          .controller
                                          .departureLatLong
                                          .value !=
                                      const LatLng(0.0, 0.0)) {
                                    widget.controller.mapController
                                        ?.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: widget
                                                  .controller
                                                  .departureLatLong
                                                  .value,
                                              zoom: 15.0,
                                            ),
                                          ),
                                        );
                                  }
                                },
                                icon: Icon(
                                  Iconsax.gps,
                                  size: 22,
                                  color: AppThemeData.primary200,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open Google Places search directly on the map
  Future<void> _openGooglePlacesSearch() async {
    try {
      // Use the existing Constant().placeSelectAPI method which handles the search
      final result = await Constant().placeSelectAPI(
        context,
        widget.controller.destinationController,
      );

      if (result != null && result.result.geometry != null) {
        final lat = result.result.geometry!.location.lat;
        final lng = result.result.geometry!.location.lng;
        final address = result.result.formattedAddress ?? '';

        // Set as destination
        widget.controller.destinationController.text = address;
        widget.controller.destinationLatLong.value = LatLng(lat, lng);
        widget.controller.setDestinationMarker(LatLng(lat, lng));

        // Animate camera to destination
        widget.controller.mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(lat, lng), zoom: 15.0),
          ),
        );

        // If departure is set, get directions
        if (widget.controller.departureLatLong.value !=
            const LatLng(0.0, 0.0)) {
          await widget.controller.getDirections();

          // Get duration and distance
          await widget.controller
              .getDurationDistance(
                widget.controller.departureLatLong.value,
                widget.controller.destinationLatLong.value,
              )
              .then((durationValue) {
                if (durationValue != null) {
                  if (Constant.distanceUnit == "KM") {
                    widget.controller.distance.value =
                        durationValue['rows']
                            .first['elements']
                            .first['distance']['value'] /
                        1000.00;
                  } else {
                    widget.controller.distance.value =
                        durationValue['rows']
                            .first['elements']
                            .first['distance']['value'] /
                        1609.34;
                  }

                  widget.controller.duration.value = durationValue['rows']
                      .first['elements']
                      .first['duration']['text'];
                }
              });
        }
      }
    } catch (e) {
      // Silent error - user just cancelled or error occurred
    }
  }
}
