import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/main.directories.g.dart';
import 'package:aplicativo_flutter/providers/theme_provider.dart' as theme_provider;
import 'package:aplicativo_flutter/l10n/app_localizations.dart';
// profile stories removed

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:aplicativo_flutter/providers/auth_provider.dart';
import 'package:widgetbook_workspace/mocks/fake_auth_repository.dart';

void main() {
  // Better error visibility: catch uncaught errors and surface them instead
  // of a white screen so we can debug runtime exceptions on web.
  FlutterError.onError = (details) {
    // Print to console (visible in browser DevTools)
    FlutterError.presentError(details);
  };

  runZonedGuarded(() {
    ErrorWidget.builder = (details) {
      return Material(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${details.exception}\n${details.stack}', style: const TextStyle(color: Colors.red)),
          ),
        ),
      );
    };

    runApp(
      ProviderScope(
        overrides: [
          // Provide a fake repository that doesn't call Firebase during stories.
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const WidgetbookApp(),
      ),
    );
  }, (error, stack) {
    // Report zone errors to console as well.
    // ignore: avoid_print
    print('Uncaught zone error: $error');
    // ignore: avoid_print
    print(stack);
  });
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the generated directories directly.

    // Build themes from the app's `kDefaultThemePresets` so Widgetbook
    // exposes the same visual presets (light & dark) as the app.
    final generatedThemes = <WidgetbookTheme<ThemeData>>[];
    for (final preset in theme_provider.kDefaultThemePresets) {
      generatedThemes.add(
        WidgetbookTheme<ThemeData>(
          name: '${preset.name} - Light',
          data: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme(
              primary: preset.lightPrimary,
              secondary: preset.lightSecondary,
              surface: Colors.white,
              error: preset.lightError,
              onPrimary: Colors.white,
              onSecondary: Colors.black,
              onSurface: Colors.black,
              onError: Colors.white,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
        ),
      );

      generatedThemes.add(
        WidgetbookTheme<ThemeData>(
          name: '${preset.name} - Dark',
          data: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme(
              primary: preset.darkPrimary,
              secondary: preset.darkSecondary,
              surface: Colors.grey[900]!,
              error: preset.darkError,
              onPrimary: Colors.white,
              onSecondary: Colors.black,
              onSurface: Colors.white,
              onError: Colors.white,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
        ),
      );
    }

    return Widgetbook.material(
      directories: directories,
      // `appBuilder` wraps the story app after Widgetbook applies the
      // selected theme. We use it to synchronize the currently selected
      // ThemeData into the app's `themeSettingsProvider` so Riverpod-driven
      // widgets react to theme changes made by the Theme addon.
      appBuilder: (context, child) => LocalizationBridge(
        child: SyncThemeBridge(child: child),
      ),
      addons: [
        ViewportAddon([
          Viewports.none,
          ...IosViewports.all,
          ...AndroidViewports.all,
        ]),
        MaterialThemeAddon(themes: generatedThemes),
      ],
    );
  }
}

// Provides localization support to widgets in widgetbook
class LocalizationBridge extends ConsumerStatefulWidget {
  final Widget child;
  const LocalizationBridge({required this.child, super.key});

  @override
  ConsumerState<LocalizationBridge> createState() => _LocalizationBridgeState();
}

class _LocalizationBridgeState extends ConsumerState<LocalizationBridge> {
  Locale _currentLocale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: _currentLocale,
      child: MaterialApp(
        locale: _currentLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Widgetbook'),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  const Text('Language:'),
                  FilterChip(
                    label: const Text('English'),
                    selected: _currentLocale.languageCode == 'en',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _currentLocale = const Locale('en'));
                      }
                    },
                  ),
                  FilterChip(
                    label: const Text('Português'),
                    selected: _currentLocale.languageCode == 'pt',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _currentLocale = const Locale('pt'));
                      }
                    },
                  ),
                  FilterChip(
                    label: const Text('Español'),
                    selected: _currentLocale.languageCode == 'es',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _currentLocale = const Locale('es'));
                      }
                    },
                  ),
                  FilterChip(
                    label: const Text('Français'),
                    selected: _currentLocale.languageCode == 'fr',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _currentLocale = const Locale('fr'));
                      }
                    },
                  ),
                  FilterChip(
                    label: const Text('中文'),
                    selected: _currentLocale.languageCode == 'zh',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _currentLocale = const Locale('zh'));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          body: widget.child,
        ),
      ),
    );
  }
}

class SyncThemeBridge extends ConsumerStatefulWidget {
  final Widget child;
  const SyncThemeBridge({required this.child, super.key});

  @override
  ConsumerState<SyncThemeBridge> createState() => _SyncThemeBridgeState();
}


class _SyncThemeBridgeState extends ConsumerState<SyncThemeBridge> {
  Color? _lastAppliedPrimary;
  bool? _lastAppliedIsDark;

  // Squared Euclidean distance between two RGB colors packed as ints.
  int _colorDistance(int a, int b) {
    final ra = (a >> 16) & 0xFF;
    final ga = (a >> 8) & 0xFF;
    final ba = a & 0xFF;
    final rb = (b >> 16) & 0xFF;
    final gb = (b >> 8) & 0xFF;
    final bb = b & 0xFF;
    final dr = ra - rb;
    final dg = ga - gb;
    final db = ba - bb;
    return dr * dr + dg * dg + db * db;
  }

  void _syncTheme() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Try to find a matching preset by primary color. If an exact match
    // isn't found, pick the closest preset by color distance (RGB).
    String? matchId;
    theme_provider.ThemePreset? matchedPreset;
    int bestDistance = 1 << 30;
    for (final p in theme_provider.kDefaultThemePresets) {
      final dLight = _colorDistance(cs.primary.toARGB32(), p.lightPrimary.toARGB32());
      final dDark = _colorDistance(cs.primary.toARGB32(), p.darkPrimary.toARGB32());
      if (dLight == 0 || dDark == 0) {
        matchId = p.id;
        matchedPreset = p;
        bestDistance = 0;
        break;
      }
      final d = dLight < dDark ? dLight : dDark;
      if (d < bestDistance) {
        bestDistance = d;
        matchId = p.id;
        matchedPreset = p;
      }
    }

    // If even the closest match is very far away, ignore it (avoid false
    // positives). Threshold tuned conservatively — RGB squared distance.
    const int kMaxDistanceThreshold = 40 * 40 * 3; // ~40 per channel
    if (bestDistance > kMaxDistanceThreshold) {
      matchId = null;
      matchedPreset = null;
    }

    // Quick check: if we've already applied this primary + dark-mode, do nothing.
    final desiredPrimary = cs.primary;
    if (_lastAppliedPrimary == desiredPrimary && _lastAppliedIsDark == isDark) {
      return;
    }

    // Schedule provider updates after this frame to avoid modifying providers
    // during the widget build lifecycle (which causes the runtime error).
    _lastAppliedPrimary = desiredPrimary;
    _lastAppliedIsDark = isDark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(theme_provider.themeSettingsProvider.notifier);
      if (matchId != null && matchedPreset != null) {
        notifier.applyPresetById(matchId);
        notifier.setDark(isDark);
      } else {
        // Fall back to only toggling dark mode; keep existing colors.
        notifier.setDark(isDark);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTheme();
  }

  @override
  Widget build(BuildContext context) {
    // Also attempt sync on every build (cheap equality check prevents churn).
    _syncTheme();
    return widget.child;
  }
}
