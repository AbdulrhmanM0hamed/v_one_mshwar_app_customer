import 'dart:ui' as ui;
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomText extends StatelessWidget {
  final String text;
  // Text widget properties
  final TextAlign? align;
  final TextDirection? direction;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final bool? strutStyle;

  // TextStyle properties
  final bool? inherit;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final FontWeight? weight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextBaseline? textBaseline;
  final double? height;
  final Paint? foreground;
  final Paint? background;
  final List<Shadow>? shadows;
  final List<FontFeature>? fontFeatures;
  final List<FontVariation>? fontVariations;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;

  final String? package;
  final bool? debugLabel;
  final ui.TextLeadingDistribution? leadingDistribution;
  final TextOverflow? textOverflow;

  /// If true, uses primary color instead of default text color
  final bool isPrimary;

  /// If true, uses secondary/muted color
  final bool isSecondary;

  /// If true, uses error color
  final bool isError;

  /// If true, uses success color
  final bool isSuccess;

  const CustomText({
    super.key,
    required this.text,
    this.align,
    this.direction,
    this.locale,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.strutStyle,

    // TextStyle properties
    this.inherit,
    this.color,
    this.backgroundColor,
    this.size,
    this.weight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.height,
    this.foreground,
    this.background,
    this.shadows,
    this.fontFeatures,
    this.fontVariations,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.package,
    this.debugLabel,
    this.leadingDistribution,
    this.textOverflow,
    this.isPrimary = false,
    this.isSecondary = false,
    this.isError = false,
    this.isSuccess = false,
  });

  /// Get the appropriate text color based on theme and color flags
  Color _getTextColor(BuildContext context, bool isDarkMode) {
    // If explicit color is provided, use it
    if (color != null) return color!;

    // Check for semantic color flags
    if (isPrimary) return AppThemeData.primary200;
    if (isError) return AppThemeData.error200;
    if (isSuccess) return AppThemeData.success200;
    if (isSecondary) {
      return isDarkMode ? AppThemeData.grey400Dark : AppThemeData.grey400;
    }

    // Default text color based on theme
    return isDarkMode ? AppThemeData.grey900Dark : AppThemeData.grey900;
  }

  @override
  Widget build(BuildContext context) {
    // Get theme state
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: true);
    final isDarkMode = themeChange.getThem();

    final textColor = _getTextColor(context, isDarkMode);

    // Determine if current locale is RTL (Arabic or Urdu)
    final currentLocale = Localizations.localeOf(context);
    final isRTL =
        currentLocale.languageCode == 'ar' ||
        currentLocale.languageCode == 'ur';

    // Use Cairo font for all languages - it supports Arabic, Urdu, and English
    final fontFamily = 'Cairo';

    return Text(
      text,
      textAlign: align,
      textDirection:
          direction ?? (isRTL ? TextDirection.rtl : TextDirection.ltr),
      locale: locale ?? currentLocale,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
      style: TextStyle(
        inherit: inherit ?? true,
        color: textColor,
        backgroundColor: backgroundColor,
        fontSize: size ?? 18,
        fontWeight: weight ?? FontWeight.normal,
        fontStyle: fontStyle ?? FontStyle.normal,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        leadingDistribution: leadingDistribution,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        fontVariations: fontVariations,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        fontFamily: fontFamily,
        package: package,
        overflow: textOverflow,
      ),
    );
  }
}
