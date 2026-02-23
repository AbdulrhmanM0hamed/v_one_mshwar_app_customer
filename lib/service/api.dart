import 'dart:io';

import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';

class API {
  // ============ LOCAL DEVELOPMENT (COMMENTED) ============
  // For iOS Simulator: use http://localhost or http://127.0.0.1
  // For Android Emulator: use http://10.0.2.2 (special IP to access host machine)
  // For Physical Device: use your computer's local IP (e.g., http://192.168.1.100)
  // static String get _baseServerUrl {
  //   // iOS Simulator uses localhost (same network stack as Mac)
  //   if (Platform.isIOS) {
  //     return "http://127.0.0.1:8000";
  //   }
  //   // Android Emulator uses special IP to access host machine
  //   return "http://10.0.2.2:8000";
  // }
  // static const apiKey = "base64:s/Dkb2SuqpA8n33wB7WktW6qqhNlc2s8Gi5rsu551UA=";

  // ============ TESTING SERVER (COMMENTED) ============
  // static const String _baseServerUrl = "http://93.127.202.7";
  // static const apiKey = "base64:s/Dkb2SuqpA8n33wB7WktW6qqhNlc2s8Gi5rsu551UA=";

  // ============ LIVE SERVER ============
  static const String _baseServerUrl = "https://mshwar-app.com";
  static const apiKey = "base64:Npu3FfBZFo1sxlY/LBzHY/VwL59xbfNoCJUZzCkYtKY=";

  // Base URL for API v1 endpoints
  static String get baseUrl => "$_baseServerUrl/api/v1/";

  // Base URL for API endpoints (non-v1)
  static String get baseApiUrl => "$_baseServerUrl/api/";

