import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/payment_setting_model.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/tax_model.dart';
import 'package:v_one_mshwar_app_customer/features/authentication/model/user_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/chat/view/conversation_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/search_location_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/controller/search_address_controller.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Constant {
  static String? kGoogleApiKey = "";
  static String? distanceUnit = "KM";
  static String? appVersion = "0.0";
  static String? decimal = "2";
  static String? currency = "KWD";
  static String? driverRadius = "0";
  static bool symbolAtRight = false;
  static List<TaxModel> allTaxList = [];
  static List<TaxModel> taxList = [];
  static String liveTrackingMapType = "google";
  static String selectedMapType = 'google'; // 'osm'

  static String driverLocationUpdate = "10";
  static String? jsonNotificationFileURL = "";
  static String? senderId = "";
  static String? homeScreenType = "UberHome"; //"OlaHome";

  static String placeholderUrl =
      'https://v_one_mshwar_app_customer.siswebapp.com/assets/images/placeholder_image.jpg';

  // static String? taxValue = "0";
  // static String? taxType = 'Percentage';
  // static String? taxName = 'Tax';
  static String? contactUsEmail = "",
      contactUsAddress = "",
      contactUsPhone = "";
  static String? rideOtp = "yes";
  static String? showDriverInfoBeforePayment =
      "no"; // "yes" to show, "no" to hide
  static String? passengerCountRequired =
      "optional"; // "required", "optional", or "hidden"

  static String stripePublishablekey =
      "pk_test_51Kaaj9SE3HQdbrEJneDaJ2aqIyX1SBpYhtcMKfwchyohSZGp53F75LojfdGTNDUwsDV5p6x5BnbATcrerModlHWa00WWm5Yf5h";

  static CollectionReference conversation = FirebaseFirestore.instance
      .collection('conversation');
  static CollectionReference driverLocationUpdateCollection = FirebaseFirestore
      .instance
      .collection('driver_location_update');

  static String getUuid() {
    var uuid = const Uuid();
    return uuid.v1();
  }

  static UserModel getUserData() {
    final String user = Preferences.getString(Preferences.user);
    Map<String, dynamic> userMap = jsonDecode(user);
    return UserModel.fromJson(userMap);
  }

  static PaymentSettingModel getPaymentSetting() {
    final String user = Preferences.getString(Preferences.paymentSetting);
    if (user.isNotEmpty) {
      Map<String, dynamic> userMap = jsonDecode(user);
      return PaymentSettingModel.fromJson(userMap);
    }
    return PaymentSettingModel();
  }

  String amountShow({required String? amount}) {
    String amountdata =
        (amount == 'null' || amount == '' || amount == null || amount == '0')
        ? '0'
        : amount;

    if (amountdata == '0') {
      if (Constant.symbolAtRight == true) {
        return "0.00 KWD";
      } else {
        return "0.00 KWD";
      }
    } else {
      // Parse and format to 2 decimal places to avoid floating point precision issues
      final parsed = double.tryParse(amountdata);
      String formattedAmount = parsed != null
          ? parsed.toStringAsFixed(2)
          : amountdata;

      if (Constant.symbolAtRight == true) {
        return "$formattedAmount KWD";
      } else {
        return "$formattedAmount KWD";
      }
    }
  }
  //V2//TODO: NEW FIX
  // String amountShow({required String? amount}) {
  //   final parsed = double.tryParse(amount ?? '');

  //   if (parsed == null || parsed == 0.0) {
  //     return "0.00 KWD";
  //   }

  //   String formattedAmount = parsed.toStringAsFixed(3);

  //   if (Constant.symbolAtRight == true) {
  //     return "$formattedAmount KWD";
  //   } else {
  //     return "KWD $formattedAmount";
  //   }
  // }

  static Widget emptyView(BuildContext context, String msg, bool isButtonShow) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset('assets/icons/appLogo.png'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomText(
                text: msg.tr,
                align: TextAlign.center,
                color: themeChange.getThem()
                    ? AppThemeData.grey300Dark
                    : AppThemeData.grey400,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget loader(context, {Color? loadingcolor, Color? bgColor}) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Center(
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              bgColor ??
              (themeChange.getThem()
                  ? AppThemeData.surface50Dark
                  : AppThemeData.surface50),
          borderRadius: BorderRadius.circular(50),
        ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            loadingcolor ?? AppThemeData.primary200,
          ),
          strokeWidth: 3,
        ),
      ),
    );
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static Future<void> launchMapURl(
    String? latitude,
    String? longLatitude,
  ) async {
    String appleUrl =
        'https://maps.apple.com/?saddr=&daddr=$latitude,$longLatitude&directionsmode=driving';
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longLatitude';

    if (Platform.isIOS) {
      if (await canLaunch(appleUrl)) {
        await launch(appleUrl);
      } else {
        if (await canLaunch(googleUrl)) {
          await launch(googleUrl);
        } else {
          throw 'Could not open the map.';
        }
      }
    }
  }

  static Future<Url> uploadChatImageToFireStorage(File image) async {
    ShowToastDialog.showLoader('Uploading image...');
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child(
      'images/$uniqueID.png',
    );

    UploadTask uploadTask = upload.putFile(image);

    uploadTask.snapshotEvents.listen((event) {
      ShowToastDialog.showLoader(
        '${'Uploading image'.tr} ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} KB',
      );
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      ShowToastDialog.closeLoader();
      log(onError.message);
      return uploadTask.snapshot;
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(
      mime: metaData.contentType ?? 'image',
      url: downloadUrl.toString(),
    );
  }

  static Future<ChatVideoContainer> uploadChatVideoToFireStorage(
    File video,
  ) async {
    ShowToastDialog.showLoader('Uploading video');
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child(
      'videos/$uniqueID.mp4',
    );
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    uploadTask.snapshotEvents.listen((event) {
      ShowToastDialog.showLoader(
        '${'Uploading video'.tr} ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} KB',
      );
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(
      video: downloadUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
    );
    final file = File(uint8list ?? '');
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    ShowToastDialog.closeLoader();
    return ChatVideoContainer(
      videoUrl: Url(
        url: downloadUrl.toString(),
        mime: metaData.contentType ?? 'video'.tr,
      ),
      thumbnailUrl: thumbnailDownloadUrl,
    );
  }

  static Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false,
      includeAudio: true,
      frameRate: 24,
    );
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child(
      'thumbnails/$uniqueID.png',
    );
    UploadTask uploadTask = upload.putFile(file);
    var downloadUrl = await (await uploadTask.whenComplete(
      () {},
    )).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  /// Opens external map app with directions from origin to destination
  static Future<void> openExternalMapWithDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String originTitle = 'Pickup',
    String destTitle = 'Dropoff',
  }) async {
    final origin = launcher.Coords(originLat, originLng);
    final destination = launcher.Coords(destLat, destLng);

    // Helper function to launch map
    Future<bool> launchMap(launcher.MapType mapType) async {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(mapType);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: mapType,
          directionsMode: launcher.DirectionsMode.driving,
          origin: origin,
          originTitle: originTitle,
          destination: destination,
          destinationTitle: destTitle,
        );
        return true;
      }
      return false;
    }

    bool launched = false;

    // On iOS, try Google Maps first, then fallback to Apple Maps
    if (Platform.isIOS) {
      launched = await launchMap(launcher.MapType.google);
      if (!launched) {
        launched = await launchMap(launcher.MapType.apple);
      }
      if (!launched) {
        launched = await launchMap(launcher.MapType.waze);
      }
    } else {
      // Android: Try Google Maps first
      launched = await launchMap(launcher.MapType.google);
      if (!launched) {
        launched = await launchMap(launcher.MapType.waze);
      }
      if (!launched) {
        launched = await launchMap(launcher.MapType.googleGo);
      }
    }

    // If no map app is available, try web fallback
    if (!launched) {
      final url =
          'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ShowToastDialog.showToast(
          "No map application available. Please install Google Maps or Apple Maps.",
        );
      }
    }
  }

  static Future<void> redirectMap({
    required String name,
    required double latitude,
    required double longLatitude,
  }) async {
    if (Constant.liveTrackingMapType == "google") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(
        launcher.MapType.google,
      );
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.google,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google map is not installed");
      }
    } else if (Constant.liveTrackingMapType == "googleGo") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(
        launcher.MapType.googleGo,
      );
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.googleGo,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google Go map is not installed");
      }
    } else if (Constant.liveTrackingMapType == "waze") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(
        launcher.MapType.waze,
      );
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.waze,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Waze is not installed");
      }
    } else if (Constant.liveTrackingMapType == "mapswithme") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(
        launcher.MapType.mapswithme,
      );
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.mapswithme,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Mapswithme is not installed");
      }
    } else if (Constant.liveTrackingMapType == "yandexNavi") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(
        launcher.MapType.yandexNavi,
      );
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.yandexNavi,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("YandexNavi is not installed");
      }
    } else if (Constant.liveTrackingMapType == "yandexMaps") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(
        launcher.MapType.yandexMaps,
      );
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.yandexMaps,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("yandexMaps map is not installed");
      }
    }
  }

  Future<PlacesDetailsResponse?> placeSelectAPI(
    BuildContext context,
    TextEditingController ctrl,
  ) async {
    // Use custom search screen instead of PlacesAutocomplete.show() to avoid "powered by Google"
    try {
      final result = await Get.to(() => AddressSearchScreen());
      if (result == null) {
        return null;
      }

      // result is AddressSuggestion
      final AddressSuggestion suggestion = result;
      ctrl.text = suggestion.address;

      // Get place details using placeId
      if (suggestion.placeId != null && suggestion.placeId!.isNotEmpty) {
        return await displayPredictionFromPlaceId(suggestion.placeId!);
      }

      // Fallback: search by address text
      return await displayPredictionFromAddress(suggestion.address);
    } catch (e) {
      log('Error in placeSelectAPI: $e');
      return null;
    }
  }

  Future<PlacesDetailsResponse?> displayPredictionFromPlaceId(
    String placeId,
  ) async {
    try {
      String apiKey = Constant.kGoogleApiKey ?? '';
      // Check for empty, null string, or the literal "null" string
      if (apiKey.isEmpty ||
          apiKey.trim().isEmpty ||
          apiKey == 'null' ||
          apiKey.trim() == 'null') {
        log(
          '⚠️ displayPredictionFromPlaceId: Using fallback API key (backend key is: "$apiKey")',
        );
        apiKey = 'AIzaSyCvUrBOS0y4FDS6kAhkZhLRjTHtudwG43c';
      } else {
        apiKey = apiKey.trim();
      }

      GoogleMapsPlaces? places = GoogleMapsPlaces(
        apiKey: apiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse? detail = await places.getDetailsByPlaceId(placeId);
      return detail;
    } catch (e) {
      log('Error getting place details: $e');
      return null;
    }
  }

  Future<PlacesDetailsResponse?> displayPredictionFromAddress(
    String address,
  ) async {
    try {
      String apiKey = Constant.kGoogleApiKey ?? '';
      // Check for empty, null string, or the literal "null" string
      if (apiKey.isEmpty ||
          apiKey.trim().isEmpty ||
          apiKey == 'null' ||
          apiKey.trim() == 'null') {
        log(
          '⚠️ displayPredictionFromAddress: Using fallback API key (backend key is: "$apiKey")',
        );
        apiKey = 'AIzaSyCvUrBOS0y4FDS6kAhkZhLRjTHtudwG43c';
      } else {
        apiKey = apiKey.trim();
      }

      GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: apiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );

      // Use autocomplete to find the place
      PlacesAutocompleteResponse response = await places.autocomplete(
        address,
        language: 'en',
        components: [
          Component(Component.country, "kw"),
        ], // Restrict to Kuwait only
      );

      if (response.isOkay && response.predictions.isNotEmpty) {
        final placeId = response.predictions.first.placeId;
        if (placeId != null) {
          return await displayPredictionFromPlaceId(placeId);
        }
      }

      return null;
    } catch (e) {
      log('Error searching by address: $e');
      return null;
    }
  }

  Future<PlacesDetailsResponse?> displayPrediction(Prediction? p) async {
    if (p != null) {
      // Use API key from backend, fallback to hardcoded key if null/empty
      String apiKey = Constant.kGoogleApiKey ?? '';
      // Check for empty, null string, or the literal "null" string
      if (apiKey.isEmpty ||
          apiKey.trim().isEmpty ||
          apiKey == 'null' ||
          apiKey.trim() == 'null') {
        log(
          '⚠️ displayPrediction: Using fallback API key (backend key is: "$apiKey")',
        );
        apiKey = 'AIzaSyCvUrBOS0y4FDS6kAhkZhLRjTHtudwG43c';
      } else {
        apiKey = apiKey.trim();
      }

      GoogleMapsPlaces? places = GoogleMapsPlaces(
        apiKey: apiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse? detail = await places.getDetailsByPlaceId(
        p.placeId.toString(),
      );
      return detail;
    }
    return null;
  }

  Future<String?> updateAddress(address) {
    return address;
  }

  Future<Map<String, dynamic>> getOSMAddressFromLatLong(
    Position position,
  ) async {
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';

    var addressData = <String, dynamic>{};
    var package = Platform.isAndroid
        ? 'com.v_one_mshwar_app_customer.driver'
        : 'com.v_one_mshwar_app_customer.driver.ios';
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': package},
    );
    showLog("API :: URL :: $url");
    showLog("API :: Request Body :: ${jsonEncode({'User-Agent': package})} ");
    showLog("API :: Request Header :: ${API.header.toString()} ");
    showLog("API :: responseStatus :: ${response.statusCode} ");
    showLog("API :: responseBody :: ${response.body} ");

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      addressData = data;
    }
    log("Adress :: ${addressData.toString()}");
    return addressData;
  }

  Future<Map<String, dynamic>> getOSMAddressFromLatLongLatlng({
    required double lat,
    required double lng,
  }) async {
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';

    var addressData = <String, dynamic>{};
    var package = Platform.isAndroid
        ? 'com.v_one_mshwar_app_customer.driver'
        : 'com.v_one_mshwar_app_customer.driver.ios';
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': package},
    );
    showLog("API :: URL :: $url");
    showLog("API :: Request Body :: ${jsonEncode({'User-Agent': package})} ");
    showLog("API :: Request Header :: ${API.header.toString()} ");
    showLog("API :: responseStatus :: ${response.statusCode} ");
    showLog("API :: responseBody :: ${response.body} ");

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      addressData = data;
    }
    log("Adress :: ${addressData.toString()}");
    return addressData;
  }

  Future<String> getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];
    return '${place.subLocality}, ${place.locality}';
  }

  Future<String> getAddressFromltlg(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];
    return '${place.subLocality}, ${place.locality}';
  }

  Future<dynamic> getDurationDistance({
    required LatLng departureLatLong,
    required LatLng destinationLatLong,
  }) async {
    ShowToastDialog.showLoader("please_wait".tr);
    double originLat, originLong, destLat, destLong;
    originLat = departureLatLong.latitude;
    originLong = departureLatLong.longitude;
    destLat = destinationLatLong.latitude;
    destLong = destinationLatLong.longitude;
    var distance = 0.0;
    var duration = '';

    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    http.Response restaurantToCustomerTime = await http.get(
      Uri.parse(
        '$url?units=metric&origins=$originLat,'
        '$originLong&destinations=$destLat,$destLong&key=${Constant.kGoogleApiKey}',
      ),
    );

    var decodedResponse = jsonDecode(restaurantToCustomerTime.body);

    if (decodedResponse['status'] == 'OK' &&
        decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
      ShowToastDialog.closeLoader();
      if (decodedResponse != null) {
        if (Constant.distanceUnit == "KM") {
          distance =
              (double.parse(
                decodedResponse['rows']
                    .first['elements']
                    .first['distance']['value']
                    .toString(),
              ) /
              1000.00);
        } else {
          distance =
              double.parse(
                decodedResponse['rows']
                    .first['elements']
                    .first['distance']['value']
                    .toString(),
              ) /
              1609.34;
        }
        duration = decodedResponse['rows']
            .first['elements']
            .first['duration']['text']
            .toString();
      }
      var data = {
        'distance': distance.toString(),
        'duration': duration.toString(),
      };
      return data;
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<Map<String, dynamic>> getDurationOsmDistance(
    LatLng departureLatLong,
    LatLng destinationLatLong,
  ) async {
    var distance = 0.0;
    var duration = '';
    // var amount = 0.0;
    String url = 'http://router.project-osrm.org/route/v1/driving';
    String coordinates =
        '${departureLatLong.longitude},${departureLatLong.latitude};${destinationLatLong.longitude},${destinationLatLong.latitude}';

    http.Response response = await http.get(
      Uri.parse('$url/$coordinates?overview=false&steps=false'),
    );
    showLog("API :: URL :: $url/$coordinates?overview=false&steps=false");
    showLog("API :: responseStatus :: ${response.statusCode} ");
    showLog("API :: responseBody :: ${response.body} ");
    Map<String, dynamic> value = jsonDecode(response.body);

    if (value != {} && value.isNotEmpty) {
      int hours = value['routes'].first['duration'] ~/ 3600;
      int minutes = ((value['routes'].first['duration'] % 3600) / 60).round();
      duration = '$hours hours $minutes minutes';
      if (Constant.distanceUnit == "Km") {
        distance = (value['routes'].first['distance'] / 1000);
        // amount = amountCalculate(selectedType.value.kmCharge.toString(), distance.toStringAsFixed(Constant.currencyModel!.decimalDigits!));
      } else {
        distance = (value['routes'].first['distance'] / 1609.34);
        // amount = amountCalculate(selectedType.value.kmCharge.toString(), distance.toStringAsFixed(Constant.currencyModel!.decimalDigits!)_;
      }
    }
    var data = {
      'distance': distance.toString(),
      'duration': duration.toString(),
    };
    return data;
  }

  String getDurationByDistance(double duration) {
    int hours = duration ~/ 3600;
    int minutes = ((duration % 3600) / 60).round();
    return '$hours hours $minutes minutes';
  }

  double amountCalculate(String amount, String distance) {
    double finalAmount = 0.0;
    log("------->");
    log(amount);
    log(distance);
    finalAmount = double.parse(amount) * double.parse(distance);
    return finalAmount;
  }

  Future<String?> getAmount() async {
    try {
      ShowToastDialog.showLoader("please_wait".tr);
      final response = await http.get(
        Uri.parse(
          "${API.wallet}?id_user=${Preferences.getInt(Preferences.userId)}&user_cat=user_app",
        ),
        headers: API.header,
      );
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody['data']['amount'].toString();
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
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
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}

class Url {
  String mime;

  String url;

  Url({this.mime = '', this.url = ''});

  factory Url.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Url(mime: parsedJson['mime'] ?? '', url: parsedJson['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'mime': mime, 'url': url};
  }
}
