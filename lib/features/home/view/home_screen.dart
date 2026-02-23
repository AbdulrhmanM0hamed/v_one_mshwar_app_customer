import 'package:v_one_mshwar_app_customer/common/widget/button.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/dash_board_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/dashboard.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/loading_screen.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/home_app_bar.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/location_text_field.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/vehicle_selection_card.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/pending_payment_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/route_wrapper_widget.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/sheets/trip_option_sheet.dart';
import 'package:v_one_mshwar_app_customer/features/home/widget/floating_search_bar.dart';

DateTime? scheduleRideDateTime;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final dashBoardController = Get.put(DashBoardController());
  final HomeController homeController = Get.put(HomeController());
  final PaymentController paymentCtrl = Get.put(PaymentController());
  double discountPrice = 0.0;
  int clickIndex = -1;

  @override
  void initState() {
    super.initState();
    initVehicleData();
  }

  Future<void> initVehicleData() async {
    await paymentCtrl.getCoupanCodeData();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildAppDrawer(context, dashBoardController),
      body: GetX<HomeController>(
        builder: (controller) {
          return Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              if (Constant.homeScreenType == 'OlaHome')
                Container(
                  color: AppThemeData.primary200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 3, child: SizedBox()),
                      Expanded(
                        flex: 13,
                        child: Container(
                          color: themeChange.getThem()
                              ? AppThemeData.surface50Dark
                              : AppThemeData.surface50,
                        ),
                      ),
                    ],
                  ),
                ),
              controller.isHomePageLoading.value
                  ? LoadingScreen(controller: controller)
                  : RouteWrapperWidget(
                      child: Column(
                        children: [
                          Constant.homeScreenType == 'OlaHome'
                              ? SafeArea(child: SizedBox(height: 30))
                              : SizedBox(),
                          if (Constant.homeScreenType != 'OlaHome')
                            Expanded(
                              child: Stack(
                                children: [
                                  GoogleMap(
                                    key: const ValueKey('google_map_home'),
                                    zoomControlsEnabled: false,
                                    myLocationButtonEnabled: false,
                                    padding: const EdgeInsets.only(top: 8.0),
                                    compassEnabled: false,
                                    initialCameraPosition: const CameraPosition(
                                      target: LatLng(29.3117, 47.4818),
                                      zoom: 2,
                                    ),
                                    minMaxZoomPreference:
                                        const MinMaxZoomPreference(2, 20.0),
                                    buildingsEnabled: false,
                                    onMapCreated: (GoogleMapController mapcontrollerdata) {
                                      controller.mapController =
                                          mapcontrollerdata;

                                      // Use cached location if available for instant navigation
                                      if (controller
                                              .cachedCurrentLocation
                                              .value !=
                                          null) {
                                        controller.mapController!.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: controller
                                                  .cachedCurrentLocation
                                                  .value!,
                                              zoom: 14.0,
                                            ),
                                          ),
                                        );
                                      } else if (controller
                                              .departureLatLong
                                              .value !=
                                          const LatLng(0.0, 0.0)) {
                                        // Fallback to departure location if set
                                        controller.mapController!.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: controller
                                                  .departureLatLong
                                                  .value,
                                              zoom: 14.0,
                                            ),
                                          ),
                                        );
                                      }
                                      // If no location available yet, the map will be updated
                                      // when getCurrentLocation() completes
                                    },
                                    polylines: Set<Polyline>.of(
                                      controller.polyLines.values,
                                    ),
                                    markers: controller.markers.values.toSet(),
                                    onTap: (LatLng tappedPoint) async {
                                      if (controller.isSelectingStart.value) {
                                        controller.markers.remove('Departure');
                                        controller.setDepartureMarker(
                                          tappedPoint,
                                        );
                                        controller.startPoint.value =
                                            tappedPoint;

                                        String address = await controller
                                            .getAddressFromLatLng(tappedPoint);
                                        controller.departureController.text =
                                            address;
                                        if (controller.departureLatLong.value !=
                                                LatLng(0.0, 0.0) &&
                                            controller
                                                    .destinationLatLong
                                                    .value !=
                                                LatLng(0.0, 0.0)) {
                                          await controller
                                              .getDurationDistance(
                                                controller
                                                    .departureLatLong
                                                    .value,
                                                controller
                                                    .destinationLatLong
                                                    .value,
                                              )
                                              .then((durationValue) {
                                                if (durationValue != null) {
                                                  if (Constant.distanceUnit ==
                                                      "KM") {
                                                    controller.distance.value =
                                                        durationValue['rows']
                                                            .first['elements']
                                                            .first['distance']['value'] /
                                                        1000.00;
                                                  } else {
                                                    controller.distance.value =
                                                        durationValue['rows']
                                                            .first['elements']
                                                            .first['distance']['value'] /
                                                        1609.34;
                                                  }

                                                  controller.duration.value =
                                                      durationValue['rows']
                                                          .first['elements']
                                                          .first['duration']['text'];
                                                }
                                              });
                                        }
                                      } else if (controller
                                          .isSelectingDestination
                                          .value) {
                                        controller.markers.remove(
                                          'Destination',
                                        );
                                        controller.setDestinationMarker(
                                          tappedPoint,
                                        );
                                        controller.endPoint.value = tappedPoint;

                                        String address = await controller
                                            .getAddressFromLatLng(tappedPoint);
                                        controller.destinationController.text =
                                            address;
                                        if (controller.departureLatLong.value !=
                                                LatLng(0.0, 0.0) &&
                                            controller
                                                    .destinationLatLong
                                                    .value !=
                                                LatLng(0.0, 0.0)) {
                                          await controller
                                              .getDurationDistance(
                                                controller
                                                    .departureLatLong
                                                    .value,
                                                controller
                                                    .destinationLatLong
                                                    .value,
                                              )
                                              .then((durationValue) {
                                                if (durationValue != null) {
                                                  if (Constant.distanceUnit ==
                                                      "KM") {
                                                    controller.distance.value =
                                                        durationValue['rows']
                                                            .first['elements']
                                                            .first['distance']['value'] /
                                                        1000.00;
                                                  } else {
                                                    controller.distance.value =
                                                        durationValue['rows']
                                                            .first['elements']
                                                            .first['distance']['value'] /
                                                        1609.34;
                                                  }

                                                  controller.duration.value =
                                                      durationValue['rows']
                                                          .first['elements']
                                                          .first['duration']['text'];
                                                }
                                              });
                                        }
                                      }
                                    },
                                  ),
                                  // Floating search bar over the map with menu button
                                  FloatingSearchBar(
                                    controller: controller,
                                    isDarkMode: themeChange.getThem(),
                                    onMenuTap: () {
                                      _scaffoldKey.currentState?.openDrawer();
                                    },
                                  ),
                                  // Current location button (bottom right)
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Column(
                                      children: [
                                        // Zoom in button
                                        GestureDetector(
                                          onTap: () {
                                            controller.mapController
                                                ?.animateCamera(
                                                  CameraUpdate.zoomIn(),
                                                );
                                          },
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.surface50Dark
                                                  : AppThemeData.surface50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 10,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Iconsax.add,
                                              color: AppThemeData.primary200,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Zoom out button
                                        GestureDetector(
                                          onTap: () {
                                            controller.mapController
                                                ?.animateCamera(
                                                  CameraUpdate.zoomOut(),
                                                );
                                          },
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.surface50Dark
                                                  : AppThemeData.surface50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 10,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Iconsax.minus,
                                              color: AppThemeData.primary200,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Current location button
                                        GestureDetector(
                                          onTap: () async {
                                            showLog('pressed button');
                                            await controller.getCurrentLocation(
                                              true,
                                            );
                                            // Animate to current location
                                            if (controller
                                                    .departureLatLong
                                                    .value !=
                                                const LatLng(0.0, 0.0)) {
                                              controller.mapController
                                                  ?.animateCamera(
                                                    CameraUpdate.newCameraPosition(
                                                      CameraPosition(
                                                        target: controller
                                                            .departureLatLong
                                                            .value,
                                                        zoom: 15.0,
                                                      ),
                                                    ),
                                                  );
                                            }
                                          },
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.surface50Dark
                                                  : AppThemeData.surface50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 10,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: Image(
                                              image: AssetImage(
                                                'assets/icons/pickup.png',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Column(
                            children: [
                              if (Constant.homeScreenType == 'OlaHome')
                                HomeAppBar(
                                  controller: controller,
                                  isDarkMode: themeChange.getThem(),
                                  scaffoldKey: _scaffoldKey,
                                ),
                              Container(
                                padding: EdgeInsets.only(
                                  top: Constant.homeScreenType == 'OlaHome'
                                      ? 10
                                      : 0,
                                ),
                                color: themeChange.getThem()
                                    ? AppThemeData.surface50Dark
                                    : AppThemeData.surface50,
                                child: Theme(
                                  data: ThemeData(
                                    tabBarTheme: TabBarThemeData(
                                      indicatorColor: AppThemeData.primary200,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              Constant.homeScreenType ==
                                                  'OlaHome'
                                              ? 0
                                              : 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 16),
                                            CustomText(
                                              text: 'enter_destination'.tr,
                                              size: 18,
                                              weight: FontWeight.bold,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey900Dark
                                                  : AppThemeData.grey900,
                                            ),
                                            const SizedBox(height: 10),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                LocationTextField(
                                                  controller: controller,
                                                  label: 'departure'.tr,
                                                  hintText:
                                                      'pick_up_location'.tr,
                                                  prefixText: 'A',
                                                  isDeparture: true,
                                                ),
                                                LocationTextField(
                                                  controller: controller,
                                                  label: 'destination'.tr,
                                                  hintText:
                                                      'where_you_want_to_go'.tr,
                                                  prefixText: 'B',
                                                  isDeparture: false,
                                                ),
                                                ReorderableListView(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  children: <Widget>[
                                                    for (
                                                      int index = 0;
                                                      index <
                                                          controller
                                                              .multiStopListNew
                                                              .length;
                                                      index += 1
                                                    )
                                                      Container(
                                                        key: ValueKey(
                                                          controller
                                                              .multiStopListNew[index],
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Expanded(
                                                                  child: TextFieldWidget(
                                                                    onTap: () async {
                                                                      await Constant()
                                                                          .placeSelectAPI(
                                                                            context,
                                                                            controller.multiStopListNew[index].editingController,
                                                                          )
                                                                          .then((
                                                                            value,
                                                                          ) {
                                                                            if (value !=
                                                                                null) {
                                                                              controller.multiStopListNew[index].latitude = value.result.geometry!.location.lat.toString();
                                                                              controller.multiStopListNew[index].longitude = value.result.geometry!.location.lng.toString();
                                                                              controller.setStopMarker(
                                                                                LatLng(
                                                                                  value.result.geometry!.location.lat,
                                                                                  value.result.geometry!.location.lng,
                                                                                ),
                                                                                index,
                                                                              );
                                                                            }
                                                                          });
                                                                    },
                                                                    isReadOnly:
                                                                        true,
                                                                    suffix: InkWell(
                                                                      onTap: () {
                                                                        controller.removeStops(
                                                                          index,
                                                                        );
                                                                        controller
                                                                            .markers
                                                                            .remove(
                                                                              "Stop $index",
                                                                            );
                                                                        controller
                                                                            .getDirections();
                                                                      },
                                                                      child: Icon(
                                                                        Icons
                                                                            .close,
                                                                        size:
                                                                            20,
                                                                        color:
                                                                            themeChange.getThem()
                                                                            ? AppThemeData.grey300Dark
                                                                            : AppThemeData.grey500Dark,
                                                                      ),
                                                                    ),
                                                                    prefix: IconButton(
                                                                      onPressed:
                                                                          () {},
                                                                      icon: Icon(
                                                                        Iconsax
                                                                            .location,
                                                                        color: Colors
                                                                            .orange,
                                                                      ),
                                                                    ),
                                                                    hintText:
                                                                        'where_do_you_want_to_stop'
                                                                            .tr,
                                                                    controller: controller
                                                                        .multiStopListNew[index]
                                                                        .editingController,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                  onReorder:
                                                      (
                                                        int oldIndex,
                                                        int newIndex,
                                                      ) {
                                                        if (oldIndex <
                                                            newIndex) {
                                                          newIndex -= 1;
                                                        }
                                                        final AddStopModel
                                                        item = controller
                                                            .multiStopListNew
                                                            .removeAt(oldIndex);
                                                        controller
                                                            .multiStopListNew
                                                            .insert(
                                                              newIndex,
                                                              item,
                                                            );
                                                      },
                                                ),
                                                CustomButton(
                                                  btnName:
                                                      'search_destination'.tr,
                                                  ontap: () async {
                                                    FocusManager
                                                        .instance
                                                        .primaryFocus
                                                        ?.unfocus();

                                                    // Validate inputs using controller method
                                                    final validationError =
                                                        controller
                                                            .validateSearchDestination();
                                                    if (validationError !=
                                                        null) {
                                                      ShowToastDialog.showToast(
                                                        validationError.tr,
                                                      );
                                                      return;
                                                    }

                                                    // Process search destination using controller method
                                                    final success = await controller
                                                        .processSearchDestination();

                                                    if (success) {
                                                      setState(() {});
                                                      // Show trip option bottom sheet
                                                      tripOptionBottomSheet(
                                                        context,
                                                        themeChange.getThem(),
                                                        controller,
                                                        paymentCtrl,
                                                        themeChange,
                                                      );
                                                    } else {
                                                      // Check if pending payment
                                                      final pendingPayment =
                                                          await controller
                                                              .getUserPendingPayment();
                                                      if (pendingPayment !=
                                                              null &&
                                                          pendingPayment['success'] ==
                                                              "success" &&
                                                          pendingPayment['data']['amount'] !=
                                                              0) {
                                                        PendingPaymentDialog.show(
                                                          context,
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                                SizedBox(height: 8),
                                                IntrinsicHeight(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (homeController
                                                                  .vehicleCategoryModel
                                                                  .value
                                                                  .data !=
                                                              null &&
                                                          homeController
                                                              .vehicleCategoryModel
                                                              .value
                                                              .data!
                                                              .isNotEmpty)
                                                        VehicleSelectionCard(
                                                          vehicle: homeController
                                                              .vehicleCategoryModel
                                                              .value
                                                              .data![0],
                                                          controller:
                                                              controller,
                                                          isSelected:
                                                              controller
                                                                  .vehicleData
                                                                  .value
                                                                  .id ==
                                                              (homeController
                                                                      .vehicleCategoryModel
                                                                      .value
                                                                      .data?[0]
                                                                      .id
                                                                      .toString() ??
                                                                  ""),
                                                        ),
                                                      SizedBox(width: 8),
                                                      if (homeController
                                                                  .vehicleCategoryModel
                                                                  .value
                                                                  .data !=
                                                              null &&
                                                          homeController
                                                                  .vehicleCategoryModel
                                                                  .value
                                                                  .data!
                                                                  .length >
                                                              1)
                                                        VehicleSelectionCard(
                                                          vehicle: homeController
                                                              .vehicleCategoryModel
                                                              .value
                                                              .data![1],
                                                          controller:
                                                              controller,
                                                          isSelected:
                                                              controller
                                                                  .vehicleData
                                                                  .value
                                                                  .id ==
                                                              (homeController
                                                                      .vehicleCategoryModel
                                                                      .value
                                                                      .data?[1]
                                                                      .id
                                                                      .toString() ??
                                                                  ""),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
