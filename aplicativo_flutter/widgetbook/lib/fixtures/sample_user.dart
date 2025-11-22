import 'package:aplicativo_flutter/models/auth_dto.dart';

/// A small sample user used for Widgetbook stories and fixtures.
final sampleAuthDto = AuthDto(
  uid: 'user_1',
  email: 'jane@example.com',
  displayName: 'Jane Doe',
  photoUrl: null,
  routines: [
    {
      'id': 'sample_1',
      'name': 'Sample Routine',
      'exercises': [
        {'type': 'timed', 'name': 'Jumping Jacks', 'seconds': 30},
        {'type': 'counting', 'name': 'Push Ups', 'sets': 3, 'reps': 10},
      ],
    }
  ],
);
