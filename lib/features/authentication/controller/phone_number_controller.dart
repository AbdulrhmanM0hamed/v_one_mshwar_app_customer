import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:http/http.dart' as http;
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneNumberController extends GetxController {
  var phoneNumber = TextEditingController().obs;
  var resendTokenData = 0.obs;

  Future<void> sendCode() async {
    await FirebaseAuth.instance
        .verifyPhoneNumber(
          phoneNumber: '+965${phoneNumber.value.text.trim()}',
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            ShowToastDialog.closeLoader();
            log(e.credential.toString());
            log(e.message.toString());
            log(e.code.toString());
            if (e.code == 'invalid-phone-number') {
              ShowToastDialog.showToast('invalid_phone_number'.tr);
            } else {
              log(e.message.toString());
              ShowToastDialog.showToast(e.message.toString());
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            resendTokenData.value = resendToken ?? 0;
            ShowToastDialog.closeLoader();
            Get.to(
              const OtpScreen(),
              arguments: {
                'phoneNumber': '+965${phoneNumber.value.text.trim()}',
                'verificationId': verificationId,
                'resendTokenData': resendTokenData.value,
              },
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          forceResendingToken: resendTokenData.value,
        )
        .catchError((error) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast('too_many_attempts'.tr);
        });
  }

  Future SendOTPApiMethod(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.post(
        Uri.parse(API.sendOtp),
        headers: API.authheader,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.sendOtp}");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Response Status :: ${response.statusCode} ");
      showLog("API :: Response Body :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['status'] == 200) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
          responseBody['message'] ?? 'otp_sent_successfully'.tr,
        );
        Get.to(
          const OtpScreen(),
          arguments: {'phoneNumber': '965${phoneNumber.value.text.trim()}'},
        );
      } else {
        ShowToastDialog.closeLoader();
        String errorMessage =
            responseBody['message'] ??
            responseBody['error'] ??
            'something_went_wrong'.tr;
        ShowToastDialog.showToast(errorMessage);
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
}
