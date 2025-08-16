// lib/services/language_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

  // Supported languages with their display names
  static const Map<String, Locale> supportedLanguages = {
    'English': Locale('en'),
    'हिंदी': Locale('hi'),
    'اردو': Locale('ur'),
    'বাংলা': Locale('bn'),
  };

  // Initialize the service and load saved language
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      
      // Validate that the language code is supported
      final supportedCodes = supportedLanguages.values.map((e) => e.languageCode).toList();
      if (supportedCodes.contains(languageCode)) {
        localeNotifier.value = Locale(languageCode);
      } else {
        // Fallback to English if invalid language code
        localeNotifier.value = const Locale('en');
      }
    } catch (e) {
      // If there's an error, default to English
      debugPrint('Error initializing LanguageService: $e');
      localeNotifier.value = const Locale('en');
    }
  }

  // Change the app language
  static Future<void> changeLanguage(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      localeNotifier.value = locale;
      debugPrint('Language changed to: ${locale.languageCode}');
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  // Get the display name for a locale
  static String getLanguageName(Locale locale) {
    return supportedLanguages.entries
        .firstWhere(
          (entry) => entry.value.languageCode == locale.languageCode,
          orElse: () => const MapEntry('English', Locale('en')),
        )
        .key;
  }

  // Get current language code
  static String get currentLanguageCode => localeNotifier.value.languageCode;

  // Get current locale
  static Locale get currentLocale => localeNotifier.value;

  // Check if current language is RTL
  static bool get isRTL => currentLanguageCode == 'ur';

  // Get text direction based on current language
  static TextDirection get textDirection => 
    isRTL ? TextDirection.rtl : TextDirection.ltr;

  // Get all supported language codes
  static List<String> get supportedLanguageCodes => 
    supportedLanguages.values.map((e) => e.languageCode).toList();

  // Get all supported locales
  static List<Locale> get supportedLocales => 
    supportedLanguages.values.toList();

  // Reset to default language (English)
  static Future<void> resetToDefault() async {
    await changeLanguage(const Locale('en'));
  }

  // Clear stored language preference
  static Future<void> clearLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);
      localeNotifier.value = const Locale('en');
    } catch (e) {
      debugPrint('Error clearing language preference: $e');
    }
  }
}