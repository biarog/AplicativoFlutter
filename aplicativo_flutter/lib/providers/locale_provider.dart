import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    // Return null to use system locale by default
    return null;
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
