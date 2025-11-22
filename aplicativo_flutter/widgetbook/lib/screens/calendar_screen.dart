import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:aplicativo_flutter/screens/calendar_screen.dart';

@widgetbook.UseCase(name: 'Default', type: CalendarScreen)
Widget buildCreateRoutineScreenUseCase(BuildContext context) {
  // Initialize Intl locale data (Widgetbook renders outside normal app
  // initialization) to avoid LocaleDataException when Calendar uses
  // `DateFormat(..., 'pt_BR')`.
  return FutureBuilder<void>(
    future: initializeDateFormatting('pt_BR'),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: SizedBox(width: 36, height: 36, child: CircularProgressIndicator()));
      }

      return const ProviderScope(child: CalendarScreen());
    },
  );
}