import 'package:flutter/material.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';

class RouteWrapperWidget extends StatelessWidget {
  final Widget child;

  const RouteWrapperWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Constant.homeScreenType == 'OlaHome') {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      );
    } else {
      return child;
    }
  }
}
