import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    // Default to English if system locale cannot be determined
    return const Locale('en');
  }

  void setLocale(Locale? locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

// Helper to get supported locales
const supportedLocales = [
  Locale('en'),
  Locale('pt'),
  Locale('es'),
  Locale('fr'),
  Locale('zh'),
];

final localeNames = {
  'en': 'English',
  'pt': 'Português',
  'es': 'Español',
  'fr': 'Français',
  'zh': '中文',
};
