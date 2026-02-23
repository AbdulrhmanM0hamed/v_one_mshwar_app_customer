// ignore_for_file: prefer_const_constructors

import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/features/plans/coupon/controller/coupon_code_controller.dart';
import 'package:v_one_mshwar_app_customer/features/payment/payment/model/CoupanCodeModel.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CouponCodeScreen extends StatelessWidget {
  const CouponCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return GetX<CouponCodeController>(
      init: CouponCodeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          body: RefreshIndicator(
            onRefresh: () => controller.getCoupanCodeData(),
            child: controller.isLoading.value
                ? SizedBox()
                : controller.coupanCodeList.isEmpty
                ? Center(
                    child: Constant.emptyView(
                      context,
                      "No coupons available",
                      false,
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.coupanCodeList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return buildPromoCodeItem(
                        context,
                        controller.coupanCodeList[index],
                        isDarkMode,
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget buildPromoCodeItem(
    BuildContext context,
    CoupanCodeData data,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeData.grey800 : AppThemeData.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppThemeData.primary200,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/icons/promocode.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.discription.toString(),
                      style: TextStyle(
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            FlutterClipboard.copy(data.code.toString()).then((
                              value,
                            ) {
                              final SnackBar snackBar = SnackBar(
                                content: Text(
                                  "Coupon Code Copied".tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.black38,
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(snackBar);
                              // return Navigator.pop(context);
                            });
                          },
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.05),
                            child: DottedBorder(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                child: Text(data.code.toString()),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Valid till".tr + data.expireAt.toString(),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
