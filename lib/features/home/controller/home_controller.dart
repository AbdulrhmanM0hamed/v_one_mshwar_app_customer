import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/driver_location_update.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/driver_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/payment_method_model.dart';
import 'package:v_one_mshwar_app_customer/features/home/model/vehicle_category_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/login_screen.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:geolocator/geolocator.dart' as locationData;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/payment_setting_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/model/user_model.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/controller/package_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/sucess_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/scheduled_rides_screen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/view/payment_webview.dart';

String? driverId;
String? driverName;

class HomeController extends GetxController with GetTickerProviderStateMixin {
  //for Choose your Rider
  TabController? tabController;
  double lat = 0.0;
  double lng = 0.0;

  final TextEditingController currentLocationController =
      TextEditingController();
  final TextEditingController departureController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final Rx<LatLng?> departurePosition = Rx<LatLng?>(null);
  final Rx<LatLng?> destinationPosition = Rx<LatLng?>(null);

  //pointer variables
  Rxn<LatLng> startPoint = Rxn<LatLng>();
  Rxn<LatLng> endPoint = Rxn<LatLng>();
  Rxn<LatLng> stopPoint = Rxn<LatLng>();
  RxBool isSelectingStart = true.obs;
  RxBool isSelectingDestination = false.obs;
  var tempMarker = Rx<Marker?>(null);
  final Rx<LatLng?> currentMarkerPosition = Rx<LatLng?>(null);
  final Rx<LatLng?> destinationMarkerPosition = Rx<LatLng?>(null);

  RxString selectPaymentMode =
      "payment_method".obs; // Use key for internal state
  List<AddChildModel> addChildList = [
    AddChildModel(editingController: TextEditingController()),
  ];
  List<AddStopModel> multiStopList = [];
  List<AddStopModel> multiStopListNew = [];

  Rx<VehicleCategoryModel> vehicleCategoryModel = VehicleCategoryModel().obs;
  List pricecal = [];

  Rx<VehicleData> vehicleData = VehicleData().obs;
  late PaymentMethodData? paymentMethodData;

  RxBool confirmWidgetVisible = false.obs;

  RxString tripOptionCategory = "General".obs;
  RxString paymentMethodType =
      "select_method".obs; // Use key for internal state
  RxString paymentMethodId = "5".obs;
  RxDouble distance = 0.0.obs;
  String? distanceUnit;
  RxString duration = "".obs;

  var paymentSettingModel = PaymentSettingModel().obs;

  RxBool uPayments = false.obs;
  RxBool cash = false.obs;
  RxBool wallet = false.obs;
  RxBool stripe = false.obs;
  RxBool razorPay = false.obs;
  RxBool paypal = false.obs;
  RxBool payStack = false.obs;
  RxBool flutterWave = false.obs;
  RxBool mercadoPago = false.obs;
  RxBool payFast = false.obs;
  RxBool xendit = false.obs;
  RxBool orangePay = false.obs;
  RxBool midtrans = false.obs;
  RxBool usePackage = false.obs; // Use purchased package KM
  Rx<dynamic> selectedUserPackage = Rx<dynamic>(
    null,
  ); // Selected package for ride
  RxDouble packageKmToUse = 0.0.obs; // KM to use from package
  RxBool isHomePageLoading =
      false.obs; // Start with false to hide loading screen
  RxString walletAmount = '0'.obs;

  // Cached current location for instant map navigation
  Rx<LatLng?> cachedCurrentLocation = Rx<LatLng?>(null);
  RxBool isLocationReady = false.obs;

  // Flag to track if data was already initialized (e.g., from splash)
  bool _isInitialized = false;

  @override
  void onInit() {
    // Only initialize if not already done (splash screen preloads data)
    if (!_isInitialized) {
      setInitData();
    }
    super.onInit();
  }

  @override
  void onClose() {
    // Dispose GoogleMapController safely to handle iOS platform channel errors
    if (mapController != null) {
      try {
        mapController?.dispose();
      } catch (e) {
        // Ignore disposal errors - common on iOS
        log('Error disposing GoogleMapController: $e');
      }
      mapController = null;
    }
    tabController?.dispose();
    super.onClose();
  }

