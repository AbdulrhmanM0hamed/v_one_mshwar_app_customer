import 'dart:io';
import 'dart:convert';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/model/user_model.dart';
import 'package:v_one_mshwar_app_customer/features/settings/profile/model/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  /// Generate PDF for ride details and return the file path
  static Future<File?> generateRidePdf(RideData rideData) async {
    try {
      final pdf = pw.Document();

      // Get current date and time
      final now = DateTime.now();
      final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
      final rideDateFormat = DateFormat('dd MMM yyyy, hh:mm a');

      // Parse ride date
      DateTime? rideDateTime;
      if (rideData.creer != null && rideData.creer!.isNotEmpty) {
        try {
          rideDateTime = DateTime.parse(rideData.creer!);
        } catch (e) {
          // If parsing fails, use current date
          rideDateTime = now;
        }
      } else {
        rideDateTime = now;
      }

      // Get currency symbol (Kuwait Dinar)
      final currency = Constant.currency ?? 'KWD';

      // Get customer details
      UserModel? customerData;
      try {
        customerData = Constant.getUserData();
      } catch (e) {
        debugPrint('Error getting customer data: $e');
      }

      // Get company/settings data
      SettingsModel? settingsData;
      try {
        settingsData = _getSettingsData();
      } catch (e) {
        debugPrint('Error getting settings data: $e');
      }

      // Build PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Company Header
              _buildCompanyHeader(settingsData),
              pw.SizedBox(height: 20),
              // Receipt Header
              _buildHeader(rideData, dateFormat.format(now)),
              pw.SizedBox(height: 30),

              // Customer Information
              if (customerData != null && customerData.data != null) ...[
                _buildSectionTitle('Customer Information'.tr),
                pw.SizedBox(height: 10),
                _buildCustomerInfo(customerData),
                pw.SizedBox(height: 20),
              ],

              // Trip Information
              _buildSectionTitle('Trip Information'.tr),
              pw.SizedBox(height: 10),
              _buildTripInfo(
                rideData,
                rideDateTime != null
                    ? rideDateFormat.format(rideDateTime)
                    : 'N/A',
              ),
              pw.SizedBox(height: 20),

              // Route Information
              _buildSectionTitle('Route Information'.tr),
              pw.SizedBox(height: 10),
              _buildRouteInfo(rideData),
              pw.SizedBox(height: 20),

              // Driver & Vehicle Information (if available)
              if (rideData.statutPaiement == 'yes' &&
                  (rideData.nomConducteur != null ||
                      rideData.prenomConducteur != null)) ...[
                _buildSectionTitle('Driver & Vehicle Information'.tr),
                pw.SizedBox(height: 10),
                _buildDriverInfo(rideData),
                pw.SizedBox(height: 20),
              ],

              // Payment Information
              _buildSectionTitle('Payment Information'.tr),
              pw.SizedBox(height: 10),
              _buildPaymentInfo(rideData, currency),
              pw.SizedBox(height: 20),

              // Footer
              pw.Spacer(),
              _buildFooter(),
            ];
          },
        ),
      );

      // Save PDF to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Ride_${rideData.id ?? 'Unknown'}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      return null;
    }
  }

  /// Generate and share PDF
  static Future<void> generateAndSharePdf(RideData rideData) async {
    try {
      final file = await generateRidePdf(rideData);
      if (file != null && await file.exists()) {
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Ride Details - Trip #${rideData.id ?? 'Unknown'}'.tr);
      } else {
        Get.snackbar(
          'Error'.tr,
          'Failed to generate PDF'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to share PDF: $e'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Generate and print PDF
  static Future<void> generateAndPrintPdf(RideData rideData) async {
    try {
      final pdf = await _buildPdfDocument(rideData);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('Error printing PDF: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to print PDF: $e'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Build PDF document
  static Future<pw.Document> _buildPdfDocument(RideData rideData) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final rideDateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    DateTime? rideDateTime;
    if (rideData.creer != null && rideData.creer!.isNotEmpty) {
      try {
        rideDateTime = DateTime.parse(rideData.creer!);
      } catch (e) {
        rideDateTime = now;
      }
    } else {
      rideDateTime = now;
    }

    final currency = Constant.currency ?? 'KWD';

    // Get customer details
    UserModel? customerData;
    try {
      customerData = Constant.getUserData();
    } catch (e) {
      debugPrint('Error getting customer data: $e');
    }

    // Get company/settings data
    SettingsModel? settingsData;
    try {
      settingsData = _getSettingsData();
    } catch (e) {
      debugPrint('Error getting settings data: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Company Header
            _buildCompanyHeader(settingsData),
            pw.SizedBox(height: 20),
            // Receipt Header
            _buildHeader(rideData, dateFormat.format(now)),
            pw.SizedBox(height: 30),
            // Customer Information
            if (customerData != null && customerData.data != null) ...[
              _buildSectionTitle('Customer Information'.tr),
              pw.SizedBox(height: 10),
              _buildCustomerInfo(customerData),
              pw.SizedBox(height: 20),
            ],
            _buildSectionTitle('Trip Information'.tr),
            pw.SizedBox(height: 10),
            _buildTripInfo(
              rideData,
              rideDateTime != null
                  ? rideDateFormat.format(rideDateTime)
                  : 'N/A',
            ),
            pw.SizedBox(height: 20),
            _buildSectionTitle('Route Information'.tr),
            pw.SizedBox(height: 10),
            _buildRouteInfo(rideData),
            pw.SizedBox(height: 20),
            if (rideData.statutPaiement == 'yes' &&
                (rideData.nomConducteur != null ||
                    rideData.prenomConducteur != null)) ...[
              _buildSectionTitle('Driver & Vehicle Information'.tr),
              pw.SizedBox(height: 10),
              _buildDriverInfo(rideData),
              pw.SizedBox(height: 20),
            ],
            _buildSectionTitle('Payment Information'.tr),
            pw.SizedBox(height: 10),
            _buildPaymentInfo(rideData, currency),
            pw.SizedBox(height: 20),
            pw.Spacer(),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf;
  }

  /// Get settings data from Preferences or return null
  static SettingsModel? _getSettingsData() {
    try {
      // Try to get settings from Preferences if stored
      // Settings might be stored with key 'settings' or similar
      final settingsJson = Preferences.getString('settings');
      if (settingsJson.isNotEmpty && settingsJson != 'null') {
        final settingsMap = jsonDecode(settingsJson);
        return SettingsModel.fromJson(settingsMap);
      }
    } catch (e) {
      debugPrint('Error parsing settings from Preferences: $e');
    }

    // If not in Preferences, return null - company header will use defaults
    return null;
  }

  /// Build company header section
  static pw.Widget _buildCompanyHeader(SettingsModel? settings) {
    final companyName = settings?.data?.title ?? 'Mshwar';
    final companyEmail =
        settings?.data?.contactUsEmail ?? settings?.data?.email ?? '';
    final companyPhone = settings?.data?.contactUsPhone ?? '';
    final companyAddress = settings?.data?.contactUsAddress ?? '';

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue900,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Company Name
          pw.Text(
            companyName,
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 12),
          // Contact Information
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (companyEmail.isNotEmpty && companyEmail != 'null')
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Row(
                          children: [
                            pw.Text(
                              'Email: ',
                              style: pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                companyEmail,
                                style: const pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (companyPhone.isNotEmpty && companyPhone != 'null')
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Row(
                          children: [
                            pw.Text(
                              'Phone: ',
                              style: pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                companyPhone,
                                style: const pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (companyAddress.isNotEmpty && companyAddress != 'null')
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Address: ',
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              companyAddress,
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.white,
                              ),
                              maxLines: 3,
                            ),
                          ),
                        ],
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

  /// Build header section
  static pw.Widget _buildHeader(RideData rideData, String generatedDate) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Ride Receipt'.tr,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Trip ID: ${rideData.id ?? 'N/A'}'.tr,
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated: $generatedDate',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build section title
  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  /// Build trip information
  static pw.Widget _buildTripInfo(RideData rideData, String rideDate) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Trip ID'.tr, '#${rideData.id ?? 'N/A'}'),
          pw.Divider(),
          _buildInfoRow('Date & Time'.tr, rideDate),
          if (rideData.statut != null) ...[
            pw.Divider(),
            _buildInfoRow('Status'.tr, _getStatusText(rideData.statut!)),
          ],
          if (rideData.distance != null && rideData.distance != 'null') ...[
            pw.Divider(),
            _buildInfoRow(
              'Distance'.tr,
              '${rideData.distance} ${rideData.distanceUnit ?? 'KM'.tr}',
            ),
          ],
          if (rideData.duree != null && rideData.duree != 'null') ...[
            pw.Divider(),
            _buildInfoRow('Duration'.tr, rideData.duree.toString()),
          ],
        ],
      ),
    );
  }

  /// Build route information
  static pw.Widget _buildRouteInfo(RideData rideData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 10,
                height: 10,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.green,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Pickup Location'.tr,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      rideData.departName ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          // Stops
          if (rideData.stops != null && rideData.stops!.isNotEmpty)
            ...rideData.stops!.asMap().entries.map((entry) {
              final index = entry.key;
              final stop = entry.value;
              return pw.Column(
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 10,
                        height: 10,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.orange,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Stop ${index + 1}'.tr,
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              stop.location ?? 'N/A',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 15),
                ],
              );
            }),
          // Dropoff
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 10,
                height: 10,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.red,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Dropoff Location'.tr,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      rideData.destinationName ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 12),
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

  /// Build customer information
  static pw.Widget _buildCustomerInfo(UserModel customerData) {
    final user = customerData.data;
    if (user == null) {
      return pw.SizedBox.shrink();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (user.prenom != null || user.nom != null)
            _buildInfoRow(
              'Customer Name'.tr,
              '${user.prenom ?? ''} ${user.nom ?? ''}'.trim(),
            ),
          if (user.email != null &&
              user.email != 'null' &&
              user.email!.isNotEmpty) ...[
            pw.Divider(),
            _buildInfoRow('Email'.tr, user.email.toString()),
          ],
          if (user.phone != null &&
              user.phone != 'null' &&
              user.phone!.isNotEmpty) ...[
            pw.Divider(),
            _buildInfoRow('Phone'.tr, user.phone.toString()),
          ],
          if (user.id != null) ...[
            pw.Divider(),
            _buildInfoRow('Customer ID'.tr, user.id.toString()),
          ],
        ],
      ),
    );
  }

  /// Build driver information
  static pw.Widget _buildDriverInfo(RideData rideData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (rideData.prenomConducteur != null ||
              rideData.nomConducteur != null)
            _buildInfoRow(
              'Driver Name'.tr,
              '${rideData.prenomConducteur ?? ''} ${rideData.nomConducteur ?? ''}'
                  .trim(),
            ),
          if (rideData.driverPhone != null &&
              rideData.driverPhone != 'null') ...[
            pw.Divider(),
            _buildInfoRow('Driver Phone'.tr, rideData.driverPhone.toString()),
          ],
          if (rideData.numberplate != null &&
              rideData.numberplate != 'null') ...[
            pw.Divider(),
            _buildInfoRow('License Plate'.tr, rideData.numberplate.toString()),
          ],
          if ((rideData.brand != null && rideData.brand != 'null') ||
              (rideData.model != null && rideData.model != 'null')) ...[
            pw.Divider(),
            _buildInfoRow(
              'Vehicle'.tr,
              '${rideData.brand ?? ''} ${rideData.model ?? ''}'.trim(),
            ),
          ],
          if (rideData.color != null && rideData.color != 'null') ...[
            pw.Divider(),
            _buildInfoRow('Color'.tr, rideData.color.toString()),
          ],
        ],
      ),
    );
  }

  /// Build payment information
  static pw.Widget _buildPaymentInfo(RideData rideData, String currency) {
    double baseAmount = 0.0;
    double totalTax = 0.0;
    double totalAmount = 0.0;

    try {
      baseAmount = double.tryParse(rideData.montant ?? '0') ?? 0.0;

      // Note: discount and tipAmount are typically calculated in PaymentController
      // For PDF, we'll use base amount and calculate tax from taxModel
      // If discount/tip data is needed, it should be passed separately or calculated here

      // Calculate tax
      if (rideData.taxModel != null && rideData.taxModel!.isNotEmpty) {
        for (var tax in rideData.taxModel!) {
          if (tax.value != null && tax.value != 'null') {
            if (tax.type == 'Fixed') {
              totalTax += double.tryParse(tax.value ?? '0') ?? 0.0;
            } else {
              // Percentage tax
              double taxPercent = double.tryParse(tax.value ?? '0') ?? 0.0;
              totalTax += (baseAmount * taxPercent) / 100;
            }
          }
        }
      }

      totalAmount = baseAmount + totalTax;
    } catch (e) {
      debugPrint('Error calculating payment: $e');
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (baseAmount > 0)
            _buildInfoRow(
              'Base Fare'.tr,
              Constant().amountShow(amount: baseAmount.toString()),
            ),
          // Discount and tip would need to be passed separately or calculated
          // For now, we'll show base amount and tax only
          if (totalTax > 0) ...[
            pw.Divider(),
            _buildInfoRow(
              'Tax'.tr,
              Constant().amountShow(amount: totalTax.toString()),
            ),
          ],
          // Tip amount would need to be passed separately
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Amount'.tr,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                Constant().amountShow(amount: totalAmount.toString()),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          if (rideData.statutPaiement != null)
            _buildInfoRow(
              'Payment Status'.tr,
              _getPaymentStatusText(rideData.statutPaiement!),
            ),
          if (rideData.payment != null && rideData.payment != 'null') ...[
            pw.Divider(),
            _buildInfoRow('Payment Method'.tr, rideData.payment.toString()),
          ],
        ],
      ),
    );
  }

  /// Build info row
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Build footer
  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Center(
        child: pw.Text(
          'Thank you for using our service!'.tr,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ),
    );
  }

  /// Get status text
  static String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending'.tr;
      case 'accepted':
        return 'Accepted'.tr;
      case 'ongoing':
        return 'Ongoing'.tr;
      case 'completed':
        return 'Completed'.tr;
      case 'cancelled':
        return 'Cancelled'.tr;
      case 'rejected':
        return 'Rejected'.tr;
      default:
        return status;
    }
  }

  /// Get payment status text
  static String _getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'yes':
        return 'Paid'.tr;
      case 'no':
        return 'Unpaid'.tr;
      default:
        return status;
    }
  }
}
