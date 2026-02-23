import 'package:v_one_mshwar_app_customer/core/app_initializer.dart';
import 'package:v_one_mshwar_app_customer/my_app.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  // Initialize all app dependencies
  await AppInitializer.initializeApp();

  // Run app with Device Preview in debug mode only
  runApp(
    // DevicePreview(
    // enabled: !kReleaseMode, // Enable only in debug mode
    /*   builder: (context) => const */ MyApp(),
    //    ),
  );
}
