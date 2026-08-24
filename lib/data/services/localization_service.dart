import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LanguageModel {
  final String code;
  final String englishName;
  final String nativeName;
  final String flag;

  const LanguageModel({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.flag,
  });
}

class LocalizationService extends Translations {
  static const fallbackLocale = Locale('en', 'US');

  static final List<LanguageModel> supportedLanguages = [
    const LanguageModel(code: 'en', englishName: 'English', nativeName: 'English', flag: '🇺🇸'),
    const LanguageModel(code: 'es', englishName: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    const LanguageModel(code: 'pt', englishName: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    const LanguageModel(code: 'fr', englishName: 'French', nativeName: 'Français', flag: '🇫🇷'),
    const LanguageModel(code: 'de', englishName: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    const LanguageModel(code: 'it', englishName: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    const LanguageModel(code: 'nl', englishName: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱'),
    const LanguageModel(code: 'sv', englishName: 'Swedish', nativeName: 'Svenska', flag: '🇸🇪'),
    const LanguageModel(code: 'ja', englishName: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    const LanguageModel(code: 'ko', englishName: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    const LanguageModel(code: 'zh', englishName: 'Chinese (Simplified)', nativeName: '简体中文', flag: '🇨🇳'),
    const LanguageModel(code: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    const LanguageModel(code: 'ar', englishName: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    const LanguageModel(code: 'ur', englishName: 'Urdu', nativeName: 'اردو', flag: '🇵🇰'),
    const LanguageModel(code: 'tr', englishName: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
    const LanguageModel(code: 'ru', englishName: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
  ];

  static final Map<String, Map<String, String>> _keys = {};

  /// Loads JSON translation files asynchronously from assets/locales/
  static Future<void> init() async {
    for (final language in supportedLanguages) {
      try {
        final jsonString = await rootBundle.loadString('assets/locales/${language.code}.json');
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        final Map<String, String> stringMap = jsonMap.map((key, value) => MapEntry(key, value.toString()));

        final locale = getLocaleFromLanguage(language.code);
        final localeKey = '${locale.languageCode}_${locale.countryCode}';

        _keys[localeKey] = stringMap;
        _keys[language.code] = stringMap;
      } catch (e) {
        debugPrint('Error loading locale ${language.code}: $e');
      }
    }
  }

  static Locale getLocaleFromLanguage(String langCode) {
    switch (langCode) {
      case 'es': return const Locale('es', 'ES');
      case 'pt': return const Locale('pt', 'PT');
      case 'fr': return const Locale('fr', 'FR');
      case 'de': return const Locale('de', 'DE');
      case 'it': return const Locale('it', 'IT');
      case 'nl': return const Locale('nl', 'NL');
      case 'sv': return const Locale('sv', 'SE');
      case 'ja': return const Locale('ja', 'JP');
      case 'ko': return const Locale('ko', 'KR');
      case 'zh': return const Locale('zh', 'CN');
      case 'hi': return const Locale('hi', 'IN');
      case 'ar': return const Locale('ar', 'SA');
      case 'ur': return const Locale('ur', 'PK');
      case 'tr': return const Locale('tr', 'TR');
      case 'ru': return const Locale('ru', 'RU');
      default: return const Locale('en', 'US');
    }
  }

  static LanguageModel getLanguageModel(String code) {
    return supportedLanguages.firstWhere(
      (element) => element.code == code,
      orElse: () => supportedLanguages.first,
    );
  }

  @override
  Map<String, Map<String, String>> get keys => _keys;
}
