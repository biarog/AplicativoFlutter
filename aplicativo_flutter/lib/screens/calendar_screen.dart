import 'package:flutter/material.dart';
import '../widgets/calendar.dart';
import '../l10n/app_localizations.dart';

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
