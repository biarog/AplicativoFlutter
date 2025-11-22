This folder contains light-weight helpers and fixtures intended for use
inside Widgetbook stories.

How to use
- Pass `sampleAuthDto` directly to widgets that accept a user model.


Examples

1) Supplying the model directly to a widget constructor

```dart
import 'package:aplicativo_flutter/models/auth_dto.dart';
import 'package:widgetbook/widgetbook.dart';
import 'fixtures/sample_user.dart';

WidgetbookUseCase(
  name: 'Profile / Logged In',
  builder: (context) => ProfileCard(user: sampleAuthDto),
)
```

(Interactive examples removed — use `ProviderScope` overrides or pass fixtures directly.)

Notes
- If you want true Riverpod provider overrides (for example to replace
  `authRepositoryProvider` or `authStateChangesProvider`), create a small
  fake class that implements the same public methods and use
  `ProviderScope(overrides: [authRepositoryProvider.overrideWithValue(...)])`.
  This repository includes Riverpod providers in `lib/providers/` — match
  their signatures when implementing overrides.
