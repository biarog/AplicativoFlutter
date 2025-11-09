import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        ViewportAddon([
          Viewports.none,
          ...IosViewports.all,
          ...AndroidViewports.all,
        ]),
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: ThemeData(
                brightness: Brightness.light,
                colorScheme: ColorScheme(
                  primary: Colors.orange,
                  secondary: const Color.fromARGB(255, 250, 189, 110),
                  surface: Colors.white,
                  error: Colors.red,
                  onPrimary: Colors.white,
                  onSecondary: Colors.black,
                  onSurface: Colors.black,
                  onError: Colors.white,
                  brightness: Brightness.light
                ),
                useMaterial3: true,
              ),
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme(
                  primary: Colors.deepOrange,
                  secondary: const Color.fromARGB(255, 94, 55, 43),
                  surface: Colors.grey[900]!,
                  error: Colors.red,
                  onPrimary: Colors.white,
                  onSecondary: Colors.black,
                  onSurface: Colors.white,
                  onError: Colors.white,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
            ),
          ]
        )
      ],
    );
  }
}