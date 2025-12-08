import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aplicativo_flutter/screens/edit_routine_screen.dart';

import 'package:widgetbook_workspace/mocks/mock_routine.dart';

@widgetbook.UseCase(name: 'Default', type: EditRoutineScreen)
Widget buildEditRoutineScreenUseCase(BuildContext context) {
  // Widgetbook builds widgets outside the normal app tree. Wrap with
  // ProviderScope so Riverpod providers used by the dialog are available.
  return ProviderScope(child: EditRoutineScreen(routine: sampleRoutine));
}