import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/dash_board_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/controller/ride_details_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/driver_location_update.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/widget/driver_info_bottom_sheet.dart';
import 'package:v_one_mshwar_app_customer/features/ride/chat/view/conversation_screen.dart';
import 'package:v_one_mshwar_app_customer/service/eta_service.dart';
import 'package:v_one_mshwar_app_customer/core/themes/button_them.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/custom_alert_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/themes/custom_dialog_box.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/common/widget/StarRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart' hide LocationAccuracy;
import 'package:geolocator/geolocator.dart' as geo show LocationAccuracy;

class RouteViewScreen extends StatefulWidget {
  const RouteViewScreen({super.key});

  @override
  State<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen> {
  dynamic argumentData = Get.arguments;

  GoogleMapController? _controller;

  Map<PolylineId, Polyline> polyLines = {};

  PolylinePoints polylinePoints = PolylinePoints(
    apiKey: Constant.kGoogleApiKey!,
  );

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;
  BitmapDescriptor? stopIcon;

  late LatLng departureLatLong;
  late LatLng destinationLatLong;

  final Map<String, Marker> _markers = {};

  String? type;
  RideData? rideData;
  String driverEstimateArrivalTime = '';

  // Live map features
  bool showMyLocation = false;
  String? currentDriverStatus;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription? _driverLocationSubscription;
  StreamSubscription? _etaSubscription;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    getArgumentData();
    // Load icons FIRST before showing markers
    await setIcons();

    showLog('🗺️ Customer Map - Icons loaded successfully');

    // Use API key from constant, fail gracefully if not available
    final apiKey = Constant.kGoogleApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      showLog('⚠️ Google API key not configured');
      // Don't initialize ETA service without API key
    } else {
      etaService = ETAService(
        apiKey: apiKey,
        destLat: destinationLatLong.latitude,
        destLng: destinationLatLong.longitude,
      );
      etaService?.startTracking();
      _etaSubscription = etaService?.etaStream.listen((eta) {
        if (mounted) {
          showLog('Updated ETA: $eta');
          // You can update a widget here using setState or Provider/BLoC/etc.
        }
      });
    }

