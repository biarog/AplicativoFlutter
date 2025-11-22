import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:aplicativo_flutter/main.dart';

@widgetbook.UseCase(name: 'Default', type: MainApp)
Widget buildMainAppUseCase(BuildContext context) {
  // Do not create a new ProviderScope here — Widgetbook already wraps the
  // app in a ProviderScope (and may provide overrides). Creating a nested
  // ProviderScope would isolate `MainApp` from those overrides and prevent
  // theme/provider updates from propagating. Return `MainApp` directly so
  // it uses the outer ProviderScope.
  return const MainApp();
}