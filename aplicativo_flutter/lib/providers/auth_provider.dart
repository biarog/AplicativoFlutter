import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_dto.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Future<AuthDto?> signInWithEmail({required String email, required String password}) async {
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = userCredential.user;
    if (user != null) {
      await _upsertUserToFirestore(user);
      return AuthDto(uid: user.uid, email: user.email, displayName: user.displayName, photoUrl: user.photoURL);
    }
    return null;
  }

  Future<AuthDto?> createUserWithEmail({required String email, required String password}) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = userCredential.user;
    if (user != null) {
      await _upsertUserToFirestore(user);
      return AuthDto(uid: user.uid, email: user.email, displayName: user.displayName, photoUrl: user.photoURL);
    }
    return null;
  }

  Future<AuthDto?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(provider);
      final user = userCredential.user;
      if (user != null) {
        await _upsertUserToFirestore(user);
        return AuthDto(uid: user.uid, email: user.email, displayName: user.displayName, photoUrl: user.photoURL);
      }
      return null;
    }

    // Mobile/Desktop: handle multiple google_sign_in versions
    GoogleSignInAccount? account;
    try {
      final gsi = _googleSignIn as dynamic;
      account = await gsi.authenticate(scopeHint: ['email']);
    } on NoSuchMethodError catch (_) {
      final gsi = _googleSignIn as dynamic;
      account = await gsi.signIn();
    }

    if (account == null) return null;

    // account.authentication may be synchronous or return a Future depending
    // on the google_sign_in package version. Use dynamic to safely handle
    // both shapes and only await when it's a Future.
    dynamic auth = (account as dynamic).authentication;
    if (auth is Future) {
      auth = await auth;
    }

  final idToken = (auth as dynamic).idToken ?? (auth as dynamic).id_token;
    if (idToken == null) throw Exception('No idToken returned by Google sign-in.');

    String? accessToken;
    try {
      accessToken = (auth as dynamic).accessToken ?? (auth as dynamic).access_token;
    } catch (_) {}

    final credential = GoogleAuthProvider.credential(idToken: idToken, accessToken: accessToken);
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await _upsertUserToFirestore(user);
      return AuthDto(uid: user.uid, email: user.email, displayName: user.displayName, photoUrl: user.photoURL);
    }
    return null;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _upsertUserToFirestore(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to upsert user: $e');
    }
  }
}
