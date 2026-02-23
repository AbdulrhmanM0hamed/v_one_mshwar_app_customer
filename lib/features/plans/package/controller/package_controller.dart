import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/model/package_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/controller/payment_controller.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PackageController extends GetxController {
  // Available packages for purchase
  var availablePackages = <PackageData>[].obs;
  var isPackagesLoading = true.obs;

  // User's purchased packages
  var userPackages = <UserPackageData>[].obs;
  var isUserPackagesLoading = true.obs;

  // Usable packages (for ride application)
  var usablePackages = <UserPackageData>[].obs;
  var isUsableLoading = false.obs;

  // Currently selected package for purchase
  var selectedPackage = Rx<PackageData?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAvailablePackages();
    fetchUserPackages();
  }

  /// Fetch available packages for purchase
  Future<void> fetchAvailablePackages() async {
    try {
      isPackagesLoading.value = true;

      final response = await http.get(
        Uri.parse(API.packages),
        headers: API.header,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = PackageModel.fromJson(data);
        if (model.success == 'success' && model.data != null) {
          availablePackages.value = model.data!;
        }
      }
    } catch (e) {
      showLog('Error fetching packages: $e');
    } finally {
      isPackagesLoading.value = false;
    }
  }

  /// Fetch user's purchased packages
  Future<void> fetchUserPackages({String? status}) async {
    try {
      isUserPackagesLoading.value = true;

      String url =
          "${API.userPackages}?user_id=${Preferences.getInt(Preferences.userId)}";
      if (status != null && status.isNotEmpty) {
        url += "&status=$status";
      }

      showLog('📦 Fetching user packages from: $url');

      final response = await http.get(Uri.parse(url), headers: API.header);

      showLog('📦 User packages response: ${response.statusCode}');
      showLog('📦 User packages body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = UserPackageModel.fromJson(data);
        if (model.success == 'success' && model.data != null) {
          userPackages.value = model.data!;
          // Log each package's KM info
          for (var pkg in model.data!) {
            showLog(
              '📦 Package ${pkg.packageName}: remaining=${pkg.remainingKm}, used=${pkg.usedKm}, total=${pkg.totalKm}',
            );
          }
        }
      }
    } catch (e) {
      showLog('📦 Error fetching user packages: $e');
    } finally {
      isUserPackagesLoading.value = false;
    }
  }

  /// Fetch usable packages for ride application
  Future<void> fetchUsablePackages() async {
    try {
      isUsableLoading.value = true;

      final response = await http.get(
        Uri.parse(
          "${API.usablePackages}?user_id=${Preferences.getInt(Preferences.userId)}",
        ),
        headers: API.header,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = UserPackageModel.fromJson(data);
        if (model.success == 'success' && model.data != null) {
          usablePackages.value = model.data!;
        }
      }
    } catch (e) {
      showLog('Error fetching usable packages: $e');
    } finally {
      isUsableLoading.value = false;
    }
  }

  /// Purchase a package (creates pending payment)
  Future<UserPackageData?> purchasePackage(
    String packageId,
    String paymentMethod,
  ) async {
    try {
      ShowToastDialog.showLoader('Initiating purchase...'.tr);

      // Convert string IDs to integers for backend validation
      final body = {
        'user_id': Preferences.getInt(Preferences.userId),
        'package_id': int.tryParse(packageId) ?? packageId,
        'payment_method': paymentMethod,
      };

      showLog('Purchase Package Request: $body');

      final response = await http.post(
        Uri.parse(API.purchasePackage),
        headers: API.header,
        body: json.encode(body),
      );

      ShowToastDialog.closeLoader();
      showLog(
        'Purchase Package Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success' && data['data'] != null) {
          return UserPackageData.fromJson(data['data']);
        } else {
          final error = data['error'];
          if (error is Map) {
            ShowToastDialog.showToast(
              error.values.first?.toString() ??
                  'Failed to initiate purchase'.tr,
            );
          } else {
            ShowToastDialog.showToast(
              error?.toString() ?? 'Failed to initiate purchase'.tr,
            );
          }
        }
      } else {
        final data = json.decode(response.body);
        final error = data['error'];
        if (error is Map) {
          ShowToastDialog.showToast(
            error.values.first?.toString() ?? 'Failed to initiate purchase'.tr,
          );
        } else {
          ShowToastDialog.showToast(
            error?.toString() ?? 'Failed to initiate purchase'.tr,
          );
        }
      }
    } on TimeoutException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Request timeout'.tr);
    } on SocketException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Network error'.tr);
    } catch (e) {
      ShowToastDialog.closeLoader();
      showLog('Purchase Package Error: $e');
      ShowToastDialog.showToast('${'Error: '.tr}$e');
    }
    return null;
  }

  /// Pay for package with wallet
  Future<Map<String, dynamic>?> payWithWallet(
    String userPackageId,
    double amount,
  ) async {
    try {
      ShowToastDialog.showLoader('Processing wallet payment...'.tr);

      // Convert string IDs to integers for backend validation
      final body = {
        'user_id': Preferences.getInt(Preferences.userId),
        'user_package_id': int.tryParse(userPackageId) ?? userPackageId,
        'amount': amount,
      };

      showLog('Pay With Wallet Request: $body');

      final response = await http.post(
        Uri.parse(API.packagePayWallet),
        headers: API.header,
        body: json.encode(body),
      );

      ShowToastDialog.closeLoader();
      showLog(
        'Pay With Wallet Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success') {
          // Update local wallet balance if available
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
          ShowToastDialog.showToast('Package purchased successfully!'.tr);
          return data;
        } else {
          final error = data['error'];
          if (error is Map) {
            ShowToastDialog.showToast(
              error.values.first?.toString() ?? 'Payment failed'.tr,
            );
          } else {
            ShowToastDialog.showToast(error?.toString() ?? 'Payment failed'.tr);
          }
        }
      } else {
        final data = json.decode(response.body);
        final error = data['error'];
        if (error is Map) {
          ShowToastDialog.showToast(
            error.values.first?.toString() ?? 'Payment failed'.tr,
          );
        } else {
          ShowToastDialog.showToast(error?.toString() ?? 'Payment failed'.tr);
        }
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      showLog('Pay With Wallet Error: $e');
      ShowToastDialog.showToast('${'Payment error: '.tr}$e');
    }
    return null;
  }

  /// Confirm payment (for KNET/other methods)
  Future<bool> confirmPayment(
    String userPackageId,
    String transactionId,
    String paymentMethod,
  ) async {
    try {
      ShowToastDialog.showLoader('Confirming payment...'.tr);

      // Convert string IDs to integers for backend validation
      final body = {
        'user_package_id': int.tryParse(userPackageId) ?? userPackageId,
        'transaction_id': transactionId,
        'payment_method': paymentMethod,
      };

      showLog('Confirm Payment Request: $body');

      final response = await http.post(
        Uri.parse(API.packageConfirmPayment),
        headers: API.header,
        body: json.encode(body),
      );

      ShowToastDialog.closeLoader();
      showLog(
        'Confirm Payment Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success') {
          ShowToastDialog.showToast('Package purchased successfully!'.tr);
          fetchUserPackages();
          return true;
        } else {
          final error = data['error'];
          if (error is Map) {
            ShowToastDialog.showToast(
              error.values.first?.toString() ?? 'Failed to confirm payment'.tr,
            );
          } else {
            ShowToastDialog.showToast(
              error?.toString() ?? 'Failed to confirm payment'.tr,
            );
          }
        }
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      showLog('Confirm Payment Error: $e');
      ShowToastDialog.showToast('${'Error: '.tr}$e');
    }
    return false;
  }

  /// Cancel a pending package
  /// [silent] - if true, don't show toast messages (for internal cancellation due to payment failure)
  Future<bool> cancelPackage(
    String userPackageId, {
    bool silent = false,
  }) async {
    try {
      if (!silent) {
        ShowToastDialog.showLoader('Cancelling...'.tr);
      }

      // Convert string IDs to integers for backend validation
      final body = {
        'user_id': Preferences.getInt(Preferences.userId),
        'user_package_id': int.tryParse(userPackageId) ?? userPackageId,
      };

      showLog('Cancel Package Request: $body');

      final response = await http.post(
        Uri.parse(API.cancelPackage),
        headers: API.header,
        body: json.encode(body),
      );

      if (!silent) {
        ShowToastDialog.closeLoader();
      }
      showLog(
        'Cancel Package Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success') {
          if (!silent) {
            ShowToastDialog.showToast('Package cancelled'.tr);
          }
          fetchUserPackages();
          return true;
        }
      }
    } catch (e) {
      if (!silent) {
        ShowToastDialog.closeLoader();
      }
      showLog('Cancel Package Error: $e');
    }
    return false;
  }

  /// Apply package to a ride
  Future<bool> applyToRide(
    String userPackageId,
    String rideId,
    double kmToDeduct,
  ) async {
    try {
      showLog('📦 ========== APPLY TO RIDE START ==========');
      showLog('📦 User Package ID: $userPackageId');
      showLog('📦 Ride ID: $rideId');
      showLog('📦 KM to Deduct: $kmToDeduct');
      showLog('📦 User ID: ${Preferences.getInt(Preferences.userId)}');

      // Convert string IDs to integers for backend validation
      final body = {
        'user_id': Preferences.getInt(Preferences.userId),
        'user_package_id': int.tryParse(userPackageId) ?? userPackageId,
        'ride_id': int.tryParse(rideId) ?? rideId,
        'km_to_deduct': kmToDeduct,
      };

      showLog('📦 Apply To Ride Request Body: $body');
      showLog('📦 API URL: ${API.applyPackageToRide}');

      final response = await http.post(
        Uri.parse(API.applyPackageToRide),
        headers: API.header,
        body: json.encode(body),
      );

      showLog('📦 Apply To Ride Response Status: ${response.statusCode}');
      showLog('📦 Apply To Ride Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == 'success') {
          showLog('📦 ✅ KM DEDUCTED SUCCESSFULLY!');
          showLog('📦 New package data: ${data['data']}');

          // Refresh package data
          await fetchUsablePackages();
          await fetchUserPackages();

          showLog('📦 ========== APPLY TO RIDE END (SUCCESS) ==========');
          return true;
        } else {
          showLog('📦 ❌ API returned error: ${data['error']}');
          final error = data['error'];
          if (error is Map) {
            ShowToastDialog.showToast(
              error.values.first?.toString() ?? 'Failed to apply package'.tr,
            );
          } else {
            ShowToastDialog.showToast(
              error?.toString() ?? 'Failed to apply package'.tr,
            );
          }
        }
      } else {
        showLog('📦 ❌ HTTP Error: ${response.statusCode}');
        showLog('📦 Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      showLog('📦 ❌ Apply To Ride Exception: $e');
      showLog('📦 Stack trace: $stackTrace');
      ShowToastDialog.showToast('${'Error applying package: '.tr}$e');
    }
    showLog('📦 ========== APPLY TO RIDE END (FAILED) ==========');
    return false;
  }

  /// Get wallet balance
  Future<double> getWalletBalance() async {
    try {
      final userData = Constant.getUserData();
      return double.tryParse(userData.data?.amount ?? '0') ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Process UPayments (KNET) payment - returns payment URL
  Future<String?> processUPaymentsPayment({
    required String userPackageId,
    required double amount,
    required String packageName,
  }) async {
    try {
      ShowToastDialog.showLoader('Initiating payment...'.tr);

      // Use PaymentController for UPayments payment
      final paymentController = Get.find<PaymentController>();
      final paymentUrl = await paymentController.processUPaymentsPaymentGeneric(
        amount: amount,
        productName: "Mshwar KM Package",
        productDescription: "Purchase: $packageName",
        customerExtraData: "user_package_id:$userPackageId",
      );

      ShowToastDialog.closeLoader();
      return paymentUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('${'Payment error: '.tr}$e');
      return null;
    }
  }
}
