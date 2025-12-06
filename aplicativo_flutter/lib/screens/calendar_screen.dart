import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/calendar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.agenda)),
      body: const CalendarWidget(),
    );
  }
}
