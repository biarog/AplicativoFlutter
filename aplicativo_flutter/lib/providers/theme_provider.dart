import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings {
  final Color lightPrimary;
  final Color lightSecondary;
  final Color lightTerciary;
  final Color lightError;
  final Color darkPrimary;
  final Color darkSecondary;
  final Color darkTerciary;
  final Color darkError;
  final bool isDark;
  final String presetId;

  ThemeSettings({
    required this.lightPrimary,
    required this.lightSecondary,
    required this.lightTerciary,
    required this.lightError,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.darkTerciary,
    required this.darkError,
    this.isDark = false,
    this.presetId = 'orange',
  });

  ThemeSettings copyWith({
    Color? lightPrimary,
    Color? lightSecondary,
    Color? lightTerciary,
    Color? lightError,
    Color? darkPrimary,
    Color? darkSecondary,
    Color? darkTerciary,
    Color? darkError,
    bool? isDark,
    String? presetId,
  }) {
    return ThemeSettings(
      lightPrimary: lightPrimary ?? this.lightPrimary,
      lightSecondary: lightSecondary ?? this.lightSecondary,
      lightTerciary: lightTerciary ?? this.lightTerciary,
      lightError: lightError ?? this.lightError,
      darkPrimary: darkPrimary ?? this.darkPrimary,
      darkSecondary: darkSecondary ?? this.darkSecondary,
      darkTerciary: darkTerciary ?? this.darkTerciary,
      darkError: darkError ?? this.darkError,
      isDark: isDark ?? this.isDark,
      presetId: presetId ?? this.presetId,
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
  final Color lightTerciary;
  final Color lightError;
  final Color darkPrimary;
  final Color darkSecondary;
  final Color darkTerciary;
  final Color darkError;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.lightPrimary,
    required this.lightSecondary,
    required this.lightTerciary,
    required this.lightError,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.darkTerciary,
    required this.darkError,
  });
}

const List<ThemePreset> kDefaultThemePresets = [
  ThemePreset(
    id: 'red',
    name: 'Red',
    lightPrimary: Color.fromARGB(255, 255, 59, 59),
    lightSecondary: Color.fromARGB(255, 228, 112, 112),
    lightTerciary: Color.fromARGB(255, 100, 50, 50),
    lightError: Color.fromARGB(255, 0, 217, 255),
    darkPrimary: Color.fromARGB(255, 145, 28, 28),
    darkSecondary: Color.fromARGB(255, 82, 28, 28),
    darkTerciary: Color.fromARGB(255, 255, 200, 200),
    darkError: Color.fromARGB(255, 0, 217, 255),
  ),
  ThemePreset(
    id: 'orange',
    name: 'Orange',
    lightPrimary: Colors.orange,
    lightSecondary: Color.fromARGB(255, 250, 219, 110),
    lightTerciary: Color.fromARGB(255, 130, 51, 28),
    lightError: Colors.red,
    darkPrimary: Colors.deepOrange,
    darkSecondary: Color.fromARGB(255, 94, 55, 43),
    darkTerciary: Color.fromARGB(255, 248, 190, 125),
    darkError: Colors.red,
  ),
  ThemePreset(
    id: 'green',
    name: 'Green',
    lightPrimary: Color.fromARGB(255, 4, 206, 14),
    lightSecondary: Color.fromARGB(255, 112, 228, 116),
    lightTerciary: Color.fromARGB(255, 35, 77, 35),
    lightError: Colors.red,
    darkPrimary: Color.fromARGB(255, 28, 145, 48),
    darkSecondary: Color.fromARGB(255, 28, 82, 30),
    darkTerciary: Color.fromARGB(255, 144, 240, 144),
    darkError: Colors.red,
  ),
  ThemePreset(
    id: 'blue',
    name: 'Blue',
    lightPrimary: Color.fromARGB(255, 0, 162, 255),
    lightSecondary: Color.fromARGB(255, 100, 204, 252),
    lightTerciary: Color.fromARGB(255, 29, 42, 81),
    lightError: Colors.red,
    darkPrimary: Color.fromARGB(255, 43, 100, 255),
    darkSecondary: Color.fromARGB(255, 36, 58, 118),
    darkTerciary: Color.fromARGB(255, 200, 230, 255),
    darkError: Colors.red,
  ),
  ThemePreset(
    id: 'purple',
    name: 'Purple',
    lightPrimary: Color.fromARGB(255, 140, 61, 210),
    lightSecondary: Color.fromARGB(255, 178, 128, 240),
    lightTerciary: Color.fromARGB(255, 73, 31, 116),
    lightError: Colors.red,
    darkPrimary: Color.fromARGB(255, 75, 0, 130),
    darkSecondary: Color.fromARGB(255, 49, 18, 98),
    darkTerciary: Color.fromARGB(255, 166, 110, 219),
    darkError: Colors.red,
  ),
  ThemePreset(
    id: 'pink',
    name: 'Pink',
    lightPrimary: Color.fromARGB(255, 243, 117, 238),
    lightSecondary: Color.fromARGB(255, 253, 182, 255),
    lightTerciary: Color.fromARGB(255, 119, 33, 127),
    lightError: Colors.red,
    darkPrimary: Color.fromARGB(255, 216, 26, 216),
    darkSecondary: Color.fromARGB(255, 132, 25, 121),
    darkTerciary: Color.fromARGB(255, 231, 130, 215),
    darkError: Colors.red,
  ),
  
];

