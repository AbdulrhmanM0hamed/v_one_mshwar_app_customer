import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/model/user_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/view/login_screen.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/dashboard.dart';
import 'package:v_one_mshwar_app_customer/features/settings/localization/view/localization_screen.dart';
import 'package:v_one_mshwar_app_customer/features/settings/profile/view/change_password_screen.dart';
import 'package:v_one_mshwar_app_customer/features/settings/profile/view/my_profile_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/normal_rides_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/scheduled_rides_screen.dart';
import 'package:v_one_mshwar_app_customer/features/plans/subscription/view/subscription_list_screen.dart';
import 'package:v_one_mshwar_app_customer/features/plans/package/view/package_list_screen.dart';
import 'package:v_one_mshwar_app_customer/features/settings/privacy_policy/view/privacy_policy_screen.dart';
import 'package:v_one_mshwar_app_customer/features/settings/terms_service/view/terms_of_service_screen.dart';
import 'package:v_one_mshwar_app_customer/features/payment/wallet/view/wallet_screen.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';

class DashBoardController extends GetxController {
  RxInt selectedDrawerIndex = 0.obs;
  RxBool darkModel = false.obs;

  @override
  void onInit() {
    getUsrData();
    super.onInit();
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    var themeProvider = Provider.of<DarkThemeProvider>(Get.context!);
    themeProvider.darkTheme = (isDarkMode == true ? 0 : 1);
  }

  UserModel? userModel;

  Future<void> getUsrData() async {
    userModel = Constant.getUserData();
    getDrawerItems();
    await updateToken();
    await getPaymentSettingData();
  }

  Future<void> updateToken() async {
    try {
      // Check if user is logged in before updating token
      if (Preferences.getInt(Preferences.userId) == 0) {
        log('User not logged in, skipping FCM token update');
        return;
      }

      // Get the FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('═══════════════════════════════════════════════════════');
        print('📱 FCM TOKEN RETRIEVED (Dashboard Controller)');
        print('═══════════════════════════════════════════════════════');
        print('Token: $token');
        print('═══════════════════════════════════════════════════════');
        log('FCM Token retrieved: $token', name: 'FCM_TOKEN');
        await updateFCMToken(token);
      } else {
        print('⚠️ FCM Token is null');
        log('FCM Token is null');
      }
    } catch (e) {
      log('Error updating FCM token: $e');
    }
  }

  void getDrawerItems() {
    drawerItems.clear();
    drawerItems.addAll([
      DrawerItem('home'.tr, 'ic_home'),
      DrawerItem('all_rides'.tr, 'ic_parcel', section: 'ride_management'.tr),
      DrawerItem(
        'scheduled_rides'.tr,
        'ic_calendar',
        section: 'ride_management'.tr,
      ),
      DrawerItem(
        'subscriptions'.tr,
        'ic_subscription',
        section: 'ride_management'.tr,
      ),
      DrawerItem('packages'.tr, 'ic_package', section: 'ride_management'.tr),
      DrawerItem('wallet'.tr, 'ic_wallet', section: 'account_payments'.tr),
      DrawerItem('my_profile'.tr, 'ic_profile'),
      DrawerItem('change_password'.tr, 'ic_lock'),
      DrawerItem(
        'change_language'.tr,
        'ic_language',
        section: 'app_settings'.tr,
      ),
      DrawerItem('terms_conditions'.tr, 'ic_terms'),
      DrawerItem('privacy_policy'.tr, 'ic_privacy'),
      DrawerItem('dark_mode'.tr, 'ic_dark', isSwitch: true),
      DrawerItem(
        'rate_the_app'.tr,
        'ic_star_line',
        section: 'feedback_support'.tr,
      ),
      DrawerItem('log_out'.tr, 'ic_logout'),
    ]);
  }

  var drawerItems = [].obs;
  final InAppReview inAppReview = InAppReview.instance;
  Future<void> onSelectItem(int index) async {
    Get.back();
    if (index == 1) {
      Get.to(() => const NewRideScreen());
    } else if (index == 2) {
      Get.to(() => const ScheduledRidesScreen());
    } else if (index == 3) {
      Get.to(() => const SubscriptionListScreen());
    } else if (index == 4) {
      Get.to(() => const PackageListScreen());
    } else if (index == 5) {
      Get.to(() => WalletScreen());
    } else if (index == 6) {
      Get.to(() => MyProfileScreen());
    } else if (index == 7) {
      Get.to(() => ChangePasswordScreen());
    } else if (index == 8) {
      Get.to(() => const LocalizationScreens(intentType: "dashBoard"));
    } else if (index == 9) {
      Get.to(const TermsOfServiceScreen());
    } else if (index == 10) {
      Get.to(const PrivacyPolicyScreen());
    } else if (index == 11) {
      // Dark mode - handled by switch
    } else if (index == 12) {
      try {
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        } else {
          log(":::::::::InAppReview:::::::::::");
          inAppReview.openStoreListing();
        }
      } catch (e) {
        log("Error triggering in-app review: $e");
      }
    } else if (index == 13) {
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Get.offAll(const LoginScreen());
    } else {
      selectedDrawerIndex.value = index;
    }
  }

  Future<dynamic> updateFCMToken(String token) async {
    try {
      Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId),
        'fcm_id': token,
        'device_id': "",
        'user_cat': userModel!.data!.userCat,
      };
      log(token, name: "token");
      final response = await http.post(
        Uri.parse(API.updateToken),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );
      showLog("API :: URL :: ${API.updateToken} ");
      showLog("API :: Request Body :: ${jsonEncode(bodyParams)} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        ShowToastDialog.showToast('something_went_wrong'.tr);
        throw Exception('Failed to load album');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getPaymentSettingData() async {
    try {
      final response = await http.get(
        Uri.parse(API.paymentSetting),
        headers: API.header,
      );
      showLog("API :: URL :: ${API.paymentSetting} ");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        Preferences.setString(
          Preferences.paymentSetting,
          jsonEncode(responseBody),
        );
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('something_went_wrong'.tr);
        throw Exception('Failed to load album');
      }
    } on TimeoutException {
      // ShowToastDialog.showToast(e.message.toString());
    } on SocketException {
      // ShowToastDialog.showToast(e.message.toString());
    } on Error {
      // ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
