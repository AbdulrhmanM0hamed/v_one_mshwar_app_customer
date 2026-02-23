import 'package:v_one_mshwar_app_customer/common/widget/custom_text.dart';
import 'package:v_one_mshwar_app_customer/common/widget/light_bordered_card.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PriceSummaryCard extends StatelessWidget {
  final double tripPrice;
  final bool isDarkMode;
  final double? discountAmount;
  final double? originalPrice;
  final bool? isPackageSelected;

  const PriceSummaryCard({
    super.key,
    required this.tripPrice,
    required this.isDarkMode,
    this.discountAmount,
    this.originalPrice,
    this.isPackageSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Show discount if there's a discount amount > 0 OR if package is selected (package provides discount)
    final hasDiscount =
        (discountAmount != null && discountAmount! > 0) ||
        (isPackageSelected == true &&
            originalPrice != null &&
            originalPrice! > tripPrice);
    final finalPrice = tripPrice;
    final original = originalPrice ?? tripPrice;
    final showOriginalPrice =
        originalPrice != null && originalPrice! > finalPrice;
    // Calculate discount amount to show (use provided discountAmount, or calculate from original - final if package selected)
    final displayDiscountAmount = discountAmount != null && discountAmount! > 0
        ? discountAmount!
        : (isPackageSelected == true &&
                  originalPrice != null &&
                  originalPrice! > tripPrice
              ? originalPrice! - tripPrice
              : 0.0);

    return LightBorderedCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.wallet_3, size: 20, color: AppThemeData.primary200),
              const SizedBox(width: 8),
              CustomText(
                text: "Price Summary".tr,
                size: 16,
                weight: FontWeight.w700,
                color: isDarkMode
                    ? AppThemeData.grey900Dark
                    : AppThemeData.grey900,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: "Total Amount".tr,
                      size: 13,
                      weight: FontWeight.w500,
                      color: isDarkMode
                          ? AppThemeData.grey500Dark
                          : AppThemeData.grey500,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (showOriginalPrice) ...[
                          CustomText(
                            text: Constant().amountShow(
                              amount: original.toStringAsFixed(2),
                            ),
                            size: 18,
                            weight: FontWeight.w500,
                            color: isDarkMode
                                ? AppThemeData.grey400Dark
                                : AppThemeData.grey400,
                            decoration: TextDecoration.lineThrough,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: CustomText(
                            text: Constant().amountShow(
                              amount: finalPrice.toStringAsFixed(2),
                            ),
                            size: 28,
                            weight: FontWeight.w800,
                            color: AppThemeData.primary200,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeData.success300.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppThemeData.success300.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.ticket_discount,
                            size: 14,
                            color: AppThemeData.success300,
                          ),
                          const SizedBox(width: 4),
                          CustomText(
                            text: "Discount".tr,
                            size: 11,
                            weight: FontWeight.w500,
                            color: AppThemeData.success300,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        text: Constant().amountShow(
                          amount: displayDiscountAmount.toStringAsFixed(2),
                        ),
                        size: 14,
                        weight: FontWeight.w700,
                        color: AppThemeData.success300,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
