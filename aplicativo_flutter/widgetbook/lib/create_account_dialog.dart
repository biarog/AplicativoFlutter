import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:aplicativo_flutter/widgets/create_account_dialog.dart';

@widgetbook.UseCase(name: 'Default', type: CreateAccountDialog)
Widget buildCreateAccountDialogUseCase(BuildContext context) {
  return CreateAccountDialog();
}