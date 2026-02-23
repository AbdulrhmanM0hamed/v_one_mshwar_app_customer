import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:v_one_mshwar_app_customer/common/widget/notification_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/data/repo/fcm_token_repo.dart';
import 'package:v_one_mshwar_app_customer/core/navigation/app_navigator.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/widget/driver_notification_popup.dart';

/// Unified Notification Service.
/// Handles FCM setup, local notifications, foreground display, and tap routing.
class NotificationService {
  final AppNavigator navigator;
  final FcmTokenRepo tokenRepo;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService({required this.navigator, required this.tokenRepo});

  // ────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────

  /// Call once from MyApp.initState to wire everything up.
  Future<void> setup() async {
    await _initLocalNotifications();
    await _requestPermission();
    await _ensureApnsToken();
    await _subscribeToTopic();
    _listenForeground();
    _listenTapFromBackground();
    _listenTokenRefresh();
    await _handleInitialMessage();
    await _getAndUpdateToken();
  }

  // ────────────────────────────────────────────
  // Local notifications init
  // ────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) async {},
    );

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Notifications for important updates and broadcasts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // ────────────────────────────────────────────
  // FCM permission + topic subscription
  // ────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('✅ User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('⚠️ User granted provisional permission');
    } else {
      log('❌ User declined or has not accepted permission');
    }
  }

  Future<void> _ensureApnsToken() async {
    if (!Platform.isIOS) return;
    try {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      }
      if (apnsToken != null) {
        log('✅ APNS token obtained: $apnsToken');
      } else {
        log('⚠️ APNS token still not available, but proceeding...');
      }
    } catch (e) {
      log('⚠️ Error getting APNS token: $e');
    }
  }

  Future<void> _subscribeToTopic() async {
    const topic = "v_one_mshwar_app_customer_customer";
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      log('✅ Subscribed to topic: $topic');
    } catch (e) {
      log('❌ Error subscribing to topic: $e');
      await Future.delayed(const Duration(seconds: 2));
      try {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
        log('✅ Subscribed to topic after retry: $topic');
      } catch (retryError) {
        log('❌ Error subscribing to topic after retry: $retryError');
      }
    }
  }

  // ────────────────────────────────────────────
  // FCM listeners
  // ────────────────────────────────────────────

  Future<void> _handleInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final title = _extractTitle(initialMessage);
      final body = _extractBody(initialMessage);
      NotificationDialog.setPendingNotification(title, body);
      _handleNotificationTap(initialMessage);
    }
  }

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📨 Foreground message received');
      log('🔍 Data: ${jsonEncode(message.data)}');
      log(
        '🔍 Notification: ${message.notification?.title} - ${message.notification?.body}',
      );
      log('🔍 Type: ${message.data['type'] ?? 'none'}');

      if (message.notification != null || message.data.isNotEmpty) {
        if (message.data.isNotEmpty && message.notification == null) {
          log('📨 Data-only message received, displaying notification');
        }
        _displayNotification(message);
      }
    });
  }

  void _listenTapFromBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      log('🔄 FCM Token refreshed: $newToken', name: 'FCM_TOKEN');
      tokenRepo.updateToken(newToken);
    });
  }

  Future<void> _getAndUpdateToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log('📱 Initial FCM Token: $token', name: 'FCM_TOKEN');
        tokenRepo.updateToken(token);
      } else {
        log('⚠️ FCM Token is null', name: 'FCM_TOKEN');
      }
    } catch (e) {
      log('❌ Error getting initial FCM token: $e', name: 'FCM_TOKEN');
    }
  }

  // ────────────────────────────────────────────
  // Display system notification + foreground dialog
  // ────────────────────────────────────────────

  Future<void> _displayNotification(RemoteMessage message) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final title = _extractTitle(message);
    final body = _extractBody(message);

    const notificationDetails = NotificationDetails(
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

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );

    // Show dialog + driver popup if app is in foreground
    final ctx = navigator.currentContext;
    if (ctx != null) {
      NotificationDialog.show(context: ctx, title: title, message: body);

      // Driver notification popup
      final tag = message.data['tag'] ?? '';
      if (tag == 'driver_on_way' ||
          tag == 'driver_arrived' ||
          tag == 'driver_arrived_manual') {
        _showDriverNotificationPopup(
          ctx,
          message,
          tag == 'driver_arrived' || tag == 'driver_arrived_manual'
              ? 'arrived'
              : 'on_way',
        );
      }
    }

    log('✅ Notification displayed: $title - $body');
  }

  // ────────────────────────────────────────────
  // Handle notification tap routing
  // ────────────────────────────────────────────

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    log('🖱️ Notification tapped: ${jsonEncode(data)}');

    final title = _extractTitle(message);
    final body = _extractBody(message);

    // broadcast → BottomNavBar index 0
    if (data['type'] == 'broadcast') {
      log('📢 Broadcast notification tapped');
      NotificationDialog.setPendingNotification(title, body);
      try {
        navigator.toBottomNav(initialIndex: 0);
        _showPendingAfterDelay();
      } catch (e) {
        log('⚠️ Error navigating to dashboard: $e');
      }
      return;
    }

    // For other types, show pending dialog
    NotificationDialog.setPendingNotification(title, body);
    _showPendingAfterDelay();

    if (data['status'] == "done") {
      try {
        final msgJson = json.decode(data['message']);
        navigator.toConversation(
          receiverId: int.parse(msgJson['senderId'].toString()),
          orderId: int.parse(msgJson['orderId'].toString()),
          receiverName: msgJson['senderName'].toString(),
          receiverPhoto: msgJson['senderPhoto'].toString(),
        );
      } catch (e) {
        log('⚠️ Error navigating to conversation: $e');
      }
    } else if (data['tag'] == 'driver_on_way' ||
        data['tag'] == 'driver_arrived' ||
        data['tag'] == 'driver_arrived_manual') {
      if (data['ride_id'] != null) {
        try {
          navigator.toBottomNav(initialIndex: 1);
        } catch (e) {
          log('⚠️ Error navigating to route screen: $e');
        }
      }
    } else if (data['statut'] == "confirmed" ||
        data['statut'] == "driver_rejected") {
      navigator.toBottomNav(initialIndex: 1);
    } else if (data['statut'] == "on ride") {
      navigator.toRouteView(rideData: RideData.fromJson(data), type: 'on_ride');
    } else if (data['statut'] == "completed") {
      navigator.toTripHistory(rideData: RideData.fromJson(data));
    }
  }

  // ────────────────────────────────────────────
  // Private helpers
  // ────────────────────────────────────────────

  String _extractTitle(RemoteMessage message) {
    return message.notification?.title ??
        message.data['title'] ??
        'Notification';
  }

  String _extractBody(RemoteMessage message) {
    return message.notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        '';
  }

  void _showPendingAfterDelay() {
    Future.delayed(const Duration(milliseconds: 800), () {
      final ctx = navigator.currentContext;
      if (ctx != null) {
        NotificationDialog.showPendingNotification(ctx);
      }
    });
  }

  void _showDriverNotificationPopup(
    BuildContext context,
    RemoteMessage message,
    String notificationType,
  ) {
    final data = message.data;
    final title =
        message.notification?.title ?? data['title'] ?? 'Driver Update';
    final body = message.notification?.body ?? data['body'] ?? '';
    final driverName = data['driver_name'] ?? '';
    final eta = data['eta'] ?? data['eta_minutes'] ?? '';

    DriverNotificationPopup.show(
      context: context,
      title: title,
      message: body,
      driverName: driverName.isNotEmpty ? driverName : null,
      eta: eta.isNotEmpty ? eta : null,
      notificationType: notificationType,
    );
  }
}
