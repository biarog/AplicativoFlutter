import 'dart:async';

import 'package:aplicativo_flutter/models/auth_dto.dart';
import 'package:aplicativo_flutter/providers/auth_provider.dart';
import '../fixtures/sample_user.dart';

/// A very small fake implementation of `AuthRepository` for Widgetbook.
///
/// It extends the real `AuthRepository` only to satisfy the provider type,
/// but overrides methods to avoid any network or Firebase calls.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  @override
  Future<AuthDto?> signInWithEmail({required String email, required String password}) async {
    // Return the sample user for any credentials.
    await Future.delayed(const Duration(milliseconds: 50));
    return sampleAuthDto;
  }

  @override
  Future<AuthDto?> createUserWithEmail({required String email, required String password, String? displayName}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return sampleAuthDto;
  }

  @override
  Future<AuthDto?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return sampleAuthDto;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    // No-op for Widgetbook stories; in stories you can supply a different
    // fixture if you want to show the updated name.
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
