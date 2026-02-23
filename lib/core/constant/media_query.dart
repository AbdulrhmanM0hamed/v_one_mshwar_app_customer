import 'package:flutter/material.dart';

extension MediaQueryExtension on BuildContext {
  double getWidth(double percentage) {
    return MediaQuery.of(this).size.width * percentage;
  }

  double getHeight(double percentage) {
    return MediaQuery.of(this).size.height * percentage;
  }
}