class ThemeSettingsNotifier extends Notifier<ThemeSettings> {
  static const _prefsKeyIsDark = 'theme_is_dark';
  static const _prefsKeyPreset = 'theme_preset_id';

  bool _didLoad = false;

  @override
  ThemeSettings build() {
    final platformIsDark = ui.PlatformDispatcher.instance.platformBrightness == Brightness.dark;

    _loadFromPrefs();

    return ThemeSettings(
      lightPrimary: Colors.orange,
      lightSecondary: Color.fromARGB(255, 250, 219, 110),
      lightTerciary: Color.fromARGB(255, 130, 51, 28),
      lightError: Colors.red,
      darkPrimary: Colors.deepOrange,
      darkSecondary: Color.fromARGB(255, 94, 55, 43),
      darkTerciary: Color.fromARGB(255, 248, 190, 125),
      darkError: Colors.red,
      isDark: platformIsDark,
      presetId: 'orange',
    );
  }

  Future<void> _loadFromPrefs() async {
    if (_didLoad) return;
    _didLoad = true;

    final prefs = await SharedPreferences.getInstance();
    final storedPreset = prefs.getString(_prefsKeyPreset);
    final storedIsDark = prefs.getBool(_prefsKeyIsDark);

    if (storedPreset != null) {
      _applyPreset(storedPreset);
    }

    if (storedIsDark != null) {
      state = state.copyWith(isDark: storedIsDark);
    }
  }

  Future<void> _persist({String? presetId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyIsDark, state.isDark);
    await prefs.setString(_prefsKeyPreset, presetId ?? state.presetId);
  }

  Future<void> setDark(bool v) async {
    state = state.copyWith(isDark: v);
    await _persist();
  }

  // Presets helpers
  List<ThemePreset> get presets => List.unmodifiable(kDefaultThemePresets);

  Future<void> applyPresetById(String id) async {
    final preset = kDefaultThemePresets.firstWhere((p) => p.id == id, orElse: () => kDefaultThemePresets.first);
    _applyPreset(preset.id);
    await _persist(presetId: preset.id);
  }

  void _applyPreset(String presetId) {
    final preset = kDefaultThemePresets.firstWhere((p) => p.id == presetId, orElse: () => kDefaultThemePresets.first);
    state = state.copyWith(
      lightPrimary: preset.lightPrimary,
      lightSecondary: preset.lightSecondary,
      lightTerciary: preset.lightTerciary,
      lightError: preset.lightError,
      darkPrimary: preset.darkPrimary,
      darkSecondary: preset.darkSecondary,
      darkTerciary: preset.darkTerciary,
      darkError: preset.darkError,
      presetId: preset.id,
    );
  }
}

final themeSettingsProvider = NotifierProvider<ThemeSettingsNotifier, ThemeSettings>(ThemeSettingsNotifier.new);