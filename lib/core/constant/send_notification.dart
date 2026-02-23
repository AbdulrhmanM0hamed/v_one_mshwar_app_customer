// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:v_one_mshwar_app_customer/core/constant/logdata.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class SendNotification {
  static final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  static Future getCharacters() {
    return http.get(Uri.parse(Constant.jsonNotificationFileURL.toString()));
  }

  static Future<String> getAccessToken() async {
    Map<String, dynamic> jsonData = {};

    await getCharacters().then((response) {
      jsonData = json.decode(response.body);
    });
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
      jsonData,
    );

    final client = await clientViaServiceAccount(
      serviceAccountCredentials,
      _scopes,
    );
    return client.credentials.accessToken.data;
  }

  static Future<bool> sendOneNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final String accessToken = await getAccessToken();
      debugPrint(accessToken);

      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'message': {
            'token': token,
            'notification': {'body': body, 'title': title},
            'data': payload,
          },
        }),
      );

      showLog(
        "API :: URL :: https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send",
      );
      showLog(
        "API :: Request Body :: ${jsonEncode(<String, dynamic>{
          'message': {
            'token': token,
            'notification': {'body': body, 'title': title},
            'data': payload,
          },
        })}",
      );
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> sendBroadcastNotification({
    required String topic,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final String accessToken = await getAccessToken();
      debugPrint(accessToken);

      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'message': {
            'topic': topic,
            'notification': {'body': body, 'title': title},
            'data': payload,
          },
        }),
      );

      showLog(
        "API :: URL :: https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send",
      );
      showLog(
        "API :: Request Body :: ${jsonEncode(<String, dynamic>{
          'message': {
            'topic': topic,
            'notification': {'body': body, 'title': title},
            'data': payload,
          },
        })}",
      );
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: responseBody :: ${response.body} ");

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to send broadcast notification: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
