import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettings {
  final Color lightPrimary;
  final Color lightSecondary;
  final Color lightError;
  final Color darkPrimary;
  final Color darkSecondary;
  final Color darkError;
  final bool isDark;

  ThemeSettings({
    required this.lightPrimary,
    required this.lightSecondary,
    required this.lightError,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.darkError,
    this.isDark = false,
  });

  ThemeSettings copyWith({
    Color? lightPrimary,
    Color? lightSecondary,
    Color? lightError,
    Color? darkPrimary,
    Color? darkSecondary,
    Color? darkError,
    bool? isDark,
  }) {
    return ThemeSettings(
      lightPrimary: lightPrimary ?? this.lightPrimary,
      lightSecondary: lightSecondary ?? this.lightSecondary,
      lightError: lightError ?? this.lightError,
      darkPrimary: darkPrimary ?? this.darkPrimary,
      darkSecondary: darkSecondary ?? this.darkSecondary,
      darkError: darkError ?? this.darkError,
      isDark: isDark ?? this.isDark,
    );
  }

  // convenience: current primary depending on mode
  Color get primaryColor => isDark ? darkPrimary : lightPrimary;
}

// Add ThemePreset and default presets
class ThemePreset {
  final String id;
  final String name;
  final Color lightPrimary;
  final Color lightSecondary;
  final Color lightError;
  final Color darkPrimary;
  final Color darkSecondary;
  final Color darkError;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.lightPrimary,
    required this.lightSecondary,
    required this.lightError,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.darkError,
  });
}

const List<ThemePreset> kDefaultThemePresets = [
  ThemePreset(
    id: 'orange',
    name: 'Orange',
    lightPrimary: Colors.orange,
    lightSecondary: Color(0xFFFADB6E),
    lightError: Colors.red,
    darkPrimary: Colors.deepOrange,
    darkSecondary: Color(0xFF5E372B),
    darkError: Colors.red,
  ),
  ThemePreset(
    id: 'blue',
    name: 'Blue',
    lightPrimary: Color.fromARGB(255, 0, 162, 255),
    lightSecondary: Color.fromARGB(255, 100, 204, 252),
    lightError: Colors.red,
    darkPrimary: Color.fromARGB(255, 43, 100, 255),
    darkSecondary: Color.fromARGB(255, 36, 58, 118),
    darkError: Colors.red,
  ),
  ThemePreset(
    id: 'green',
    name: 'Green',
    lightPrimary: Color.fromARGB(255, 4, 206, 14),
    lightSecondary: Color.fromARGB(255, 112, 228, 116),
    lightError: Colors.red,
    darkPrimary: Color.fromARGB(255, 28, 145, 48),
    darkSecondary: Color.fromARGB(255, 28, 82, 30),
    darkError: Colors.red,
  ),
];

class ThemeSettingsNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    final platformIsDark = ui.PlatformDispatcher.instance.platformBrightness == Brightness.dark;

    return ThemeSettings(
      lightPrimary: Colors.orange,
      lightSecondary:  Color(0xFFFADB6E),
      lightError: Colors.red,
      darkPrimary: Colors.deepOrange,
      darkSecondary:  Color(0xFF5E372B),
      darkError: Colors.red,
      isDark: platformIsDark,
    );
  }
  
  void setDark(bool v) => state = state.copyWith(isDark: v);

  // Presets helpers
  List<ThemePreset> get presets => List.unmodifiable(kDefaultThemePresets);

  void applyPresetById(String id) {
    final preset = kDefaultThemePresets.firstWhere((p) => p.id == id, orElse: () => kDefaultThemePresets.first);
    state = state.copyWith(
      lightPrimary: preset.lightPrimary,
      lightSecondary: preset.lightSecondary,
      lightError: preset.lightError,
      darkPrimary: preset.darkPrimary,
      darkSecondary: preset.darkSecondary,
      darkError: preset.darkError,
    );
  }
}

final themeSettingsProvider = NotifierProvider<ThemeSettingsNotifier, ThemeSettings>(ThemeSettingsNotifier.new);