// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/create_account_dialog.dart'
    as _widgetbook_workspace_create_account_dialog;
import 'package:widgetbook_workspace/login_dialog.dart'
    as _widgetbook_workspace_login_dialog;
import 'package:widgetbook_workspace/main_app.dart'
    as _widgetbook_workspace_main_app;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookLeafComponent(
    name: 'MainApp',
    useCase: _widgetbook.WidgetbookUseCase(
      name: 'Default',
      builder: _widgetbook_workspace_main_app.buildMainAppUseCase,
    ),
  ),
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookLeafComponent(
        name: 'CreateAccountDialog',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_create_account_dialog
              .buildCreateAccountDialogUseCase,
        ),
      ),
      _widgetbook.WidgetbookLeafComponent(
        name: 'LoginDialog',
        useCase: _widgetbook.WidgetbookUseCase(
          name: 'Default',
          builder: _widgetbook_workspace_login_dialog.buildLoginDialogUseCase,
        ),
      ),
    ],
  ),
];
