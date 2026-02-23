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

class NewRideController extends GetxController {
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // All rides in one list
  var allRideList = <RideData>[].obs;

  // Legacy lists for backward compatibility with existing tabs
  var newRideList = <RideData>[].obs;
  var completedRideList = <RideData>[].obs;
  var rejectedRideList = <RideData>[].obs;

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
    'new',
    'confirmed',
    'on ride',
    'completed',
    'rejected',
    'cancelled',
  ];

  // Get filtered and searched rides - optimized
  List<RideData> get filteredRideList {
    List<RideData> filtered = allRideList.toList();

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
            (ride.nomConducteur?.toLowerCase().contains(query) ?? false) ||
            (ride.prenomConducteur?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.creer ?? '');
        final dateB = DateTime.parse(b.creer ?? '');
        return dateB.compareTo(dateA);
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
    if (filter == 'all') return allRideList.length;
    return allRideList.where((ride) {
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
    getNewRide(isinit: true);
    // Optimize timer - only refresh if needed (not in background)
    timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      // Only refresh if cache is stale
      if (_lastFetchTime == null ||
          DateTime.now().difference(_lastFetchTime!) > _cacheDuration) {
        getNewRide();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  Future<dynamic> getNewRide({
    bool isinit = false,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first (unless force refresh)
      if (!forceRefresh &&
          !isinit &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        showLog('Using cached ride data');
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
              "${API.userAllRides}?id_user_app=${Preferences.getInt(Preferences.userId)}",
            ),
            headers: API.header,
          )
          .timeout(const Duration(seconds: 10));

      showLog(
        "API :: URL :: ${API.userAllRides}?id_user_app=${Preferences.getInt(Preferences.userId)} ",
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
        allRideList.clear();
        newRideList.clear();
        completedRideList.clear();
        rejectedRideList.clear();

        // Store all rides
        if (model.data != null) {
          allRideList.addAll(model.data!);

          // Also populate legacy lists for backward compatibility
          for (var ride in model.data!) {
            if (ride.statut == "new" ||
                ride.statut == "on ride" ||
                ride.statut == "confirmed" ||
                ride.statut == "Pending") {
              newRideList.add(ride);
            } else if (ride.statut == "completed") {
              completedRideList.add(ride);
            } else if (ride.statut == "rejected") {
              rejectedRideList.add(ride);
            }
          }
        }
        update();
      } else {
        _handleError('Failed to load rides. Please try again.');
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
      log('getNewRide error: $e');
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

  // Retry loading rides
  Future<void> retry() async {
    hasError.value = false;
    await getNewRide(isinit: true, forceRefresh: true);
  }
}
