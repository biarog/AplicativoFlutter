import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../firebase_options.dart';

import 'package:firebase_storage/firebase_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSigningIn = false;
  String? _errorMessage;
  bool _isSignUpMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      UserCredential userCredential;

      if (_isSignUpMode) {
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final user = userCredential.user;
      if (user != null) {
        await _upsertUserToFirestore(user);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            _errorMessage = 'Incorrect password.';
            break;
          case 'email-already-in-use':
            _errorMessage = 'An account already exists with this email.';
            break;
          case 'weak-password':
            _errorMessage = 'Password is too weak. Use at least 6 characters.';
            break;
          case 'invalid-email':
            _errorMessage = 'Invalid email address.';
            break;
          default:
            _errorMessage = e.message ?? 'Authentication failed.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
      debugPrint('Email/Password auth error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        // Web: Use Firebase popup flow
        final provider = GoogleAuthProvider();
        final userCredential =
            await FirebaseAuth.instance.signInWithPopup(provider);

        final user = userCredential.user;
        if (user != null) {
          await _upsertUserToFirestore(user);
        }
      } else {
        // Mobile/Desktop: Use v7.0+ authenticate() method
        final GoogleSignInAccount account =
            await GoogleSignIn.instance.authenticate(
          scopeHint: ['email'],
        );

        // In v7.0+, authentication is now synchronous (no await)
        final auth = account.authentication;

        if (auth.idToken == null) {
          throw Exception('No idToken returned by Google sign-in.');
        }
        String? accessToken;
        try {
          accessToken =
              (auth as dynamic).accessToken ?? (auth as dynamic).access_token;
        } catch (_) {
          // ignore
        }

        final credential = GoogleAuthProvider.credential(
          idToken: auth.idToken,
          accessToken: accessToken,
        );

        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final user = userCredential.user;
        if (user != null) {
          await _upsertUserToFirestore(user);
        }
      }
    } on GoogleSignInException catch (e) {
      setState(() {
        _errorMessage =
            _googleSignInExceptionToMessage(e) ?? 'Google sign-in failed.';
      });
      debugPrint(
          'Google Sign In error: code: ${e.code.name}, description: ${e.description}');
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'popup-closed-by-user' || e.code == 'cancelled') {
          _errorMessage = null;
        } else {
          _errorMessage = e.message ?? 'Google sign-in failed.';
        }
      });
    } catch (e, st) {
      setState(() {
        _errorMessage = 'Google sign-in error. Please try again.';
      });
      debugPrint('Google sign-in error: $e\n$st');
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

  }
}