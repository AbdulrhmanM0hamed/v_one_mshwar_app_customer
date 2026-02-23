import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/my_custom_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/controller/subscription_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/search_location_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/controller/search_address_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class CreateSubscriptionScreen extends StatelessWidget {
  const CreateSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final controller = Get.find<SubscriptionController>();

    return Scaffold(
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      appBar: CustomAppBar(title: 'Create Subscription'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeData.primary200.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppThemeData.primary200.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppThemeData.primary200),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => CustomText(
                        text:
                            '${'Subscription Price:'.tr} ${controller.settingsModel.value.data?.subscriptionKmPrice ?? '0'} ${'KWD'.tr}/${'KM'.tr}',
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppThemeData.primary200,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Trip Type Selection
            _buildSectionTitle('Trip Type'.tr, themeChange),
            const SizedBox(height: 12),
            _buildTripTypeSelector(controller, themeChange),

            const SizedBox(height: 24),

            // Locations
            _buildSectionTitle('Locations'.tr, themeChange),
            const SizedBox(height: 12),
            _buildLocationInput(
              context,
              controller,
              themeChange,
              'Home Address'.tr,
              Icons.home,
              Colors.green,
              controller.homeAddressController,
              (address, lat, lng) =>
                  controller.setHomeLocation(address, lat, lng),
              controller.homeAddress, // Pass reactive address value
              isHome: true, // ✅ Mark as home location
            ),
            const SizedBox(height: 12),
            _buildLocationInput(
              context,
              controller,
              themeChange,
              'Destination (School/Work)'.tr,
              Icons.location_on,
              Colors.red,
              controller.destinationAddressController,
              (address, lat, lng) =>
                  controller.setDestinationLocation(address, lat, lng),
              controller.destinationAddress, // Pass reactive address value
              isHome: false, // ✅ Mark as destination location
            ),

            const SizedBox(height: 24),

            // Schedule
            _buildSectionTitle('Schedule'.tr, themeChange),
            const SizedBox(height: 12),

            // Date Range
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    context,
                    controller,
                    themeChange,
                    'Start Date'.tr,
                    controller.startDate,
                    (date) => controller.setStartDate(date),
                    minDate: DateTime.now(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => _buildDatePicker(
                      context,
                      controller,
                      themeChange,
                      'End Date'.tr,
                      controller.endDate,
                      (date) => controller.setEndDate(date),
                      minDate:
                          controller.startDate.value?.add(
                            const Duration(days: 1),
                          ) ??
                          DateTime.now().add(const Duration(days: 1)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Working Days
            _buildSectionTitle('Working Days'.tr, themeChange),
            const SizedBox(height: 12),
            _buildWorkingDaysSelector(controller, themeChange),

            const SizedBox(height: 16),

            // Pickup Times
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    context,
                    controller,
                    themeChange,
                    'First Pickup Time'.tr,
                    controller.morningPickupTime,
                    (time) => controller.morningPickupTime.value = time,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => controller.tripType.value == 'two_way'
                      ? Expanded(
                          child: _buildTimePicker(
                            context,
                            controller,
                            themeChange,
                            'Return Pickup Time'.tr,
                            controller.returnPickupTime,
                            (time) => controller.returnPickupTime.value = time,
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Optional: Passenger Info
            _buildSectionTitle('Additional Info (Optional)'.tr, themeChange),
            const SizedBox(height: 12),
            _buildTextField(
              controller.passengerNameController,
              'Passenger Name'.tr,
              Icons.person_outline,
              themeChange,
              onChanged: (v) => controller.passengerName.value = v,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller.passengerPhoneController,
              'Passenger Phone'.tr,
              Icons.phone_outlined,
              themeChange,
              keyboardType: TextInputType.phone,
              onChanged: (v) => controller.passengerPhone.value = v,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller.specialInstructionsController,
              'Special Instructions'.tr,
              Icons.note_outlined,
              themeChange,
              maxLines: 2,
              onChanged: (v) => controller.specialInstructions.value = v,
            ),

            const SizedBox(height: 24),

            // Price Summary
            _buildPriceSummary(controller, themeChange),

            const SizedBox(height: 24),

            // Create Subscription Button (without payment - approval required first)
            Obx(
              () => CustomButton(
                btnName: 'Create Subscription'.tr,
                ontap:
                    controller.isPriceLoading.value ||
                        controller.priceData.value == null
                    ? null
                    : () => _createSubscriptionOnly(
                        context,
                        controller,
                        themeChange,
                      ),
                isLoading: controller.isPriceLoading.value,
                borderRadius: 14,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, DarkThemeProvider themeChange) {
    return CustomText(
      text: title.tr,
      size: 16,
      weight: FontWeight.bold,
      color: themeChange.getThem() ? Colors.white : Colors.black87,
    );
  }

  Widget _buildTripTypeSelector(
    SubscriptionController controller,
    DarkThemeProvider themeChange,
  ) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildTripTypeOption(
              controller,
              themeChange,
              'one_way',
              'One Way'.tr,
              'Single trip per day'.tr,
              Icons.arrow_forward,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTripTypeOption(
              controller,
              themeChange,
              'two_way',
              'Two Way'.tr,
              'Round trip per day'.tr,
              Icons.swap_horiz,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeOption(
    SubscriptionController controller,
    DarkThemeProvider themeChange,
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = controller.tripType.value == value;

    return InkWell(
      onTap: () {
        controller.tripType.value = value;
        controller.calculatePrice();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeData.primary200.withValues(alpha: 0.1)
              : (themeChange.getThem() ? AppThemeData.grey800 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppThemeData.primary200 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppThemeData.primary200 : Colors.grey,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: title.tr,
              size: 14,
              weight: FontWeight.bold,
              color: isSelected
                  ? AppThemeData.primary200
                  : (themeChange.getThem() ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            CustomText(
              text: subtitle.tr,
              size: 11,
              color: themeChange.getThem() ? Colors.white54 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput(
    BuildContext context,
    SubscriptionController controller,
    DarkThemeProvider themeChange,
    String hint,
    IconData icon,
    Color iconColor,
    TextEditingController textController,
    Function(String address, double lat, double lng) onSelect,
    RxString addressValue, {
    bool isHome = true, // ✅ Add parameter to distinguish home vs destination
  }) {
    return InkWell(
      onTap: () {
        // ✅ Show dialog with "Search" and "On Map" options (same as ride booking)
        MyCustomDialog.showWithActions(
          context: context,
          title: isHome
              ? "Select Home Location".tr
              : "Select Destination Location".tr,
          message: isHome
              ? "Choose how to select home location".tr
              : "Choose how to select destination location".tr,
          actions: [
            CustomButton(
              btnName: "search".tr,
              icon: Icon(Iconsax.search_normal, size: 18, color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              fontSize: 13,
              ontap: () async {
                Get.back();
                await _selectPlace(context, textController, onSelect);
              },
            ),
            CustomButton(
              btnName: "on_map".tr,
              isOutlined: true,
              icon: Icon(
                Iconsax.location,
                size: 18,
                color: AppThemeData.primary200,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              fontSize: 13,
              ontap: () async {
                Get.back();
                // Navigate to map picker screen
                final result = await Get.to(
                  () => _MapLocationPickerScreen(
                    title: isHome
                        ? "Select Home Location".tr
                        : "Select Destination Location".tr,
                  ),
                );
                if (result != null && result is LatLng) {
                  // Get address from coordinates
                  try {
                    final address = await _getAddressFromLatLng(result);
                    textController.text = address;
                    onSelect(address, result.latitude, result.longitude);
                  } catch (e) {
                    log('Error getting address from coordinates: $e');
                    textController.text = 'Selected Location'.tr;
                    onSelect(
                      'Selected Location'.tr,
                      result.latitude,
                      result.longitude,
                    );
                  }
                }
              },
            ),
          ],
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.grey800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeChange.getThem() ? Colors.white24 : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => CustomText(
                  text: addressValue.value.isEmpty
                      ? hint.tr
                      : addressValue.value,
                  size: 14,
                  color: addressValue.value.isEmpty
                      ? (themeChange.getThem()
                            ? Colors.white54
                            : Colors.black45)
                      : (themeChange.getThem() ? Colors.white : Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(Iconsax.location, color: AppThemeData.primary200),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPlace(
    BuildContext context,
    TextEditingController controller,
    Function(String address, double lat, double lng) onSelect,
  ) async {
    // Use custom search screen instead of PlacesAutocomplete.show() to avoid "powered by Google"
    final result = await Get.to(() => AddressSearchScreen());

    if (result == null) {
      return;
    }

    // result is AddressSuggestion
    final AddressSuggestion suggestion = result;

    // ✅ CRITICAL: Store the ORIGINAL address that user selected - NEVER change this
    final String originalAddress = suggestion.address.trim();

    // Validate address
    if (originalAddress.isEmpty) {
      log('⚠️ Empty address from suggestion');
      ShowToastDialog.showToast('Invalid address selected'.tr);
      return;
    }

    // ✅ Log for debugging - this is what user selected
    log(
      '📍 Location selected by user - Original Address: "$originalAddress", PlaceId: ${suggestion.placeId ?? "missing"}',
    );

    // Use originalAddress throughout - never modify it
    String address = originalAddress;

    // Get place details
    String apiKey = Constant.kGoogleApiKey ?? '';
    // Check for empty, null string, or the literal "null" string
    if (apiKey.isEmpty ||
        apiKey.trim().isEmpty ||
        apiKey == 'null' ||
        apiKey.trim() == 'null') {
      log(
        '⚠️ Using fallback API key in subscription screen (backend key is: "$apiKey")',
      );
      apiKey = 'AIzaSyCvUrBOS0y4FDS6kAhkZhLRjTHtudwG43c';
    } else {
      apiKey = apiKey.trim();
    }

    double lat = 0.0;
    double lng = 0.0;
    bool coordinatesFound = false;

    // ✅ FIX: Try to get coordinates using placeId first (most accurate)
    if (suggestion.placeId != null && suggestion.placeId!.isNotEmpty) {
      try {
        GoogleMapsPlaces places = GoogleMapsPlaces(
          apiKey: apiKey,
          apiHeaders: await const GoogleApiHeaders().getHeaders(),
        );
        PlacesDetailsResponse detail = await places.getDetailsByPlaceId(
          suggestion.placeId!,
        );

        if (detail.result.geometry?.location != null) {
          lat = detail.result.geometry!.location.lat;
          lng = detail.result.geometry!.location.lng;
          coordinatesFound = true;
          log(
            '✅ Got coordinates from placeId: $lat, $lng for address: $address',
          );
        } else {
          log(
            '⚠️ Place details missing geometry for placeId: ${suggestion.placeId}',
          );
        }
      } catch (e) {
        log('❌ Error getting place details from placeId: $e');
        // Will fallback to geocoding below
      }
    }

    // ✅ FIX: Fallback to geocoding only if placeId lookup failed
    // This is especially important for history items that might not have placeId
    if (!coordinatesFound) {
      try {
        log(
          '🔄 Falling back to geocoding for address: $address (placeId: ${suggestion.placeId ?? "missing"})',
        );

        // Try geocoding with the address
        List<geo.Location> locations = await geo.locationFromAddress(address);
        if (locations.isNotEmpty) {
          lat = locations.first.latitude;
          lng = locations.first.longitude;
          coordinatesFound = true;
          log(
            '✅ Got coordinates from geocoding: $lat, $lng for address: $address',
          );
        } else {
          log('⚠️ Geocoding returned no locations for address: $address');

          // ✅ Try with a more specific search using Places API if geocoding fails
          if (address.isNotEmpty) {
            try {
              GoogleMapsPlaces places = GoogleMapsPlaces(
                apiKey: apiKey,
                apiHeaders: await const GoogleApiHeaders().getHeaders(),
              );

              // Search by address text as fallback
              PlacesAutocompleteResponse autocompleteResponse = await places
                  .autocomplete(
                    address,
                    language: 'en',
                    components: [Component(Component.country, "kw")],
                  );

              if (autocompleteResponse.isOkay &&
                  autocompleteResponse.predictions.isNotEmpty) {
                // ✅ Find the best matching prediction (exact match or closest)
                Prediction? bestMatch;
                for (var prediction in autocompleteResponse.predictions) {
                  if (prediction.description?.toLowerCase() ==
                      address.toLowerCase()) {
                    bestMatch = prediction;
                    break;
                  }
                }
                // If no exact match, use first one but keep original address
                bestMatch ??= autocompleteResponse.predictions.first;

                if (bestMatch.placeId != null) {
                  PlacesDetailsResponse detail = await places
                      .getDetailsByPlaceId(bestMatch.placeId!);
                  if (detail.result.geometry?.location != null) {
                    lat = detail.result.geometry!.location.lat;
                    lng = detail.result.geometry!.location.lng;
                    coordinatesFound = true;
                    log(
                      '✅ Got coordinates from Places API search fallback: $lat, $lng',
                    );
                    log(
                      '⚠️ Note: Using original address "$address" (not "${bestMatch.description}")',
                    );
                    // ✅ IMPORTANT: Don't change the address - keep the original one user selected
                  }
                }
              }
            } catch (e) {
              log('❌ Error in Places API fallback search: $e');
            }
          }
        }
      } catch (e) {
        log('❌ Error geocoding address: $e');
      }
    }

    // ✅ FIX: Validate coordinates before proceeding
    if (!coordinatesFound || lat == 0.0 || lng == 0.0) {
      log('❌ Failed to get valid coordinates for address: $address');
      log(
        '❌ Debug info - placeId: ${suggestion.placeId ?? "null"}, coordinatesFound: $coordinatesFound',
      );
      ShowToastDialog.showToast(
        'Failed to get location coordinates. Please try selecting the location again or use map picker.'
            .tr,
      );
      return;
    }

    // ✅ CRITICAL FIX: Always use the ORIGINAL address that user selected
    // NEVER replace it with formattedAddress or any other address from API
    // The address from suggestion is exactly what the user selected and saw
    // Use originalAddress (not address variable which might have been modified)
    final finalAddress =
        originalAddress; // Use the original, never-modified address

    controller.text = finalAddress;
    onSelect(finalAddress, lat, lng);
    log(
      '✅ Location successfully selected and set: "$finalAddress" at ($lat, $lng)',
    );
    log('✅ Original address preserved - user selected: "$originalAddress"');
    log('✅ Coordinates: ($lat, $lng)');
  }

  Widget _buildDatePicker(
    BuildContext context,
    SubscriptionController controller,
    DarkThemeProvider themeChange,
    String label,
    Rx<DateTime?> dateValue,
    Function(DateTime) onSelect, {
    DateTime? minDate,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: dateValue.value ?? minDate ?? DateTime.now(),
          firstDate: minDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onSelect(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.grey800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeChange.getThem() ? Colors.white24 : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: AppThemeData.primary200,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(
                () => CustomText(
                  text: dateValue.value != null
                      ? DateFormat('MMM dd, yyyy').format(dateValue.value!)
                      : label.tr,
                  size: 14,
                  color: dateValue.value != null
                      ? (themeChange.getThem() ? Colors.white : Colors.black87)
                      : (themeChange.getThem()
                            ? Colors.white54
                            : Colors.black45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    SubscriptionController controller,
    DarkThemeProvider themeChange,
    String label,
    Rx<TimeOfDay> timeValue,
    Function(TimeOfDay) onSelect,
  ) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: timeValue.value,
        );
        if (time != null) {
          onSelect(time);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.grey800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeChange.getThem() ? Colors.white24 : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 20, color: AppThemeData.primary200),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: label.tr,
                    size: 11,
                    color: themeChange.getThem()
                        ? Colors.white54
                        : Colors.black45,
                  ),
                  Obx(
                    () => CustomText(
                      text: timeValue.value.format(context),
                      size: 14,
                      weight: FontWeight.bold,
                      color: themeChange.getThem()
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingDaysSelector(
    SubscriptionController controller,
    DarkThemeProvider themeChange,
  ) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(7, (index) {
          final isSelected = controller.selectedWorkingDays.contains(index);
          return InkWell(
            onTap: () => controller.toggleWorkingDay(index),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppThemeData.primary200
                    : (themeChange.getThem()
                          ? AppThemeData.grey800
                          : Colors.white),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppThemeData.primary200
                      : (themeChange.getThem()
                            ? Colors.white24
                            : Colors.black12),
                ),
              ),
              child: Center(
                child: CustomText(
                  text: days[index],
                  size: 12,
                  weight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (themeChange.getThem()
                            ? Colors.white70
                            : Colors.black54),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    DarkThemeProvider themeChange, {
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: themeChange.getThem() ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: themeChange.getThem() ? Colors.white54 : Colors.black45,
        ),
        prefixIcon: Icon(icon, color: AppThemeData.primary200),
        filled: true,
        fillColor: themeChange.getThem() ? AppThemeData.grey800 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeChange.getThem() ? Colors.white24 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeChange.getThem() ? Colors.white24 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppThemeData.primary200),
        ),
      ),
    );
  }

  Widget _buildPriceSummary(
    SubscriptionController controller,
    DarkThemeProvider themeChange,
  ) {
    return Obx(() {
      final price = controller.priceData.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.grey800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Price Summary'.tr,
              size: 18,
              weight: FontWeight.bold,
              color: themeChange.getThem() ? Colors.white : Colors.black87,
            ),
            const SizedBox(height: 16),
            if (price != null) ...[
              _buildPriceRow(
                'KM Price'.tr,
                '${price.kmPrice} ${'KWD'.tr}/${'KM'.tr}',
                themeChange,
              ),
              _buildPriceRow(
                'Distance'.tr,
                '${price.distanceKm} ${'KM'.tr}',
                themeChange,
              ),
              _buildPriceRow(
                'Single Trip Price'.tr,
                '${price.singleTripPrice} ${'KWD'.tr}',
                themeChange,
              ),
              _buildPriceRow(
                'Total Trips'.tr,
                '${price.totalTrips}',
                themeChange,
              ),
              _buildPriceRow(
                'Duration'.tr,
                '${price.totalDays} ${'days'.tr}',
                themeChange,
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'Total Price'.tr,
                    size: 18,
                    weight: FontWeight.bold,
                    color: themeChange.getThem()
                        ? Colors.white
                        : Colors.black87,
                  ),
                  CustomText(
                    text: '${price.totalPrice} ${'KWD'.tr}',
                    size: 24,
                    weight: FontWeight.bold,
                    color: AppThemeData.primary200,
                  ),
                ],
              ),
            ] else
              Center(
                child: CustomText(
                  text: 'Fill in all details to see price'.tr,
                  size: 14,
                  color: themeChange.getThem()
                      ? Colors.white54
                      : Colors.black45,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPriceRow(
    String label,
    String value,
    DarkThemeProvider themeChange, {
    bool isSubItem = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: isSubItem ? 8 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label.tr,
            size: 14,
            color: themeChange.getThem() ? Colors.white70 : Colors.black54,
          ),
          CustomText(
            text: value,
            size: 14,
            weight: FontWeight.w600,
            color: themeChange.getThem() ? Colors.white : Colors.black87,
          ),
        ],
      ),
    );
  }

  /// Create subscription only (without payment - requires admin approval first)
  Future<void> _createSubscriptionOnly(
    BuildContext context,
    SubscriptionController controller,
    DarkThemeProvider themeChange,
  ) async {
    // Validate form first
    if (!controller.validateForm()) return;

    // Create subscription (status will be pending_approval)
    final subscription = await controller.createSubscription();
    if (subscription == null) return;

    // Show success message
    ShowToastDialog.showToast(
      'Subscription created successfully! Waiting for admin approval. You will be notified when approved and can then proceed with payment.',
    );

    controller.resetForm();
    Get.back(result: true);
  }

  // ✅ Helper method to get address from LatLng
  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
            .replaceAll(RegExp(r',\s*,+'), ',')
            .replaceAll(RegExp(r'^,\s*'), '')
            .replaceAll(RegExp(r'\s*,$'), '');
      }
    } catch (e) {
      log('Error getting address from coordinates: $e');
    }
    return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
  }
}

// ✅ Map Location Picker Screen
class _MapLocationPickerScreen extends StatefulWidget {
  final String title;

  const _MapLocationPickerScreen({required this.title});

  @override
  State<_MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<_MapLocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(
    29.3759,
    47.9774,
  ); // Default: Kuwait City
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _updateMarker(_selectedLocation);
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _selectedLocation, zoom: 14.0),
        ),
      );
    } catch (e) {
      log('Error getting current location: $e');
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _marker = Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: widget.title),
        backgroundColor: AppThemeData.primary200,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng position) {
              _updateMarker(position);
            },
            markers: _marker != null ? {_marker!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
          ),
          // Center marker indicator
          Center(
            child: Icon(
              Iconsax.location,
              size: 40,
              color: AppThemeData.primary200,
            ),
          ),
          // Bottom button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: CustomButton(
              btnName: 'Select This Location'.tr,
              ontap: () {
                Get.back(result: _selectedLocation);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
