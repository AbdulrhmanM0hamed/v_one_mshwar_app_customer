import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/CoupanCodeModel.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/payment_setting_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_details_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/tax_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/model/user_model.dart';
import 'package:v_one_mshwar_app_customer/common/screens/botton_nav_bar.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/sucess_screen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/view/payment_webview.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/scheduled_rides_screen.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PaymentController extends GetxController {
  var paymentSettingModel = PaymentSettingModel().obs;
  var walletAmount = "0.0".obs;
  TextEditingController couponCodeController = TextEditingController();
  TextEditingController tripAmountTextFieldController = TextEditingController();

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
  RxBool upayments = false.obs;
  dynamic argumentData = {};

  @override
  void onInit() {
    super.onInit();
    getCoupanCodeData();
    getArgument();
    getUsrData();
    paymentSettingModel.value = Constant.getPaymentSetting();
  }

  Future<dynamic> feelNotSafe(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("please_wait".tr);
      final response = await http.post(
        Uri.parse(API.feelSafeAtDestination),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody['success'] == 'success') {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
        // throw Exception('Failed to load album');
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

  Future<dynamic> canceledRide(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("please_wait".tr);
      final response = await http.post(
        Uri.parse(API.rejectRide),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.rejectRide}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  RxDouble subTotalAmount = 0.0.obs;
  RxDouble tipAmount = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
  RxDouble discountAmount = 0.0.obs;
  RxDouble adminCommission = 0.0.obs;
  RxString selectedPromoCode = "".obs;
  RxString selectedPromoValue = "".obs;
  var data = RideData().obs;
  var coupanCodeList = <CoupanCodeData>[].obs;

  // Package selection
  Rx<String?> selectedPackageId = Rx<String?>(null);
  RxDouble packageKmToDeduct = 0.0.obs;

  Future<dynamic> getCoupanCodeData() async {
    try {
      final response = await http.get(
        Uri.parse(API.discountList),
        headers: API.header,
      );
      showLog("API :: URL :: ${API.discountList}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        CoupanCodeModel model = CoupanCodeModel.fromJson(responseBody);
        if (model.data != null) {
          coupanCodeList.value = model.data!;
        } else {
          coupanCodeList.clear();
        }
        print('COupan: ${coupanCodeList.length}');
        update();
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        coupanCodeList.clear();
      } else {
        ShowToastDialog.showToast(
          'Something want wrong. Please try again later',
        );
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  // Validate discount code via API
  Future<Map<String, dynamic>?> validateDiscountCode(
    String code,
    double amount,
  ) async {
    try {
      ShowToastDialog.showLoader("Validating code...");
      final userId = Preferences.getInt(Preferences.userId);
      final response = await http.post(
        Uri.parse(API.validateDiscount),
        headers: API.header,
        body: jsonEncode({
          'code': code,
          'id_user_app': userId.toString(),
          'amount': amount.toString(),
          'coupon_type': 'Ride',
        }),
      );
      showLog("API :: URL :: ${API.validateDiscount}");
      showLog("API :: Request Body :: code=$code, amount=$amount");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);
      ShowToastDialog.closeLoader();

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        return responseBody['data'];
      } else {
        ShowToastDialog.showToast(
          responseBody['error'] ?? 'Invalid discount code',
        );
        return null;
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Error validating code: ${e.toString()}');
      return null;
    }
  }

  Future<void> getArgument() async {
    print("getArgument() is called");
    subTotalAmount.value = 0.0;
    tipAmount.value = 0.0;
    discountAmount.value = 0.0;
    taxAmount.value = 0.0;
    adminCommission.value = 0.0;
    argumentData = Get.arguments as RideData?;
    // print("Get.arguments: ${argumentData!.departName.toString() }");
    if (argumentData != null) {
      // data.value = argumentData["rideData"]!;
      selectedRadioTile.value = data.value.payment.toString();
      subTotalAmount.value = double.parse(data.value.montant.toString());
      // taxAmount.value = double.parse(Constant.taxValue ?? "0.0");
      if (selectedRadioTile.value == "Wallet") {
        wallet.value = true;
      } else if (selectedRadioTile.value == "Cash") {
        cash.value = true;
      } else if (selectedRadioTile.value == "Stripe") {
        stripe.value = true;
      } else if (selectedRadioTile.value == "PayStack") {
        payStack.value = true;
      } else if (selectedRadioTile.value == "FlutterWave") {
        flutterWave.value = true;
      } else if (selectedRadioTile.value == "RazorPay") {
        razorPay.value = true;
      } else if (selectedRadioTile.value == "PayFast") {
        payFast.value = true;
      } else if (selectedRadioTile.value == "MercadoPago") {
        mercadoPago.value = true;
      } else if (selectedRadioTile.value == "PayPal") {
        paypal.value = true;
      } else if (selectedRadioTile.value == "UPayments") {
        upayments.value = true;
      }
    }
    getAmount();
    print("statutPaiement: ${data.value.statutPaiement}");
    if (data.value.statutPaiement == "yes") {
      getRideDetailsData(data.value.id.toString());
    }
    if (data.value.statutPaiement != "yes") {
      for (var i = 0; i < Constant.taxList.length; i++) {
        if (Constant.taxList[i].statut == 'yes') {
          if (Constant.taxList[i].type == "Fixed") {
            taxAmount.value += double.parse(
              Constant.taxList[i].value.toString(),
            );
          } else {
            taxAmount.value +=
                ((subTotalAmount.value - discountAmount.value) *
                    double.parse(Constant.taxList[i].value!.toString())) /
                100;
          }
        }
      }
    }
    update();
  }

  Future<dynamic> getAmount() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${API.wallet}?id_user=${Preferences.getInt(Preferences.userId)}&user_cat=user_app",
        ),
        headers: API.header,
      );
      showLog(
        "API :: URL :: ${API.wallet}?id_user=${Preferences.getInt(Preferences.userId)}&user_cat=user_app",
      );
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        walletAmount.value = responseBody['data']['amount'].toString();
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast(
          'Something want wrong. Please try again later',
        );
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getRideDetailsData(String id) async {
    try {
      final response = await http.get(
        Uri.parse("${API.rideDetails}?ride_id=$id"),
        headers: API.header,
      );
      showLog("API :: URL :: ${API.rideDetails}?ride_id=$id");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        RideDetailsModel rideDetailsModel = RideDetailsModel.fromJson(
          responseBody,
        );

        subTotalAmount.value = double.parse(
          rideDetailsModel.rideDetailsdata!.montant.toString(),
        );
        tipAmount.value = double.parse(
          rideDetailsModel.rideDetailsdata!.tipAmount.toString(),
        );
        discountAmount.value = double.parse(
          rideDetailsModel.rideDetailsdata!.discount.toString(),
        );
        for (
          var i = 0;
          i < rideDetailsModel.rideDetailsdata!.taxModel!.length;
          i++
        ) {
          if (rideDetailsModel.rideDetailsdata!.taxModel![i].statut! == 'yes') {
            if (rideDetailsModel.rideDetailsdata!.taxModel![i].type ==
                "Fixed") {
              taxAmount.value += double.parse(
                rideDetailsModel.rideDetailsdata!.taxModel![i].value.toString(),
              );
            } else {
              taxAmount.value +=
                  ((subTotalAmount.value - discountAmount.value) *
                      double.parse(
                        rideDetailsModel.rideDetailsdata!.taxModel![i].value!
                            .toString(),
                      )) /
                  100;
            }
          }
        }
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast(
          'Something want wrong. Please try again later',
        );
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      print("Error in getRideDetailsData: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  double calculateTax({TaxModel? taxModel}) {
    double tax = 0.0;
    if (taxModel != null && taxModel.statut == 'yes') {
      if (taxModel.type.toString() == "Fixed") {
        tax = double.parse(taxModel.value.toString());
      } else {
        tax =
            ((subTotalAmount.value - discountAmount.value) *
                double.parse(taxModel.value!.toString())) /
            100;
      }
    }
    return tax;
  }

  double getTotalAmount() {
    // if (Constant.taxType == "Percentage") {
    //   taxAmount.value = Constant.taxValue != 0
    //       ? (subTotalAmount.value - discountAmount.value) *
    //           double.parse(Constant.taxValue.toString()) /
    //           100
    //       : 0.0;
    // } else {
    //   taxAmount.value = Constant.taxValue != 0
    //       ? double.parse(Constant.taxValue.toString())
    //       : 0.0;
    // }
    // if (paymentSettingModel.value.tax!.taxType == "percentage") {
    //   taxAmount.value = paymentSettingModel.value.tax!.taxAmount != null
    //       ? (subTotalAmount.value - discountAmount.value) *
    //           double.parse(
    //               paymentSettingModel.value.tax!.taxAmount.toString()) /
    //           100
    //       : 0.0;
    // } else {
    //   taxAmount.value = paymentSettingModel.value.tax!.taxAmount != null
    //       ? double.parse(paymentSettingModel.value.tax!.taxAmount.toString())
    //       : 0.0;
    // }

    return (subTotalAmount.value - discountAmount.value) +
        tipAmount.value +
        taxAmount.value;
  }

  Rx<UserModel> userModel = UserModel().obs;

  void getUsrData() {
    userModel.value = Constant.getUserData();
  }

  var isLoading = true.obs;
  RxString selectedRadioTile = "".obs;
  RxString paymentMethodId = "5".obs;

  Future<dynamic> walletDebitAmountRequest(
    Map<String, dynamic> bodyParams,
  ) async {
    try {
      ShowToastDialog.showLoader("please_wait".tr);

      final response = await http.post(
        Uri.parse(API.payRequestWallet),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.payRequestWallet}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        paymentLoader = false;
        update();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> cashPaymentRequest(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("please_wait".tr);
      final response = await http.post(
        Uri.parse(API.payRequestCash),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.payRequestCash}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 &&
          responseBody['success'].toString().toLowerCase() ==
              "Success".toString().toLowerCase()) {
        // transactionAmountRequest();
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> transactionAmountRequest() async {
    List taxList = [];

    for (var v in Constant.taxList) {
      taxList.add(v.toJson());
    }
    Map<String, dynamic> bodyParams = {
      'id_ride': data.value.id.toString(),
      'id_driver': data.value.idConducteur.toString(),
      'id_user_app': data.value.idUserApp.toString(),
      'amount': subTotalAmount.value.toString(),
      'paymethod': selectedRadioTile.value,
      'discount': discountAmount.value.toString(),
      'tip': tipAmount.value.toString(),
      'tax': taxList,
      'transaction_id': DateTime.now().microsecondsSinceEpoch.toString(),
      'payment_status': "success",
    };

    try {
      ShowToastDialog.showLoader("please_wait".tr);
      final response = await http.post(
        Uri.parse(API.payRequestTransaction),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.payRequestTransaction}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
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
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  String generateRandomId(int length) {
    final random = Random();
    const chars = '0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  bool paymentLoader = false;

  /// Generic UPayments payment processor - can be used from anywhere
  Future<String?> processUPaymentsPaymentGeneric({
    required double amount,
    required String productName,
    required String productDescription,
    String? customerExtraData,
  }) async {
    try {
      UserModel userModel = Constant.getUserData();
      User? user = userModel.data;

      // Generate random IDs
      final orderId = generateRandomId(11);
      final referenceId = generateRandomId(8);

      // Get customer data
      final customerName = "${user?.prenom ?? ''} ${user?.nom}";
      final customerEmail = user?.email;
      final customerMobile = user?.phone;
      final customerId = Preferences.getInt(Preferences.userId).toString();

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "products": [
          {
            "name": productName,
            "description": productDescription,
            "price": amount,
            "quantity": 1,
          },
        ],
        "order": {
          "id": orderId,
          "reference": referenceId,
          "description": productDescription,
          "currency": "KWD",
          "amount": amount,
        },
        "language": "en",
        "reference": {"id": referenceId},
        "customer": {
          "uniqueId": customerId,
          "name": customerName,
          "email": customerEmail,
          "mobile": customerMobile,
        },
        "returnUrl":
            paymentSettingModel.value.uPayments?.returnUrl ??
            "https://upayments.com/en/",
        "cancelUrl":
            paymentSettingModel.value.uPayments?.cancelUrl ??
            "https://error.com/",
        "notificationUrl":
            paymentSettingModel.value.uPayments?.notificationUrl ??
            "https://webhook.site/d7c6e1c8-b98b-4f77-8b51-b487540df336",
        "customerExtraData": customerExtraData ?? "",
      };

      // Get UPayments key from settings, fallback to hardcoded if not available
      final upaymentsKey =
          paymentSettingModel.value.uPayments?.key ??
          "4b49217c07291ab034197b3096d6eb77c2000653";

      // Always use production API endpoint
      final apiUrl = 'https://uapi.upayments.com/api/v1/charge';

      // Make API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $upaymentsKey',
        },
        body: json.encode(requestBody),
      );

      showLog('UPayments Response: ${response.body.toString()}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = UPaymentsResponse.fromJson(
          json.decode(response.body),
        );
        if (responseData.success && responseData.paymentUrl != null) {
          return responseData.paymentUrl;
        } else {
          showLog('UPayments Error: ${responseData.message}');
          return null;
        }
      } else {
        showLog('UPayments HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      showLog('UPayments Exception: $e');
      return null;
    }
  }

  Future<void> processUPaymentsPayment({
    required double amount,
    required BuildContext context,
    required HomeController controller,
    required driverid,
    required stoplist,
    required Function onPaymentSuccess,
    required bool isSchedule,
    DateTime? scheduleRideDateTime,
  }) async {
    try {
      // final walletController = Get.find<WalletController>();
      UserModel userModel = Constant.getUserData();
      User? user = userModel.data;

      // Generate random IDs
      final orderId = generateRandomId(11);
      final referenceId = generateRandomId(8);

      // Get customer data from preferences
      final customerName = "${user?.prenom ?? ''} ${user?.nom}";
      final customerEmail = user?.email;
      final customerMobile = user?.phone;
      final customerId = Preferences.getInt(Preferences.userId).toString();

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "products": [
          {
            "name": "Mshwar Taxi Booking",
            "description":
                "Taxi booking from ${controller.departureController.text} to ${controller.destinationController.text}",
            "price": amount,
            "quantity": 1,
          },
        ],
        "order": {
          "id": orderId,
          "reference": referenceId,
          "description":
              "Taxi booking from ${controller.departureController.text} to ${controller.destinationController.text}",
          "currency": "KWD",
          "amount": amount,
        },
        "language": "en",
        "reference": {"id": referenceId},
        "customer": {
          "uniqueId": customerId,
          "name": customerName,
          "email": customerEmail,
          "mobile": customerMobile,
        },
        "returnUrl":
            paymentSettingModel.value.uPayments?.returnUrl ??
            "https://upayments.com/en/",
        "cancelUrl":
            paymentSettingModel.value.uPayments?.cancelUrl ??
            "${API.baseUrl}check-requete",
        "notificationUrl":
            paymentSettingModel.value.uPayments?.notificationUrl ??
            "https://webhook.site/d7c6e1c8-b98b-4f77-8b51-b487540df336",
        "customerExtraData": "Taxi Booking",
      };

      // Get UPayments key from settings, fallback to hardcoded if not available
      final upaymentsKey =
          paymentSettingModel.value.uPayments?.key ??
          "4b49217c07291ab034197b3096d6eb77c2000653";

      // Always use production API endpoint
      final apiUrl = 'https://uapi.upayments.com/api/v1/charge';

      // Make API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $upaymentsKey',
        },
        body: json.encode(requestBody),
      );

      showLog(response.body.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = UPaymentsResponse.fromJson(
          json.decode(response.body),
        );
        showLog('Response: ${response.body.toString()}');
        if (responseData.success && responseData.paymentUrl != null) {
          ShowToastDialog.closeLoader();
          showLog('Payment URL from API: ${responseData.paymentUrl}');
          try {
            final result = await Get.to(
              () => PaymentWebViewScreen(
                url: responseData.paymentUrl!,
                title: 'Payment'.tr,
              ),
            );
            showLog('🔍 KNET Payment WebView returned: $result');
            showLog('🔍 Result type: ${result.runtimeType}');
            showLog(
              '🔍 Contains https: ${result.toString().contains('https')}',
            );
            showLog('🔍 Is false string: ${result == 'false'}');
            showLog('🔍 Is false bool: ${result == false}');
            showLog('🔍 Platform.isIOS: ${Platform.isIOS}');

            if (result.toString().contains('https')) {
              showLog('🔍 Processing URL result...');
              if (Platform.isAndroid == true) {
                Uri uri = Uri.parse(result);
                final Map<String, String> paymentDetails = uri.queryParameters;
                showLog('Payment result: $paymentDetails');

                if (paymentDetails['result'] == 'FAILED' ||
                    paymentDetails['result'] == 'CANCELD' ||
                    paymentDetails['result'] == 'CANCELED' ||
                    paymentDetails['result'] == 'NOT CAPTURED') {
                  ShowToastDialog.showToast(
                    "Oops!\nTransaction Declined 🚫".tr,
                  );
                  controller.destinationController.clear();
                  controller.polyLines.value = {};
                  // controller.departureLatLong.value = const LatLng(0, 0);
                  controller.destinationLatLong.value = const LatLng(0, 0);
                  controller.markers.clear();
                  controller.clearData();
                  controller.getDirections();
                  paymentLoader = false;
                  update();
                  Get.offAll(() => BottomNavBar());
                } else if (paymentDetails['result'] == 'SUCCESS' ||
                    paymentDetails['result'] == 'CAPTURED') {
                  if (isSchedule == false) {
                    Map<String, dynamic> successParams = {
                      'user_id': Preferences.getInt(
                        Preferences.userId,
                      ).toString(),
                      'lat1': controller.departureLatLong.value.latitude
                          .toString(),
                      'lng1': controller.departureLatLong.value.longitude
                          .toString(),
                      'lat2': controller.destinationLatLong.value.latitude
                          .toString(),
                      'lng2': controller.destinationLatLong.value.longitude
                          .toString(),
                      'cout': amount,
                      'distance': controller.distance.value.toString(),
                      'distance_unit': Constant.distanceUnit.toString(),
                      'duree': controller.duration.toString(),
                      'id_conducteur': driverid?.isNotEmpty == true
                          ? driverid
                          : '',
                      'id_payment':
                          controller.paymentMethodType.value ==
                              "KNET, Credit Card & Others"
                          ? '8'
                          : controller.paymentMethodId.value,
                      'payment_status': 'Success',
                      'depart_name': controller.departureController.text,
                      'destination_name': controller.destinationController.text,
                      'stops': stoplist,
                      'place': '',
                      'number_poeple': '1',
                      'image': '',
                      'image_name': "",
                      'statut_round': 'no',
                      'trip_objective': controller.tripOptionCategory.value,
                      'age_children1':
                          controller.addChildList[0].editingController.text,
                      'age_children2': controller.addChildList.length == 2
                          ? controller.addChildList[1].editingController.text
                          : "",
                      'age_children3': controller.addChildList.length == 3
                          ? controller.addChildList[2].editingController.text
                          : "",
                      "statut_payment": "yes", //Newly added parameter
                    };

                    // Add discount code if applied
                    if (selectedPromoCode.value.isNotEmpty) {
                      successParams['discount_code'] = selectedPromoCode.value;
                      successParams['discount'] = discountAmount.value
                          .toString();
                    }

                    controller.bookRide(successParams).then((value) async {
                      if (value != null) {
                        if (value['success'] == "success") {
                          Get.back();
                          // controller.departureController.clear();
                          controller.destinationController.clear();
                          controller.polyLines.value = {};
                          // controller.departureLatLong.value =
                          //     const LatLng(0, 0);
                          controller.destinationLatLong.value = const LatLng(
                            0,
                            0,
                          );
                          // passengerController.clear();

                          controller.markers.clear();
                          controller.clearData();
                          controller.getDirections();
                          paymentLoader = false;
                          Get.to(() => const RideBookingSuccessScreen());
                          ShowToastDialog.showToast(
                            "Payment Successfully ✅".tr,
                          );
                        }
                      }
                    });
                  } else {
                    final homeController = Get.find<HomeController>();
                    UserModel? user = UserModel.fromJson(
                      jsonDecode(Preferences.getString(Preferences.user)),
                    );
                    Map<String, dynamic> bodyParams = {
                      "ride_type": "Normal",
                      "statut": "new",
                      "distance_unit": Constant.distanceUnit,
                      "trip_objective": "General",
                      "statut_paiement": "yes",
                      "source": controller.departureController.text,
                      "destination": controller.destinationController.text,
                      "user_id": Preferences.getInt(
                        Preferences.userId,
                      ).toString(),
                      "user_detail": {
                        "name":
                            "${user.data?.nom ?? ""} ${user.data?.prenom ?? ""}",
                        "phone": user.data?.phone ?? "+923001234567",
                        "email": user.data?.email ?? "adil@example.com",
                      },
                      "lat1": controller.departureLatLong.value.latitude
                          .toString(),
                      "lng1": controller.departureLatLong.value.longitude
                          .toString(),
                      "lat2": controller.destinationLatLong.value.latitude
                          .toString(),
                      "lng2": controller.destinationLatLong.value.longitude
                          .toString(),
                      "cout": controller.ridePrice,
                      "duree": controller.duration.value,
                      "distance": controller.distance.value,
                      "age_children1": null,
                      "age_children2": null,
                      "age_children3": null,
                      "trip_category": homeController.tripOptionCategory.value,
                      "id_conducteur": driverId,
                      "id_payment": 5,
                      "depart_name": controller.departureController.text,
                      "destination_name": controller.destinationController.text,
                      "place": controller.departureController.text,
                      "number_poeple": "2",
                      "statut_round": "no",
                      "stops": stoplist,
                      "date_retour": "2025-10-30",
                      "heure_retour": "17:30:00",
                      "ride_sch_type": "schedule-ride",
                      "ride_date":
                          ("${scheduleRideDateTime?.year}-${scheduleRideDateTime?.month}-${scheduleRideDateTime?.day}"),
                      "ride_time":
                          ("${scheduleRideDateTime?.hour}:${scheduleRideDateTime?.minute}"),
                    };
                    await controller.scheduleRide(bodyParams).then((
                      value,
                    ) async {
                      if (value != null) {
                        if (value['success'] == "success") {
                          Get.back();
                          // controller.departureController.clear();
                          controller.destinationController.clear();
                          controller.polyLines.value = {};
                          // controller.departureLatLong.value =
                          //     const LatLng(0, 0);
                          controller.destinationLatLong.value = const LatLng(
                            0,
                            0,
                          );
                          // passengerController.clear();

                          controller.markers.clear();
                          controller.clearData();
                          controller.getDirections();
                          paymentLoader = false;
                          // ✅ FIX: Navigate to ScheduledRidesScreen for scheduled rides
                          Get.off(() => const ScheduledRidesScreen());
                          ShowToastDialog.showToast(
                            "Ride scheduled successfully ✅".tr,
                          );
                        }
                      }
                    });
                  }
                }
              } else if (Platform.isIOS == true) {
                showLog('🔍 iOS detected - calling getPaymentResponse...');
                getPaymentResponse(
                  result,
                  controller,
                  amount,
                  driverid,
                  stoplist,
                  isSchedule: isSchedule,
                  scheduleRideDateTime: scheduleRideDateTime,
                );
              }
            } else if (result == 'false' || result == false) {
              showLog(
                '🔍 Payment returned false - user cancelled or bank declined',
              );
              controller.destinationController.clear();
              controller.polyLines.value = {};
              // controller.departureLatLong.value = const LatLng(0, 0);
              controller.destinationLatLong.value = const LatLng(0, 0);
              // passengerController.clear();
              controller.markers.clear();
              controller.clearData();
              controller.getDirections();
              paymentLoader = false;
              update();
              Get.offAll(() => BottomNavBar());
              ShowToastDialog.showToast("Payment cancelled by user".tr);
            } else {
              showLog('🔍 Unexpected result format - going to else block');
              showLog('🔍 Result was: $result');
              ShowToastDialog.showToast("Oops!\nTransaction Declined 🚫".tr);
              controller.destinationController.clear();
              controller.polyLines.value = {};
              // controller.departureLatLong.value = const LatLng(0, 0);
              controller.destinationLatLong.value = const LatLng(0, 0);
              // passengerController.clear();
              controller.markers.clear();
              controller.clearData();
              controller.getDirections();
              paymentLoader = false;

              update();
              Get.offAll(() => BottomNavBar());
            }
            // if (result != null && result is Map<String, String>) {
            //   debugPrint('Processing successful payment with details: $result');
            //   // await _handlePaymentCompletion(
            //   //   result,
            //   //   amount: amount.toString(),
            //   // );
            //   if (result['result'].toString().toLowerCase() == 'captured') {
            //     onPaymentSuccess();
            //   }
            // } else if (result == false) {
            //   debugPrint('Payment cancelled by user');
            // ShowToastDialog.showToast("Payment cancelled by user".tr);
            // } else {
            //   debugPrint('Payment failed or returned null');
            //   ShowToastDialog.showToast("Payment failed".tr);
            // }
          } catch (e) {
            paymentLoader = false;
            update();
            debugPrint('Error in payment flow: $e');
            ShowToastDialog.showToast("Payment error occurred".tr);
          }
        }
      } else {
        paymentLoader = false;
        update();
        ShowToastDialog.showToast(
          "Payment service error: ${response.statusCode}".tr,
        );
      }
    } catch (e) {
      paymentLoader = false;
      update();
      ShowToastDialog.showToast("Payment error: ${e.toString()}".tr);
    }
  }

  Future<void> getPaymentResponse(
    url,
    HomeController controller,
    amount,
    driverid,
    stoplist, {
    required isSchedule,
    DateTime? scheduleRideDateTime,
  }) async {
    showLog("🍎 iOS getPaymentResponse CALLED");
    showLog("🍎 DRIVER ID: $driverid");
    showLog("🍎 isSchedule: $isSchedule");
    showLog("🍎 amount: $amount");
    try {
      final String urlString = url.toString();
      showLog("🍎 Processing URL: $urlString");

      // Decode URL in case it's URL-encoded
      final String decodedUrl = Uri.decodeFull(urlString);
      showLog("Decoded URL: $decodedUrl");

      final queryParams = Uri.parse(urlString).queryParameters;
      showLog("QUERY PARAMS $queryParams");

      String? paymentResult;

      // Method 1: Check for direct result parameter
      if (queryParams.containsKey('result')) {
        paymentResult = queryParams['result']?.toUpperCase();
        showLog("Found direct result: $paymentResult");
      }

      // Method 2: Check for kib_return_url parameter (iOS specific for KNET)
      if (paymentResult == null && queryParams.containsKey('kib_return_url')) {
        final kibReturnUrl = queryParams['kib_return_url'];
        showLog("Found kib_return_url: $kibReturnUrl");
        if (kibReturnUrl != null && kibReturnUrl.isNotEmpty) {
          // Decode the kib_return_url as it might be URL-encoded
          final decodedKibUrl = Uri.decodeFull(kibReturnUrl);
          final kibUri = Uri.tryParse(decodedKibUrl);
          if (kibUri != null && kibUri.queryParameters.containsKey('result')) {
            paymentResult = kibUri.queryParameters['result']?.toUpperCase();
            showLog("Extracted result from kib_return_url: $paymentResult");
          }
        }
      }

      // Method 3: Check URL patterns in decoded URL
      if (paymentResult == null) {
        final lowerUrl = decodedUrl.toLowerCase();
        showLog("Checking URL patterns in: $lowerUrl");
        if (lowerUrl.contains('result=captured') ||
            lowerUrl.contains('result=success') ||
            lowerUrl.contains('status=captured') ||
            lowerUrl.contains('status=success')) {
          paymentResult = 'CAPTURED';
          showLog("Pattern match found: CAPTURED");
        } else if (lowerUrl.contains('result=failed') ||
            lowerUrl.contains('result=canceled') ||
            lowerUrl.contains('result=cancelled') ||
            lowerUrl.contains('status=failed') ||
            lowerUrl.contains('error.com')) {
          paymentResult = 'FAILED';
          showLog("Pattern match found: FAILED");
        }
      }

      // Method 4: If URL is pay.upayments.com (returnUrl) and no failure detected,
      // UPayments only redirects to returnUrl on successful payment
      if (paymentResult == null &&
          (urlString.contains('pay.upayments.com') ||
              urlString.contains('upayments.com/en')) &&
          !urlString.contains('error')) {
        showLog(
          "UPayments return URL detected without error - treating as SUCCESS",
        );
        paymentResult = 'CAPTURED';
      }

      showLog("Final payment result: $paymentResult");

      // If still no result found
      if (paymentResult == null) {
        showLog("Could not determine payment result from URL: $urlString");
        ShowToastDialog.showToast("Oops!\nTransaction Declined 🚫".tr);
        return;
      }

      if (paymentResult == 'FAILED' ||
          paymentResult == 'CANCELD' ||
          paymentResult == 'CANCELED' ||
          paymentResult == 'NOT CAPTURED') {
        ShowToastDialog.showToast("Oops!\nTransaction Declined 🚫".tr);
        controller.destinationController.clear();
        controller.polyLines.value = {};
        // controller.departureLatLong.value = const LatLng(0, 0);
        controller.destinationLatLong.value = const LatLng(0, 0);
        controller.markers.clear();
        controller.clearData();
        controller.getDirections();
        update();
        Get.offAll(() => BottomNavBar());
      } else if (paymentResult == 'SUCCESS' || paymentResult == 'CAPTURED') {
        showLog("🍎 ✅ PAYMENT SUCCESS DETECTED! Booking ride...");
        showLog("🍎 isSchedule: $isSchedule");
        if (isSchedule == false) {
          showLog("🍎 Creating booking params for normal ride...");
          Map<String, dynamic> successParams = {
            'user_id': Preferences.getInt(Preferences.userId).toString(),
            'lat1': controller.departureLatLong.value.latitude.toString(),
            'lng1': controller.departureLatLong.value.longitude.toString(),
            'lat2': controller.destinationLatLong.value.latitude.toString(),
            'lng2': controller.destinationLatLong.value.longitude.toString(),
            'cout': amount,
            'distance': controller.distance.value.toString(),
            'distance_unit': Constant.distanceUnit.toString(),
            'duree': controller.duration.toString(),
            'id_conducteur': driverid?.isNotEmpty == true ? driverid : '',
            'id_payment':
                controller.paymentMethodType.value ==
                    "KNET, Credit Card & Others"
                ? '8'
                : controller.paymentMethodId.value,
            'payment_status': 'Success',
            'depart_name': controller.departureController.text,
            'destination_name': controller.destinationController.text,
            'stops': stoplist,
            'place': '',
            'number_poeple': '1',
            'image': '',
            'image_name': "",
            'statut_round': 'no',
            'trip_objective': controller.tripOptionCategory.value,
            'age_children1': controller.addChildList[0].editingController.text,
            'age_children2': controller.addChildList.length == 2
                ? controller.addChildList[1].editingController.text
                : "",
            'age_children3': controller.addChildList.length == 3
                ? controller.addChildList[2].editingController.text
                : "",
            "statut_payment": "yes", //Newly added parameter
          };
          showLog("🍎 Calling bookRide API with params: $successParams");
          controller.bookRide(successParams).then((value) async {
            showLog("🍎 bookRide API response: $value");
            if (value != null) {
              showLog("🍎 bookRide success status: ${value['success']}");

              if (value['success'] == "success") {
                showLog("🍎 ✅ RIDE BOOKED! Navigating to success screen...");
                Get.back();
                // controller.departureController.clear();
                controller.destinationController.clear();
                controller.polyLines.value = {};
                // controller.departureLatLong.value = const LatLng(0, 0);
                controller.destinationLatLong.value = const LatLng(0, 0);
                // passengerController.clear();
                controller.markers.clear();
                controller.clearData();
                controller.getDirections();
                // ✅ FIX: For scheduled rides, navigate to ScheduledRidesScreen
                if (isSchedule) {
                  Get.off(() => const ScheduledRidesScreen());
                  ShowToastDialog.showToast("Ride scheduled successfully ✅".tr);
                } else {
                  Get.to(() => const RideBookingSuccessScreen());
                  ShowToastDialog.showToast("Payment Successfully ✅".tr);
                }
              }
            }
          });
        } else {
          // ✅ Scheduled ride - use scheduleRideDateTime parameter
          final homeController = Get.find<HomeController>();
          UserModel? user = UserModel.fromJson(
            jsonDecode(Preferences.getString(Preferences.user)),
          );
          Map<String, dynamic> bodyParams = {
            "ride_type": "Normal",
            "statut": "new",
            "distance_unit": Constant.distanceUnit,
            "trip_objective": "General",
            "statut_paiement": "yes",
            "source": controller.departureController.text,
            "destination": controller.destinationController.text,
            "user_id": Preferences.getInt(Preferences.userId).toString(),
            "user_detail": {
              "name": "${user.data?.nom ?? ""} ${user.data?.prenom ?? ""}",
              "phone": user.data?.phone ?? "+923001234567",
              "email": user.data?.email ?? "adil@example.com",
            },
            "lat1": controller.departureLatLong.value.latitude.toString(),
            "lng1": controller.departureLatLong.value.longitude.toString(),
            "lat2": controller.destinationLatLong.value.latitude.toString(),
            "lng2": controller.destinationLatLong.value.longitude.toString(),
            "cout": controller.ridePrice,
            "duree": controller.duration.value,
            "distance": controller.distance.value,
            "age_children1": null,
            "age_children2": null,
            "age_children3": null,
            "trip_category": homeController.tripOptionCategory.value,
            "id_conducteur": driverId,
            "id_payment": 5,
            "depart_name": controller.departureController.text,
            "destination_name": controller.destinationController.text,
            "place": controller.departureController.text,
            "number_poeple": "2",
            "statut_round": "no",
            "stops": stoplist,
            "date_retour": "2025-10-30",
            "heure_retour": "17:30:00",
            "ride_sch_type": "schedule-ride",
            "ride_date":
                ("${scheduleRideDateTime?.year}-${scheduleRideDateTime?.month}-${scheduleRideDateTime?.day}"),
            "ride_time":
                ("${scheduleRideDateTime?.hour}:${scheduleRideDateTime?.minute}"),
          };
          await controller.scheduleRide(bodyParams).then((value) async {
            showLog("Value $value");
            if (value != null) {
              showLog("Value ${value['success']}");

              if (value['success'] == "success") {
                Get.back();
                // controller.departureController.clear();
                controller.destinationController.clear();
                controller.polyLines.value = {};
                // controller.departureLatLong.value = const LatLng(0, 0);
                controller.destinationLatLong.value = const LatLng(0, 0);
                // passengerController.clear();
                controller.markers.clear();
                controller.clearData();
                controller.getDirections();
                // ✅ FIX: Navigate to ScheduledRidesScreen for scheduled rides
                Get.off(() => const ScheduledRidesScreen());
                ShowToastDialog.showToast("Ride scheduled successfully ✅".tr);
              }
            }
          });
        }
      }
      paymentLoader = false;
      update();
    } catch (e, st) {
      showLog("❌ Error: $e");
      showLog("STACK $st");
      ShowToastDialog.showToast("Oops!\nTransaction Declined 🚫".tr);
      paymentLoader = false;
      update();
    }
  }

  // ============ Payment Method Selection ============
  /// Selects a payment method and clears all others
  /// Returns a map with paymentMethodType and paymentMethodId
  Map<String, String> selectPaymentMethod({
    required String method, // 'cash', 'wallet', 'upayments'
    required String paymentId,
  }) {
    // Clear all payment methods
    cash.value = false;
    wallet.value = false;
    stripe.value = false;
    razorPay.value = false;
    paypal.value = false;
    payStack.value = false;
    flutterWave.value = false;
    mercadoPago.value = false;
    payFast.value = false;
    xendit.value = false;
    orangePay.value = false;
    midtrans.value = false;
    upayments.value = false;

    String paymentMethodTypeValue = "select_method"; // Use localization key

    // Set selected payment method
    if (method == 'cash') {
      cash.value = true;
      paymentMethodTypeValue = "cash"; // Use localization key
    } else if (method == 'wallet') {
      wallet.value = true;
      paymentMethodTypeValue = "wallet"; // Use localization key
    } else if (method == 'upayments') {
      upayments.value = true;
      paymentMethodTypeValue =
          "knet_credit_card_others"; // Use localization key
    }

    update();

    return {
      'paymentMethodType': paymentMethodTypeValue,
      'paymentMethodId': paymentId,
    };
  }

  // ============ Discount Code Management ============
  RxString appliedDiscountCode = ''.obs;

  /// Apply discount code and calculate discount amount
  /// Returns the discount amount if successful, null otherwise
  Future<double?> applyDiscountCode({
    required String code,
    required double originalAmount,
  }) async {
    try {
      final discountData = await validateDiscountCode(code, originalAmount);
      if (discountData != null) {
        appliedDiscountCode.value = code.toUpperCase();
        final discountAmt = double.parse(
          discountData['discount_amount'].toString(),
        );
        discountAmount.value = discountAmt;
        return discountAmt;
      }
      return null;
    } catch (e) {
      showLog("Error applying discount: $e");
      return null;
    }
  }

  /// Remove applied discount code
  void removeDiscountCode() {
    appliedDiscountCode.value = '';
    discountAmount.value = 0.0;
    update();
  }

  /// Calculate final price after discount
  double calculateFinalPrice(double originalPrice) {
    return originalPrice - discountAmount.value;
  }
}
