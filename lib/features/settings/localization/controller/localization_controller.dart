import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/settings/localization/model/language_model.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LocalizationController extends GetxController {
  var languageList = <LanguageData>[].obs;
  RxString selectedLanguage = "en".obs;

  @override
  void onInit() {
    if (Preferences.getString(
      Preferences.languageCodeKey,
    ).toString().isNotEmpty) {
      selectedLanguage(
        Preferences.getString(Preferences.languageCodeKey).toString(),
      );
    }
    // getLanguage();
    loadData();
    super.onInit();
  }

  void loadData() async {
    // Hardcoded language options - no API call needed
    languageList.value = [
      LanguageData(
        id: '1',
        language: 'English',
        code: 'en',
        flag: 'https://flagcdn.com/w40/us.png', // US flag for English
        status: 'true',
        isRtl: 'false',
      ),
      LanguageData(
        id: '2',
        language: 'العربية', // Arabic
        code: 'ar',
        flag: 'https://flagcdn.com/w40/ae.png', // UAE flag for Arabic
        status: 'true',
        isRtl: 'true',
      ),
      LanguageData(
        id: '3',
        language: 'اردو', // Urdu
        code: 'ur',
        flag: 'https://flagcdn.com/w40/pk.png', // Pakistan flag for Urdu
        status: 'true',
        isRtl: 'true',
      ),
    ];

    // Uncomment below if you want to use API instead
    // await getLanguage().then((value) {
    //   if (value != null && value.success == 'Success' && value.data != null) {
    //     languageList
    //         .addAll(value.data!.where((element) => element.status == 'true'));
    //   }
    // });
  }

  Future<LanguageModel?> getLanguage() async {
    try {
      // ShowToastDialog.showLoader("please_wait");
      final response = await http.get(
        Uri.parse(API.getLanguage),
        headers: API.authheader,
      );
      showLog("API :: URL :: ${API.getLanguage}");
      showLog("API :: Response Header :: ${API.authheader.toString()} ");
      showLog("API :: Response Status :: ${response.statusCode} ");
      showLog("API :: Response Body :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        // ShowToastDialog.closeLoader();

        return LanguageModel.fromJson(responseBody);
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        // ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        // ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('something_went_wrong'.tr);
        throw Exception('failed_to_load_album');
      }
    } on TimeoutException catch (e) {
      // ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      // ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      // ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      // ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }
}
