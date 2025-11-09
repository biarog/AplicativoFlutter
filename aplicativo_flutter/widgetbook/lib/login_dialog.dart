import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:aplicativo_flutter/widgets/login_dialog.dart';

@widgetbook.UseCase(name: 'Default', type: LoginDialog)
Widget buildLoginDialogUseCase(BuildContext context) {
  return LoginDialog();
}