  static Map<String, String> authheader = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
  };
  static Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
    'accesstoken': Preferences.getString(Preferences.accesstoken),
  };

  static String get userSignUP => "${baseUrl}user";
  static String get editProfile => "${baseUrl}update-user-profile";
  static String get userLogin => "${baseUrl}user-login";
  static String get sendOtp => "${baseUrl}send-otp";
  static String get verifyOtp => "${baseUrl}verify-otp";
  static String get resendOtp => "${baseUrl}resend-otp";
  static String get sendResetPasswordOtp => "${baseUrl}reset-password-otp";
  static String get resetPasswordOtp => "${baseUrl}resert-password";
  static String get getProfileByPhone => "${baseUrl}profilebyphone";
  static String get getExistingUserOrNot => "${baseUrl}existing-user";
  //static String get updateUserNic => "${baseUrl}update-user-nic";
  static String get uploadUserPhoto => "${baseUrl}user-photo";
  //  static String get updateUserEmail => "${baseUrl}update-user-email";
  static String get changePassword => "${baseUrl}update-user-mdp";
  static String get updatePreName => "${baseUrl}user-pre-name";
  static String get updateLastName => "${baseUrl}user-name";
  static String get updateAddress => "${baseUrl}user-address";
  static String get contactUs => "${baseUrl}contact-us";
  static String get updateToken => "${baseUrl}update-fcm";
  // static String get favorite => "${baseUrl}favorite";
  static String get transaction => "${baseUrl}transaction";
  static String get wallet => "${baseUrl}wallet";
  static String get amount => "${baseUrl}amount";
  static String get getFcmToken => "${baseUrl}fcm-token";
  //static String get deleteFavouriteRide => "${baseUrl}delete-favorite-ride";
  static String get rejectRide => "${baseUrl}set-rejected-requete";
  // static String getCommissionUrl({required driverId}) {
  //   return "$baseApiUrl/calculate-commission/$driverId";
  // }

  static String get getRideReview => "${baseUrl}get-ride-review";
  static String get userPendingPayment => "${baseUrl}user-pending-payment";
  // static String get scheduleRide => "$baseApiUrl/schedule-rides";
  static String get scheduleRide => "${baseUrl}requete-register";
  //static String get setFavouriteRide => "${baseUrl}favorite-ride";
  static String get getVehicleCategory => "${baseUrl}Vehicle-category";
  static String get driverDetails => "${baseUrl}driver";
  static String get getPaymentMethod => "${baseUrl}payment-method";
  static String get bookRides => "${baseUrl}requete-register";
  static String get userAllRides => "${baseUrl}user-all-rides";
  static String get userScheduledRides => "${baseUrl}user-scheduled-rides";
  //static String get newRide => "${baseUrl}requete-userapp";
  static String get confirmedRide => "${baseUrl}user-confirmation";
  //  static String get onRide => "${baseUrl}user-ride";
  //  static String get completedRide => "${baseUrl}user-complete";
  // static String get canceledRide => "${baseUrl}user-cancel";
  static String get driverConfirmRide => "${baseUrl}driver-confirm";
  static String get feelSafeAtDestination => "${baseUrl}feel-safe";
  static String get sos => "${baseUrl}storesos";
  static String get paymentSetting => "${baseUrl}payment-settings";
  static String get payRequestWallet => "${baseUrl}pay-requete-wallet";
  static String get payRequestCash => "${baseUrl}payment-by-cash";
  static String get payRequestTransaction => "${baseUrl}pay-requete";
  static String get addReview => "${baseUrl}note";
  static String get addComplaint => "${baseUrl}complaints";
  static String get getComplaint => "${baseUrl}complaintsList";
  static String get discountList => "${baseUrl}discount-list";
  static String get validateDiscount => "${baseUrl}validate-discount";
  static String get rideDetails => "${baseUrl}ridedetails";
  static String get getLanguage => "${baseUrl}language";
  static String deleteUser(String userId) =>
      "${baseUrl}user-delete?user_id=$userId";
  static String get settings => "${baseUrl}settings";
  static String get privacyPolicy => "${baseUrl}privacy-policy";
  static String get termsOfCondition => "${baseUrl}terms-of-condition";

  /* CalCulate Price */
  static String get getDistancePrice => "${baseUrl}calculate-fare";

  /* Subscription APIs */
  static String get subscriptionSettings => "${baseUrl}subscription/settings";
  static String get subscriptionCalculatePrice =>
      "${baseUrl}subscription/calculate-price";
  static String get subscriptionCreate => "${baseUrl}subscription/create";
  static String get subscriptionConfirmPayment =>
      "${baseUrl}subscription/confirm-payment";
  static String get subscriptionPayWallet =>
      "${baseUrl}subscription/pay-wallet";
  static String get subscriptionUserList =>
      "${baseUrl}subscription/user-subscriptions";
  static String get subscriptionDetails => "${baseUrl}subscription/details";
  static String get subscriptionUpcomingRides =>
      "${baseUrl}subscription/upcoming-rides";
  static String get subscriptionCancel => "${baseUrl}subscription/cancel";

  /* Package APIs */
  static String get packages => "${baseUrl}packages";
  static String get purchasePackage => "${baseUrl}packages/purchase";
  static String get packagePayWallet => "${baseUrl}packages/pay-wallet";
  static String get packageConfirmPayment =>
      "${baseUrl}packages/confirm-payment";
  static String get userPackages => "${baseUrl}packages/user-packages";
  static String get usablePackages => "${baseUrl}packages/usable";
  static String get applyPackageToRide => "${baseUrl}packages/apply-to-ride";
  // static String get packageUsageHistory => "${baseUrl}packages/usage-history";
  static String get cancelPackage => "${baseUrl}packages/cancel";

  /* Broadcast Notifications */
  //static String get getBroadcastNotifications => "${baseUrl}broadcast-user";

  /* Professional Notification System */
  static String getNotifications({int? limit, int? offset, bool? unreadOnly}) {
    String url = "${baseUrl}notifications/?user_type=customer";
    if (limit != null) url += "&limit=$limit";
    if (offset != null) url += "&offset=$offset";
    if (unreadOnly == true) url += "&unread_only=true";
    return url;
  }

  static String getUnreadCount() =>
      "${baseUrl}notifications/unread-count?user_type=customer";
  static String markAsRead(int id) =>
      "${baseUrl}notifications/$id/read?user_type=customer";
  static String markAllAsRead() =>
      "${baseUrl}notifications/read-all?user_type=customer";
  static String deleteNotification(int id) =>
      "${baseUrl}notifications/$id?user_type=customer";
  static String deleteAllNotifications() =>
      "${baseUrl}notifications/?user_type=customer";
}
