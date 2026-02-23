import 'package:v_one_mshwar_app_customer/core/lang/app_ar.dart';
import 'package:v_one_mshwar_app_customer/core/lang/app_en.dart';
import 'package:v_one_mshwar_app_customer/core/lang/app_ur.dart';
import 'package:v_one_mshwar_app_customer/core/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('en', 'US');

  static final locales = [
    const Locale('en', 'US'),
    const Locale('ar', 'AE'),
    const Locale('ur', 'PK'),
  ];

  // Get current locale from preferences or return default
  static Locale getCurrentLocale() {
    final langCode = Preferences.getString(Preferences.languageCodeKey);
    if (langCode.isEmpty) {
      return locale;
    }

    // Handle specific locale codes
    if (langCode == 'ar') {
      return const Locale('ar', 'AE');
    } else if (langCode == 'ur') {
      return const Locale('ur', 'PK');
    } else if (langCode == 'en') {
      return const Locale('en', 'US');
    }

    // Try to find matching locale
    for (var loc in locales) {
      if (loc.languageCode == langCode) {
        return loc;
      }
    }

    return locale;
  }

  // Check if locale is RTL
  static bool isRTL(Locale? locale) {
    if (locale == null) return false;
    return locale.languageCode == 'ar' || locale.languageCode == 'ur';
  }

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
    'en': enUS,
    'ar': arAE,
    'ur': urPK,
  };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    Locale newLocale;
    if (lang == 'ar') {
      newLocale = const Locale('ar', 'AE');
    } else if (lang == 'ur') {
      newLocale = const Locale('ur', 'PK');
    } else if (lang == 'en') {
      newLocale = const Locale('en', 'US');
    } else {
      newLocale = Locale(lang);
    }
    Get.updateLocale(newLocale);
  }
}
