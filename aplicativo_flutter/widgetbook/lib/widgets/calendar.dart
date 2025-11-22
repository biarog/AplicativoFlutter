import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:aplicativo_flutter/widgets/calendar.dart';

@widgetbook.UseCase(name: 'Default', type: CalendarWidget)
Widget buildCreateRoutineScreenUseCase(BuildContext context) {
  // The calendar widget uses `DateFormat(..., 'pt_BR')`. When Widgetbook
  // renders widgets outside the normal app lifecycle the Intl locale data
  // may not be initialized. Initialize the locale data first and show a
  // small loader until ready.
  return FutureBuilder<void>(
    future: initializeDateFormatting('pt_BR'),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: SizedBox(width: 36, height: 36, child: CircularProgressIndicator()));
      }

      // Now it's safe to render the calendar.
      return ProviderScope(child: CalendarWidget());
    },
  );
}