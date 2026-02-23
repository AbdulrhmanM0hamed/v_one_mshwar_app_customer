import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import '../service/firebase_options.dart';

/// Global notification plugin instance for background handler
final FlutterLocalNotificationsPlugin backgroundNotificationPlugin =
    FlutterLocalNotificationsPlugin();

/// Firebase background message handler
/// Handles incoming FCM messages when app is in background or terminated
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  log('📨 Background Message received: ${jsonEncode(message.data)}');
  log(
    '📨 Notification: ${message.notification?.title} - ${message.notification?.body}',
  );

  // Initialize notification settings for both platforms
  const InitializationSettings initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ),
  );

  await backgroundNotificationPlugin.initialize(settings: initSettings);

  // Initialize notification channel for Android
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Notifications for important updates and broadcasts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await backgroundNotificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // Display notification if it has notification payload
  if (message.notification != null) {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await backgroundNotificationPlugin.show(
      id: id,
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );

    log('✅ Background notification displayed');
  }
}

/// App Initializer class
/// Handles all app initialization logic
class AppInitializer {
  /// Initialize Firebase services
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  }

  /// Initialize local notifications
  static Future<void> initializeNotifications() async {
    // Initialize notifications for iOS
    if (Platform.isIOS) {
      const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: iosInit,
      );

      await backgroundNotificationPlugin.initialize(settings: initSettings);
    }

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Initialize Google Maps
  static Future<void> initializeGoogleMaps() async {
    if (!Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Use Hybrid Composition for Android API 29+
      if (androidInfo.version.sdkInt > 28) {
        final GoogleMapsFlutterPlatform mapsImplementation =
            GoogleMapsFlutterPlatform.instance;
        if (mapsImplementation is GoogleMapsFlutterAndroid) {
          mapsImplementation.useAndroidViewSurface = true;
        }
      }
    }
  }

  /// Set device orientation
  static Future<void> setOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Initialize shared preferences
  static Future<void> initializePreferences() async {
    await Preferences.initPref();
  }

  /// Initialize all app dependencies
  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await initializeFirebase();

    // Set device orientation
    await setOrientation();

    // Initialize preferences
    await initializePreferences();

    // Initialize notifications
    await initializeNotifications();

    // Initialize Google Maps
    await initializeGoogleMaps();
  }
}
