import 'package:v_one_mshwar_app_customer/common/widget/my_custom_dialog.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class LocationPermissionDisclosureDialog extends StatelessWidget {
  const LocationPermissionDisclosureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MyCustomDialog(
      title: 'Location Access Disclosure'.tr,
      message:
          'We need access to your location to assign for booking feature.\n\nThis information will only be used for booking purpose and will not be shared with any third parties.'
              .tr,
      confirmText: 'Accept'.tr,
      cancelText: 'Decline'.tr,
      onConfirm: () {
        _requestLocationPermission(context);
      },
      onCancel: () {
        SystemNavigator.pop();
      },
    );
  }

  // Method to request location permission using permission_handler package
  void _requestLocationPermission(BuildContext context) async {
    PermissionStatus location = await Location().requestPermission();
    if (location == PermissionStatus.granted) {
      Get.back();
    } else {
      ShowToastDialog.showToast("Permission Denied".tr);
    }
  }
}
