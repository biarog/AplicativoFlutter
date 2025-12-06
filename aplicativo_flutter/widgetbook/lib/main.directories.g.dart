// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering
// ignore_for_file: deprecated_member_use

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/dialogs/account_settings_dialog.dart'
    as _widgetbook_workspace_dialogs_account_settings_dialog;
import 'package:widgetbook_workspace/dialogs/create_account_dialog.dart'
    as _widgetbook_workspace_dialogs_create_account_dialog;
import 'package:widgetbook_workspace/dialogs/login_dialog.dart'
    as _widgetbook_workspace_dialogs_login_dialog;
import 'package:widgetbook_workspace/main_app.dart'
    as _widgetbook_workspace_main_app;
import 'package:widgetbook_workspace/screens/calendar_screen.dart'
    as _widgetbook_workspace_screens_calendar_screen;
import 'package:widgetbook_workspace/screens/create_routine_screen.dart'
    as _widgetbook_workspace_screens_create_routine_screen;
import 'package:widgetbook_workspace/screens/routine_player_screen.dart'
    as _widgetbook_workspace_screens_routine_player_screen;
import 'package:widgetbook_workspace/widgets/calendar.dart'
    as _widgetbook_workspace_widgets_calendar;
import 'package:widgetbook_workspace/widgets/youtube_player.dart'
    as _widgetbook_workspace_widgets_youtube_player;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookLeafComponent(
    name: 'MainApp',
    useCase: _widgetbook.WidgetbookUseCase(
      name: 'Default',
      builder: _widgetbook_workspace_main_app.buildMainAppUseCase,
    ),
  ),
  _widgetbook.WidgetbookFolder(
    name: 'screens',
    children: [
      _widgetbook.WidgetbookLeafComponent(
        name: 'CalendarScreen',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_screens_calendar_screen
              .buildCreateRoutineScreenUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'CreateRoutineScreen',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_screens_create_routine_screen
              .buildCreateRoutineScreenUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'RoutinePlayerScreen',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_screens_routine_player_screen
              .buildCreateRoutineScreenUseCase,
        ),
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookLeafComponent(
        name: 'AccountSettingsDialog',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_dialogs_account_settings_dialog
              .buildAccountSettingsDialogUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'CalendarWidget',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_widgets_calendar
              .buildCreateRoutineScreenUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'CreateAccountDialog',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_dialogs_create_account_dialog
              .buildCreateAccountDialogUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'LoginDialog',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_dialogs_login_dialog
              .buildLoginDialogUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'YouTubePlayerWidget',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_widgets_youtube_player
              .buildCreateRoutineScreenUseCase,
        ),
      ),
    ],
  ),
];
