import 'package:v_one_mshwar_app_customer/common/widget/my_custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PendingPaymentDialog {
  static void show(BuildContext context) {
    MyCustomDialog.show(
      context: context,
      title: "Cab me".tr,
      message: 'pending_payment_message'.tr,
      confirmText: "OK".tr,
      showCancel: false,
    );
  }
}
