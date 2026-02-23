import 'package:v_one_mshwar_app_customer/core/data/repo/fcm_token_repo.dart';
import 'package:v_one_mshwar_app_customer/core/navigation/app_navigator.dart';
import 'package:v_one_mshwar_app_customer/core/notifications/notification_service.dart';
import 'package:v_one_mshwar_app_customer/features/splash/splash_screen.dart';
import 'package:v_one_mshwar_app_customer/service/localization_service.dart';
import 'package:v_one_mshwar_app_customer/core/themes/styles.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late Locale _currentLocale = LocalizationService.getCurrentLocale();
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCurrentAppTheme();
    _loadLocale();

    // Setup notification service with navigator and token repo
    _notificationService = NotificationService(
      navigator: AppNavigator(navigatorKey),
      tokenRepo: FcmTokenRepoImpl(),
    );
    _notificationService.setup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadLocale() async {
    final locale = LocalizationService.getCurrentLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider
        .darkThemePreference
        .getTheme();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = LocalizationService.isRTL(_currentLocale);

    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Mshwar',
            debugShowCheckedModeBanner: false,
            locale: _currentLocale,
            builder: (context, child) {
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
