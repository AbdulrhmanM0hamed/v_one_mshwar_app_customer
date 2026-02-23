import 'package:v_one_mshwar_app_customer/core/app_initializer.dart';
import 'package:v_one_mshwar_app_customer/my_app.dart';
import 'package:flutter/material.dart';

void main() async {
  // Initialize all app dependencies
  await AppInitializer.initializeApp();

  runApp(const MyApp());
}
