import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/ride/review/controller/add_review_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/review/view/review_sucess_screen.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/themes/button_them.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/themes/text_field_them.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AddReviewScreen extends StatelessWidget {
  const AddReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();
    return GetX<AddReviewController>(
      init: AddReviewController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          appBar: CustomAppBar(
            title: 'Review'.tr,
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
                                Icons.star_outline,
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
                                        'Your feedback helps us improve and provide a better experience. Rate your driver and leave a comment!'
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
                        const SizedBox(height: 16),
                        Center(
                          child: RatingBar.builder(
                            itemSize: 32,
                            initialRating: controller.rating.value,
                            minRating: 0,
                            unratedColor: isDarkMode
                                ? AppThemeData.grey300Dark
                                : AppThemeData.grey400,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                            ),
                            itemBuilder: (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {
                              controller.rating(rating);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Comment Card
                  LightBorderedCard(
                    margin: EdgeInsets.zero,
                    child: TextFieldThem.boxBuildTextField(
                      conext: context,
                      hintText: 'Leave a comment'.tr,
                      controller: controller.reviewCommentController.value,
                      textInputType: TextInputType.multiline,
                      maxLine: 5,
                      contentPadding: EdgeInsets.zero,
                      validators: (String? value) {
                        if (value!.isNotEmpty) {
                          return null;
                        } else {
                          return 'Comment is required'.tr;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Submit Button
                  ButtonThem.buildButton(
                    context,
                    title: "Submit Review".tr,
                    onPress: () async {
                      if (controller.rating.value == 0 ||
                          controller.rating.value == 0.0) {
                        ShowToastDialog.showToast("Please add star rating".tr);
                      } else if (controller
                          .reviewCommentController
                          .value
                          .text
                          .isEmpty) {
                        ShowToastDialog.showToast(
                          "Please enter the comments".tr,
                        );
                      } else {
                        Map<String, String> bodyParams = {
                          'ride_id': controller.rideData.value.id.toString(),
                          'id_user_app': controller.rideData.value.idUserApp
                              .toString(),
                          'id_conducteur': controller
                              .rideData
                              .value
                              .idConducteur
                              .toString(),
                          'note_value': controller.rating.value.toString(),
                          'comment':
                              controller.reviewCommentController.value.text,
                          'ride_type': controller.rideType.value.toString(),
                        };

                        await controller.addReview(bodyParams).then((value) {
                          if (value != null) {
                            if (value == true) {
                              Get.off(const ReviewSuccessScreen());
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
