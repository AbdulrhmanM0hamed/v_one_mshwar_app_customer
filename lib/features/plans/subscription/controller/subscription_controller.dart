import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/model/subscription_model.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/model/subscription_settings_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class SubscriptionController extends GetxController {
  // Settings
  var settingsModel = SubscriptionSettingsModel().obs;
  var isSettingsLoading = true.obs;
  var isSubscriptionAvailable = false.obs;

  // Subscriptions list
  var subscriptionsList = <SubscriptionData>[].obs;
  var isListLoading = true.obs;

  // Upcoming rides
  var upcomingRides = <SubscriptionRideData>[].obs;
  var isRidesLoading = true.obs;

  // Create subscription form
  var tripType = 'two_way'.obs;
  var homeAddress = ''.obs;
  var homeLatitude = 0.0.obs;
  var homeLongitude = 0.0.obs;
  var destinationAddress = ''.obs;
  var destinationLatitude = 0.0.obs;
  var destinationLongitude = 0.0.obs;
  var distanceKm = 0.0.obs;
  var startDate = Rx<DateTime?>(null);
  var endDate = Rx<DateTime?>(null);
  var selectedWorkingDays = <int>[1, 2, 3, 4, 5].obs; // Mon-Fri by default
  var morningPickupTime = TimeOfDay(hour: 7, minute: 0).obs;
  var returnPickupTime = TimeOfDay(hour: 14, minute: 0).obs;
  var passengerName = ''.obs;
  var passengerPhone = ''.obs;
  var specialInstructions = ''.obs;

  // Price calculation
  var priceData = Rx<SubscriptionPriceData?>(null);
  var isPriceLoading = false.obs;

  // Text controllers
  final homeAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  final distanceController = TextEditingController();
  final passengerNameController = TextEditingController();
  final passengerPhoneController = TextEditingController();
  final specialInstructionsController = TextEditingController();

  // Firebase Realtime Database listener
  DatabaseReference? _settingsRef;
  StreamSubscription<DatabaseEvent>? _settingsSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
    fetchUserSubscriptions();
    fetchUpcomingRides();
    _setupFirebaseListener();
  }

  @override
  void onClose() {
    _settingsSubscription?.cancel();
    homeAddressController.dispose();
    destinationAddressController.dispose();
    distanceController.dispose();
    passengerNameController.dispose();
    passengerPhoneController.dispose();
    specialInstructionsController.dispose();
    super.onClose();
  }

  /// Setup Firebase Realtime Database listener for subscription settings
  void _setupFirebaseListener() {
    try {
      final database = FirebaseDatabase.instance;
      _settingsRef = database.ref('subscription_settings');

      _settingsSubscription = _settingsRef!.onValue.listen(
        (DatabaseEvent event) {
          if (event.snapshot.value != null) {
            final data = event.snapshot.value as Map<dynamic, dynamic>;

            // Update settings model from Firebase
            settingsModel.value = SubscriptionSettingsModel(
              success: 'success',
              data: SubscriptionSettingsData(
                isAvailable: data['is_available'] ?? false,
                subscriptionKmPrice:
                    data['subscription_km_price']?.toString() ?? '0',
                minSubscriptionDays:
                    data['min_subscription_days']?.toString() ?? '7',
                maxSubscriptionDays:
                    data['max_subscription_days']?.toString() ?? '365',
                minimumDistanceKm:
                    data['minimum_distance_km']?.toString() ?? '1',
              ),
            );

            // Update availability status
            isSubscriptionAvailable.value =
                settingsModel.value.data?.isAvailable ?? false;

            print('✅ Subscription settings updated from Firebase in real-time');
          }
        },
        onError: (error) {
          print('❌ Firebase subscription settings listener error: $error');
        },
      );
    } catch (e) {
      print('❌ Error setting up Firebase listener: $e');
    }
  }

  /// Fetch subscription settings
  Future<void> fetchSettings() async {
    try {
      isSettingsLoading.value = true;

      final response = await http.get(
        Uri.parse(API.subscriptionSettings),
        headers: API.authheader,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        settingsModel.value = SubscriptionSettingsModel.fromJson(data);
        isSubscriptionAvailable.value =
            settingsModel.value.data?.isAvailable ?? false;
      }
    } catch (e) {
      print('Error fetching subscription settings: $e');
    } finally {
      isSettingsLoading.value = false;
    }
  }

  /// Fetch user's subscriptions
  /// Note: status parameter is kept for backward compatibility but ignored - we use client-side filtering instead
  Future<void> fetchUserSubscriptions({String? status}) async {
    try {
      isListLoading.value = true;

      // Always fetch all subscriptions - filtering is done client-side
      String url =
          "${API.subscriptionUserList}?user_id=${Preferences.getInt(Preferences.userId)}";

      final response = await http.get(Uri.parse(url), headers: API.header);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = SubscriptionListModel.fromJson(data);
        if (model.success == 'success' && model.data != null) {
          subscriptionsList.value = model.data!;
        }
      }
    } catch (e) {
      print('Error fetching subscriptions: $e');
    } finally {
      isListLoading.value = false;
    }
  }

  /// Fetch upcoming rides
  Future<void> fetchUpcomingRides() async {
    try {
      isRidesLoading.value = true;

      final response = await http.get(
        Uri.parse(
          "${API.subscriptionUpcomingRides}?user_id=${Preferences.getInt(Preferences.userId)}&limit=10",
        ),
        headers: API.header,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success' && data['data'] != null) {
          upcomingRides.value = (data['data'] as List)
              .map((e) => SubscriptionRideData.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching upcoming rides: $e');
    } finally {
      isRidesLoading.value = false;
    }
  }

  /// Calculate subscription price
  Future<void> calculatePrice() async {
    if (distanceKm.value <= 0 ||
        startDate.value == null ||
        endDate.value == null) {
      return;
    }

    try {
      isPriceLoading.value = true;

      // ✅ Build request body with coordinates for accurate distance and zone pricing
      final body = <String, dynamic>{
        'distance_km': distanceKm.value.toString(),
        'trip_type': tripType.value,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate.value!),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate.value!),
        'working_days': selectedWorkingDays.toList(),
      };

      // ✅ Add coordinates if available for accurate distance calculation and zone pricing
      if (homeLatitude.value != 0 && homeLongitude.value != 0) {
        body['home_latitude'] = homeLatitude.value.toString();
        body['home_longitude'] = homeLongitude.value.toString();
      }
      if (destinationLatitude.value != 0 && destinationLongitude.value != 0) {
        body['destination_latitude'] = destinationLatitude.value.toString();
        body['destination_longitude'] = destinationLongitude.value.toString();
      }

      final response = await http.post(
        Uri.parse(API.subscriptionCalculatePrice),
        headers: API.header,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = SubscriptionPriceModel.fromJson(data);
        if (model.success == 'success') {
          priceData.value = model.data;
          // ✅ Update distance with backend-calculated distance (more accurate)
          if (model.data?.distanceKm != null) {
            final backendDistance = double.tryParse(model.data!.distanceKm!);
            if (backendDistance != null && backendDistance > 0) {
              final oldDistance = distanceKm.value;
              distanceKm.value = backendDistance;
              distanceController.text = distanceKm.value.toStringAsFixed(2);
              print(
                '✅ Distance updated from backend: $oldDistance km → ${distanceKm.value} km (Google Maps route distance)',
              );
            } else {
              print(
                '⚠️ Backend returned invalid distance: ${model.data!.distanceKm}',
              );
            }
          } else {
            print('⚠️ Backend response missing distance_km field');
          }
        } else {
          ShowToastDialog.showToast(
            model.error?.toString() ?? 'Failed to calculate price'.tr,
          );
        }
      } else {
        print(
          '❌ Price calculation API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error calculating price: $e');
    } finally {
      isPriceLoading.value = false;
    }
  }

  /// Create a new subscription
  Future<SubscriptionData?> createSubscription() async {
    if (!validateForm()) return null;

    try {
      ShowToastDialog.showLoader('Creating subscription...'.tr);

      final body = {
        'user_id': Preferences.getInt(Preferences.userId),
        'trip_type': tripType.value,
        'home_address': homeAddress.value,
        'home_latitude': homeLatitude.value,
        'home_longitude': homeLongitude.value,
        'destination_address': destinationAddress.value,
        'destination_latitude': destinationLatitude.value,
        'destination_longitude': destinationLongitude.value,
        'distance_km': distanceKm.value,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate.value!),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate.value!),
        'working_days': selectedWorkingDays.toList(),
        'morning_pickup_time':
            '${morningPickupTime.value.hour.toString().padLeft(2, '0')}:${morningPickupTime.value.minute.toString().padLeft(2, '0')}',
        'return_pickup_time': tripType.value == 'two_way'
            ? '${returnPickupTime.value.hour.toString().padLeft(2, '0')}:${returnPickupTime.value.minute.toString().padLeft(2, '0')}'
            : null,
        'passenger_name': passengerName.value.isEmpty
            ? null
            : passengerName.value,
        'passenger_phone': passengerPhone.value.isEmpty
            ? null
            : passengerPhone.value,
        'special_instructions': specialInstructions.value.isEmpty
            ? null
            : specialInstructions.value,
        'payment_method': 'app',
      };

      final response = await http.post(
        Uri.parse(API.subscriptionCreate),
        headers: API.header,
        body: json.encode(body),
      );

      ShowToastDialog.closeLoader();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = SubscriptionResponseModel.fromJson(data);
        if (model.success == 'success') {
          ShowToastDialog.showToast(
            'Subscription created successfully! Waiting for admin approval.'.tr,
          );
          resetForm();
          fetchUserSubscriptions();
          return model.data;
        } else {
          ShowToastDialog.showToast(
            model.error?.toString() ?? 'Failed to create subscription'.tr,
          );
        }
      } else {
        final data = json.decode(response.body);
        ShowToastDialog.showToast(
          data['error']?.toString() ?? 'Failed to create subscription'.tr,
        );
      }
    } on TimeoutException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Request timeout'.tr);
    } on SocketException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Network error'.tr);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('${'Payment error:'.tr} $e');
    }
    return null;
  }

  /// Confirm payment for subscription
  Future<bool> confirmPayment(
    String subscriptionId,
    String transactionId,
    String paymentMethod,
  ) async {
    try {
      ShowToastDialog.showLoader('Confirming payment...'.tr);

      final body = {
        'subscription_id': subscriptionId,
        'transaction_id': transactionId,
        'payment_method': paymentMethod,
      };

      final response = await http.post(
        Uri.parse(API.subscriptionConfirmPayment),
        headers: API.header,
        body: json.encode(body),
      );

      ShowToastDialog.closeLoader();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success') {
          ShowToastDialog.showToast(
            'Payment confirmed! Subscription activated.'.tr,
          );
          fetchUserSubscriptions();
          fetchUpcomingRides();
          return true;
        } else {
          ShowToastDialog.showToast(
            data['error']?.toString() ?? 'Failed to confirm payment'.tr,
          );
        }
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('${'Payment error:'.tr} $e');
    }
    return false;
  }

  /// Cancel subscription
  Future<bool> cancelSubscription(String subscriptionId, String reason) async {
    try {
      ShowToastDialog.showLoader('Cancelling subscription...'.tr);

      final body = {
        'subscription_id': subscriptionId,
        'user_id': Preferences.getInt(Preferences.userId),
        'cancellation_reason': reason,
      };

      final response = await http.post(
        Uri.parse(API.subscriptionCancel),
        headers: API.header,
        body: json.encode(body),
      );

      ShowToastDialog.closeLoader();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success') {
          ShowToastDialog.showToast('Subscription cancelled'.tr);
          fetchUserSubscriptions();
          fetchUpcomingRides();
          return true;
        } else {
          ShowToastDialog.showToast(
            data['error']?.toString() ?? 'Failed to cancel'.tr,
          );
        }
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('${'Payment error:'.tr} $e');
    }
    return false;
  }

  /// Get subscription details
  Future<SubscriptionData?> getSubscriptionDetails(
    String subscriptionId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("${API.subscriptionDetails}?subscription_id=$subscriptionId"),
        headers: API.header,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success' && data['data'] != null) {
          return SubscriptionData.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('Error fetching subscription details: $e');
    }
    return null;
  }

  /// Validate form before submission
  bool validateForm() {
    if (homeAddress.value.isEmpty) {
      ShowToastDialog.showToast('Please enter home address'.tr);
      return false;
    }
    if (destinationAddress.value.isEmpty) {
      ShowToastDialog.showToast('Please enter destination address'.tr);
      return false;
    }
    if (distanceKm.value <= 0) {
      ShowToastDialog.showToast('Please enter valid distance'.tr);
      return false;
    }
    if (startDate.value == null) {
      ShowToastDialog.showToast('Please select start date'.tr);
      return false;
    }
    if (endDate.value == null) {
      ShowToastDialog.showToast('Please select end date'.tr);
      return false;
    }
    if (selectedWorkingDays.isEmpty) {
      ShowToastDialog.showToast('Please select at least one working day'.tr);
      return false;
    }
    return true;
  }

  /// Reset form to initial state
  void resetForm() {
    tripType.value = 'two_way';
    homeAddress.value = '';
    homeLatitude.value = 0.0;
    homeLongitude.value = 0.0;
    destinationAddress.value = '';
    destinationLatitude.value = 0.0;
    destinationLongitude.value = 0.0;
    distanceKm.value = 0.0;
    startDate.value = null;
    endDate.value = null;
    selectedWorkingDays.value = [1, 2, 3, 4, 5];
    morningPickupTime.value = TimeOfDay(hour: 7, minute: 0);
    returnPickupTime.value = TimeOfDay(hour: 14, minute: 0);
    passengerName.value = '';
    passengerPhone.value = '';
    specialInstructions.value = '';
    priceData.value = null;

    homeAddressController.clear();
    destinationAddressController.clear();
    distanceController.clear();
    passengerNameController.clear();
    passengerPhoneController.clear();
    specialInstructionsController.clear();
  }

  /// Set home location from picker
  void setHomeLocation(String address, double lat, double lng) {
    homeAddress.value = address;
    homeLatitude.value = lat;
    homeLongitude.value = lng;
    homeAddressController.text = address;
    _updateDistance();
  }

  /// Set destination location from picker
  void setDestinationLocation(String address, double lat, double lng) {
    destinationAddress.value = address;
    destinationLatitude.value = lat;
    destinationLongitude.value = lng;
    destinationAddressController.text = address;
    _updateDistance();
  }

  /// Calculate distance between home and destination using Haversine formula
  /// Note: This is a straight-line distance (as the crow flies)
  /// The backend will recalculate using Google Maps API for accurate route distance
  void _updateDistance() {
    if (homeLatitude.value != 0 &&
        homeLongitude.value != 0 &&
        destinationLatitude.value != 0 &&
        destinationLongitude.value != 0) {
      // Calculate haversine distance using proper math functions
      final lat1 = homeLatitude.value;
      final lon1 = homeLongitude.value;
      final lat2 = destinationLatitude.value;
      final lon2 = destinationLongitude.value;

      const R = 6371.0; // Earth's radius in km
      final dLat = math.pi / 180 * (lat2 - lat1);
      final dLon = math.pi / 180 * (lon2 - lon1);
      final a =
          math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(math.pi / 180 * lat1) *
              math.cos(math.pi / 180 * lat2) *
              math.sin(dLon / 2) *
              math.sin(dLon / 2);
      final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      final distance = R * c;

      distanceKm.value = double.parse(distance.toStringAsFixed(2));
      distanceController.text = distanceKm.value.toString();

      // Auto-calculate price (backend will recalculate with Google Maps API)
      calculatePrice();
    }
  }

  /// Toggle working day
  void toggleWorkingDay(int day) {
    if (selectedWorkingDays.contains(day)) {
      selectedWorkingDays.remove(day);
    } else {
      selectedWorkingDays.add(day);
    }
    selectedWorkingDays.sort();
    calculatePrice();
  }

  /// Set start date
  void setStartDate(DateTime date) {
    startDate.value = date;
    // If end date is before start date, reset it
    if (endDate.value != null && endDate.value!.isBefore(date)) {
      endDate.value = null;
    }
    calculatePrice();
  }

  /// Set end date
  void setEndDate(DateTime date) {
    endDate.value = date;
    calculatePrice();
  }

  // =====================================================
  // PAYMENT PROCESSING
  // =====================================================

  /// Process wallet payment for subscription
  Future<Map<String, dynamic>?> processWalletPayment({
    required String subscriptionId,
    required double amount,
  }) async {
    try {
      ShowToastDialog.showLoader('Processing wallet payment...');

      final bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId),
        'subscription_id': int.tryParse(subscriptionId) ?? 0,
        'amount': amount.toStringAsFixed(3),
      };

      final response = await http.post(
        Uri.parse(API.subscriptionPayWallet),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );

      ShowToastDialog.closeLoader();

      // Check if response is JSON
      final contentType = response.headers['content-type'] ?? '';
      final isJson =
          contentType.contains('application/json') ||
          response.body.trim().startsWith('{') ||
          response.body.trim().startsWith('[');

      if (!isJson) {
        // Response is not JSON (likely HTML error page)
        ShowToastDialog.showToast(
          '${'Server error'.tr} (${response.statusCode}). ${'Please try again later'.tr}',
        );
        return null;
      }

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          if (data['success'] == 'success' || data['success'] == 'Success') {
            // Update local user data with new wallet balance if available
            if (data['data']?['new_wallet_balance'] != null) {
              try {
                final userData = Constant.getUserData();
                userData.data?.amount = data['data']['new_wallet_balance'];
                Preferences.setString(
                  Preferences.user,
                  jsonEncode(userData.toJson()),
                );
              } catch (_) {}
            }
            return data;
          } else {
            ShowToastDialog.showToast(
              data['error']?.toString() ?? 'Payment failed'.tr,
            );
          }
        } catch (e) {
          ShowToastDialog.showToast('Failed to process payment response'.tr);
        }
      } else {
        try {
          final data = json.decode(response.body);
          ShowToastDialog.showToast(
            data['error']?.toString() ?? 'Payment failed. Please try again.'.tr,
          );
        } catch (e) {
          ShowToastDialog.showToast(
            '${'Payment failed'.tr} (${response.statusCode}). ${'Please try again later'.tr}',
          );
        }
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      if (e.toString().contains('FormatException')) {
        ShowToastDialog.showToast(
          '${'Server error'.tr}. ${'Please try again later'.tr}',
        );
      } else {
        ShowToastDialog.showToast('${'Payment error:'.tr} ${e.toString()}');
      }
    }
    return null;
  }

  /// Process UPayments (KNET) payment - returns payment URL
  Future<String?> processUPaymentsPayment({
    required String subscriptionId,
    required double amount,
    required String homeAddress,
    required String destinationAddress,
  }) async {
    try {
      ShowToastDialog.showLoader('Initiating payment...'.tr);

      // Use PaymentController for UPayments payment
      final paymentController = Get.find<PaymentController>();
      final paymentUrl = await paymentController.processUPaymentsPaymentGeneric(
        amount: amount,
        productName: "Mshwar Subscription",
        productDescription:
            "Subscription from $homeAddress to $destinationAddress",
        customerExtraData: "subscription_id:$subscriptionId",
      );

      ShowToastDialog.closeLoader();
      return paymentUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('${'Payment error:'.tr} $e');
      return null;
    }
  }

  /// Handle UPayments callback result
  Future<bool> handleUPaymentsCallback({
    required String subscriptionId,
    required String result,
    String? transactionId,
  }) async {
    if (result == 'SUCCESS' || result == 'CAPTURED') {
      // Payment successful - confirm the subscription
      return await confirmPayment(
        subscriptionId,
        transactionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'upayments',
      );
    } else {
      ShowToastDialog.showToast('Payment was not successful'.tr);
      return false;
    }
  }

  /// Get wallet balance from server (not cached)
  Future<double> getWalletBalance() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${API.wallet}?id_user=${Preferences.getInt(Preferences.userId)}&user_cat=user_app",
        ),
        headers: API.header,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success' && data['data'] != null) {
          final balance =
              double.tryParse(data['data']['amount']?.toString() ?? '0') ?? 0.0;

          // Also update the cached user data with fresh balance
          try {
            final userData = Constant.getUserData();
            userData.data?.amount = data['data']['amount']?.toString();
            Preferences.setString(
              Preferences.user,
              jsonEncode(userData.toJson()),
            );
          } catch (_) {}

          return balance;
        }
      }

      // Fallback to cached data if API fails
      final userData = Constant.getUserData();
      return double.tryParse(userData.data?.amount ?? '0') ?? 0.0;
    } catch (e) {
      print('Error fetching wallet balance: $e');
      // Fallback to cached data
      try {
        final userData = Constant.getUserData();
        return double.tryParse(userData.data?.amount ?? '0') ?? 0.0;
      } catch (_) {
        return 0.0;
      }
    }
  }

  /// Check if wallet has sufficient balance
  Future<bool> hasEnoughWalletBalance(double amount) async {
    final balance = await getWalletBalance();
    return balance >= amount;
  }
}
