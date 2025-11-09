import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:aplicativo_flutter/main.dart';

@widgetbook.UseCase(name: 'Default', type: MainApp)
Widget buildMainAppUseCase(BuildContext context) {
  return MainApp();
}