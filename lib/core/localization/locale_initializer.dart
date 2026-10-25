import 'dart:ui' show Locale;

import '../constants/app_constants.dart';
import '../constants/app_setting.dart';

Future<Locale> determineInitialLocale() async {
  final bool alreadyInitialized =
      prefs.getBool(AppConstants.isLocaleInitialized) ?? false;

  if (alreadyInitialized) {
    final int code =
        prefs.getInt(AppConstants.selectedLanguageCode) ?? AppLanguages.codeFa;
    return AppLanguages.localeFromCode(code);
  }

  // زبان پیش‌فرض اولیه فارسی است؛ کاربر می‌تواند از طریق سوئیچ زبان آن را تغییر دهد
  const Locale decidedLocale = AppLanguages.fa;
  await _persistLocaleDecision(decidedLocale);
  return decidedLocale;
}

Future<void> _persistLocaleDecision(Locale locale) async {
  final int code = (locale.languageCode == AppLanguages.fa.languageCode)
      ? AppLanguages.codeFa
      : AppLanguages.codeEn;

  await prefs.setBool(AppConstants.isLocaleInitialized, true);
  await prefs.setInt(AppConstants.selectedLanguageCode, code);
}

/// هر زمان کاربر به صورت دستی زبان را تغییر دهد فراخوانی می‌شود.
Future<void> persistUserSelectedLocale(Locale locale) async {
  await _persistLocaleDecision(locale);
}
