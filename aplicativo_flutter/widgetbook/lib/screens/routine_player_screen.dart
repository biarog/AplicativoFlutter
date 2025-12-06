import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aplicativo_flutter/screens/routine_player_screen.dart';

import 'package:widgetbook_workspace/mocks/mock_routine.dart';


@widgetbook.UseCase(name: 'Default', type: RoutinePlayerScreen)
Widget buildCreateRoutineScreenUseCase(BuildContext context) {
  // Widgetbook builds widgets outside the normal app tree. Wrap with
  // ProviderScope so Riverpod providers used by the dialog are available.
  return ProviderScope(child: RoutinePlayerScreen(routine: sampleRoutine),);
}