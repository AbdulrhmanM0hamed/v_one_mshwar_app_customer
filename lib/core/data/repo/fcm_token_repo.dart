import 'dart:convert';
import 'dart:developer';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:http/http.dart' as http;

/// Repository interface for FCM token operations
abstract class FcmTokenRepo {
  Future<void> updateToken(String token);
}

/// Repository implementation for FCM token operations
class FcmTokenRepoImpl implements FcmTokenRepo {
  @override
  Future<void> updateToken(String token) async {
    try {
      final userId = Preferences.getInt(Preferences.userId);
      if (userId == 0) {
        log('⚠️ User not logged in, skipping token update');
        return;
      }

      final userModel = Constant.getUserData();
      if (userModel.data == null) {
        log('⚠️ User data not available, skipping token update');
        return;
      }

      final Map<String, dynamic> bodyParams = {
        'user_id': userId,
        'fcm_id': token,
        'device_id': "",
        'user_cat': userModel.data!.userCat,
      };

      final response = await http.post(
        Uri.parse(API.updateToken),
        headers: API.header,
        body: jsonEncode(bodyParams),
      );

      log('📤 Token update API response: ${response.statusCode}');
      if (response.statusCode == 200) {
        log('✅ FCM Token updated successfully');
      }
    } catch (e) {
      log('❌ Error in FCM token update: $e');
    }
  }
}
