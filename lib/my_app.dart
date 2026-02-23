import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/features/home/controller/dash_board_controller.dart';
import 'package:v_one_mshwar_app_customer/features/home/view/dashboard.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/model/ride_model.dart';
import 'package:v_one_mshwar_app_customer/features/ride/chat/view/conversation_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/ride_details.dart';
import 'package:v_one_mshwar_app_customer/common/screens/botton_nav_bar.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/view/route_view_screen.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/widget/driver_notification_popup.dart';
import 'package:v_one_mshwar_app_customer/features/splash/splash_screen.dart';
import 'package:v_one_mshwar_app_customer/service/localization_service.dart';
import 'package:v_one_mshwar_app_customer/service/api.dart';
import 'package:v_one_mshwar_app_customer/core/themes/styles.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:v_one_mshwar_app_customer/common/widget/notification_dialog.dart';
import 'package:v_one_mshwar_app_customer/service/localization_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // Initialize with locale from preferences (synchronously)
  late Locale _currentLocale = LocalizationService.getCurrentLocale();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCurrentAppTheme();
    setupFCM(context);
    _loadLocale();
    // Listen to locale changes from GetX
    _listenToLocaleChanges();
  }

  void _listenToLocaleChanges() {
    // No listener needed - locale will be reloaded on app restart
  }

  Future<void> _loadLocale() async {
    final locale = LocalizationService.getCurrentLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
      // Always update GetX locale to ensure it's in sync
      Get.updateLocale(locale);
    }
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider
        .darkThemePreference
        .getTheme();
  }

  Future<void> setupFCM(BuildContext context) async {
    await initializeNotifications();

    // Request notification permissions
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
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

    // For iOS, wait for APNS token before subscribing to topics
    if (Platform.isIOS) {
      try {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          // Retry getting APNS token with a delay
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

    // Subscribe to topic after ensuring APNS token is available (iOS) or directly (Android)
    try {
      await FirebaseMessaging.instance.subscribeToTopic(
        "v_one_mshwar_app_customer_customer",
      );
      log('✅ Subscribed to topic: v_one_mshwar_app_customer_customer');
    } catch (e) {
      log('❌ Error subscribing to topic: $e');
      // Retry after a delay if it fails
      await Future.delayed(const Duration(seconds: 2));
      try {
        await FirebaseMessaging.instance.subscribeToTopic(
          "v_one_mshwar_app_customer_customer",
        );
        log(
          '✅ Subscribed to topic after retry: v_one_mshwar_app_customer_customer',
        );
      } catch (retryError) {
        log('❌ Error subscribing to topic after retry: $retryError');
      }
    }

    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      // Store the notification to show dialog after splash screen
      String title =
          initialMessage.notification?.title ??
          initialMessage.data['title'] ??
          'Notification';
      String body =
          initialMessage.notification?.body ??
          initialMessage.data['body'] ??
          initialMessage.data['message'] ??
          '';
      NotificationDialog.setPendingNotification(title, body);
      _handleNotificationTap(initialMessage);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📨 Foreground message received');
      log('🔍 Data: ${jsonEncode(message.data)}');
      log(
        '🔍 Notification: ${message.notification?.title} - ${message.notification?.body}',
      );
      log('🔍 Type: ${message.data['type'] ?? 'none'}');

      if (message.notification != null) {
        displayNotification(message);
      } else if (message.data.isNotEmpty) {
        // Handle data-only messages (for broadcast or other types)
        log('📨 Data-only message received, displaying notification');
        displayNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Listen for token refresh and update it automatically
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      log('🔄 FCM Token refreshed: $newToken', name: 'FCM_TOKEN');
      _updateTokenToBackend(newToken);
    });

    // Get initial token and update it
    _getAndUpdateToken();
  }

  Future<void> _getAndUpdateToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log('📱 Initial FCM Token: $token', name: 'FCM_TOKEN');
        _updateTokenToBackend(token);
      } else {
        log('⚠️ FCM Token is null', name: 'FCM_TOKEN');
      }
    } catch (e) {
      log('❌ Error getting initial FCM token: $e', name: 'FCM_TOKEN');
    }
  }

  Future<void> _updateTokenToBackend(String token) async {
    try {
      // Check if user is logged in
      final userId = Preferences.getInt(Preferences.userId);
      if (userId == 0) {
        log('⚠️ User not logged in, skipping token update');
        return;
      }

      // Try to get dashboard controller if it exists, otherwise update directly
      try {
        if (Get.isRegistered<DashBoardController>()) {
          final dashBoardController = Get.find<DashBoardController>();
          await dashBoardController.updateFCMToken(token);
          log('✅ FCM Token updated successfully via controller');
        } else {
          // Controller not initialized yet, update directly
          await _updateFCMTokenDirectly(token);
          log('✅ FCM Token updated successfully (direct)');
        }
      } catch (e) {
        // Fallback to direct update if controller access fails
        log('⚠️ Controller access failed, trying direct update: $e');
        await _updateFCMTokenDirectly(token);
      }
    } catch (e) {
      log('❌ Error updating FCM token to backend: $e');
    }
  }

  Future<void> _updateFCMTokenDirectly(String token) async {
    try {
      final userModel = Constant.getUserData();
      if (userModel.data == null) {
        log('⚠️ User data not available, skipping token update');
        return;
      }

      final Map<String, dynamic> bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId),
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
      log('❌ Error in direct token update: $e');
    }
  }

  Future<void> initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) async {
        // Optional: Handle tap from system tray
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Notifications for important updates and broadcasts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void displayNotification(RemoteMessage message) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Get title and body from notification or data payload
    String title =
        message.notification?.title ?? message.data['title'] ?? 'Notification';
    String body =
        message.notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        '';

    // Always show system notification with sound for audio feedback
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

    // Show system notification with sound (even if dialog is shown)
    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );

    // Also show beautiful dialog if app is in foreground
    if (navigatorKey.currentContext != null) {
      NotificationDialog.show(
        context: navigatorKey.currentContext!,
        title: title,
        message: body,
      );
    }

    log('✅ Notification displayed: $title - $body');
  }

  void _handleNotificationTap(RemoteMessage message) async {
    final data = message.data;
    log('🖱️ Notification tapped: ${jsonEncode(data)}');

    // Get title and body for dialog
    String title =
        message.notification?.title ?? data['title'] ?? 'Notification';
    String body =
        message.notification?.body ?? data['body'] ?? data['message'] ?? '';

    // Handle broadcast notifications - show dialog and navigate to dashboard
    if (data['type'] == 'broadcast') {
      log('📢 Broadcast notification tapped');

      // Store pending notification to show after app is ready
      NotificationDialog.setPendingNotification(title, body);

      try {
        Get.put(DashBoardController()).selectedDrawerIndex.value = 0;
        await Get.to(() => BottomNavBar());

        // Show dialog after navigation
        Future.delayed(const Duration(milliseconds: 800), () {
          if (navigatorKey.currentContext != null) {
            NotificationDialog.showPendingNotification(
              navigatorKey.currentContext!,
            );
          }
        });
      } catch (e) {
        log('⚠️ Error navigating to dashboard: $e');
      }
      return;
    }

    // For other notification types, also show dialog
    NotificationDialog.setPendingNotification(title, body);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (navigatorKey.currentContext != null) {
        NotificationDialog.showPendingNotification(
          navigatorKey.currentContext!,
        );
      }
    });

    if (data['status'] == "done") {
      await Get.to(
        () => ConversationScreen(),
        arguments: {
          'receiverId': int.parse(
            json.decode(data['message'])['senderId'].toString(),
          ),
          'orderId': int.parse(
            json.decode(data['message'])['orderId'].toString(),
          ),
          'receiverName': json.decode(data['message'])['senderName'].toString(),
          'receiverPhoto': json
              .decode(data['message'])['senderPhoto']
              .toString(),
        },
      );
    } else if (data['tag'] == 'driver_on_way' ||
        data['tag'] == 'driver_arrived' ||
        data['tag'] == 'driver_arrived_manual') {
      // Handle driver notification taps - navigate to route screen if available
      final rideId = data['ride_id'];
      if (rideId != null) {
        try {
          Get.put(DashBoardController()).selectedDrawerIndex.value = 1;
          await Get.to(() => BottomNavBar());
        } catch (e) {
          log('⚠️ Error navigating to route screen: $e');
        }
      }
    } else if (data['statut'] == "confirmed" ||
        data['statut'] == "driver_rejected") {
      Get.put(DashBoardController()).selectedDrawerIndex.value = 1;
      await Get.to(() => BottomNavBar());
    } else if (data['statut'] == "on ride") {
      var argumentData = {
        'type': 'on_ride'.tr,
        'data': RideData.fromJson(data),
      };
      Get.to(() => const RouteViewScreen(), arguments: argumentData);
    } else if (data['statut'] == "completed") {
      Get.to(
        () => TripHistoryScreen(),
        arguments: {"rideData": RideData.fromJson(data)},
      );
    }
  }

  // Show driver notification popup
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

    // Only show driver name if it's not empty (respects admin setting)
    final displayDriverName = driverName.isNotEmpty ? driverName : null;

    DriverNotificationPopup.show(
      context: context,
      title: title,
      message: body,
      driverName: displayDriverName,
      eta: eta.isNotEmpty ? eta : null,
      notificationType: notificationType,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  // void getCurrentAppTheme() async {
  //   themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
  // }

  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // For iOS, wait for APNS token before subscribing to topics
    if (Platform.isIOS) {
      try {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        }
      } catch (e) {
        log('⚠️ Error getting APNS token: $e');
      }
    }

    // Subscribe to topic after ensuring APNS token is available
    try {
      await FirebaseMessaging.instance.subscribeToTopic(
        "v_one_mshwar_app_customer_customer",
      );
    } catch (e) {
      log('❌ Error subscribing to topic: $e');
      await Future.delayed(const Duration(seconds: 2));
      try {
        await FirebaseMessaging.instance.subscribeToTopic(
          "v_one_mshwar_app_customer_customer",
        );
      } catch (retryError) {
        log('❌ Error subscribing to topic after retry: $retryError');
      }
    }

    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {}

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        display(message);

        // Handle driver notification popups
        final data = message.data;
        final tag = data['tag'] ?? '';

        if (tag == 'driver_on_way' ||
            tag == 'driver_arrived' ||
            tag == 'driver_arrived_manual') {
          // Show popup for driver notifications
          _showDriverNotificationPopup(
            context,
            message,
            tag == 'driver_arrived' || tag == 'driver_arrived_manual'
                ? 'arrived'
                : 'on_way',
          );
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        if (message.data['status'] == "done") {
          await Get.to(
            ConversationScreen(),
            arguments: {
              'receiverId': int.parse(
                json.decode(message.data['message'])['senderId'].toString(),
              ),
              'orderId': int.parse(
                json.decode(message.data['message'])['orderId'].toString(),
              ),
              'receiverName': json
                  .decode(message.data['message'])['senderName']
                  .toString(),
              'receiverPhoto': json
                  .decode(message.data['message'])['senderPhoto']
                  .toString(),
            },
          );
        } else if (message.data['tag'] == 'driver_on_way' ||
            message.data['tag'] == 'driver_arrived' ||
            message.data['tag'] == 'driver_arrived_manual') {
          // Handle driver notification taps - navigate to route screen if available
          final rideId = message.data['ride_id'];
          if (rideId != null) {
            try {
              DashBoardController dashBoardController = Get.put(
                DashBoardController(),
              );
              dashBoardController.selectedDrawerIndex.value = 1;
              await Get.to(DashBoard());
            } catch (e) {
              log('⚠️ Error navigating to route screen: $e');
            }
          }
        } else if (message.data['statut'] == "confirmed" ||
            message.data['statut'] == "driver_rejected") {
          DashBoardController dashBoardController = Get.put(
            DashBoardController(),
          );
          dashBoardController.selectedDrawerIndex.value = 1;
          await Get.to(DashBoard());
        } else if (message.data['statut'] == "on ride") {
          var argumentData = {
            'type': 'on_ride'.tr,
            'data': RideData.fromJson(message.data),
          };

          Get.to(const RouteViewScreen(), arguments: argumentData);
        } else if (message.data['statut'] == "completed") {
          Get.to(
            TripHistoryScreen(),
            arguments: {"rideData": RideData.fromJson(message.data)},
          );
        }
      }
    });
  }

  Future<void> initialize(BuildContext context) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'Notifications for important updates and broadcasts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: iosInitializationSettings,
        );
    await FlutterLocalNotificationsPlugin().initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {},
    );

    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Get title and body from notification or data payload
      String title =
          message.notification?.title ??
          message.data['title'] ??
          'Notification';
      String body =
          message.notification?.body ??
          message.data['body'] ??
          message.data['message'] ??
          '';

      // Always show system notification with sound for audio feedback
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

      // Show system notification with sound (even if dialog is shown)
      await FlutterLocalNotificationsPlugin().show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: jsonEncode(message.data),
      );

      log('✅ Notification displayed: $title - $body');
    } on Exception catch (e) {
      log('❌ Error displaying notification: $e');
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Use Get.locale if available, otherwise use _currentLocale
    final currentLocale = Get.locale ?? _currentLocale;
    final isRTL = LocalizationService.isRTL(currentLocale);

    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GetMaterialApp(
            navigatorKey: navigatorKey,
            title: 'Mshwar',
            debugShowCheckedModeBanner: false,
            // Device Preview integration
            //  locale: DevicePreview.locale(context) ?? currentLocale,
            builder: (context, child) {
              // Wrap with Device Preview builder
              //        child = DevicePreview.appBuilder(context, child);
              return Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: EasyLoading.init()(context, child),
              );
            },
            theme: Styles.themeData(
              themeChangeProvider.darkTheme == 0
                  ? true
                  : themeChangeProvider.darkTheme == 1
                  ? false
                  : themeChangeProvider.getSystemThem(),
              context,
            ),
            fallbackLocale: LocalizationService.locale,
            translations: LocalizationService(),
            // Add Material localizations for date picker, time picker, etc.
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'AE'),
              Locale('ur', 'PK'),
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
