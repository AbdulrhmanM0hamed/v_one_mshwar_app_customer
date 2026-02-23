import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/features/settings/contact_us/controller/contact_us_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final ContactUsController controller = Get.put(ContactUsController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> bodyParams = {
        'title': _titleController.text.trim(),
        'user_message': _messageController.text.trim(),
        'user_id': Constant.getUserData().data!.id.toString(),
        'user_cat': controller.userCat.isEmpty
            ? 'user_app'
            : controller.userCat,
      };

      final response = await controller.contactUsSend(bodyParams);
      if (response != null && response['success'] == 'success') {
        Get.back();
        Get.snackbar(
          'Success'.tr,
          'Your message has been sent successfully!'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppThemeData.success300,
          colorText: Colors.white,
        );
        _titleController.clear();
        _messageController.clear();
      } else {
        Get.snackbar(
          'Error'.tr,
          response?['error'] ?? 'Failed to send message. Please try again.'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppThemeData.error200,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      appBar: CustomAppBar(
        title: 'Contact Us'.tr,
        showBackButton: true,
        onBackPressed: () => Get.back(),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'Contact Us Phone',
        onPressed: () {
          if (Constant.contactUsPhone != null &&
              Constant.contactUsPhone!.isNotEmpty) {
            String url = 'tel:${Constant.contactUsPhone}';
            launchUrl(Uri.parse(url));
          } else {
            Get.snackbar(
              'Error'.tr,
              'Phone number not available'.tr,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        backgroundColor: AppThemeData.primary200,
        child: const Icon(CupertinoIcons.phone_solid, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Information Card
            LightBorderedCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Our Address'.tr,
                    size: 20,
                    weight: FontWeight.bold,
                    color: isDarkMode
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                  ),
                  const SizedBox(height: 12),
                  if (Constant.contactUsAddress != null &&
                      Constant.contactUsAddress!.isNotEmpty)
                    CustomText(
                      text: Constant.contactUsAddress!.replaceAll(r'\n', '\n'),
                      size: 14,
                      color: isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    )
                  else
                    CustomText(
                      text: 'Address not available'.tr,
                      size: 14,
                      color: isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                  const SizedBox(height: 24),
                  CustomText(
                    text: 'Email Us'.tr,
                    size: 20,
                    weight: FontWeight.bold,
                    color: isDarkMode
                        ? AppThemeData.grey900Dark
                        : AppThemeData.grey900,
                  ),
                  const SizedBox(height: 8),
                  if (Constant.contactUsEmail != null &&
                      Constant.contactUsEmail!.isNotEmpty)
                    InkWell(
                      onTap: () {
                        String url = 'mailto:${Constant.contactUsEmail}';
                        launchUrl(Uri.parse(url));
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomText(
                              text: Constant.contactUsEmail.toString(),
                              size: 14,
                              color: AppThemeData.primary200,
                            ),
                          ),
                          Icon(
                            Iconsax.arrow_right_3,
                            size: 20,
                            color: AppThemeData.primary200,
                          ),
                        ],
                      ),
                    )
                  else
                    CustomText(
                      text: 'Email not available'.tr,
                      size: 14,
                      color: isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Send Message Form
            LightBorderedCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Send us a Message'.tr,
                      size: 20,
                      weight: FontWeight.bold,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Subject'.tr,
                        hintText: 'Enter message subject'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? AppThemeData.grey100Dark
                            : AppThemeData.grey100,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subject'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Message'.tr,
                        hintText: 'Enter your message here...'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? AppThemeData.grey100Dark
                            : AppThemeData.grey100,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a message'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeData.primary200,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: CustomText(
                          text: 'Send Message'.tr,
                          size: 16,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
