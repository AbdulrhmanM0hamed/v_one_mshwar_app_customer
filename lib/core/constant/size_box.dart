import 'package:flutter/material.dart';

extension SizedBoxExtension on BuildContext {
  Widget sizedBoxHeight(double percentage) {
    return SizedBox(height: MediaQuery.of(this).size.height * percentage);
  }

  Widget sizedBoxWidth(double percentage) {
    return SizedBox(width: MediaQuery.of(this).size.width * percentage);
  }
}
