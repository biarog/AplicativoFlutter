import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aplicativo_flutter/main.dart';

@widgetbook.UseCase(name: 'Default', type: MainApp)
Widget buildMainAppUseCase(BuildContext context) {
  // Wrap the main app use-case in ProviderScope so Riverpod is available
  // when previewing the widget in Widgetbook.
  return const ProviderScope(child: MainApp());
}