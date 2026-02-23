import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ScheduledRideController extends GetxController {
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // All scheduled rides in one list
  var allScheduledRideList = <RideData>[].obs;

  // Legacy lists for backward compatibility
  var pendingRideList = <RideData>[].obs;
  var confirmedRideList = <RideData>[].obs;
  var completedRideList = <RideData>[].obs;

  Timer? timer;

  // Filter state
  var selectedFilter = 'all'.obs;

  // Search functionality
  var searchQuery = ''.obs;

  // Cache for performance
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 1);

  // Filter options - same as driver app
  static const List<String> filterOptions = [
    'all',
    'pending',
    'new',
    'confirmed',
    'on ride',
    'completed',
  ];

  // Get filtered and searched scheduled rides - optimized
  List<RideData> get filteredRideList {
    List<RideData> filtered = allScheduledRideList.toList();

    // Apply status filter
    if (selectedFilter.value != 'all') {
      filtered = filtered.where((ride) {
        final status = ride.statut?.toLowerCase() ?? '';
        final filter = selectedFilter.value.toLowerCase();

        if (filter == 'on ride') {
          return status == 'on ride' || status == 'onride';
        }
        return status == filter;
      }).toList();
    }

    // Apply search query if exists
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((ride) {
        return (ride.departName?.toLowerCase().contains(query) ?? false) ||
            (ride.destinationName?.toLowerCase().contains(query) ?? false) ||
            (ride.id?.toLowerCase().contains(query) ?? false) ||
            (ride.rideDate?.toLowerCase().contains(query) ?? false) ||
            (ride.rideTime?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort by scheduled date/time (upcoming first)
    filtered.sort((a, b) {
      try {
        if (a.rideDate != null && b.rideDate != null) {
          final dateA = DateTime.parse(a.rideDate!);
          final dateB = DateTime.parse(b.rideDate!);
          if (dateA != dateB) return dateA.compareTo(dateB);

          // If same date, compare time
          if (a.rideTime != null && b.rideTime != null) {
            final timeA = a.rideTime!.split(':');
            final timeB = b.rideTime!.split(':');
            if (timeA.length >= 2 && timeB.length >= 2) {
              final hourA = int.tryParse(timeA[0]) ?? 0;
              final hourB = int.tryParse(timeB[0]) ?? 0;
              final minA = int.tryParse(timeA[1]) ?? 0;
              final minB = int.tryParse(timeB[1]) ?? 0;
              if (hourA != hourB) return hourA.compareTo(hourB);
              return minA.compareTo(minB);
            }
          }
        }
        return 0;
      } catch (e) {
        return 0;
      }
    });

    return filtered;
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    update();
  }

  // Get count for a specific status
  int getStatusCount(String filter) {
    if (filter == 'all') return allScheduledRideList.length;
    return allScheduledRideList.where((ride) {
      final status = ride.statut?.toLowerCase() ?? '';
      if (filter == 'on ride') {
        return status == 'on ride' || status == 'onride';
      }
      return status == filter.toLowerCase();
    }).length;
  }

  // Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  @override
  void onInit() {
    getScheduledRides(isinit: true);
    // Optimize timer - only refresh if needed
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // Only refresh if cache is stale
      if (_lastFetchTime == null ||
          DateTime.now().difference(_lastFetchTime!) > _cacheDuration) {
        getScheduledRides();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  Future<dynamic> getScheduledRides({
    bool isinit = false,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first (unless force refresh)
      if (!forceRefresh &&
          !isinit &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        showLog('Using cached scheduled ride data');
        return null;
      }

      if (isinit) {
        isLoading.value = true;
        hasError.value = false;
      } else {
        isRefreshing.value = true;
      }

      final response = await http
          .get(
            Uri.parse(
              "${API.userScheduledRides}?id_user_app=${Preferences.getInt(Preferences.userId)}",
            ),
            headers: API.header,
          )
          .timeout(const Duration(seconds: 10));

      showLog(
        "API :: URL :: ${API.userScheduledRides}?id_user_app=${Preferences.getInt(Preferences.userId)}",
      );
      showLog("API :: Header :: ${API.header.toString()}");
      showLog("API :: responseStatus :: ${response.statusCode}");

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        isRefreshing.value = false;
        hasError.value = false;
        _lastFetchTime = DateTime.now();

        RideModel model = RideModel.fromJson(responseBody);

        // Clear all lists
        allScheduledRideList.clear();
        pendingRideList.clear();
        confirmedRideList.clear();
        completedRideList.clear();

        // Store all rides
        if (model.data != null) {
          allScheduledRideList.addAll(model.data!);

          // Also populate legacy lists for backward compatibility
          for (var ride in model.data!) {
            if (ride.statut == "pending" || ride.statut == "new") {
              pendingRideList.add(ride);
            } else if (ride.statut == "confirmed" || ride.statut == "on ride") {
              confirmedRideList.add(ride);
            } else if (ride.statut == "completed") {
              completedRideList.add(ride);
            }
          }
        }
        update();
      } else {
        _handleError('Failed to load scheduled rides. Please try again.');
      }
    } on TimeoutException {
      _handleError('Request timed out. Please check your connection.');
    } on SocketException {
      _handleError('No internet connection. Please check your network.');
    } on FormatException catch (e) {
      _handleError('Invalid server response. Please try again.');
      log('JSON Parse error: $e');
    } catch (e) {
      _handleError('An error occurred. Please try again.');
      log('getScheduledRides error: $e');
    }
    return null;
  }

  void _handleError(String message) {
    isLoading.value = false;
    isRefreshing.value = false;
    hasError.value = true;
    errorMessage.value = message;
    update();
  }

  // Retry loading scheduled rides
  Future<void> retry() async {
    hasError.value = false;
    await getScheduledRides(isinit: true, forceRefresh: true);
  }
}
