import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/tax_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/review/view/add_review_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/route_view_screen.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/themes/button_them.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/custom_alert_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/themes/custom_dialog_box.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/common/widget/StarRating.dart';
import 'package:v_one_mshwar_app_customer/service/pdf_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'payment_selection_screen.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  RideData data = RideData();
  void getSession() {
    setState(() {
      data = Get.arguments;
    });
  }

  @override
  void initState() {
    getSession();
    super.initState();
  }

  /// Show PDF options dialog
  void _showPdfOptions(BuildContext context, RideData data, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppThemeData.surface50Dark
                : AppThemeData.surface50,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppThemeData.grey500Dark
                        : AppThemeData.grey400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Generate PDF'.tr,
                        size: 20,
                        weight: FontWeight.w700,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                      const SizedBox(height: 20),
                      // Share PDF option
                      _buildPdfOption(
                        context: context,
                        icon: Iconsax.share,
                        title: 'Share PDF'.tr,
                        subtitle: 'Generate and share PDF via apps'.tr,
                        onTap: () async {
                          Navigator.pop(context);
                          EasyLoading.show(status: 'Generating PDF...'.tr);
                          try {
                            await PdfService.generateAndSharePdf(data);
                          } catch (e) {
                            Get.snackbar(
                              'Error'.tr,
                              'Failed to generate PDF: $e'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } finally {
                            EasyLoading.dismiss();
                          }
                        },
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      // Print PDF option
                      _buildPdfOption(
                        context: context,
                        icon: Iconsax.printer,
                        title: 'Print PDF'.tr,
                        subtitle: 'Generate and print PDF'.tr,
                        onTap: () async {
                          Navigator.pop(context);
                          EasyLoading.show(status: 'Generating PDF...'.tr);
                          try {
                            await PdfService.generateAndPrintPdf(data);
                          } catch (e) {
                            Get.snackbar(
                              'Error'.tr,
                              'Failed to generate PDF: $e'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } finally {
                            EasyLoading.dismiss();
                          }
                        },
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      // Save PDF option
                      _buildPdfOption(
                        context: context,
                        icon: Iconsax.document_download,
                        title: 'Save PDF'.tr,
                        subtitle: 'Generate and save PDF to device'.tr,
                        onTap: () async {
                          Navigator.pop(context);
                          EasyLoading.show(status: 'Generating PDF...'.tr);
                          try {
                            final file = await PdfService.generateRidePdf(data);
                            if (file != null && await file.exists()) {
                              EasyLoading.dismiss();
                              Get.snackbar(
                                'Success'.tr,
                                'PDF saved successfully'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                              // Optionally share the saved file
                              await Share.shareXFiles(
                                [XFile(file.path)],
                                text:
                                    'Ride Details - Trip #${data.id ?? 'Unknown'}'
                                        .tr,
                              );
                            } else {
                              EasyLoading.dismiss();
                              Get.snackbar(
                                'Error'.tr,
                                'Failed to generate PDF'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          } catch (e) {
                            EasyLoading.dismiss();
                            Get.snackbar(
                              'Error'.tr,
                              'Failed to save PDF: $e'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build PDF option tile
  Widget _buildPdfOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppThemeData.grey800Dark : AppThemeData.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? AppThemeData.grey800Dark : AppThemeData.grey200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeData.primary200.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppThemeData.primary200, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    size: 16,
                    weight: FontWeight.w600,
                    color: isDarkMode
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: subtitle,
                    size: 12,
                    color: isDarkMode
                        ? AppThemeData.grey500Dark
                        : AppThemeData.grey500,
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: isDarkMode
                  ? AppThemeData.grey500Dark
                  : AppThemeData.grey500,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool isDarkMode = themeChange.getThem();
    return GetX<PaymentController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          appBar: CustomAppBar(
            title: 'Ride Details'.tr,
            showBackButton: true,
            onBackPressed: () => Get.back(),
            actions: [
              // PDF Generation Button
              IconButton(
                icon: Icon(
                  Iconsax.document_download,
                  color: isDarkMode ? Colors.white : Colors.white,
                ),
                onPressed: () => _showPdfOptions(context, data, isDarkMode),
                tooltip: 'Generate PDF'.tr,
              ),
            ],
          ),
          body: data.departName == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Status Banner at Top
                        _buildStatusBanner(data, isDarkMode),
                        const SizedBox(height: 16),
                        // Trip Summary Card
                        _buildTripSummaryCard(data, controller, isDarkMode),
                        const SizedBox(height: 16),
                        // Route Section
                        LightBorderedCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'Route'.tr,
                                size: 18,
                                weight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                              ),
                              const SizedBox(height: 20),
                              // Pickup Location with Visual Connection Line
                              Column(
                                children: [
                                  // Pickup Location
                                  _buildLocationRow(
                                    icon: Iconsax.location,
                                    iconColor: AppThemeData.success300,
                                    iconBg: AppThemeData.success50,
                                    label: 'Pickup'.tr,
                                    address: data.departName.toString(),
                                    isDarkMode: isDarkMode,
                                    onTap: () async {
                                      final availableMaps =
                                          await MapLauncher.installedMaps;
                                      if (availableMaps.isNotEmpty) {
                                        await availableMaps.first.showMarker(
                                          coords: Coords(
                                            double.parse(
                                              data.latitudeDepart.toString(),
                                            ),
                                            double.parse(
                                              data.longitudeDepart.toString(),
                                            ),
                                          ),
                                          title: data.departName.toString(),
                                        );
                                      }
                                    },
                                    onCopy: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: data.departName.toString(),
                                        ),
                                      );
                                      ShowToastDialog.showToast(
                                        'Address copied'.tr,
                                      );
                                    },
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Container(
                                      width: 2,
                                      height: 20,
                                      margin: const EdgeInsets.only(left: 19),
                                      color: isDarkMode
                                          ? AppThemeData.grey300Dark.withValues(
                                              alpha: 0.3,
                                            )
                                          : AppThemeData.grey300.withValues(
                                              alpha: 0.3,
                                            ),
                                    ),
                                  ),
                                  // Dropoff Location
                                  _buildLocationRow(
                                    icon: Iconsax.location5,
                                    iconColor: AppThemeData.warning200,
                                    iconBg: AppThemeData.error50,
                                    label: 'Dropoff'.tr,
                                    address: data.destinationName.toString(),
                                    isDarkMode: isDarkMode,
                                    onTap: () async {
                                      final availableMaps =
                                          await MapLauncher.installedMaps;
                                      if (availableMaps.isNotEmpty) {
                                        await availableMaps.first.showMarker(
                                          coords: Coords(
                                            double.parse(
                                              data.latitudeArrivee.toString(),
                                            ),
                                            double.parse(
                                              data.longitudeArrivee.toString(),
                                            ),
                                          ),
                                          title: data.destinationName
                                              .toString(),
                                        );
                                      }
                                    },
                                    onCopy: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: data.destinationName.toString(),
                                        ),
                                      );
                                      ShowToastDialog.showToast(
                                        'Address copied'.tr,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              // Distance Info
                              if (data.distance != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? AppThemeData.grey800
                                          : AppThemeData.grey100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        if (data.distance != null &&
                                            data.distance != 'null')
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Iconsax.routing,
                                                  size: 16,
                                                  color: isDarkMode
                                                      ? AppThemeData.grey500Dark
                                                      : AppThemeData.grey500,
                                                ),
                                                const SizedBox(width: 8),
                                                CustomText(
                                                  text:
                                                      '${data.distance} ${data.distanceUnit ?? 'KM'.tr}',
                                                  size: 13,
                                                  weight: FontWeight.w500,
                                                  color: isDarkMode
                                                      ? AppThemeData.grey500Dark
                                                      : AppThemeData.grey500,
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
                        ),
                        // Driver and Cab Details Section
                        Visibility(
                          visible: data.statutPaiement == 'yes',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              CustomText(
                                text: 'Driver and Cab Details'.tr,
                                size: 18,
                                weight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                              ),
                              const SizedBox(height: 12),
                              LightBorderedCard(
                                child: Column(
                                  children: [
                                    _buildDetailRow(
                                      icon: Iconsax.user,
                                      label: 'Driver Name'.tr,
                                      value:
                                          "${data.prenomConducteur.toString()} ${data.nomConducteur.toString()}",
                                      isDarkMode: isDarkMode,
                                      showDivider: true,
                                    ),
                                    _buildDetailRow(
                                      icon: Iconsax.car,
                                      label: 'Cab Details'.tr,
                                      value: data.numberplate.toString(),
                                      isDarkMode: isDarkMode,
                                      showDivider: true,
                                    ),
                                    if (data.brand != null &&
                                        data.brand != 'null')
                                      _buildDetailRow(
                                        icon: Iconsax.tag,
                                        label: 'Vehicle'.tr,
                                        value:
                                            '${data.brand ?? ''} ${data.model ?? ''}',
                                        isDarkMode: isDarkMode,
                                        showDivider: true,
                                      ),
                                    if (data.color != null &&
                                        data.color != 'null')
                                      _buildDetailRow(
                                        icon: Iconsax.paintbucket,
                                        label: 'Color'.tr,
                                        value: data.color.toString(),
                                        isDarkMode: isDarkMode,
                                        showDivider: true,
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Iconsax.call,
                                            size: 18,
                                            color: isDarkMode
                                                ? AppThemeData.grey500Dark
                                                : AppThemeData.grey500,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: CustomText(
                                              text: 'Contact Details'.tr,
                                              size: 15,
                                              weight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? AppThemeData.grey900Dark
                                                  : AppThemeData.grey900,
                                            ),
                                          ),
                                          CustomText(
                                            text: '${data.driverPhone}',
                                            size: 15,
                                            weight: FontWeight.w500,
                                            color: isDarkMode
                                                ? AppThemeData.grey500Dark
                                                : AppThemeData.grey500,
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () {
                                              Constant.makePhoneCall(
                                                controller
                                                    .data
                                                    .value
                                                    .driverPhone
                                                    .toString(),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppThemeData.primary50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Iconsax.call,
                                                size: 18,
                                                color: AppThemeData.primary200,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      color: isDarkMode
                                          ? AppThemeData.grey200Dark
                                          : AppThemeData.grey200,
                                    ),
                                    _buildDetailRow(
                                      icon: Iconsax.calendar,
                                      label: 'Date and Time'.tr,
                                      value:
                                          '${data.dateRetour} ${data.heureRetour}',
                                      isDarkMode: isDarkMode,
                                      showDivider: false,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Driver Card with Photo, Rating, and Action Buttons
                        Visibility(
                          visible: data.statutPaiement == 'yes',
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              LightBorderedCard(
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child:
                                          (data.photoPath != null &&
                                              data.photoPath
                                                  .toString()
                                                  .isNotEmpty &&
                                              data.photoPath.toString() !=
                                                  'null')
                                          ? CachedNetworkImage(
                                              imageUrl: data.photoPath
                                                  .toString(),
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Constant.loader(context),
                                              errorWidget:
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => Container(
                                                    height: 70,
                                                    width: 70,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppThemeData.grey200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Iconsax.user,
                                                      size: 35,
                                                      color:
                                                          AppThemeData.grey400,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                color: AppThemeData.grey200,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Iconsax.user,
                                                size: 35,
                                                color: AppThemeData.grey400,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text:
                                                "${data.prenomConducteur} ${data.nomConducteur}",
                                            size: 16,
                                            weight: FontWeight.w600,
                                            color: isDarkMode
                                                ? AppThemeData.grey900Dark
                                                : AppThemeData.grey900,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              StarRating(
                                                size: 16,
                                                rating: data.moyenne != "null"
                                                    ? double.parse(
                                                        data.moyenne.toString(),
                                                      )
                                                    : 0.0,
                                                color: AppThemeData.warning200,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        // Action buttons for active rides
                                        Visibility(
                                          visible:
                                              data.statut == "new" ||
                                              data.statut == "on ride" ||
                                              data.statut == "confirmed",
                                          child: Row(
                                            children: [
                                              // Navigate Button
                                              Visibility(
                                                visible:
                                                    data.statut == "on ride" ||
                                                    data.statut == "confirmed",
                                                child: InkWell(
                                                  onTap: () async {
                                                    await Constant.openExternalMapWithDirections(
                                                      originLat:
                                                          double.tryParse(
                                                            data.latitudeDepart
                                                                .toString(),
                                                          ) ??
                                                          0.0,
                                                      originLng:
                                                          double.tryParse(
                                                            data.longitudeDepart
                                                                .toString(),
                                                          ) ??
                                                          0.0,
                                                      destLat:
                                                          double.tryParse(
                                                            data.latitudeArrivee
                                                                .toString(),
                                                          ) ??
                                                          0.0,
                                                      destLng:
                                                          double.tryParse(
                                                            data.longitudeArrivee
                                                                .toString(),
                                                          ) ??
                                                          0.0,
                                                      originTitle: data
                                                          .departName
                                                          .toString(),
                                                      destTitle: data
                                                          .destinationName
                                                          .toString(),
                                                    );
                                                  },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height: 44,
                                                    width: 44,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppThemeData
                                                          .primary200
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Iconsax.routing_2,
                                                      size: 20,
                                                      color: AppThemeData
                                                          .primary200,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Share Button
                                              InkWell(
                                                onTap: () async {
                                                  ShowToastDialog.showLoader(
                                                    'please_wait'.tr,
                                                  );
                                                  final Location
                                                  currentLocation = Location();
                                                  LocationData location =
                                                      await currentLocation
                                                          .getLocation();
                                                  ShowToastDialog.closeLoader();
                                                  await Share.share(
                                                    'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
                                                    subject:
                                                        'v_one_mshwar_app_customer'
                                                            .tr,
                                                  );
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 44,
                                                  width: 44,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppThemeData
                                                        .secondary200
                                                        .withValues(alpha: 0.2),
                                                  ),
                                                  child: Icon(
                                                    Iconsax.share,
                                                    size: 20,
                                                    color: AppThemeData
                                                        .secondary200,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Call Button
                                              InkWell(
                                                onTap: () {
                                                  Constant.makePhoneCall(
                                                    data.driverPhone.toString(),
                                                  );
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 44,
                                                  width: 44,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppThemeData
                                                        .warning200
                                                        .withValues(alpha: 0.2),
                                                  ),
                                                  child: Icon(
                                                    Iconsax.call,
                                                    size: 20,
                                                    color:
                                                        AppThemeData.warning200,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Rating button for completed rides
                                        Visibility(
                                          visible:
                                              data.statut == "completed" ||
                                              data.statut == "rejected",
                                          child: InkWell(
                                            onTap: () async {
                                              Get.to(
                                                const AddReviewScreen(),
                                                arguments: {
                                                  "data": data,
                                                  "ride_type": "ride",
                                                },
                                              )!.then((value) {
                                                // Refresh if needed
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppThemeData.primary50,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Iconsax.add,
                                                    size: 18,
                                                    color:
                                                        AppThemeData.primary200,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  CustomText(
                                                    text: 'Ratings'.tr,
                                                    size: 14,
                                                    weight: FontWeight.w600,
                                                    color:
                                                        AppThemeData.primary200,
                                                  ),
                                                ],
                                              ),
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
                        const SizedBox(height: 20),
                        // Bill Details Section
                        CustomText(
                          text: 'Bill Details'.tr,
                          size: 18,
                          weight: FontWeight.w600,
                          color: isDarkMode
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                        ),
                        const SizedBox(height: 12),
                        LightBorderedCard(
                          child: Column(
                            children: [
                              _buildBillRow(
                                icon: Iconsax.dollar_circle,
                                label: 'Ride Cost'.tr,
                                value: Constant().amountShow(
                                  amount: data.montant,
                                ),
                                isDarkMode: isDarkMode,
                                showDivider: true,
                              ),
                              _buildBillRow(
                                icon: Iconsax.discount_shape,
                                label: 'Discount'.tr,
                                value:
                                    "(-${Constant().amountShow(amount: controller.discountAmount.value.toString())})",
                                isDarkMode: isDarkMode,
                                showDivider: true,
                              ),
                              ListView.builder(
                                itemCount:
                                    controller.data.value.statutPaiement ==
                                        "yes"
                                    ? controller.data.value.taxModel!.length
                                    : Constant.taxList.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  TaxModel taxModel =
                                      controller.data.value.statutPaiement ==
                                          "yes"
                                      ? controller.data.value.taxModel![index]
                                      : Constant.taxList[index];
                                  return _buildBillRow(
                                    icon: Iconsax.receipt_item,
                                    label:
                                        '${taxModel.libelle.toString()} (${taxModel.type == "Fixed" ? Constant().amountShow(amount: taxModel.value) : "${taxModel.value}%"})',
                                    value: Constant().amountShow(
                                      amount: controller
                                          .calculateTax(taxModel: taxModel)
                                          .toString(),
                                    ),
                                    isDarkMode: isDarkMode,
                                    showDivider: true,
                                  );
                                },
                              ),
                              Visibility(
                                visible: controller.tipAmount.value == 0
                                    ? false
                                    : true,
                                child: _buildBillRow(
                                  icon: Iconsax.wallet_money,
                                  label: "Driver Tip".tr,
                                  value: Constant().amountShow(
                                    amount: controller.tipAmount.value
                                        .toString(),
                                  ),
                                  isDarkMode: isDarkMode,
                                  showDivider: true,
                                ),
                              ),
                              Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                color: isDarkMode
                                    ? AppThemeData.grey200Dark
                                    : AppThemeData.grey200,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.wallet_3,
                                      size: 20,
                                      color: AppThemeData.primary200,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustomText(
                                        text: 'Total Payable Amount'.tr,
                                        size: 16,
                                        weight: FontWeight.w600,
                                        color: isDarkMode
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                    ),
                                    CustomText(
                                      text: Constant().amountShow(
                                        amount: data.montant,
                                      ),
                                      size: 18,
                                      weight: FontWeight.w700,
                                      color: AppThemeData.primary200,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        //  ils Section
                        CustomText(
                          text: 'Order Details'.tr,
                          size: 18,
                          weight: FontWeight.w600,
                          color: isDarkMode
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                        ),
                        const SizedBox(height: 12),
                        LightBorderedCard(
                          child: Column(
                            children: [
                              _buildDetailRow(
                                icon: Iconsax.hashtag,
                                label: 'Order ID'.tr,
                                value: "#${data.id ?? ''}",
                                isDarkMode: isDarkMode,
                                showDivider: true,
                              ),
                              if (data.payment != null &&
                                  data.payment != 'null')
                                _buildDetailRow(
                                  icon: Iconsax.card,
                                  label: 'Payment Method'.tr,
                                  value: data.statutPaiement == "yes"
                                      ? "${"Paid using".tr} ${data.payment}"
                                      : "${"Pay using".tr} ${data.payment}",
                                  isDarkMode: isDarkMode,
                                  showDivider: true,
                                ),
                              if (data.rideType != null &&
                                  data.rideType != 'null')
                                _buildDetailRow(
                                  icon: Iconsax.car,
                                  label: 'Ride Type'.tr,
                                  value: data.rideType.toString(),
                                  isDarkMode: isDarkMode,
                                  showDivider: true,
                                ),
                              if (data.numberPoeple != null &&
                                  data.numberPoeple != 'null' &&
                                  data.numberPoeple != '0')
                                _buildDetailRow(
                                  icon: Iconsax.profile_2user,
                                  label: 'Passengers'.tr,
                                  value: data.numberPoeple.toString(),
                                  isDarkMode: isDarkMode,
                                  showDivider: false,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Action Buttons Section
                        if (controller.data.value.statut == 'new' ||
                            controller.data.value.statut == 'on ride' ||
                            controller.data.value.statut == 'confirmed')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                controller.data.value.statut == 'new' ||
                                        controller.data.value.statut ==
                                            'confirmed'
                                    ? Expanded(
                                        child: ButtonThem.buildButton(
                                          context,
                                          btnColor: AppThemeData.error200,
                                          title: 'Cancel Ride'.tr,
                                          btnWidthRatio: 1,
                                          onPress: () async {
                                            buildShowBottomSheet(
                                              context,
                                              themeChange.getThem(),
                                              controller,
                                            );
                                          },
                                        ),
                                      )
                                    : Visibility(
                                        visible:
                                            controller.data.value.statut ==
                                                "on ride"
                                            ? true
                                            : false,
                                        child: Expanded(
                                          child: ButtonThem.buildButton(
                                            context,
                                            title: 'I do not feel safe'.tr,
                                            btnWidthRatio: 1,
                                            onPress: () async {
                                              ShowToastDialog.showLoader(
                                                'please_wait'.tr,
                                              );
                                              LocationData location =
                                                  await Location()
                                                      .getLocation();
                                              Map<String, dynamic>
                                              bodyParams = {
                                                'lat': location.latitude,
                                                'lng': location.longitude,
                                                'user_id': Preferences.getInt(
                                                  Preferences.userId,
                                                ).toString(),
                                                'user_name':
                                                    "${controller.userModel.value.data!.prenom} ${controller.userModel.value.data!.nom}",
                                                'user_cat': controller
                                                    .userModel
                                                    .value
                                                    .data!
                                                    .userCat,
                                                'id_driver': controller
                                                    .data
                                                    .value
                                                    .idConducteur,
                                                'feel_safe': 0,
                                                'trip_id':
                                                    controller.data.value.id,
                                              };
                                              controller
                                                  .feelNotSafe(bodyParams)
                                                  .then((value) {
                                                    ShowToastDialog.closeLoader();
                                                    if (value != null) {
                                                      if (value['success'] ==
                                                          "success") {
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: ButtonThem.buildButton(
                                      context,
                                      title: 'Track Ride'.tr,
                                      onPress: () async {
                                        var argumentData = {
                                          'type': controller.data.value.statut
                                              .toString(),
                                          'data': controller.data.value,
                                        };

                                        if (Constant.liveTrackingMapType ==
                                            "inappmap") {
                                          Get.to(
                                            const RouteViewScreen(),
                                            arguments: argumentData,
                                          );
                                        } else {
                                          Constant.redirectMap(
                                            latitude: double.parse(
                                              controller
                                                  .data
                                                  .value
                                                  .latitudeArrivee!,
                                            ),
                                            longLatitude: double.parse(
                                              controller
                                                  .data
                                                  .value
                                                  .longitudeArrivee!,
                                            ),
                                            name: controller
                                                .data
                                                .value
                                                .destinationName!,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (data.statut == "completed" ||
                            data.statut == "rejected")
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                Visibility(
                                  visible:
                                      data.statut == "completed" &&
                                      data.statutPaiement != "yes" &&
                                      data.statut != "rejected",
                                  child: Expanded(
                                    child: ButtonThem.buildButton(
                                      context,
                                      title: "Pay Now".tr,
                                      onPress: () {
                                        Get.to(
                                          PaymentSelectionScreen(),
                                          arguments: {
                                            "rideData": controller.data.value,
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      (data.statutPaiement == "yes") ||
                                      (data.statut == "rejected"),
                                  child: Expanded(
                                    child: ButtonThem.buildButton(
                                      context,
                                      title: 'Add Review'.tr,
                                      onPress: () async {
                                        Get.to(
                                          const AddReviewScreen(),
                                          arguments: {
                                            "data": controller.data.value,
                                            "ride_type": "ride",
                                          },
                                        );
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
                ),
        );
      },
    );
  }

  final resonController = TextEditingController();

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDarkMode
                    ? AppThemeData.grey500Dark
                    : AppThemeData.grey500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomText(
                  text: label,
                  size: 15,
                  weight: FontWeight.w500,
                  color: isDarkMode
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                ),
              ),
              CustomText(
                text: value,
                size: 15,
                weight: FontWeight.w500,
                color: isDarkMode
                    ? AppThemeData.grey500Dark
                    : AppThemeData.grey500,
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            color: isDarkMode ? AppThemeData.grey200Dark : AppThemeData.grey200,
          ),
      ],
    );
  }

  Widget _buildBillRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDarkMode
                    ? AppThemeData.grey500Dark
                    : AppThemeData.grey500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomText(
                  text: label,
                  size: 15,
                  weight: FontWeight.w500,
                  color: isDarkMode
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                ),
              ),
              CustomText(
                text: value,
                size: 15,
                weight: FontWeight.w500,
                color: isDarkMode
                    ? AppThemeData.grey500Dark
                    : AppThemeData.grey500,
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            color: isDarkMode ? AppThemeData.grey200Dark : AppThemeData.grey200,
          ),
      ],
    );
  }

  Future buildShowBottomSheet(
    BuildContext context,
    bool isDarkMode,
    PaymentController controller,
  ) {
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
                                              'id_ride': controller
                                                  .data
                                                  .value
                                                  .id
                                                  .toString(),
                                              'id_user': controller
                                                  .data
                                                  .value
                                                  .idConducteur
                                                  .toString(),
                                              'name':
                                                  "${controller.data.value.prenom} ${controller.data.value.nom}",
                                              'from_id': Preferences.getInt(
                                                Preferences.userId,
                                              ).toString(),
                                              'user_cat': controller
                                                  .userModel
                                                  .value
                                                  .data!
                                                  .userCat
                                                  .toString(),
                                              'reason': resonController.text
                                                  .toString(),
                                            };
                                            controller.canceledRide(bodyParams).then((
                                              value,
                                            ) {
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
                                      'Please enter a reason'.tr,
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

  Widget statusTile({required String title, Color? bgColor, Color? txtColor}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: bgColor,
      ),
      alignment: Alignment.center,
      height: 32,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          title.tr,
          style: TextStyle(
            fontSize: 14,
            color: txtColor,
            fontFamily: AppThemeData.medium,
          ),
        ),
      ),
    );
  }

  // Status Banner Widget
  Widget _buildStatusBanner(RideData data, bool isDarkMode) {
    String status = data.statut ?? '';
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'new':
        bgColor = AppThemeData.primary200.withValues(alpha: 0.15);
        textColor = AppThemeData.primary200;
        icon = Iconsax.clock;
        break;
      case 'confirmed':
        bgColor = AppThemeData.success300.withValues(alpha: 0.15);
        textColor = AppThemeData.success300;
        icon = Iconsax.tick_circle;
        break;
      case 'on ride':
        bgColor = AppThemeData.warning200.withValues(alpha: 0.15);
        textColor = AppThemeData.warning200;
        icon = Iconsax.car;
        break;
      case 'completed':
        bgColor = AppThemeData.success300.withValues(alpha: 0.15);
        textColor = AppThemeData.success300;
        icon = Iconsax.tick_square;
        break;
      case 'rejected':
      case 'cancelled':
        bgColor = AppThemeData.error200.withValues(alpha: 0.15);
        textColor = AppThemeData.error200;
        icon = Iconsax.close_circle;
        break;
      default:
        bgColor = AppThemeData.grey500.withValues(alpha: 0.15);
        textColor = AppThemeData.grey500;
        icon = Iconsax.document;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              text: status.toUpperCase().tr,
              size: 16,
              weight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          if (data.id != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomText(
                text: '#${data.id}',
                size: 12,
                weight: FontWeight.w600,
                color: textColor,
              ),
            ),
        ],
      ),
    );
  }

  // Trip Summary Card
  Widget _buildTripSummaryCard(
    RideData data,
    PaymentController controller,
    bool isDarkMode,
  ) {
    return LightBorderedCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Distance
          if (data.distance != null && data.distance != 'null')
            Expanded(
              child: _buildSummaryItem(
                icon: Iconsax.routing_2,
                label: 'Distance'.tr,
                value:
                    '${double.parse(data.distance.toString()).toStringAsFixed(int.parse(Constant.decimal ?? '2'))} ${data.distanceUnit ?? 'KM'.tr}',
                isDarkMode: isDarkMode,
              ),
            ),
          if (data.distance != null && data.distance != 'null')
            Container(
              width: 1,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: isDarkMode
                  ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                  : AppThemeData.grey300.withValues(alpha: 0.3),
            ),
          // Duration (if available)
          if (data.duree != null &&
              data.duree != 'null' &&
              data.duree!.isNotEmpty)
            Expanded(
              child: _buildSummaryItem(
                icon: Iconsax.clock,
                label: 'Duration'.tr,
                value: data.duree.toString(),
                isDarkMode: isDarkMode,
              ),
            ),
          if (data.duree != null &&
              data.duree != 'null' &&
              data.duree!.isNotEmpty) ...[
            Container(
              width: 1,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: isDarkMode
                  ? AppThemeData.grey300Dark.withValues(alpha: 0.3)
                  : AppThemeData.grey300.withValues(alpha: 0.3),
            ),
          ],
          // Price
          Expanded(
            child: _buildSummaryItem(
              icon: Iconsax.wallet_3,
              label: 'Total'.tr,
              value: Constant().amountShow(amount: data.montant.toString()),
              isDarkMode: isDarkMode,
              isPrice: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    bool isPrice = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrice
                  ? AppThemeData.primary200
                  : (isDarkMode
                        ? AppThemeData.grey400Dark
                        : AppThemeData.grey500),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: CustomText(
                text: label,
                size: 11,
                weight: FontWeight.w500,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        CustomText(
          text: value,
          size: 15,
          weight: isPrice ? FontWeight.w700 : FontWeight.w600,
          color: isPrice
              ? AppThemeData.primary200
              : (isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900),
        ),
      ],
    );
  }

  // Enhanced Location Row with Copy Functionality
  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String address,
    required bool isDarkMode,
    required VoidCallback onTap,
    required VoidCallback onCopy,
    bool showStopBadge = false,
    String? stopLetter,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: showStopBadge && stopLetter != null
                ? Center(
                    child: CustomText(
                      text: stopLetter,
                      size: 14,
                      weight: FontWeight.w600,
                      color: iconColor,
                    ),
                  )
                : Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: label,
                  size: 12,
                  weight: FontWeight.w500,
                  color: isDarkMode
                      ? AppThemeData.grey500Dark
                      : AppThemeData.grey500,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: address,
                  size: 14,
                  weight: FontWeight.w500,
                  color: isDarkMode
                      ? AppThemeData.grey900Dark
                      : AppThemeData.grey900,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppThemeData.grey800Dark
                    : AppThemeData.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Iconsax.copy,
                size: 16,
                color: isDarkMode
                    ? AppThemeData.grey400Dark
                    : AppThemeData.grey500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
