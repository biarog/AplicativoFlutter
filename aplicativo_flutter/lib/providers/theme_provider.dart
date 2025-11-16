import 'package:flutter/material.dart';
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
    lightPrimary: Color(0xFF0277BD),
    lightSecondary: Color(0xFF81D4FA),
    lightError: Colors.red,
    darkPrimary: Color(0xFF01579B),
    darkSecondary: Color(0xFF0288D1),
    darkError: Colors.red,
  ),
  ThemePreset(
    id: 'green',
    name: 'Green',
    lightPrimary: Color(0xFF2E7D32),
    lightSecondary: Color(0xFFA5D6A7),
    lightError: Colors.red,
    darkPrimary: Color(0xFF1B5E20),
    darkSecondary: Color(0xFF2E7D32),
    darkError: Colors.red,
  ),
];

class ThemeSettingsNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    return ThemeSettings(
      lightPrimary: Colors.orange,
      lightSecondary:  Color(0xFFFADB6E),
      lightError: Colors.red,
      darkPrimary: Colors.deepOrange,
      darkSecondary:  Color(0xFF5E372B),
      darkError: Colors.red,
      isDark: false,
    );
  }

  // Light setters
  void setLightPrimary(Color c) => state = state.copyWith(lightPrimary: c);
  void setLightSecondary(Color c) => state = state.copyWith(lightSecondary: c);
  void setLightError(Color c) => state = state.copyWith(lightError: c);

  // Dark setters
  void setDarkPrimary(Color c) => state = state.copyWith(darkPrimary: c);
  void setDarkSecondary(Color c) => state = state.copyWith(darkSecondary: c);
  void setDarkError(Color c) => state = state.copyWith(darkError: c);

  // Combined helpers
  void setBothPrimary(Color c) => state = state.copyWith(lightPrimary: c, darkPrimary: c);

  // convenience: set primary for current mode
  void setPrimaryColor(Color c) {
    if (state.isDark) {
      setDarkPrimary(c);
    } else {
      setLightPrimary(c);
    }
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