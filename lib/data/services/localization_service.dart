import 'package:flutter/material.dart';
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
  ];

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
      default: return const Locale('en', 'US');
    }
  }

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'app_name': 'BMI Calculator',
          'splash_tagline': 'Know Your Body. Live Healthier',
          'loading': 'Loading...',
          'skip': 'Skip',
          'next': 'Next',
          'calculate': 'Calculate',
          'calculate_bmi': 'Calculate BMI',
          'reset': 'Reset',
          'recalculate': 'Recalculate',
          'your_bmi': 'Your BMI',
          'underweight': 'Underweight',
          'normal': 'Normal',
          'overweight': 'Overweight',
          'obese': 'Obese',
          'weight': 'Weight',
          'height': 'Height',
          'age': 'Age',
          'gender': 'Gender',
          'male': 'Male',
          'female': 'Female',
          'other': 'Other',
          'languages': 'Languages',
          'select_lang_subtitle': 'Select your preferred language to continue.',
          'done': 'Done',
          'save_language': 'Save Language',
          'unlock_premium': 'Unlock Premium',
          'start_free_trial': 'Start Free Trial',
          'monthly_plan': 'Monthly Plan',
          'yearly_plan': 'Yearly Plan',
          'history': 'History',
          'weight_tracking': 'Weight Tracking',
          'health_insights': 'Health Insights',
          'profile': 'Profile',
        },
        'es_ES': {
          'app_name': 'Calculadora de IMC',
          'splash_tagline': 'Conoce tu cuerpo. Vive más saludable',
          'loading': 'Cargando...',
          'skip': 'Saltar',
          'next': 'Siguiente',
          'calculate': 'Calcular',
          'calculate_bmi': 'Calcular IMC',
          'reset': 'Restablecer',
          'recalculate': 'Recalcular',
          'your_bmi': 'Tu IMC',
          'underweight': 'Bajo peso',
          'normal': 'Normal',
          'overweight': 'Sobrepeso',
          'obese': 'Obesidad',
          'weight': 'Peso',
          'height': 'Altura',
          'age': 'Edad',
          'gender': 'Género',
          'male': 'Hombre',
          'female': 'Mujer',
          'other': 'Otro',
          'languages': 'Idiomas',
          'select_lang_subtitle': 'Selecciona tu idioma preferido para continuar.',
          'done': 'Listo',
          'save_language': 'Guardar idioma',
          'unlock_premium': 'Desbloquear Premium',
          'start_free_trial': 'Comenzar prueba gratis',
          'monthly_plan': 'Plan Mensual',
          'yearly_plan': 'Plan Anual',
          'history': 'Historial',
          'weight_tracking': 'Seguimiento de peso',
          'health_insights': 'Consejos de salud',
          'profile': 'Perfil',
        },
      };
}
