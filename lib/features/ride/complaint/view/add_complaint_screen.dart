import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/ride/complaint/controller/add_complaint_controller.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/themes/button_them.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AddComplaintScreen extends StatelessWidget {
  AddComplaintScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetX<AddComplaintController>(
      init: AddComplaintController(),
      builder: (controller) {
        final themeChange = Provider.of<DarkThemeProvider>(context);
        final isDarkMode = themeChange.getThem();
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          appBar: CustomAppBar(
            title: 'Complaint'.tr,
            showBackButton: true,
            onBackPressed: () => Get.back(),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Header Card
                  LightBorderedCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(20),
                    backgroundColor: AppThemeData.primary200.withValues(
                      alpha: 0.1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppThemeData.primary200.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                size: 28,
                                color: AppThemeData.primary200,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: 'How is your trip?'.tr,
                                    size: 18,
                                    weight: FontWeight.w600,
                                    color: isDarkMode
                                        ? AppThemeData.grey900Dark
                                        : AppThemeData.grey900,
                                  ),
                                  const SizedBox(height: 4),
                                  CustomText(
                                    text:
                                        'Your complaint will help us improve driving experience better'
                                            .tr,
                                    size: 13,
                                    color: isDarkMode
                                        ? AppThemeData.grey400Dark
                                        : AppThemeData.grey500,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomText(
                          text: 'Complaint for '.tr,
                          size: 13,
                          color: isDarkMode
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text:
                              "${controller.rideData.value.prenomConducteur.toString()} ${controller.rideData.value.nomConducteur.toString()}",
                          size: 15,
                          weight: FontWeight.w600,
                          color: isDarkMode
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                        ),
                        if (controller.complaintStatus.value.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CustomText(
                                text: 'Status: '.tr,
                                size: 13,
                                color: isDarkMode
                                    ? AppThemeData.grey400Dark
                                    : AppThemeData.grey500,
                              ),
                              CustomText(
                                text: controller.complaintStatus.value,
                                size: 13,
                                weight: FontWeight.w600,
                                color: isDarkMode
                                    ? AppThemeData.grey900Dark
                                    : AppThemeData.grey900,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Form Card
                  LightBorderedCard(
                    margin: EdgeInsets.zero,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFieldThem.boxBuildTextField(
                            conext: context,
                            hintText: 'Type title....'.tr,
                            controller: controller.complaintTitleController,
                            textInputType: TextInputType.text,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'Title is required'.tr;
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFieldThem.boxBuildTextField(
                            conext: context,
                            hintText: 'Type description....'.tr,
                            controller:
                                controller.complaintDiscriptionController,
                            textInputType: TextInputType.multiline,
                            maxLine: 5,
                            contentPadding: EdgeInsets.zero,
                            validators: (String? value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'Description is required'.tr;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Submit Button
                  ButtonThem.buildButton(
                    context,
                    title: "Submit Complaint".tr,
                    onPress: () async {
                      if (_formKey.currentState!.validate()) {
                        Map<String, String> bodyParams = {
                          'id_user_app': controller.rideData.value.idUserApp
                              .toString(),
                          'id_conducteur': controller
                              .rideData
                              .value
                              .idConducteur
                              .toString(),
                          'user_type': 'customer',
                          'description': controller
                              .complaintDiscriptionController
                              .text
                              .toString(),
                          'title': controller.complaintTitleController.text
                              .toString(),
                          'order_id': controller.rideData.value.id.toString(),
                        };

                        await controller.addComplaint(bodyParams).then((value) {
                          if (value != null) {
                            if (value == true) {
                              ShowToastDialog.showToast(
                                "Complaint added successfully!".tr,
                              );
                              Get.back();
                            } else {
                              ShowToastDialog.showToast(
                                "Something went wrong".tr,
                              );
                            }
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
