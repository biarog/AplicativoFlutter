import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aplicativo_flutter/widgets/account_settings_dialog.dart';

@widgetbook.UseCase(name: 'Default', type: AccountSettingsDialog)
Widget buildAccountSettingsDialogUseCase(BuildContext context) {
  // Widgetbook builds widgets outside the normal app tree. Wrap with
  // ProviderScope so Riverpod providers used by the dialog are available.
  return const ProviderScope(child: AccountSettingsDialog());
}