    // Now call getDirections after icons are loaded
    if (rideData!.statut == "on ride" || rideData!.statut == 'confirmed') {
      showLog(
        '🗺️ Customer Map - Starting driver location tracking after icon load...',
      );
      _startDriverLocationTracking();
      // Show pickup and destination markers first
      getDirections(dLat: 0.0, dLng: 0.0);
    } else {
      showLog(
        '🗺️ Customer Map - Showing completed ride route after icon load...',
      );
      getDirections(dLat: 0.0, dLng: 0.0);
    }
  }

  @override
  void dispose() {
    // Stop ETA tracking service
    etaService?.stopTracking();
    etaService = null;

    // Cancel subscriptions
    _etaSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    _positionSubscription?.cancel();
    _updateTimer?.cancel();

    // Dispose GoogleMapController safely
    if (_controller != null) {
      try {
        _controller!.dispose();
      } catch (e) {
        // Ignore disposal errors - common on iOS
        showLog('Error disposing GoogleMapController: $e');
      }
      _controller = null;
    }

    // Clear markers and polylines
    _markers.clear();
    polyLines.clear();

    super.dispose();
  }

  ETAService? etaService;

  final controllerRideDetails = Get.put(RideDetailsController());
  final controllerDashBoard = Get.put(DashBoardController());

  void getArgumentData() {
    if (argumentData != null) {
      type = argumentData['type'];
      rideData = argumentData['data'];

      departureLatLong = LatLng(
        double.parse(rideData!.latitudeDepart.toString()),
        double.parse(rideData!.longitudeDepart.toString()),
      );
      destinationLatLong = LatLng(
        double.parse(rideData!.latitudeArrivee.toString()),
        double.parse(rideData!.longitudeArrivee.toString()),
      );

      showLog('🗺️ Customer Map - Ride Status: ${rideData!.statut}');
      showLog(
        '🗺️ Customer Map - Pickup: ${departureLatLong.latitude}, ${departureLatLong.longitude}',
      );
      showLog(
        '🗺️ Customer Map - Destination: ${destinationLatLong.latitude}, ${destinationLatLong.longitude}',
      );
      showLog('🗺️ Customer Map - Driver ID: ${rideData!.idConducteur}');
    }
  }

  Future<void> setIcons() async {
    departureIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/icons/pickup.png",
    );

    destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/icons/dropoff.png",
    );

    taxiIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/icons/ic_taxi.png",
    );

    stopIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/icons/location.png",
    );
  }

  // Determine driver status based on ride status
  String _determineDriverStatus(
    String? rideStatus,
    DriverLocationUpdate? driverUpdate,
  ) {
    if (driverUpdate?.status != null && driverUpdate!.status!.isNotEmpty) {
      return driverUpdate.status!;
    }

    // Fallback: determine from ride status
    switch (rideStatus?.toLowerCase()) {
      case 'confirmed':
        return 'en-route';
      case 'on ride':
        return 'en-route';
      default:
        return 'online';
    }
  }

  // Show driver info bottom sheet when marker is clicked
  void _showDriverInfo(String driverMarkerId) {
    if (rideData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DriverInfoBottomSheet(
        rideData: rideData!,
        driverStatus: currentDriverStatus,
        isDarkMode: Provider.of<DarkThemeProvider>(
          context,
          listen: false,
        ).getThem(),
      ),
    );
  }

  // Toggle customer location on map
  void _toggleMyLocation() async {
    if (!showMyLocation) {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ShowToastDialog.showToast('Location permission denied'.tr);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ShowToastDialog.showToast(
          'Location permissions are permanently denied. Please enable them in settings.'
              .tr,
        );
        return;
      }

      // Start listening to location updates
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: geo.LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((Position position) {
            if (mounted) {
              setState(() {
                _markers['my_location'] = Marker(
                  markerId: const MarkerId('my_location'),
                  position: LatLng(position.latitude, position.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                  infoWindow: const InfoWindow(title: 'My Location'),
                );
              });
            }
          });

      setState(() {
        showMyLocation = true;
      });
    } else {
      // Stop location updates
      _positionSubscription?.cancel();
      setState(() {
        showMyLocation = false;
        _markers.remove('my_location');
      });
    }
  }

  // Start tracking driver location with configurable interval
  void _startDriverLocationTracking() {
    if (rideData == null ||
        (rideData!.statut != "on ride" && rideData!.statut != 'confirmed')) {
      return;
    }

    // Parse update interval from constant (default to 10 seconds)
    int updateIntervalSeconds =
        int.tryParse(Constant.driverLocationUpdate) ?? 10;
    // Ensure interval is between 5-15 seconds
    updateIntervalSeconds = updateIntervalSeconds.clamp(5, 15);

    // Cancel existing subscription
    _driverLocationSubscription?.cancel();
    _updateTimer?.cancel();

    showLog(
      '🗺️ Customer Map - Listening to driver location updates for ID: ${rideData!.idConducteur}',
    );

    // Set up driver location update listener
    _driverLocationSubscription = Constant.driverLocationUpdateCollection
        .doc(rideData!.idConducteur)
        .snapshots()
        .listen((event) async {
          if (!mounted) return;

          if (!event.exists) {
            showLog(
              '🗺️ Customer Map - Driver location document does not exist!',
            );
            return;
          }

          showLog(
            '🗺️ Customer Map - Received driver location update from Firebase',
          );

          DriverLocationUpdate driverLocationUpdate =
              DriverLocationUpdate.fromJson(
                event.data() as Map<String, dynamic>,
              );

          showLog(
            '🗺️ Customer Map - Driver Lat: ${driverLocationUpdate.driverLatitude}',
          );
          showLog(
            '🗺️ Customer Map - Driver Lng: ${driverLocationUpdate.driverLongitude}',
          );

          // Determine driver status
          currentDriverStatus = _determineDriverStatus(
            rideData!.statut,
            driverLocationUpdate,
          );

          // Calculate ETA
          try {
            Dio dio = Dio();
            dynamic response = await dio.get(
              "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${rideData!.latitudeDepart},${rideData!.longitudeDepart}&destinations=${double.parse(driverLocationUpdate.driverLatitude.toString())},${double.parse(driverLocationUpdate.driverLongitude.toString())}&key=${Constant.kGoogleApiKey}",
            );

            if (response.data['rows'] != null &&
                response.data['rows'].isNotEmpty &&
                response.data['rows'][0]['elements'] != null &&
                response.data['rows'][0]['elements'].isNotEmpty) {
              driverEstimateArrivalTime = response
                  .data['rows'][0]['elements'][0]['duration']['text']
                  .toString();
            }
          } catch (e) {
            showLog('Error calculating ETA: $e');
          }

          // Update driver position
          if (mounted) {
            setState(() {
              final driverLat = double.parse(
                driverLocationUpdate.driverLatitude.toString().isNotEmpty
                    ? driverLocationUpdate.driverLatitude.toString()
                    : "0.0",
              );
              final driverLng = double.parse(
                driverLocationUpdate.driverLongitude.toString().isNotEmpty
                    ? driverLocationUpdate.driverLongitude.toString()
                    : "0.0",
              );

              if (driverLat != 0.0 && driverLng != 0.0) {
                final driverLocation = LatLng(driverLat, driverLng);

                showLog(
                  '🗺️ Customer Map - Creating driver marker at: $driverLat, $driverLng',
                );
                showLog(
                  '🗺️ Customer Map - Taxi icon loaded: ${taxiIcon != null}',
                );

                // Create driver marker with taxi icon and click handler
                _markers['Driver'] = Marker(
                  markerId: const MarkerId('Driver'),
                  infoWindow: InfoWindow(
                    title:
                        '${rideData!.prenomConducteur ?? ''} ${rideData!.nomConducteur ?? ''}',
                    snippet: 'Status: ${currentDriverStatus ?? 'Unknown'}'.tr,
                  ),
                  position: driverLocation,
                  icon:
                      taxiIcon ??
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                  rotation: double.parse(
                    driverLocationUpdate.rotation.toString().isNotEmpty
                        ? driverLocationUpdate.rotation.toString()
                        : "0.0",
                  ),
                  onTap: () => _showDriverInfo('Driver'),
                );

                showLog(
                  '🗺️ Customer Map - Driver marker created. Total markers: ${_markers.length}',
                );

                // Update directions with driver's current location
                getDirections(dLat: driverLat, dLng: driverLng);
              } else {
                showLog(
                  '🗺️ Customer Map - Invalid driver coordinates: $driverLat, $driverLng',
                );
              }
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: showMyLocation,
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.8561, 2.2930),
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              if (mounted) {
                _controller = controller;
                try {
                  _controller?.moveCamera(
                    CameraUpdate.newLatLngZoom(departureLatLong, 12),
                  );
                } catch (e) {
                  // Handle iOS platform channel errors gracefully
                  showLog('Error moving camera: $e');
                }
              }
            },
            polylines: Set<Polyline>.of(polyLines.values),
            markers: _markers.values.toSet(),
          ),
          Positioned(
            top: 10,
            left: 5,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Directionality.of(context) == TextDirection.rtl
                      ? Matrix4.rotationY(3.14159)
                      : Matrix4.identity(),
                  child: Icon(
                    Iconsax.arrow_left_2,
                    size: 35,
                    color: AppThemeData.grey900,
                  ),
                ),
              ),
            ),
          ),
          // Toggle button for showing customer location
          if (rideData != null &&
              (rideData!.statut == "on ride" ||
                  rideData!.statut == 'confirmed'))
            Positioned(
              top: 60,
              right: 10,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeChange.getThem()
                        ? AppThemeData.surface50Dark
                        : AppThemeData.surface50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _toggleMyLocation,
                    icon: Icon(
                      showMyLocation ? Icons.my_location : Icons.location_off,
                      color: showMyLocation
                          ? AppThemeData.secondary200
                          : AppThemeData.grey400,
                      size: 24,
                    ),
                    tooltip: showMyLocation
                        ? 'Hide my location'.tr
                        : 'Show my location'.tr,
                  ),
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: themeChange.getThem()
                          ? AppThemeData.grey200Dark
                          : AppThemeData.grey200,
                    ),
                    color: themeChange.getThem()
                        ? AppThemeData.surface50Dark
                        : AppThemeData.surface50,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        if (rideData!.statut == 'confirmed')
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Driver Estimate Arrival Time : '.tr,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppThemeData.medium,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                    ),
                                  ),
                                ),
                                Text(
                                  driverEstimateArrivalTime,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.medium,
                                    color: AppThemeData.secondary200,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Visibility(
                          visible:
                              Constant.rideOtp.toString().toLowerCase() ==
                                      'yes'.toLowerCase() &&
                                  rideData!.statut == 'confirmed' &&
                                  rideData!.rideType != 'driver'
                              ? true
                              : false,
                          child: Column(
                            children: [
                              Divider(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey200Dark
                                    : AppThemeData.grey200,
                                thickness: 1,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'OTP : '.tr,
                                    style: TextStyle(
                                      fontFamily: AppThemeData.regular,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey400
                                          : AppThemeData.grey300Dark,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    rideData!.otp.toString(),
                                    style: TextStyle(
                                      letterSpacing: 1.2,
                                      fontFamily: AppThemeData.semiBold,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey200Dark
                                    : AppThemeData.grey200,
                                thickness: 1,
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: [
                        //       Expanded(
                        //         child: Padding(
                        //           padding: const EdgeInsets.only(left: 5.0),
                        //           child: Container(
                        //             height: 100,
                        //             decoration: BoxDecoration(
                        //                 border: Border.all(
                        //                   color: Colors.black12,
                        //                 ),
                        //                 borderRadius: const BorderRadius.all(Radius.circular(10))),
                        //             child: Padding(
                        //               padding: const EdgeInsets.symmetric(vertical: 20),
                        //               child: Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 children: [
                        //                   Image.asset(
                        //                     'assets/icons/passenger.png',
                        //                     height: 22,
                        //                     width: 22,
                        //                     color: AppThemeData.secondary200,
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.only(top: 8.0),
                        //                     child: Text(" ${rideData!.numberPoeple.toString()}",
                        //                         //DateFormat('\$ KK:mm a, dd MMM yyyy').format(date),
                        //                         style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black54)),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       Expanded(
                        //         child: Padding(
                        //           padding: const EdgeInsets.only(left: 5.0),
                        //           child: Container(
                        //             height: 100,
                        //             decoration: BoxDecoration(
                        //                 border: Border.all(
                        //                   color: Colors.black12,
                        //                 ),
                        //                 borderRadius: const BorderRadius.all(Radius.circular(10))),
                        //             child: Padding(
                        //               padding: const EdgeInsets.symmetric(vertical: 20),
                        //               child: Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 children: [
                        //                   Text(
                        //                     Constant.currency.toString(),
                        //                     style: TextStyle(
                        //                       color: AppThemeData.secondary200,
                        //                       fontWeight: FontWeight.bold,
                        //                       fontSize: 20,
                        //                     ),
                        //                   ),
                        //                   Text(
                        //                     Constant().amountShow(amount: rideData!.montant!.toString()),
                        //                     style: const TextStyle(
                        //                       fontWeight: FontWeight.w800,
                        //                       color: Colors.black54,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       Expanded(
                        //         child: Padding(
                        //           padding: const EdgeInsets.only(left: 5.0),
                        //           child: Container(
                        //             height: 100,
                        //             decoration: BoxDecoration(
                        //                 border: Border.all(
                        //                   color: Colors.black12,
                        //                 ),
                        //                 borderRadius: const BorderRadius.all(Radius.circular(10))),
                        //             child: Padding(
                        //               padding: const EdgeInsets.symmetric(vertical: 20),
                        //               child: Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 children: [
                        //                   Image.asset(
                        //                     'assets/icons/ic_distance.png',
                        //                     height: 22,
                        //                     width: 22,
                        //                     color: AppThemeData.secondary200,
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.only(top: 8.0),
                        //                     child: Text(
                        //                       "${rideData!.distance.toString()} ${rideData!.distanceUnit}",
                        //                       overflow: TextOverflow.ellipsis,
                        //                       style: const TextStyle(
                        //                         fontWeight: FontWeight.w800,
                        //                         color: Colors.black54,
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       Expanded(
                        //         child: Padding(
                        //           padding: const EdgeInsets.only(left: 5.0),
                        //           child: Container(
                        //             height: 100,
                        //             decoration: BoxDecoration(
                        //                 border: Border.all(
                        //                   color: Colors.black12,
                        //                 ),
                        //                 borderRadius: const BorderRadius.all(Radius.circular(10))),
                        //             child: Padding(
                        //               padding: const EdgeInsets.symmetric(vertical: 20),
                        //               child: Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 children: [
                        //                   Image.asset(
                        //                     'assets/icons/time.png',
                        //                     height: 22,
                        //                     width: 22,
                        //                     color: AppThemeData.secondary200,
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.only(top: 8.0),
                        //                     child: Text(
                        //                       rideData!.duree.toString(),
                        //                       overflow: TextOverflow.ellipsis,
                        //                       style: const TextStyle(
                        //                         fontWeight: FontWeight.w800,
                        //                         color: Colors.black54,
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: rideData!.statut == 'confirmed' ? 10 : 0,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(80),
                                child:
                                    (rideData!.photoPath != null &&
                                        rideData!.photoPath
                                            .toString()
                                            .isNotEmpty &&
                                        rideData!.photoPath.toString() !=
                                            'null')
                                    ? CachedNetworkImage(
                                        imageUrl: rideData!.photoPath
                                            .toString(),
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Constant.loader(context),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                              "assets/icons/appLogo.png",
                                            ),
                                      )
                                    : Image.asset(
                                        "assets/icons/appLogo.png",
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${rideData!.prenomConducteur.toString()} ${rideData!.nomConducteur.toString()}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                        fontSize: 16,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        StarRating(
                                          size: 20,
                                          rating: rideData!.moyenne != "null"
                                              ? double.parse(
                                                  rideData!.moyenne.toString(),
                                                )
                                              : 0.0,
                                          color: AppThemeData.secondary200,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Visibility(
                                          visible:
                                              rideData!.statut == "confirmed"
                                              ? true
                                              : false,
                                          child: InkWell(
                                            onTap: () {
                                              Get.to(
                                                ConversationScreen(),
                                                arguments: {
                                                  'receiverId': int.parse(
                                                    rideData!.idConducteur
                                                        .toString(),
                                                  ),
                                                  'orderId': int.parse(
                                                    rideData!.id.toString(),
                                                  ),
                                                  'receiverName':
                                                      "${rideData!.prenomConducteur} ${rideData!.nomConducteur}",
                                                  'receiverPhoto':
                                                      rideData!.photoPath,
                                                },
                                              );
                                            },
                                            child: Image.asset(
                                              'assets/icons/chat_icon.png',
                                              height: 40,
                                              width: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        rideData!.statut != "rejected"
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 10,
                                                ),
                                                child: InkWell(
                                                  onTap: () async {
                                                    ShowToastDialog.showLoader(
                                                      "Please wait".tr,
                                                    );
                                                    final Location
                                                    currentLocation =
                                                        Location();
                                                    LocationData location =
                                                        await currentLocation
                                                            .getLocation();
                                                    await Share.share(
                                                      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
                                                      subject:
                                                          "v_one_mshwar_app_customer"
                                                              .tr,
                                                    );
                                                    // await FlutterShareMe()
                                                    //     .shareToWhatsApp(msg: 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppThemeData
                                                          .secondary200,
                                                    ),
                                                    child: Icon(
                                                      Iconsax.share,
                                                      size: 20,
                                                      color:
                                                          themeChange.getThem()
                                                          ? AppThemeData
                                                                .surface50Dark
                                                          : AppThemeData
                                                                .surface50,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const Offstage(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Constant.makePhoneCall(
                                                rideData!.driverPhone
                                                    .toString(),
                                              );
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppThemeData.warning200,
                                              ),
                                              child: Icon(
                                                Iconsax.call,
                                                size: 20,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.surface50Dark
                                                    : AppThemeData.surface50,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: rideData!.statut == "on ride"
                                              ? true
                                              : false,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: ButtonThem.buildButton(
                                              context,
                                              radius: 5,
                                              txtSize: 12,
                                              title: 'sos'.tr,
                                              btnHeight: 40,
                                              btnWidthRatio: 0.15,
                                              onPress: () async {
                                                LocationData location =
                                                    await Location()
                                                        .getLocation();
                                                Map<String, dynamic>
                                                bodyParams = {
                                                  'lat': location.latitude,
                                                  'lng': location.longitude,
                                                  'ride_id': rideData!.id,
                                                };
                                                controllerRideDetails
                                                    .sos(bodyParams)
                                                    .then((value) {
                                                      if (value != null) {
                                                        if (value['success'] ==
                                                            "success") {
                                                          ShowToastDialog.showToast(
                                                            value['message'],
                                                          );
                                                        }
                                                      }
                                                    });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      rideData!.dateRetour.toString(),
                                      style: TextStyle(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                        fontFamily: AppThemeData.medium,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Visibility(
                      visible: rideData!.statut == "on ride" ? true : false,
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ButtonThem.buildButton(
                            context,
                            title: 'I do not feel safe'.tr,
                            btnWidthRatio: 1,
                            onPress: () async {
                              LocationData location = await Location()
                                  .getLocation();
                              Map<String, dynamic> bodyParams = {
                                'lat': location.latitude,
                                'lng': location.longitude,
                                'user_id': Preferences.getInt(
                                  Preferences.userId,
                                ).toString(),
                                'user_name':
                                    "${controllerRideDetails.userModel!.data!.prenom} ${controllerRideDetails.userModel!.data!.nom}",
                                'user_cat': controllerRideDetails
                                    .userModel!
                                    .data!
                                    .userCat,
                                'id_driver': rideData!.idConducteur,
                                'feel_safe': 0,
                                'trip_id': rideData!.id,
                              };
                              controllerRideDetails
                                  .feelNotSafe(bodyParams)
                                  .then((value) {
                                    if (value != null) {
                                      if (value['success'] == "success") {
                                        ShowToastDialog.showToast(
                                          "Report submitted".tr,
                                        );
                                      }
                                    }
                                  });
                            },
                          ),
                        ),
                      ),
                    ),
                    // Visibility(
                    //   visible: rideData!.statut == "confirmed" ? true : false,
                    //   child: Expanded(
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(bottom: 5),
                    //       child: ButtonThem.buildButton(
                    //         context,
                    //         title: 'Conform Ride'.tr,
                    //         btnHeight: 45,
                    //         btnWidthRatio: 0.8,
                    //         btnColor: AppThemeData.primary200,
                    //         txtColor: Colors.white,
                    //         onPress: () async {
                    //           showDialog(
                    //             barrierColor: Colors.black26,
                    //             context: context,
                    //             builder: (context) {
                    //               return CustomAlertDialog(
                    //                 title: "Do you want to confirm this ride?",
                    //                 onPressNegative: () {
                    //                   Get.back();
                    //                 },
                    //                 onPressPositive: () {
                    //                   Map<String, dynamic> bodyParams = {
                    //                     'id_ride': rideData!.id.toString(),
                    //                     'id_user': rideData!.idConducteur.toString(),
                    //                     'use_name': rideData!.prenomConducteur.toString(),
                    //                     'car_driver_confirmed': 1,
                    //                     'from_id': Preferences.getInt(Preferences.userId).toString(),
                    //                   };
                    //                   controllerRideDetails.setConformRequest(bodyParams).then((value) {
                    //                     if (value != null) {
                    //                       Get.back();
                    //                       showDialog(
                    //                           context: context,
                    //                           builder: (BuildContext context) {
                    //                             return CustomDialogBox(
                    //                               title: "On ride Successfully",
                    //                               descriptions: "Ride Successfully On ride .",
                    //                               onPress: () {
                    //                                 Get.back();
                    //                                 controllerDashBoard.onSelectItem(4);
                    //                               },
                    //                               img: Image.asset('assets/images/green_checked.png'),
                    //                             );
                    //                           });
                    //                     }
                    //                   });
                    //                 },
                    //               );
                    //             },
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Visibility(
                      visible: rideData!.statut == "on ride" ? true : false,
                      child: const SizedBox(width: 10),
                    ),
                    Visibility(
                      visible: rideData!.statut == "rejected" ? false : true,
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ButtonThem.buildButton(
                            context,
                            btnColor: AppThemeData.error200,
                            title: 'Cancel Ride'.tr,
                            btnWidthRatio: 1,
                            onPress: () async {
                              buildShowBottomSheet(
                                context,
                                themeChange.getThem(),
                              );
                              // showDialog(
                              //   barrierColor: Colors.black26,
                              //   context: context,
                              //   builder: (context) {
                              //     return CustomAlertDialog(
                              //       title: "Do you want to cancel this booking?",
                              //       onPressNegative: () {
                              //         Get.back();
                              //       },
                              //       onPressPositive: () {
                              //         Map<String, String> bodyParams = {
                              //           'id_ride': rideData!.id.toString(),
                              //           'id_user': rideData!.idConducteur.toString(),
                              //           'name': rideData!.prenom.toString(),
                              //           'from_id': Preferences.getInt(Preferences.userId).toString(),
                              //           'user_cat': controllerRideDetails.userModel!.data!.userCat.toString(),
                              //         };
                              //         controllerRideDetails.canceledRide(bodyParams).then((value) {
                              //           Get.back();
                              //           if (value != null) {
                              //             showDialog(
                              //                 context: context,
                              //                 builder: (BuildContext context) {
                              //                   return CustomDialogBox(
                              //                     title: "Cancel Successfully",
                              //                     descriptions: "Ride Successfully cancel.",
                              //                     onPress: () {
                              //                       Get.back();
                              //                       controllerDashBoard.onSelectItem(4);
                              //                     },
                              //                     img: Image.asset('assets/images/green_checked.png'),
                              //                   );
                              //                 });
                              //           }
                              //         });
                              //       },
                              //     );
                              //   },
                              // );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final resonController = TextEditingController();

  Future buildShowBottomSheet(BuildContext context, bool isDarkMode) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          topLeft: Radius.circular(15),
        ),
      ),
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: isDarkMode
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 10,
              ),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Cancel Trip".tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: AppThemeData.semiBold,
                          color: isDarkMode
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Write a reason for trip cancellation".tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppThemeData.regular,
                          color: isDarkMode
                              ? AppThemeData.grey400
                              : AppThemeData.grey300Dark,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextFieldWidget(
                        maxLine: 3,
                        controller: resonController,
                        hintText: '',
                        fontSize: 14,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ButtonThem.buildButton(
                                context,
                                title: 'Cancel Trip'.tr,
                                btnWidthRatio: 0.8,
                                onPress: () async {
                                  if (resonController.text.isNotEmpty) {
                                    Get.back();
                                    showDialog(
                                      barrierColor: Colors.black26,
                                      context: context,
                                      builder: (context) {
                                        return CustomAlertDialog(
                                          title:
                                              "Do you want to cancel this booking?"
                                                  .tr,
                                          onPressNegative: () {
                                            Get.back();
                                          },
                                          onPressPositive: () {
                                            Map<String, String> bodyParams = {
                                              'id_ride': rideData!.id
                                                  .toString(),
                                              'id_user': rideData!.idConducteur
                                                  .toString(),
                                              'name':
                                                  "${rideData!.prenom} ${rideData!.nom}",
                                              'from_id': Preferences.getInt(
                                                Preferences.userId,
                                              ).toString(),
                                              'user_cat': controllerRideDetails
                                                  .userModel!
                                                  .data!
                                                  .userCat
                                                  .toString(),
                                              'reason': resonController.text
                                                  .toString(),
                                            };
                                            controllerRideDetails
                                                .canceledRide(bodyParams)
                                                .then((value) {
                                                  Get.back();
                                                  if (value != null) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return CustomDialogBox(
                                                          title:
                                                              "Cancel Successfully"
                                                                  .tr,
                                                          descriptions:
                                                              "Ride Successfully cancel."
                                                                  .tr,
                                                          onPress: () {
                                                            Get.back();
                                                            Get.back();
                                                            Get.back();
                                                          },
                                                          img: Image.asset(
                                                            'assets/images/green_checked.png',
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                });
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    ShowToastDialog.showToast(
                                      "Please enter a reason",
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 5,
                                left: 10,
                              ),
                              child: ButtonThem.buildBorderButton(
                                context,
                                title: 'Close'.tr,
                                btnWidthRatio: 0.8,
                                btnColor: isDarkMode
                                    ? AppThemeData.surface50Dark
                                    : AppThemeData.surface50,
                                txtColor: AppThemeData.primary200,
                                btnBorderColor: AppThemeData.primary200,
                                onPress: () async {
                                  Get.back();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> getDirections({
    required double dLat,
    required double dLng,
  }) async {
    showLog(
      '🗺️ Customer Map - getDirections called with driver location: $dLat, $dLng',
    );
    showLog('🗺️ Customer Map - Ride status: ${rideData!.statut}');
    showLog(
      '🗺️ Customer Map - Icons loaded - Departure: ${departureIcon != null}, Destination: ${destinationIcon != null}, Taxi: ${taxiIcon != null}',
    );

    List<LatLng> polylineCoordinates = [];
    PolylineResult result;
    List<PolylineWayPoint> wayPointList = [];
    for (var i = 0; i < rideData!.stops!.length; i++) {
      wayPointList.add(
        PolylineWayPoint(location: rideData!.stops![i].location!),
      );
    }

    // Show pickup marker for ALL active rides
    if (rideData!.statut != "completed" && rideData!.statut != "rejected") {
      // Show pickup marker for active rides
      showLog(
        '🗺️ Customer Map - Creating Pickup marker (status: ${rideData!.statut})',
      );
      _markers['Pickup'] = Marker(
        markerId: const MarkerId('Pickup'),
        infoWindow: InfoWindow(title: "Pickup Location".tr),
        position: LatLng(
          double.parse(rideData!.latitudeDepart.toString()),
          double.parse(rideData!.longitudeDepart.toString()),
        ),
        icon:
            departureIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
    }

    // Always show destination marker
    showLog('🗺️ Customer Map - Creating Destination marker');
    _markers['Destination'] = Marker(
      markerId: const MarkerId('Destination'),
      infoWindow: InfoWindow(title: "Destination".tr),
      position: destinationLatLong,
      icon:
          destinationIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    showLog(
      '🗺️ Customer Map - Markers created. Total: ${_markers.length}. Keys: ${_markers.keys.toList()}',
    );

    // Add stop markers if any
    for (var i = 0; i < rideData!.stops!.length; i++) {
      _markers['Stop_$i'] = Marker(
        markerId: MarkerId('Stop_$i'),
        infoWindow: InfoWindow(title: rideData!.stops![i].location!),
        position: LatLng(
          double.parse(rideData!.stops![i].latitude!),
          double.parse(rideData!.stops![i].longitude!),
        ),
        icon: stopIcon!,
      );
    }

    // Get route based on ride status
    if (rideData!.statut == "confirmed") {
      // Driver coming to pickup: route from driver to pickup location
      if (dLat != 0.0 && dLng != 0.0) {
        PolylineRequest requestData = PolylineRequest(
          wayPoints: [],
          optimizeWaypoints: true,
          mode: TravelMode.driving,
          origin: PointLatLng(dLat, dLng),
          destination: PointLatLng(
            double.parse(rideData!.latitudeDepart.toString()),
            double.parse(rideData!.longitudeDepart.toString()),
          ),
        );
        result = await polylinePoints.getRouteBetweenCoordinates(
          request: requestData,
        );
      } else {
        // No driver location yet, show route from pickup to destination
        PolylineRequest requestData = PolylineRequest(
          wayPoints: wayPointList,
          optimizeWaypoints: true,
          mode: TravelMode.driving,
          origin: PointLatLng(
            double.parse(rideData!.latitudeDepart.toString()),
            double.parse(rideData!.longitudeDepart.toString()),
          ),
          destination: PointLatLng(
            destinationLatLong.latitude,
            destinationLatLong.longitude,
          ),
        );
        result = await polylinePoints.getRouteBetweenCoordinates(
          request: requestData,
        );
      }
    } else if (rideData!.statut == "on ride") {
      // Driver on trip: route from driver to destination
      if (dLat != 0.0 && dLng != 0.0) {
        PolylineRequest requestData = PolylineRequest(
          wayPoints: wayPointList,
          optimizeWaypoints: true,
          mode: TravelMode.driving,
          origin: PointLatLng(dLat, dLng),
          destination: PointLatLng(
            destinationLatLong.latitude,
            destinationLatLong.longitude,
          ),
        );
        result = await polylinePoints.getRouteBetweenCoordinates(
          request: requestData,
        );
      } else {
        // Fallback
        PolylineRequest requestData = PolylineRequest(
          wayPoints: wayPointList,
          optimizeWaypoints: true,
          mode: TravelMode.driving,
          origin: PointLatLng(
            departureLatLong.latitude,
            departureLatLong.longitude,
          ),
          destination: PointLatLng(
            destinationLatLong.latitude,
            destinationLatLong.longitude,
          ),
        );
        result = await polylinePoints.getRouteBetweenCoordinates(
          request: requestData,
        );
      }
    } else {
      // Default: route from pickup to destination
      PolylineRequest requestData = PolylineRequest(
        wayPoints: wayPointList,
        optimizeWaypoints: true,
        mode: TravelMode.driving,
        origin: PointLatLng(
          departureLatLong.latitude,
          departureLatLong.longitude,
        ),
        destination: PointLatLng(
          destinationLatLong.latitude,
          destinationLatLong.longitude,
        ),
      );
      result = await polylinePoints.getRouteBetweenCoordinates(
        request: requestData,
      );
    }

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      showLog(
        '🗺️ Customer Map - Route points received: ${result.points.length}',
      );
    } else {
      showLog('🗺️ Customer Map - No route points received!');
      showLog('🗺️ Customer Map - Error message: ${result.errorMessage}');
      showLog('🗺️ Customer Map - Status: ${result.status}');

      // If no route available, draw a straight line at least
      if (polylineCoordinates.isEmpty) {
        showLog('🗺️ Customer Map - Drawing straight line fallback');
        polylineCoordinates.add(
          LatLng(
            double.parse(rideData!.latitudeDepart.toString()),
            double.parse(rideData!.longitudeDepart.toString()),
          ),
        );
        polylineCoordinates.add(destinationLatLong);
      }
    }

    addPolyLine(polylineCoordinates);
    showLog(
      '🗺️ Customer Map - getDirections completed. Markers: ${_markers.keys.toList()}',
    );
  }

  void addPolyLine(List<LatLng> polylineCoordinates) {
    if (polylineCoordinates.isEmpty) return;

    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: AppThemeData.primary200,
      points: polylineCoordinates,
      width: 8, // Increased width for better visibility
      geodesic: true,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );
    polyLines[id] = polyline;

    if (mounted) {
      updateCameraLocation(
        polylineCoordinates.first,
        polylineCoordinates.last,
        _controller,
      );

      setState(() {});
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

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
    CameraUpdate cameraUpdate,
    GoogleMapController mapController,
  ) async {
    try {
      await mapController.animateCamera(cameraUpdate);
      LatLngBounds l1 = await mapController.getVisibleRegion();
      LatLngBounds l2 = await mapController.getVisibleRegion();

      if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
        return checkCameraLocation(cameraUpdate, mapController);
      }
    } on PlatformException catch (e) {
      // Handle iOS platform channel errors gracefully
      showLog('PlatformException in checkCameraLocation: $e');
    } catch (e) {
      showLog('Error in checkCameraLocation: $e');
    }
  }
}
