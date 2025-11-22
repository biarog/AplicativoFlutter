import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aplicativo_flutter/providers/theme_provider.dart' as theme_provider;

/// Collapsible overlay that displays the current `themeSettingsProvider` values.
class ThemeIndicator extends ConsumerStatefulWidget {
  const ThemeIndicator({super.key});

  @override
  ConsumerState<ThemeIndicator> createState() => _ThemeIndicatorState();
}

class _ThemeIndicatorState extends ConsumerState<ThemeIndicator> {
  bool _collapsed = false;

  void _toggle() => setState(() => _collapsed = !_collapsed);

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(theme_provider.themeSettingsProvider);

    if (_collapsed) {
      return GestureDetector(
        onTap: _toggle,
        child: Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _colorBox(settings.primaryColor),
              const SizedBox(width: 6),
              const Icon(Icons.expand_less, size: 18),
            ]),
          ),
        ),
      );
    }

    return Card(
      elevation: 6,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _colorBox(settings.primaryColor),
            const SizedBox(width: 8),
            _tinyColumn('Light', settings.lightPrimary, settings.lightSecondary),
            const SizedBox(width: 8),
            _tinyColumn('Dark', settings.darkPrimary, settings.darkSecondary),
            const SizedBox(width: 8),
            Text(settings.isDark ? 'Dark' : 'Light', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            InkWell(onTap: _toggle, child: const Icon(Icons.close, size: 18)),
          ],
        ),
      ),
    );
  }

  Widget _colorBox(Color c) => Container(width: 18, height: 18, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black12)));

  Widget _tinyColumn(String label, Color primary, Color secondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Row(children: [
          Container(width: 12, height: 12, color: primary),
          const SizedBox(width: 4),
          Container(width: 12, height: 12, color: secondary),
        ])
      ],
    );
  }
}
