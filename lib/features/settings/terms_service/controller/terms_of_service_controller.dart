import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class TermsOfServiceController extends GetxController {
  var data = ''.obs;
  @override
  void onInit() {
    getTermsOfService();

    super.onInit();
  }

  Future<dynamic> getTermsOfService() async {
    try {
      ShowToastDialog.showLoader('please_wait'.tr);
      final response = await http.get(
        Uri.parse(API.termsOfCondition),
        headers: API.header,
      );
      showLog("API :: URL :: ${API.termsOfCondition}");
      showLog("API :: Request Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        data.value = responseBody['data']['terms'];
        ShowToastDialog.closeLoader();
        return responseBody;
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
    update();
    return null;
  }
}
