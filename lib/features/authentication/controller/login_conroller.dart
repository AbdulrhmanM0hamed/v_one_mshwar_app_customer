import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/settings/profile/controller/settings_controller.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/model/user_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/signup_screen.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/home_controller.dart';
import 'package:v_one_mshwar_app_customer/common/screens/botton_nav_bar.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  var phoneController = TextEditingController().obs;
  var passwordController = TextEditingController().obs;

  Future<UserModel?> loginAPI(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.post(
        Uri.parse(API.userLogin),
        headers: API.authheader,
        body: jsonEncode(bodyParams),
      );

      showLog("API :: URL :: ${API.userLogin}");
      showLog("API :: Response Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Response Header :: ${API.authheader.toString()} ");
      showLog("API :: Response Status :: ${response.statusCode} ");
      showLog("API :: Response Body :: ${response.body} ");

      // Check if response is HTML (server error page)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        log('Server returned HTML instead of JSON - likely server error');
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Server error. Please try again later.');
        return null;
      }

      Map<String, dynamic> responseBody;
      try {
        responseBody = json.decode(response.body);
      } on FormatException catch (e) {
        log('JSON Parse Error: $e');
        log(
          'Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
        );
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Invalid server response. Please try again.');
        return null;
      }

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        Preferences.setString(
          Preferences.accesstoken,
          responseBody['data']['accesstoken'].toString(),
        );
        Preferences.setString(
          Preferences.admincommission,
          responseBody['data']['admin_commission'].toString(),
        );
        SettingsController settingsController = Get.put(SettingsController());
        settingsController.getSettingsData();
        API.header['accesstoken'] = Preferences.getString(
          Preferences.accesstoken,
        );

        return UserModel.fromJson(responseBody);
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('something_went_wrong'.tr);
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

  Future<bool?> phoneNumberIsExit(Map<String, String> bodyParams) async {
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
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        if (responseBody['data'] == true) {
          return true;
        } else {
          return false;
        }
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
        return false;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('something_went_wrong'.tr);
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
        return UserModel.fromJson(responseBody);
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('something_went_wrong'.tr);
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

  Future<void> loginWithGoogle() async {
    ShowToastDialog.showLoader('please_wait_dots'.tr);
    await signInWithGoogle().then((googleUser) async {
      ShowToastDialog.closeLoader();
      if (googleUser != null) {
        Map<String, String> bodyParams = {
          'user_cat': "customer",
          'email': googleUser.user!.email.toString(),
          'login_type': "google",
        };
        await phoneNumberIsExit(bodyParams).then((value) async {
          if (value == true) {
            Map<String, String> bodyParams = {
              'email': googleUser.user!.email.toString(),
              'user_cat': "customer",
              'login_type': "google",
            };
            await getDataByPhoneNumber(bodyParams).then((value) async {
              if (value != null) {
                if (value.success == "success") {
                  ShowToastDialog.closeLoader();

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
                    final homeController = Get.put(
                      HomeController(),
                      permanent: true,
                    );
                    await homeController.setInitData(forceInit: true);
                  } catch (e) {
                    debugPrint('Error preloading home data: $e');
                  }
                  ShowToastDialog.closeLoader();

                  Get.offAll(BottomNavBar());
                } else {
                  ShowToastDialog.showToast(value.error);
                }
              }
            });
          } else if (value == false) {
            ShowToastDialog.closeLoader();
            Get.off(
              SignupScreen(),
              arguments: {
                'email': googleUser.user!.email,
                'firstName': googleUser.user!.displayName,
                'login_type': "google",
              },
            );
          }
        });
      }
    });
  }

  Future<void> loginWithApple() async {
    ShowToastDialog.showLoader('please_wait_dots'.tr);
    await signInWithApple().then((value) async {
      ShowToastDialog.closeLoader();
      if (value != null) {
        Map<String, dynamic> map = value;
        AuthorizationCredentialAppleID appleCredential = map['appleCredential'];
        UserCredential userCredential = map['userCredential'];
        Map<String, String> bodyParams = {
          'user_cat': "customer",
          'email': userCredential.user!.email.toString(),
          'login_type': "apple",
        };
        await phoneNumberIsExit(bodyParams).then((value) async {
          if (value == true) {
            Map<String, String> bodyParams = {
              'email': userCredential.user!.email.toString(),
              'user_cat': "customer",
              'login_type': "apple",
            };
            await getDataByPhoneNumber(bodyParams).then((value) async {
              if (value != null) {
                if (value.success == "success") {
                  ShowToastDialog.closeLoader();

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
                    final homeController = Get.put(
                      HomeController(),
                      permanent: true,
                    );
                    await homeController.setInitData(forceInit: true);
                  } catch (e) {
                    debugPrint('Error preloading home data: $e');
                  }
                  ShowToastDialog.closeLoader();

                  Get.offAll(BottomNavBar());
                } else {
                  ShowToastDialog.showToast(value.error);
                }
              }
            });
          } else if (value == false) {
            ShowToastDialog.closeLoader();
            Get.off(
              SignupScreen(),
              arguments: {
                'email': userCredential.user!.email,
                'firstName': appleCredential.givenName,
                'lastname': appleCredential.familyName,
                'login_type': "apple",
              },
            );
          }
        });
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        // User canceled the sign-in
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('sign_in_cancelled'.tr);
        return null;
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      // final GoogleSignInAccount? googleUser =
      //     await GoogleSignIn().signIn().catchError((error) {
      //   ShowToastDialog.closeLoader();
      //   ShowToastDialog.showToast("something_went_wrong".tr);
      //   return null;
      // });

      // // Obtain the auth details from the request
      // final GoogleSignInAuthentication? googleAuth =
      //     await googleUser?.authentication;

      // // Create a new credential
      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth?.accessToken,
      //   idToken: googleAuth?.idToken,
      // );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
    // Trigger the authentication flow
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      AuthorizationCredentialAppleID
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        // webAuthenticationOptions: WebAuthenticationOptions(clientId: clientID, redirectUri: Uri.parse(redirectURL)),
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);
      return {
        "appleCredential": appleCredential,
        "userCredential": userCredential,
      };
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
