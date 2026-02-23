import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomSheetHeader extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final bool isDarkMode;

  const BottomSheetHeader({
    super.key,
    this.title,
    this.onBack,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 8,
            width: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: isDarkMode
                  ? AppThemeData.grey300Dark
                  : AppThemeData.grey300,
            ),
          ),
        ),
        if (onBack != null || title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Row(
              children: [
                if (onBack != null)
                  IconButton(
                    onPressed: onBack,
                    icon: Transform(
                      alignment: Alignment.center,
                      transform: Directionality.of(context) == TextDirection.rtl
                          ? Matrix4.rotationY(3.14159)
                          : Matrix4.identity(),
                      child: SvgPicture.asset(
                        'assets/icons/ic_left.svg',
                        colorFilter: ColorFilter.mode(
                          isDarkMode
                              ? AppThemeData.grey900Dark
                              : AppThemeData.grey900,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: AppThemeData.bold,
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
