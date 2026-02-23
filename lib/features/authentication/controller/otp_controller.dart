import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/model/user_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/signup_screen.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/common/screens/botton_nav_bar.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OTPController extends GetxController {
  RxString phoneNumber = "".obs;

  var otpController = TextEditingController().obs;
  var verificationId = ''.obs;
  var resendToken = 0.obs;

  @override
  void onInit() {
    super.onInit();
    otpController.value.clear();
    getArgument();
    startTimer();
  }

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      phoneNumber.value = argumentData['phoneNumber'] ?? '';
      verificationId.value = argumentData['verificationId'] ?? '';
      resendToken.value = argumentData['resendTokenData'] ?? 0;
      update();
    }
  }

  Future<void> resendOTP() async {
    await resendOTPApiMethod({'mobile': phoneNumber.value});
    secondsRemaining.value = 60;
    enableResend.value = false;
    startTimer();
    otpController.value = TextEditingController();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
        update();
      } else {
        timer.cancel();
        enableResend.value = true;
        update();
      }
    });
  }

  RxInt secondsRemaining = 60.obs;
  Timer? timer;
  RxBool enableResend = false.obs;

  Future resendOTPApiMethod(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.post(
        Uri.parse(API.resendOtp),
        headers: API.authheader,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.resendOtp}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Response Status :: ${response.statusCode} ");
      showLog("API :: Response Body :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['status'] == 200) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          responseBody['message'] ?? 'otp_sent_successfully'.tr,
        );
      } else {
        ShowToastDialog.closeLoader();
        // Show the actual error message from API response
        String errorMessage =
            responseBody['message'] ??
            responseBody['error'] ??
            'failed_to_resend_otp'.tr;
        ShowToastDialog.showToast(errorMessage);
      }
    } on TimeoutException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('request_timed_out'.tr);
    } on SocketException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('no_internet_connection'.tr);
    } on FormatException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('invalid_server_response'.tr);
    } on Error {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('an_error_occurred'.tr);
    } catch (_) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('unexpected_error'.tr);
    }
    return null;
  }

  Future<bool> sendOTP() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber.value,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId0, int? resendToken0) async {
        verificationId.value = verificationId0;
        resendToken.value = resendToken0!;
        ShowToastDialog.showToast('otp_sent'.tr);
      },
      timeout: const Duration(seconds: 25),
      forceResendingToken: resendToken.value,
      codeAutoRetrievalTimeout: (String verificationId0) {
        verificationId0 = verificationId.value;
      },
    );
    return true;
  }

  Future VerifyOTPApiMethod(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.post(
        Uri.parse(API.verifyOtp),
        headers: API.authheader,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.verifyOtp}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Response Status :: ${response.statusCode} ");
      showLog("API :: Response Body :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 200) {
        print(response.body);
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          responseBody['message'] ?? 'otp_verified_successfully'.tr,
        );
        update();
        Map<String, String> body = {
          'phone': bodyParams['mobile'].toString(),
          'user_cat': "customer",
          'login_type': "phoneNumber",
        };
        phoneNumberIsExit(body);
      } else {
        ShowToastDialog.closeLoader();
        // Show the actual error message from API response
        String errorMessage =
            responseBody['message'] ??
            responseBody['error'] ??
            'invalid_otp'.tr;
        ShowToastDialog.showToast(errorMessage);
      }
    } on TimeoutException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('request_timed_out'.tr);
    } on SocketException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('no_internet_connection'.tr);
    } on FormatException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('invalid_server_response'.tr);
    } on Error {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('an_error_occurred'.tr);
    } catch (_) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('unexpected_error'.tr);
    }
    return null;
  }

  Future<bool?> phoneNumberIsExit(Map<String, String> bodyParams) async {
    print(bodyParams['mobile'].toString());
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.post(
        Uri.parse(API.getExistingUserOrNot),
        headers: API.authheader,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.getExistingUserOrNot}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Response Status :: ${response.statusCode} ");
      showLog("API :: Response Body :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        if (responseBody['success'] == "Failed") {
          ShowToastDialog.showToast(
            responseBody['error'] ?? 'failed_to_verify_user'.tr,
          );
          return false;
        }
        if (responseBody['data'] == true) {
          Map<String, String> body = {
            'phone': responseBody['mobile'].toString(),
            'user_cat': "customer",
            'login_type': "phoneNumber",
          };
          getDataByPhoneNumber(body);
          return true;
        } else {
          Get.off(
            SignupScreen(),
            arguments: {
              'phoneNumber': responseBody['mobile'].toString(),
              'login_type': "phoneNumber",
            },
          );
          return false;
        }
      } else {
        ShowToastDialog.closeLoader();
        String errorMessage =
            responseBody['message'] ??
            responseBody['error'] ??
            'unable_to_verify_user'.tr;
        ShowToastDialog.showToast(errorMessage);
        return false;
      }
    } on TimeoutException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('request_timed_out'.tr);
    } on SocketException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('no_internet_connection'.tr);
    } on FormatException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('invalid_server_response'.tr);
    } on Error {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('an_error_occurred'.tr);
    } catch (_) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('unexpected_error'.tr);
    }
    return null;
  }

  Future<UserModel?> getDataByPhoneNumber(
    Map<String, String> bodyParams,
  ) async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.post(
        Uri.parse(API.getProfileByPhone),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.getProfileByPhone}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Response Status :: ${response.statusCode} ");
      showLog("API :: Response Body :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        UserModel value = UserModel.fromJson(responseBody);
        Preferences.setInt(
          Preferences.userId,
          int.parse(value.data!.id.toString()),
        );
        Preferences.setString(Preferences.user, jsonEncode(value));
        Preferences.setString(
          Preferences.accesstoken,
          value.data!.accesstoken.toString(),
        );
        Preferences.setString(
          Preferences.admincommission,
          value.data!.adminCommission.toString(),
        );
        API.header['accesstoken'] = Preferences.getString(
          Preferences.accesstoken,
        );
        Preferences.setBoolean(Preferences.isLogin, true);

        // Preload home screen data before navigating
        ShowToastDialog.showLoader('Loading...'.tr);
        try {
          // Delete existing controller if any and create fresh one
          if (Get.isRegistered<HomeController>()) {
            Get.delete<HomeController>(force: true);
          }
          final homeController = Get.put(HomeController(), permanent: true);
          await homeController.setInitData(forceInit: true);
        } catch (e) {
          debugPrint('Error preloading home data: $e');
        }
        ShowToastDialog.closeLoader();

        Get.offAll(BottomNavBar());
        update();
        return UserModel.fromJson(responseBody);
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          responseBody['error'] ?? 'failed_to_get_profile'.tr,
        );
      } else {
        ShowToastDialog.closeLoader();
        String errorMessage =
            responseBody['message'] ??
            responseBody['error'] ??
            'unable_to_fetch_profile'.tr;
        ShowToastDialog.showToast(errorMessage);
      }
    } on TimeoutException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('request_timed_out'.tr);
    } on SocketException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('no_internet_connection'.tr);
    } on FormatException {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('invalid_server_response'.tr);
    } on Error {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('an_error_occurred'.tr);
    } catch (_) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('unexpected_error'.tr);
    }
    return null;
  }

  @override
  void onClose() {
    secondsRemaining.value = 60;
    timer?.cancel();
    super.onClose();
  }

  String formatTime() {
    final minutes = secondsRemaining.value ~/ 60;
    final remainingSeconds = secondsRemaining.value % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
