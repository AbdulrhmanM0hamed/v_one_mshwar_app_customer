import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/features/ride/ride/controller/search_address_controller.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final controller = Get.put(SearchAddressController());
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = controller.searchTxtController.value;
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    controller.searchText.value = text;
    controller.debouncer(() => controller.fetchAddress(text));
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppThemeData.surface50Dark
          : AppThemeData.surface50,
      appBar: AppBar(
        backgroundColor: AppThemeData.primary200,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        title: TextField(
          controller: _textController,
          focusNode: _focusNode,
          autofocus: true,
          cursorColor: Colors.white,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Search Adress'.tr,
            hintStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            isDense: true,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final isEmpty = controller.searchText.value.isEmpty;
          final hasRecentSearches = controller.recentSearches.isNotEmpty;

          // Show empty state centered when no text and no recent searches
          if (isEmpty && !hasRecentSearches) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 64,
                      color: isDarkMode
                          ? AppThemeData.grey400Dark
                          : AppThemeData.grey400,
                    ),
                    const SizedBox(height: 16),
                    CustomText(
                      text: 'No Recent Searches'.tr,
                      size: 16,
                      weight: FontWeight.w600,
                      color: isDarkMode
                          ? AppThemeData.grey900Dark
                          : AppThemeData.grey900,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start typing to search for locations'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? AppThemeData.grey500Dark
                            : AppThemeData.grey500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Show scrollable content for recent searches or search results
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Recent Searches Section
                if (isEmpty && hasRecentSearches)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LightBorderedCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Iconsax.clock,
                                      size: 20,
                                      color: AppThemeData.primary200,
                                    ),
                                    const SizedBox(width: 8),
                                    CustomText(
                                      text: 'Recent Searches'.tr,
                                      size: 16,
                                      weight: FontWeight.w600,
                                      color: isDarkMode
                                          ? AppThemeData.grey900Dark
                                          : AppThemeData.grey900,
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () =>
                                      controller.clearRecentSearches(),
                                  child: CustomText(
                                    text: 'Clear'.tr,
                                    size: 14,
                                    color: AppThemeData.primary200,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.recentSearches.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    controller.saveRecentSearch(
                                      controller.recentSearches[index],
                                    );
                                    Get.back(
                                      result: controller.recentSearches[index],
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Iconsax.clock,
                                          size: 18,
                                          color: isDarkMode
                                              ? AppThemeData.grey500Dark
                                              : AppThemeData.grey500,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: CustomText(
                                            text: controller
                                                .recentSearches[index]
                                                .address,
                                            size: 14,
                                            color: isDarkMode
                                                ? AppThemeData.grey900Dark
                                                : AppThemeData.grey900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                // Search Results Section
                Obx(() {
                  final hasText = controller.searchText.value.isNotEmpty;

                  if (!hasText) {
                    return const SizedBox();
                  }

                  if (controller.isSearch.value) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: AppThemeData.primary200,
                            ),
                            const SizedBox(height: 16),
                            CustomText(
                              text: 'location Searching....'.tr,
                              size: 14,
                              color: isDarkMode
                                  ? AppThemeData.grey400Dark
                                  : AppThemeData.grey500,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.suggestionsList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: CustomText(
                          text: 'Not Found Location'.tr,
                          size: 14,
                          color: isDarkMode
                              ? AppThemeData.grey400Dark
                              : AppThemeData.grey500,
                        ),
                      ),
                    );
                  }

                  return LightBorderedCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.location,
                              size: 20,
                              color: AppThemeData.primary200,
                            ),
                            const SizedBox(width: 8),
                            CustomText(
                              text: 'Suggested location'.tr,
                              size: 16,
                              weight: FontWeight.w600,
                              color: isDarkMode
                                  ? AppThemeData.grey900Dark
                                  : AppThemeData.grey900,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.suggestionsList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                final selectedSuggestion =
                                    controller.suggestionsList[index];
                                controller.saveRecentSearch(selectedSuggestion);
                                Get.back(result: selectedSuggestion);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.location,
                                      size: 18,
                                      color: isDarkMode
                                          ? AppThemeData.grey500Dark
                                          : AppThemeData.grey500,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustomText(
                                        text: controller
                                            .suggestionsList[index]
                                            .address,
                                        size: 14,
                                        color: isDarkMode
                                            ? AppThemeData.grey900Dark
                                            : AppThemeData.grey900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }
}