  Future<void> setInitData({bool forceInit = false}) async {
    if (_isInitialized && !forceInit) {
      return; // Skip if already initialized (unless forced)
    }

    // Run location fetch and icons in parallel for faster loading
    final locationFuture = getCurrentLocation(true).catchError((error) {
      log('Failed to get current location: $error');
    });

    if (Constant.homeScreenType != 'OlaHome') {
      await setIcons();
    }

    // Wait for location to complete (with timeout to not block forever)
    await locationFuture.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        log('Location fetch timed out during splash, continuing...');
      },
    );

    await getTaxiData();
    await initData();
    setTabr();

    paymentSettingModel.value = Constant.getPaymentSetting();

    _isInitialized = true; // Mark as initialized
  }

  Future<void> initData() async {
    multiStopList.clear();
    multiStopListNew.clear();
    // Location is already fetched in setInitData, no need to fetch again
    await getVehicleCategory(true);
  }

  void enableDepartureSelection() {
    isSelectingStart.value = true;
  }

  void enableDestinationSelection() {
    isSelectingStart.value = false;
  }

  void loadMarkersAndPolylines() async {
    LocationData location = await currentLocation.value.getLocation();
    mapController?.moveCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0),
        14,
      ),
    );

    // Optional: Add default markers or initial setup
    if (departureLatLong.value != LatLng(0.0, 0.0)) {
      setDepartureMarker(departureLatLong.value);
    }

    if (destinationLatLong.value != LatLng(0.0, 0.0)) {
      setDestinationMarker(destinationLatLong.value);
    }

    // You can also re-fetch polylines or add other startup tasks here
    if (departureLatLong.value != LatLng(0.0, 0.0) &&
        destinationLatLong.value != LatLng(0.0, 0.0)) {
      var durationValue = await getDurationDistance(
        departureLatLong.value,
        destinationLatLong.value,
      );

      if (durationValue != null) {
        if (Constant.distanceUnit == "KM") {
          distance.value =
              durationValue['rows']
                  .first['elements']
                  .first['distance']['value'] /
              1000.00;
          distanceUnit = "KM";
        } else {
          distance.value =
              durationValue['rows']
                  .first['elements']
                  .first['distance']['value'] /
              1609.34;
          distanceUnit = "Miles";
        }

        duration.value =
            durationValue['rows'].first['elements'].first['duration']['text'];

        // var tripPrice = calculateTripPrice(
        //   distance: distance.value,
        //   deliveryCharges:
        //       double.parse(vehicleData.value.deliveryCharges ?? '0'),
        //   minimumDeliveryCharges:
        //       double.parse(vehicleData.value.minimumDeliveryCharges ?? '0'),
        //   minimumDeliveryChargesWithin: double.parse(
        //       vehicleData.value.minimumDeliveryChargesWithin ?? '0'),
        // );

        // log("Trip Price: $tripPrice");
      }
    }
  }

  Future<void> getCurrentAddress() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ShowToastDialog.showToast('location_services_disabled'.tr);
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log("Location permission is denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ShowToastDialog.showToast('location_permissions_permanently_denied'.tr);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: locationData.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      currentLocationController.text = await Constant().getAddressFromLatLong(
        position,
      );
      departureController.text = await Constant().getAddressFromLatLong(
        position,
      );
      departureLatLong.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      log('Error getting current address: $e');
      // Don't show toast - this runs in background
      // Only set unavailable if no location already set
      if (cachedCurrentLocation.value == null) {
        currentLocationController.text = 'location_unavailable'.tr;
        departureController.text = 'location_unavailable'.tr;
      }
    }
  }

  Rx<Location> currentLocation = Location().obs;
  Future<void> getCurrentLocation(bool isDepartureSet) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await currentLocation.value.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await currentLocation.value.requestService();
        if (!serviceEnabled) {
          log('Location services are disabled');
          // Only set unavailable if no location already set
          if (cachedCurrentLocation.value == null) {
            currentLocationController.text = 'location_unavailable'.tr;
            departureController.text = 'location_unavailable'.tr;
          }
          return;
        }
      }

      // Check location permission
      PermissionStatus permissionGranted = await currentLocation.value
          .hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await currentLocation.value.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          log('Location permission denied');
          // Only set unavailable if no location already set
          if (cachedCurrentLocation.value == null) {
            currentLocationController.text = 'location_unavailable'.tr;
            departureController.text = 'location_unavailable'.tr;
          }
          return;
        }
      }

      // Get current location with timeout
      LocationData location;
      try {
        location = await currentLocation.value.getLocation().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Location request timed out');
          },
        );
      } catch (e) {
        // Fallback to Geolocator if location package fails
        log('Location package failed, trying Geolocator: $e');
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: locationData.LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
          );
          location = LocationData.fromMap({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
            'altitude': position.altitude,
            'speed': position.speed,
            'speed_accuracy': position.speedAccuracy,
            'heading': position.heading,
            'timestamp': position.timestamp.millisecondsSinceEpoch,
          });
        } catch (geolocatorError) {
          log('Geolocator also failed: $geolocatorError');
          // Only set unavailable if no location already set
          if (cachedCurrentLocation.value == null) {
            currentLocationController.text = 'location_unavailable'.tr;
            departureController.text = 'location_unavailable'.tr;
          }
          return;
        }
      }

      // Validate location data
      if (location.latitude == null || location.longitude == null) {
        ShowToastDialog.showToast('unable_to_get_current_location'.tr);
        return;
      }

      // Get address from coordinates
      List<get_cord_address.Placemark> placeMarks = await get_cord_address
          .placemarkFromCoordinates(
            location.latitude ?? 0.0,
            location.longitude ?? 0.0,
          );

      if (placeMarks.isEmpty) {
        ShowToastDialog.showToast('unable_to_get_address'.tr);
        return;
      }

      // Process tax list
      for (var i = 0; i < Constant.allTaxList.length; i++) {
        if (placeMarks.first.country.toString().toUpperCase() ==
            Constant.allTaxList[i].country!.toUpperCase()) {
          Constant.taxList.add(Constant.allTaxList[i]);
        }
      }

      // Build address string
      final address =
          (placeMarks.first.subLocality?.isEmpty == true
              ? ''
              : "${placeMarks.first.subLocality}, ") +
          (placeMarks.first.street?.isEmpty == true
              ? ''
              : "${placeMarks.first.street}, ") +
          (placeMarks.first.name?.isEmpty == true
              ? ''
              : "${placeMarks.first.name}, ") +
          (placeMarks.first.subAdministrativeArea?.isEmpty == true
              ? ''
              : "${placeMarks.first.subAdministrativeArea}, ") +
          (placeMarks.first.administrativeArea?.isEmpty == true
              ? ''
              : "${placeMarks.first.administrativeArea}, ") +
          (placeMarks.first.country?.isEmpty == true
              ? ''
              : "${placeMarks.first.country}, ") +
          (placeMarks.first.postalCode?.isEmpty == true
              ? ''
              : "${placeMarks.first.postalCode}, ");

      // Update UI
      currentLocationController.text = address;
      departureController.text = address;
      final currentLatLng = LatLng(
        location.latitude ?? 0.0,
        location.longitude ?? 0.0,
      );

      // Cache location for instant map navigation
      cachedCurrentLocation.value = currentLatLng;
      isLocationReady.value = true;

      // Navigate map immediately if controller is available
      if (mapController != null) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentLatLng, zoom: 14.0),
          ),
        );
      }

      setDepartureMarker(currentLatLng);
      update();
    } catch (e) {
      log('Error getting current location: $e');
      // Don't show toast since this runs in background - just log and set defaults
      // Only set unavailable if no location already set
      if (cachedCurrentLocation.value == null) {
        currentLocationController.text = 'location_unavailable'.tr;
        departureController.text = 'location_unavailable'.tr;
      }
    }
    // if (isDepartureSet) {
    //   LocationData location = await currentLocation.value.getLocation();
    //   List<get_cord_address.Placemark> placeMarks =
    //       await get_cord_address.placemarkFromCoordinates(
    //           location.latitude ?? 0.0, location.longitude ?? 0.0);
    //   for (var i = 0; i < Constant.allTaxList.length; i++) {
    //     if (placeMarks.first.country.toString().toUpperCase() ==
    //         Constant.allTaxList[i].country!.toUpperCase()) {
    //       Constant.taxList.add(Constant.allTaxList[i]);
    //     }
    //   }

    //   final address = (placeMarks.first.subLocality!.isEmpty
    //           ? ''
    //           : "${placeMarks.first.subLocality}, ") +
    //       (placeMarks.first.street!.isEmpty
    //           ? ''
    //           : "${placeMarks.first.street}, ") +
    //       (placeMarks.first.name!.isEmpty ? '' : "${placeMarks.first.name}, ") +
    //       (placeMarks.first.subAdministrativeArea!.isEmpty
    //           ? ''
    //           : "${placeMarks.first.subAdministrativeArea}, ") +
    //       (placeMarks.first.administrativeArea!.isEmpty
    //           ? ''
    //           : "${placeMarks.first.administrativeArea}, ") +
    //       (placeMarks.first.country!.isEmpty
    //           ? ''
    //           : "${placeMarks.first.country}, ") +
    //       (placeMarks.first.postalCode!.isEmpty
    //           ? ''
    //           : "${placeMarks.first.postalCode}, ");
    //   currentLocationController.text = address;
    //   departureController.text = address;
    //   setDepartureMarker(
    //       LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0));
    //   update();
    // }
  }

  GoogleMapController? mapController;
  void setDepartureMarker(LatLng departure) {
    departureLatLong.value = departure;

    if (Constant.homeScreenType != 'OlaHome') {
      markers.remove("Departure");
      markers['Departure'] = Marker(
        markerId: const MarkerId('Departure'),
        infoWindow: InfoWindow(title: "Departure".tr),
        position: departure,
        icon: departureIcon!,
      );

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(departure.latitude, departure.longitude),
            zoom: 14,
          ),
        ),
      );

      // _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(departure.latitude, departure.longitude), zoom: 18)));
      if (departureLatLong.value.latitude != 0 &&
          destinationLatLong.value.latitude != 0) {
        getDirections();
        confirmWidgetVisible.value = true;
        // conformationBottomSheet(context);
      }
    }
  }

  void setDestinationMarker(LatLng destination) {
    destinationLatLong.value = destination;
    if (Constant.homeScreenType != 'OlaHome') {
      markers['Destination'] = Marker(
        markerId: const MarkerId('Destination'),
        infoWindow: InfoWindow(title: "Destination".tr),
        position: destination,
        icon: destinationIcon!,
      );

      if (departureLatLong.value.latitude != 0 &&
          destinationLatLong.value.latitude != 0) {
        getDirections();
        confirmWidgetVisible.value = true;
        // conformationBottomSheet(context);
      }
    }
  }

  void setStopMarker(LatLng destination, int index) {
    // final List<int> codeUnits = "Anand".codeUnits;
    // final Uint8List unit8List = Uint8List.fromList(codeUnits);
    // print('\x1b[97m ===== $unit8List =====');
    markers['Stop $index'] = Marker(
      markerId: MarkerId('Stop $index'),
      infoWindow: InfoWindow(
        title: "${"Stop".tr} ${String.fromCharCode(index + 65)}",
      ),
      position: destination,
      icon: stopIcon!,
    ); //BitmapDescriptor.fromBytes(unit8List));
    // destinationLatLong = destination;

    if (departureLatLong.value.latitude != 0 &&
        destinationLatLong.value.latitude != 0) {
      getDirections();
      confirmWidgetVisible.value = true;
      // conformationBottomSheet(context);
    }
  }

  Rx<LatLng> departureLatLong = const LatLng(0.0, 0.0).obs;
  Rx<LatLng> destinationLatLong = const LatLng(0.0, 0.0).obs;
  Future<void> getDirections() async {
    if (Constant.homeScreenType != 'OlaHome') {
      List<PolylineWayPoint> wayPointList = [];
      for (var i = 0; i < multiStopList.length; i++) {
        wayPointList.add(
          PolylineWayPoint(location: multiStopList[i].editingController.text),
        );
      }
      List<LatLng> polylineCoordinates = [];

      PolylineRequest requestData = PolylineRequest(
        wayPoints: wayPointList,
        optimizeWaypoints: true,
        mode: TravelMode.driving,
        origin: PointLatLng(
          departureLatLong.value.latitude,
          departureLatLong.value.longitude,
        ),
        destination: PointLatLng(
          destinationLatLong.value.latitude,
          destinationLatLong.value.longitude,
        ),
      );
      PolylineResult result =
          await PolylinePoints(
            apiKey: Constant.kGoogleApiKey!,
          ).getRouteBetweenCoordinates(
            // googleApiKey: Constant.kGoogleApiKey.toString(),
            request: requestData,
          );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
      addPolyLine(polylineCoordinates);
    }
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  void addPolyLine(List<LatLng> polylineCoordinates) {
    if (polylineCoordinates.isEmpty) {
      log('Warning: polylineCoordinates is empty, cannot add polyline');
      return;
    }

    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: AppThemeData.primary200,
      points: polylineCoordinates,
      width: 6,
      geodesic: true,
    );
    polyLines[id] = polyline;

    // Only update camera location if we have valid coordinates
    if (polylineCoordinates.length >= 2) {
      updateCameraLocation(
        polylineCoordinates.first,
        polylineCoordinates.last,
        mapController,
      );
    } else if (polylineCoordinates.length == 1) {
      // If only one point, just center on that point
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(polylineCoordinates.first, 14),
      );
    }
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(source.latitude, destination.longitude),
        northeast: LatLng(destination.latitude, source.longitude),
      );
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destination.latitude, source.longitude),
        northeast: LatLng(source.latitude, destination.longitude),
      );
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 90);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
    CameraUpdate cameraUpdate,
    GoogleMapController mapController,
  ) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      List<get_cord_address.Placemark> placemarks = await get_cord_address
          .placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        get_cord_address.Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
      return 'Address not found';
    } catch (e) {
      return 'error_fetching_address'.tr;
    }
  }

  void setTabr() {
    tabController = TabController(length: 1, vsync: this);
  }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;
  BitmapDescriptor? stopIcon;

  final Map<String, Marker> markers = {};

  Future<void> setIcons() async {
    try {
      const ImageConfiguration imageConfig = ImageConfiguration(
        size: Size(48, 48),
      );
      departureIcon = await BitmapDescriptor.fromAssetImage(
        imageConfig,
        "assets/icons/pickup.png",
      );
      destinationIcon = await BitmapDescriptor.fromAssetImage(
        imageConfig,
        "assets/icons/dropoff.png",
      );
      taxiIcon = await BitmapDescriptor.fromAssetImage(
        imageConfig,
        "assets/icons/ic_taxi.png",
      );
      stopIcon = await BitmapDescriptor.fromAssetImage(
        imageConfig,
        "assets/icons/location.png",
      );
    } catch (e) {
      log('Error loading icons: $e');
    }
  }

  Future<void> addStops() async {
    ShowToastDialog.showLoader('please_wait'.tr);
    multiStopList.add(
      AddStopModel(
        editingController: TextEditingController(),
        latitude: "",
        longitude: "",
      ),
    );
    multiStopListNew = List<AddStopModel>.generate(
      multiStopList.length,
      (int index) => AddStopModel(
        editingController: multiStopList[index].editingController,
        latitude: multiStopList[index].latitude,
        longitude: multiStopList[index].longitude,
      ),
    );
    ShowToastDialog.closeLoader();
    update();
  }

  void removeStops(int index) {
    ShowToastDialog.showLoader('please_wait'.tr);
    multiStopList.removeAt(index);
    multiStopListNew = List<AddStopModel>.generate(
      multiStopList.length,
      (int index) => AddStopModel(
        editingController: multiStopList[index].editingController,
        latitude: multiStopList[index].latitude,
        longitude: multiStopList[index].longitude,
      ),
    );
    ShowToastDialog.closeLoader();
    update();
  }

  void clearData() {
    selectPaymentMode.value = "payment_method";
    tripOptionCategory = "General".obs;
    paymentMethodType = "select_method".obs;
    paymentMethodId = "".obs;
    distance = 0.0.obs;
    duration = "".obs;
    multiStopList.clear();
    multiStopListNew.clear();
  }

  RxList<DriverLocationUpdate> driverLocationList =
      <DriverLocationUpdate>[].obs;

  Future getTaxiData() async {
    // Car icons on map disabled per client request
    Constant.driverLocationUpdateCollection
        .where("active", isEqualTo: true)
        .snapshots()
        .listen((event) {
          for (var element in event.docs) {
            DriverLocationUpdate driverLocationUpdate =
                DriverLocationUpdate.fromJson(
                  element.data() as Map<String, dynamic>,
                );
            driverLocationList.add(driverLocationUpdate);
            // Driver car markers removed - client does not want car icons on home map
          }
        });
  }

  Future<dynamic> getDurationDistance(
    LatLng departureLatLong,
    LatLng destinationLatLong,
  ) async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      double originLat, originLong, destLat, destLong;
      originLat = departureLatLong.latitude;
      originLong = departureLatLong.longitude;
      destLat = destinationLatLong.latitude;
      destLong = destinationLatLong.longitude;

      String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
      http.Response response = await http.get(
        Uri.parse(
          '$url?units=metric&origins=$originLat,'
          '$originLong&destinations=$destLat,$destLong&key=${Constant.kGoogleApiKey}',
        ),
      );

      showLog(
        "API :: URL :: '${'$url?units=metric&origins=$originLat,'
            '$originLong&destinations=$destLat,$destLong&key=${Constant.kGoogleApiKey}'}",
      );
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      var decodedResponse = jsonDecode(response.body);

      if (decodedResponse['status'] == 'OK' &&
          decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
        ShowToastDialog.closeLoader();
        return decodedResponse;
      } else {
        ShowToastDialog.closeLoader();
        return null;
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
  }

  Future<dynamic> getUserPendingPayment() async {
    try {
      Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId),
      };
      final response = await http.post(
        Uri.parse(API.userPendingPayment),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: '${API.userPendingPayment}");
      showLog("API :: Body :: '${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        ShowToastDialog.showToast(
          'Something want wrong. Please try again later',
        );
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<VehicleCategoryModel?> getVehicleCategory(type) async {
    try {
      update();
      final response = await http
          .get(Uri.parse(API.getVehicleCategory), headers: API.header)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              log('getVehicleCategory timed out after 10s');
              throw TimeoutException('Vehicle category request timed out');
            },
          );
      showLog("API :: URL :: '${API.getVehicleCategory}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody ::YY ${response.body} ");

      // Check if response is HTML (server error page)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        log('Server returned HTML instead of JSON - likely server error');
        isHomePageLoading.value = false;
        ShowToastDialog.showToast('Server error. Please try again later.');
        update();
        return null;
      }

      Map<String, dynamic> responseBody;
      try {
        responseBody = json.decode(response.body);
      } on FormatException catch (e) {
        log('JSON Parse Error in getVehicleCategory: $e');
        log(
          'Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
        );
        isHomePageLoading.value = false;
        ShowToastDialog.showToast('Invalid server response. Please try again.');
        update();
        return null;
      }
      if (response.statusCode == 200) {
        isHomePageLoading.value = false;
        vehicleCategoryModel.value = VehicleCategoryModel.fromJson(
          responseBody,
        );
        pricecal = responseBody['calculation'];

        // Auto-select first vehicle type if available and none selected
        if (vehicleCategoryModel.value.data != null &&
            vehicleCategoryModel.value.data!.isNotEmpty &&
            (vehicleData.value.id == null || vehicleData.value.id!.isEmpty)) {
          vehicleData.value = vehicleCategoryModel.value.data![0];
          log(
            'Auto-selected vehicle type: ${vehicleData.value.libelle} (ID: ${vehicleData.value.id})',
          );
        }

        // Log available vehicle types for debugging
        if (vehicleCategoryModel.value.data != null) {
          log(
            'Available vehicle types: ${vehicleCategoryModel.value.data!.map((v) => '${v.libelle} (ID: ${v.id}, Status: ${v.status})').join(', ')}',
          );
        }

        update();
        return VehicleCategoryModel.fromJson(responseBody);
      } else {
        // ShowToastDialog.closeLoader();
        isHomePageLoading.value = false;
        log('JJ: ${responseBody.toString()}');
        if (responseBody['data']['message'] == 'Unauthorized') {
          Preferences.clearSharPreference();
          Get.offAll(LoginScreen());
          ShowToastDialog.showToast(responseBody['data']['message'].toString());
          update();
        }
        ShowToastDialog.showToast(
          'Something want wrong. Please try again later',
        );
        update();
        throw Exception('Failed to load album');
      }
    } on FormatException catch (e) {
      isHomePageLoading.value = false;
      log('FormatException in getVehicleCategory: $e');
      ShowToastDialog.showToast(
        'Invalid server response. Please check your connection and try again.',
      );
      update();
    } on TimeoutException {
      isHomePageLoading.value = false;
      ShowToastDialog.showToast('Request timed out. Please try again.');
      update();
    } on SocketException {
      isHomePageLoading.value = false;
      ShowToastDialog.showToast(
        'No internet connection. Please check your network.',
      );
      update();
    } on Error catch (e) {
      isHomePageLoading.value = false;
      log('Error in getVehicleCategory: $e');
      ShowToastDialog.showToast('An error occurred. Please try again.');
      update();
    } catch (e) {
      isHomePageLoading.value = false;
      log('Unexpected error in getVehicleCategory: $e');
      ShowToastDialog.showToast('Something went wrong. Please try again.');
      update();
    }
    return null;
  }

  Future<DriverModel?> getDriverDetails(
    String typeVehicle,
    String lat1,
    String lng1,
  ) async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.get(
        Uri.parse(
          "${API.driverDetails}?type_vehicle=$typeVehicle&lat1=$lat1&lng1=$lng1",
        ),
        headers: API.header,
      );
      showLog(
        "API :: URL :: ${API.driverDetails}?type_vehicle=$typeVehicle&lat1=$lat1&lng1=$lng1",
      );
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        final driverModel = DriverModel.fromJson(responseBody);

        // Log debug info if no drivers found
        if (driverModel.success != "Success" && driverModel.debug != null) {
          log("=== DRIVER AVAILABILITY DEBUG ===");
          log("Error reason: ${driverModel.reason}");
          log("Debug info: ${driverModel.debug}");
          log("Total drivers: ${driverModel.debug!['total_drivers']}");
          log("Approved drivers: ${driverModel.debug!['approved_drivers']}");
          log("Verified drivers: ${driverModel.debug!['verified_drivers']}");
          log("Online drivers: ${driverModel.debug!['online_drivers']}");
          log(
            "Drivers with location: ${driverModel.debug!['drivers_with_location']}",
          );
          log(
            "Drivers with balance: ${driverModel.debug!['drivers_with_balance']}",
          );
          log("Drivers in zone: ${driverModel.debug!['drivers_in_zone']}");
          log(
            "Drivers with vehicle: ${driverModel.debug!['drivers_with_vehicle']}",
          );
          log("=== END DEBUG ===");
        }

        return driverModel;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          'Something want wrong. Please try again later',
        );
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  String ridePrice = '0';
  // Zone pricing breakdown for package calculation
  RxDouble zoneFare = 0.0.obs;
  RxDouble kmFare = 0.0.obs;

  /* get Calculate Price */
  Future<dynamic> getCalculatePrice(Map<String, String> bodyParams) async {
    try {
      showLog('api started');
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.post(
        Uri.parse(API.getDistancePrice),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      Map<String, dynamic> responseBody = json.decode(response.body);
      showLog("API :: URL :: ${API.getDistancePrice}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        ridePrice = responseBody['fare'];
        // Store zone pricing breakdown for package calculations
        zoneFare.value =
            double.tryParse(responseBody['zone_fare']?.toString() ?? '0') ??
            0.0;
        kmFare.value =
            double.tryParse(responseBody['km_fare']?.toString() ?? '0') ?? 0.0;
        showLog("💰 Zone Fare: ${zoneFare.value}, KM Fare: ${kmFare.value}");
        update();
        return responseBody;
      } else if (response.statusCode == 404) {
        ShowToastDialog.closeLoader();
        if (bodyParams['name']?.toLowerCase() == "business") {
          ShowToastDialog.showToast(responseBody['message'].toString());
        } else {
          if (responseBody['message'] != null) {
            ShowToastDialog.showToast(responseBody['message'].toString());
          } else {
            ShowToastDialog.showToast('service_not_available_location'.tr);
          }
        }
        return null;
      } else {
        ShowToastDialog.closeLoader();
        if (bodyParams['name']?.toLowerCase() == "business") {
          ShowToastDialog.showToast(responseBody['message'].toString());
        } else {
          ShowToastDialog.showToast('selected_zone_not_available'.tr);
        }
        return null;
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      return null;
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      return null;
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      return null;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      return null;
    }
  }

  Future<dynamic> bookRide(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.post(
        Uri.parse(API.bookRides),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.bookRides}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 500) {
        ShowToastDialog.closeLoader();
        showLog(response.body.toString());
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          'Something want wrong. Please try again later',
        );
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> scheduleRide(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final headers = Map<String, String>.from(API.header);
      headers.remove('content-type'); // lowercase key
      headers.remove('Content-Type'); // just in case it's capitalized
      headers['Content-Type'] =
          'application/x-www-form-urlencoded'; // ✅ correct type for form data

      final response = await http.post(
        Uri.parse(API.scheduleRide),
        headers: headers,
        body: bodyParams.map((key, value) => MapEntry(key, value.toString())),
      );

      showLog("API :: URL :: ${API.scheduleRide}");
      showLog("API :: Request Body :: $bodyParams");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode}");
      showLog("API :: responseBody :: ${response.body}");

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        ShowToastDialog.showToast(responseBody['success']);
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 500) {
        ShowToastDialog.closeLoader();
        showLog(response.body.toString());
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          'Something went wrong. Please try again later',
        );
        throw Exception('Failed to load data');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      showLog(e.toString());
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  // ============ Booking Logic ============
  /// Prepares booking body parameters
  Map<String, dynamic> prepareBookingBodyParams({
    required String driverId,
    required double tripPrice,
    String? discountCode,
    double? discountAmount,
    DateTime? scheduleDateTime,
    String? packageId,
    double? packageKmUsed,
  }) {
    List stopsList = [];
    for (var i = 0; i < multiStopListNew.length; i++) {
      stopsList.add({
        "latitude": multiStopListNew[i].latitude.toString(),
        "longitude": multiStopListNew[i].longitude.toString(),
        "location": multiStopListNew[i].editingController.text.toString(),
      });
    }

    UserModel? user = UserModel.fromJson(
      jsonDecode(Preferences.getString(Preferences.user)),
    );

    Map<String, dynamic> bodyParams = {
      "ride_type": "Normal",
      "statut": "new",
      "distance_unit": Constant.distanceUnit,
      "trip_objective": tripOptionCategory.value,
      "statut_paiement": "yes",
      "source": departureController.text,
      "destination": destinationController.text,
      "user_id": Preferences.getInt(Preferences.userId).toString(),
      "user_detail": {
        "name": "${user.data?.nom ?? ""} ${user.data?.prenom ?? ""}",
        "phone": user.data?.phone ?? "+923001234567",
        "email": user.data?.email ?? "adil@example.com",
      },
      "lat1": departureLatLong.value.latitude.toString(),
      "lng1": departureLatLong.value.longitude.toString(),
      "lat2": destinationLatLong.value.latitude.toString(),
      "lng2": destinationLatLong.value.longitude.toString(),
      "cout": tripPrice.toString(),
      "duree": duration.value,
      "distance": distance.value.toString(),
      "age_children1": addChildList.isNotEmpty
          ? addChildList[0].editingController.text
          : null,
      "age_children2": addChildList.length >= 2
          ? addChildList[1].editingController.text
          : null,
      "age_children3": addChildList.length >= 3
          ? addChildList[2].editingController.text
          : null,
      "trip_category": tripOptionCategory.value,
      "id_conducteur": driverId,
      "id_payment": "5",
      "depart_name": departureController.text,
      "destination_name": destinationController.text,
      "place": departureController.text,
      "number_poeple": "2",
      "statut_round": "no",
      "stops": stopsList,
      "date_retour": "2025-10-30",
      "heure_retour": "17:30:00",
    };

    // Add schedule ride parameters if scheduling
    if (scheduleDateTime != null) {
      bodyParams["ride_sch_type"] = "schedule-ride";
      bodyParams["ride_date"] =
          "${scheduleDateTime.year}-${scheduleDateTime.month}-${scheduleDateTime.day}";
      bodyParams["ride_time"] =
          "${scheduleDateTime.hour}:${scheduleDateTime.minute}";
    }

    // Add discount code if applied
    if (discountCode != null && discountCode.isNotEmpty) {
      bodyParams["discount_code"] = discountCode;
      bodyParams["discount"] = discountAmount?.toString() ?? "0";
    }

    // Add package parameters if using package
    // Note: Payment method for extra amount will be set in _handlePackageBooking
    if (packageId != null && packageKmUsed != null) {
      bodyParams["payment"] = "Package";
      bodyParams["package_id"] = packageId;
      bodyParams["package_km_used"] = packageKmUsed.toString();
      // Don't set id_payment and statut_paiement here if there's extra amount
      // They will be set in _handlePackageBooking based on payment method
    }

    return bodyParams;
  }

  /// Handles complete ride booking flow with all payment types
  /// Returns true if booking was successful, false otherwise
  Future<bool> processRideBooking({
    required DriverData driverData,
    required double tripPrice,
    required bool isSchedule,
    DateTime? scheduleDateTime,
    String? discountCode,
    double? discountAmount,
    required BuildContext context,
  }) async {
    try {
      final paymentCtrl = Get.find<PaymentController>();
      paymentCtrl.paymentLoader = true;

      // Validate payment method
      // If package is selected and tripPrice > 0, payment method is required for extra amount
      // If package is selected and tripPrice == 0, no payment needed
      // If no package, payment method is always required
      final needsPayment =
          !usePackage.value || (usePackage.value && tripPrice > 0);

      if (needsPayment) {
        // Check if payment method is selected
        if (paymentMethodType.value == "select_method" ||
            paymentMethodType.value.isEmpty ||
            (!cash.value && !wallet.value && !uPayments.value)) {
          ShowToastDialog.showToast("Please select payment method".tr);
          paymentCtrl.paymentLoader = false;
          return false;
        }
      }

      // Prepare booking body parameters
      // For package with extra amount, pass original trip price to calculate correctly
      final originalTripPrice =
          usePackage.value && selectedUserPackage.value != null
          ? (tripPrice > 0
                ? tripPrice
                : 0.0) // If extra amount exists, use it; otherwise 0
          : tripPrice;

      final bodyParams = prepareBookingBodyParams(
        driverId: driverData.id?.toString() ?? '',
        tripPrice: originalTripPrice,
        discountCode: discountCode,
        discountAmount: discountAmount,
        scheduleDateTime: scheduleDateTime,
        packageId: usePackage.value && selectedUserPackage.value != null
            ? selectedUserPackage.value!.id.toString()
            : null,
        packageKmUsed: usePackage.value && selectedUserPackage.value != null
            ? distance.value
            : null,
      );

      // Handle Package payment
      if (usePackage.value && selectedUserPackage.value != null) {
        return await _handlePackageBooking(
          bodyParams: bodyParams,
          driverData: driverData,
          tripPrice: tripPrice, // Pass extra amount if any
          isSchedule: isSchedule,
          context: context,
        );
      }

      // Handle Cash payment
      if (paymentMethodType.value == "cash") {
        return await _handleCashBooking(
          bodyParams: bodyParams,
          isSchedule: isSchedule,
          context: context,
        );
      }

      // Handle Wallet payment
      if (paymentMethodType.value == "wallet") {
        return await _handleWalletBooking(
          bodyParams: bodyParams,
          driverData: driverData,
          tripPrice: tripPrice,
          discountCode: discountCode,
          discountAmount: discountAmount,
          isSchedule: isSchedule,
          scheduleDateTime: scheduleDateTime,
          context: context,
        );
      }

      // Handle UPayments (KNET, Credit Card & Others)
      if (paymentMethodType.value == "knet_credit_card_others") {
        return await _handleUPaymentsBooking(
          driverData: driverData,
          tripPrice: tripPrice,
          discountCode: discountCode,
          discountAmount: discountAmount,
          isSchedule: isSchedule,
          scheduleDateTime: scheduleDateTime,
          context: context,
        );
      }

      ShowToastDialog.showToast('payment_method_not_implemented'.tr);
      paymentCtrl.paymentLoader = false;
      return false;
    } catch (e) {
      final paymentCtrl = Get.find<PaymentController>();
      paymentCtrl.paymentLoader = false;
      ShowToastDialog.showToast('error_colon'.tr + e.toString());
      return false;
    }
  }

  /// Handles package-based booking
  /// If tripPrice > 0, processes payment for extra amount (zone charges)
  /// Then applies package KM to the ride
  Future<bool> _handlePackageBooking({
    required Map<String, dynamic> bodyParams,
    required DriverData driverData,
    required double tripPrice, // Extra amount to pay (zone charges)
    required bool isSchedule,
    required BuildContext context,
  }) async {
    try {
      final packageController = Get.find<PackageController>();
      final selectedPkg = selectedUserPackage.value;
      final rideDistance = distance.value;
      final paymentCtrl = Get.find<PaymentController>();

      ShowToastDialog.showLoader('booking_ride'.tr);

      // If there's an extra amount to pay, process payment first
      if (tripPrice > 0) {
        // Update bodyParams with payment method for extra amount
        if (paymentMethodType.value == "wallet") {
          // Check wallet balance
          final walletBalanceStr = paymentCtrl.walletAmount.value.toString();
          final walletBalance = double.tryParse(walletBalanceStr) ?? 0.0;

          if (walletBalance < tripPrice) {
            ShowToastDialog.closeLoader();
            ShowToastDialog.showToast(
              'not_enough_balance_wallet'.tr
                  .replaceAll(
                    '{amount1}',
                    Constant().amountShow(
                      amount: walletBalance.toStringAsFixed(2),
                    ),
                  )
                  .replaceAll(
                    '{amount2}',
                    Constant().amountShow(amount: tripPrice.toStringAsFixed(2)),
                  ),
            );
            paymentCtrl.paymentLoader = false;
            return false;
          }

          // Set wallet payment parameters
          bodyParams['id_payment'] = '9'; // Wallet payment ID
          bodyParams["statut_paiement"] = "yes";
          bodyParams["statut_payment"] = "yes";

          // Ensure the backend knows this is a wallet payment for extra amount
          // The package will be applied separately via applyToRide
        } else if (paymentMethodType.value == "cash") {
          bodyParams['id_payment'] = '1'; // Cash payment ID
          bodyParams["statut_paiement"] = "no";
          bodyParams["statut_payment"] = "no";
        } else if (paymentMethodType.value == "knet_credit_card_others" ||
            uPayments.value) {
          bodyParams['id_payment'] = paymentMethodId.value.isNotEmpty
              ? paymentMethodId.value
              : '8'; // Default UPayments ID
          bodyParams["statut_paiement"] = "no";
          bodyParams["statut_payment"] = "no";
          // UPayments will be handled separately after booking
        }

        // Update the amount to be paid (extra amount only)
        bodyParams['cout'] = tripPrice.toString();
      } else {
        // No extra amount - package covers everything
        bodyParams['id_payment'] = '10'; // Package payment ID
        bodyParams["statut_paiement"] = "yes";
        bodyParams["statut_payment"] = "yes";
        // Set cout to 0 since package covers everything
        bodyParams['cout'] = '0';
      }

      final response = isSchedule
          ? await scheduleRide(bodyParams)
          : await bookRide(bodyParams);

      if (response != null && response['success'] == "success") {
        final rideData = response['data'];
        String rideId = '';
        if (rideData is List && rideData.isNotEmpty) {
          rideId = rideData[0]['id']?.toString() ?? '';
        } else if (rideData is Map) {
          rideId = rideData['id']?.toString() ?? '';
        }

        // Process payment for extra amount
        if (tripPrice > 0 && rideId.isNotEmpty) {
          if (paymentMethodType.value == "wallet") {
            // Prepare wallet debit request for extra amount
            List taxList = [];
            for (var v in Constant.taxList) {
              taxList.add(v.toJson());
            }

            Map<String, dynamic> walletDebitBody = {
              'id_ride': rideId,
              'id_driver': driverData.id?.toString() ?? '',
              'id_user_app': Preferences.getInt(Preferences.userId).toString(),
              'amount': tripPrice.toString(), // Extra amount only
              'paymethod': "Wallet",
              'discount': "0", // Discount already applied in tripPrice
              'discount_code': null,
              'tip': "0",
              'tax': taxList,
              'transaction_id': DateTime.now().microsecondsSinceEpoch
                  .toString(),
              'commission': Preferences.getString(Preferences.admincommission),
              'payment_status': "success",
            };

            final walletResponse = await paymentCtrl.walletDebitAmountRequest(
              walletDebitBody,
            );

            if (walletResponse == null ||
                walletResponse['success'] != 'Success') {
              ShowToastDialog.closeLoader();
              ShowToastDialog.showToast(
                walletResponse?['error'] ?? 'wallet_payment_failed'.tr,
              );
              paymentCtrl.paymentLoader = false;
              return false;
            }
          } else if (paymentMethodType.value == "knet_credit_card_others" ||
              uPayments.value) {
            // Process UPayments (KNET) payment for extra amount
            final paymentResult = await _processUPaymentsForPackageExtraAmount(
              rideId: rideId,
              amount: tripPrice,
              driverData: driverData,
              isSchedule: isSchedule,
              context: context,
            );

            if (paymentResult != true) {
              ShowToastDialog.closeLoader();
              paymentCtrl.paymentLoader = false;
              return false;
            }
          }
          // Cash payment doesn't need processing - it's handled by driver
        }

        // Apply package to ride
        if (rideId.isNotEmpty) {
          await packageController.applyToRide(
            selectedPkg!.id.toString(),
            rideId,
            rideDistance,
          );
        }

        packageController.fetchUserPackages();
        packageController.fetchUsablePackages();

        ShowToastDialog.closeLoader();

        // Navigate immediately using off() to replace payment screen with success screen
        if (isSchedule) {
          Get.off(() => const ScheduledRidesScreen());
          ShowToastDialog.showToast('ride_scheduled_successfully'.tr);
        } else {
          Get.off(() => const RideBookingSuccessScreen());
          ShowToastDialog.showToast('ride_booked_using_package_km'.tr);
        }

        // Reset after a delay to avoid state changes affecting the success screen
        Future.delayed(const Duration(milliseconds: 500), () {
          _resetAfterBooking();
        });

        paymentCtrl.paymentLoader = false;
        return true;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(response?['error'] ?? 'booking_failed'.tr);
        paymentCtrl.paymentLoader = false;
        return false;
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      final paymentCtrl = Get.find<PaymentController>();
      paymentCtrl.paymentLoader = false;
      ShowToastDialog.showToast('booking_error'.tr + e.toString());
      return false;
    }
  }

  /// Processes UPayments (KNET) payment for package extra amount
  /// Returns true if payment successful, false otherwise
  Future<bool> _processUPaymentsForPackageExtraAmount({
    required String rideId,
    required double amount,
    required DriverData driverData,
    required bool isSchedule,
    required BuildContext context,
  }) async {
    try {
      final paymentCtrl = Get.find<PaymentController>();
      // User data is available via Constant.getUserData() if needed

      // Use PaymentController for UPayments payment
      final paymentController = Get.find<PaymentController>();
      final paymentUrl = await paymentController.processUPaymentsPaymentGeneric(
        amount: amount,
        productName: "Mshwar Ride - Package Extra Amount",
        productDescription:
            "Extra amount for zone charges (Package ride #$rideId)",
        customerExtraData: "ride_id:$rideId|package_extra_amount",
      );

      if (paymentUrl != null) {
        ShowToastDialog.closeLoader();

        // Open payment webview
        final result = await Get.to(
          () => PaymentWebViewScreen(url: paymentUrl, title: 'Payment'.tr),
        );

        // Check payment result
        if (result == null || result == false || result == 'false') {
          ShowToastDialog.showToast('payment_was_cancelled_declined'.tr);
          paymentCtrl.paymentLoader = false;
          return false;
        }

        // Process payment result URL
        if (result is String && result.contains('https')) {
          final uri = Uri.parse(result);
          final paymentDetails = uri.queryParameters;

          if (paymentDetails['result'] == 'FAILED' ||
              paymentDetails['result'] == 'CANCELD' ||
              paymentDetails['result'] == 'CANCELED' ||
              paymentDetails['result'] == 'NOT CAPTURED') {
            ShowToastDialog.showToast('payment_declined'.tr);
            paymentCtrl.paymentLoader = false;
            return false;
          } else if (paymentDetails['result'] == 'SUCCESS' ||
              paymentDetails['result'] == 'CAPTURED') {
            // Payment successful - update ride payment status
            // The backend webhook should handle this, but we can also call the payment API
            List taxList = [];
            for (var v in Constant.taxList) {
              taxList.add(v.toJson());
            }

            Map<String, dynamic> paymentUpdateBody = {
              'id_ride': rideId,
              'id_driver': driverData.id?.toString() ?? '',
              'id_user_app': Preferences.getInt(Preferences.userId).toString(),
              'amount': amount.toString(),
              'paymethod': "UPayments",
              'discount': "0",
              'discount_code': null,
              'tip': "0",
              'tax': taxList,
              'transaction_id':
                  paymentDetails['transaction_id'] ??
                  "${Preferences.getInt(Preferences.userId)}_${rideId}_${DateTime.now().millisecondsSinceEpoch}",
              'commission': Preferences.getString(Preferences.admincommission),
              'payment_status': "success",
            };

            // Update ride payment status via wallet payment API (it handles all payment types)
            final paymentUpdateResponse = await paymentCtrl
                .walletDebitAmountRequest(paymentUpdateBody);

            if (paymentUpdateResponse != null &&
                paymentUpdateResponse['success'] == 'Success') {
              return true;
            } else {
              ShowToastDialog.showToast('payment_processed_update_failed'.tr);
              // Still return true as payment was successful
              return true;
            }
          }
        }
      } else {
        ShowToastDialog.showToast('payment_initialization_failed'.tr);
        paymentCtrl.paymentLoader = false;
        return false;
      }
    } catch (e) {
      ShowToastDialog.showToast('payment_error_colon'.tr + e.toString());
      final paymentCtrl = Get.find<PaymentController>();
      paymentCtrl.paymentLoader = false;
      return false;
    }
    return false;
  }

  /// Handles cash payment booking
  Future<bool> _handleCashBooking({
    required Map<String, dynamic> bodyParams,
    required bool isSchedule,
    required BuildContext context,
  }) async {
    try {
      final paymentCtrl = Get.find<PaymentController>();
      final response = isSchedule
          ? await scheduleRide(bodyParams)
          : await bookRide(bodyParams);

      if (response != null && response['success'] == "success") {
        paymentCtrl.paymentLoader = false;

        // Navigate immediately using off() to replace payment screen with success screen
        if (isSchedule) {
          Get.off(() => const ScheduledRidesScreen());
          ShowToastDialog.showToast('ride_scheduled_successfully'.tr);
        } else {
          Get.off(() => const RideBookingSuccessScreen());
        }

        // Reset after a delay to avoid state changes affecting the success screen
        Future.delayed(const Duration(milliseconds: 500), () {
          _resetAfterBooking();
        });

        return true;
      }
      paymentCtrl.paymentLoader = false;
      return false;
    } catch (e) {
      final paymentCtrl = Get.find<PaymentController>();
      paymentCtrl.paymentLoader = false;
      ShowToastDialog.showToast('booking_error'.tr + e.toString());
      return false;
    }
  }

  /// Handles wallet payment booking
  Future<bool> _handleWalletBooking({
    required Map<String, dynamic> bodyParams,
    required DriverData driverData,
    required double tripPrice,
    String? discountCode,
    double? discountAmount,
    required bool isSchedule,
    DateTime? scheduleDateTime,
    required BuildContext context,
  }) async {
    try {
      final paymentCtrl = Get.find<PaymentController>();

      // Check wallet balance
      if (double.parse(paymentCtrl.walletAmount.value.toString()) <=
          tripPrice) {
        ShowToastDialog.showToast(
          "Oops! Not enough balance in your wallet.".tr,
        );
        paymentCtrl.paymentLoader = false;
        return false;
      }

      // Prepare wallet-specific body params
      Map<String, dynamic> bodyParamswallet = Map.from(bodyParams);
      bodyParamswallet['id_payment'] = '9';
      bodyParamswallet["statut_payment"] = "yes";

      if (discountCode != null && discountCode.isNotEmpty) {
        bodyParamswallet['discount_code'] = discountCode;
        bodyParamswallet['cout'] = tripPrice.toString();
      }

      final rideResponse = isSchedule
          ? await scheduleRide(bodyParamswallet)
          : await bookRide(bodyParamswallet);

      if (rideResponse != null && rideResponse['success'] == "success") {
        // Prepare wallet debit request
        List taxList = [];
        for (var v in Constant.taxList) {
          taxList.add(v.toJson());
        }

        String rideId = '';
        final rideData = rideResponse['data'];
        if (rideData is List && rideData.isNotEmpty) {
          rideId = rideData[0]['id']?.toString() ?? '';
        } else if (rideData is Map) {
          rideId = rideData['id']?.toString() ?? '';
        }

        Map<String, dynamic> walletDebitBody = {
          'id_ride': rideId,
          'id_driver': driverData.id?.toString() ?? '',
          'id_user_app': Preferences.getInt(Preferences.userId).toString(),
          'amount': tripPrice.toString(),
          'paymethod': "Wallet",
          'discount': discountAmount?.toString() ?? "0",
          'discount_code': discountCode,
          'tip': paymentCtrl.tipAmount.value.toString(),
          'tax': taxList,
          'transaction_id': DateTime.now().microsecondsSinceEpoch.toString(),
          'commission': Preferences.getString(Preferences.admincommission),
          'payment_status': "success",
        };

        final walletResponse = await paymentCtrl.walletDebitAmountRequest(
          walletDebitBody,
        );

        if (walletResponse != null && walletResponse['success'] == 'Success') {
          ShowToastDialog.showToast('payment_successfully_completed'.tr);
          paymentCtrl.paymentLoader = false;

          // Navigate immediately using off() to replace payment screen with success screen
          if (isSchedule) {
            Get.off(() => const ScheduledRidesScreen());
            ShowToastDialog.showToast('ride_scheduled_successfully'.tr);
          } else {
            Get.off(() => const RideBookingSuccessScreen());
          }

          // Reset after a delay to avoid state changes affecting the success screen
          Future.delayed(const Duration(milliseconds: 500), () {
            _resetAfterBooking();
          });

          return true;
        } else {
          paymentCtrl.paymentLoader = false;
          ShowToastDialog.closeLoader();
          return false;
        }
      }
      paymentCtrl.paymentLoader = false;
      return false;
    } catch (e) {
      final paymentCtrl = Get.find<PaymentController>();
      paymentCtrl.paymentLoader = false;
      ShowToastDialog.showToast('wallet_payment_error'.tr + e.toString());
      return false;
    }
  }

  /// Handles UPayments (KNET, Credit Card) booking
  Future<bool> _handleUPaymentsBooking({
    required DriverData driverData,
    required double tripPrice,
    String? discountCode,
    double? discountAmount,
    required bool isSchedule,
    DateTime? scheduleDateTime,
    required BuildContext context,
  }) async {
    try {
      final paymentCtrl = Get.find<PaymentController>();

      // Prepare stops list
      List stopsList = [];
      for (var i = 0; i < multiStopListNew.length; i++) {
        stopsList.add({
          "latitude": multiStopListNew[i].latitude.toString(),
          "longitude": multiStopListNew[i].longitude.toString(),
          "location": multiStopListNew[i].editingController.text.toString(),
        });
      }

      // Set discount code in payment controller if applied
      if (discountCode != null) {
        paymentCtrl.selectedPromoCode.value = discountCode;
        paymentCtrl.discountAmount.value = discountAmount ?? 0.0;
      }

      // Process UPayments payment
      await paymentCtrl.processUPaymentsPayment(
        amount: double.parse(tripPrice.toStringAsFixed(3)),
        context: context,
        controller: this,
        driverid: driverData.id?.toString() ?? '',
        stoplist: stopsList,
        onPaymentSuccess: () {},
        isSchedule: isSchedule,
        scheduleRideDateTime: scheduleDateTime,
      );

      // Note: processUPaymentsPayment handles navigation internally
      return true;
    } catch (e) {
      final paymentCtrl = Get.find<PaymentController>();
      paymentCtrl.paymentLoader = false;
      ShowToastDialog.showToast('${'payment_error'.tr}: ${e.toString()}');
      return false;
    }
  }

  /// Resets all booking-related state after successful booking
  void _resetAfterBooking() {
    destinationController.clear();
    polyLines.value = {};
    departureLatLong.value = const LatLng(0, 0);
    destinationLatLong.value = const LatLng(0, 0);
    usePackage.value = false;
    selectedUserPackage.value = null;
    markers.clear();
    clearData();
    // Don't call getDirections() here as it might trigger navigation or state changes
    // that affect the success screen
  }

  // ============ Search Destination Logic ============
  /// Validates search destination inputs
  String? validateSearchDestination() {
    // Check if vehicle category data has been loaded
    // This prevents validation from running before API call completes
    if (vehicleCategoryModel.value.data == null ||
        vehicleCategoryModel.value.data!.isEmpty) {
      log('Vehicle category data not loaded yet - attempting to reload...');
      // Try to reload vehicle data if not loaded
      return 'please_wait'.tr + ' - Loading vehicle types...';
    }

    // Check if vehicle is selected
    // Note: API already filters by status='Yes', so only enabled vehicles are returned
    // No need to check vehicle name - admin panel controls which vehicles are enabled
    if (vehicleData.value.id == null || vehicleData.value.id!.isEmpty) {
      log(
        'No vehicle selected - available vehicles: ${vehicleCategoryModel.value.data!.map((v) => v.libelle).join(", ")}',
      );
      return 'please_select_vehicle_type'.tr;
    }

    // Verify selected vehicle is still in the enabled list (handles cases where admin disabled it)
    final isVehicleEnabled = vehicleCategoryModel.value.data!.any(
      (v) =>
          v.id == vehicleData.value.id &&
          (v.status == 'Yes' || v.status == null),
    );

    if (!isVehicleEnabled) {
      log(
        'Selected vehicle (ID: ${vehicleData.value.id}) is no longer enabled - auto-selecting first available',
      );
      // Auto-select first available vehicle if current selection is invalid
      if (vehicleCategoryModel.value.data!.isNotEmpty) {
        vehicleData.value = vehicleCategoryModel.value.data![0];
        log(
          'Auto-selected new vehicle: ${vehicleData.value.libelle} (ID: ${vehicleData.value.id})',
        );
      } else {
        return 'please_select_vehicle_type'.tr;
      }
    }

    if (departureLatLong.value == const LatLng(0.0, 0.0)) {
      return 'please_enter_pickup_address'.tr;
    }

    if (destinationLatLong.value == const LatLng(0.0, 0.0)) {
      return 'please_enter_destination_address'.tr;
    }

    return null; // No errors
  }

  /// Processes search destination flow
  /// Returns true if successful and trip option bottom sheet should be shown
  Future<bool> processSearchDestination() async {
    try {
      // Get duration and distance
      final durationValue = await getDurationDistance(
        departureLatLong.value,
        destinationLatLong.value,
      );

      if (durationValue == null) {
        return false;
      }

      // Check pending payment
      final pendingPayment = await getUserPendingPayment();
      if (pendingPayment != null &&
          pendingPayment['success'] == "success" &&
          pendingPayment['data']['amount'] != 0) {
        // Has pending payment - should show dialog
        return false;
      }

      // Process distance and duration
      if (Constant.distanceUnit == "KM") {
        distance.value =
            durationValue['rows'].first['elements'].first['distance']['value'] /
            1000.00;
      } else {
        distance.value =
            durationValue['rows'].first['elements'].first['distance']['value'] /
            1609.34;
      }

      duration.value =
          durationValue['rows'].first['elements'].first['duration']['text'];

      confirmWidgetVisible.value = false;

      // Filter valid stops
      var dataMulti = multiStopListNew
          .where(
            (stop) =>
                stop.latitude.isNotEmpty &&
                stop.longitude.isNotEmpty &&
                stop.editingController.text.isNotEmpty,
          )
          .toList();

      multiStopListNew = dataMulti;
      multiStopList = List.from(dataMulti);

      // Calculate price
      // Map vehicle name to backend expected format (case-insensitive)
      final vehicleName =
          vehicleData.value.libelle?.toString().toLowerCase().trim() ?? '';
      final backendVehicleName = vehicleName == 'classic'
          ? 'classic'
          : vehicleName == 'business' || vehicleName == 'family'
          ? 'business'
          : 'classic'; // Default to classic if unknown

      log(
        'Calculating price for vehicle: ${vehicleData.value.libelle} (mapped to: $backendVehicleName)',
      );

      final priceResult = await getCalculatePrice({
        'name': backendVehicleName,
        'distance': distance.value.toStringAsFixed(2).toString(),
        'pickup_latitude': departureLatLong.value.latitude.toString(),
        'pickup_longitude': departureLatLong.value.longitude.toString(),
        'destination_latitude': destinationLatLong.value.latitude.toString(),
        'destination_longitude': destinationLatLong.value.longitude.toString(),
      });

      if (priceResult != null && priceResult['status'] == true) {
        return true; // Success - show trip option bottom sheet
      }

      return false;
    } catch (e) {
      showLog("Error in processSearchDestination: $e");
      ShowToastDialog.showToast(
        '${'error_processing_destination'.tr}: ${e.toString()}',
      );
      return false;
    }
  }

  /// Handles payment method selection from trip option bottom sheet
  /// Returns the driver data if successful, null otherwise
  Future<DriverData?> handlePaymentMethodSelection({
    required BuildContext context,
    required double tripPrice,
    double discountPrice = 0.0,
  }) async {
    try {
      // Get vehicle category
      final vehicleCategoryResult = await getVehicleCategory(false);
      if (vehicleCategoryResult == null ||
          vehicleCategoryResult.success != "Success") {
        return null;
      }

      update();

      if (vehicleData.value.id == null) {
        return null;
      }

      // Get driver details
      final driverResult = await getDriverDetails(
        vehicleData.value.id ?? '',
        departureLatLong.value.latitude.toString(),
        departureLatLong.value.longitude.toString(),
      );

      if (driverResult == null) {
        ShowToastDialog.showToast('unable_to_connect_server'.tr);
        return null;
      }

      if (driverResult.success != "Success") {
        ShowToastDialog.showToast(
          driverResult.error ?? 'unable_to_find_drivers'.tr,
        );
        return null;
      }

      if (driverResult.data?.isNotEmpty != true) {
        ShowToastDialog.showToast(
          driverResult.error ?? "no_drivers_available_in_your_area".tr,
        );
        return null;
      }

      // Set driver info
      final driverData = driverResult.data!.first;

      // Update wallet amount
      final paymentCtrl = Get.find<PaymentController>();
      var amount = await Constant().getAmount();
      if (amount != null) {
        walletAmount.value = amount;
        paymentCtrl.walletAmount.value = amount;
      } else {
        await paymentCtrl.getAmount();
      }

      paymentSettingModel.value = Constant.getPaymentSetting();

      return driverData;
    } catch (e) {
      showLog("Error in handlePaymentMethodSelection: $e");
      ShowToastDialog.showToast('error_colon'.tr + e.toString());
      return null;
    }
  }
}

class AddChildModel {
  TextEditingController editingController = TextEditingController();

  AddChildModel({required this.editingController});
}

class AddStopModel {
  String latitude = "";
  String longitude = "";
  TextEditingController editingController = TextEditingController();

  AddStopModel({
    required this.editingController,
    required this.latitude,
    required this.longitude,
  });
}
