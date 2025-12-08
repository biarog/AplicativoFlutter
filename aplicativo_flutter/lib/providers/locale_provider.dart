import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends AsyncNotifier<Locale?> {
  static const String _storageKey = 'selected_locale';

  @override
  Future<Locale?> build() async {
    return _loadLocaleFromStorage();
  }

  /// Carrega o idioma salvo do armazenamento local
  Future<Locale?> _loadLocaleFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_storageKey);
      
      if (savedLocale != null && savedLocale.isNotEmpty) {
        return Locale(savedLocale);
      }
    } catch (e) {
      // Silently fail and use default
    }
    
    // Default to English if nothing saved
    return const Locale('en');
  }

  /// Define o idioma e salva no armazenamento local
  Future<void> setLocale(Locale? locale) async {
    if (locale == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, locale.languageCode);
      state = AsyncValue.data(locale);
    } catch (e) {
      // Silently fail but still update state
      state = AsyncValue.data(locale);
    }
  }
}

final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

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
