import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_dto.dart';
import '../providers/auth_provider.dart';

/// Use with `showDialog<AuthDto?>(context: context, builder: (_) => CreateAccountDialog())`.
class CreateAccountDialog extends ConsumerStatefulWidget {
  /// Optional dialog width in logical pixels. If null, a responsive
  /// width based on screen size will be used.
  final double? width;

  /// Optional maximum width for the dialog. Defaults to 600 if null.
  final double? maxWidth;

  const CreateAccountDialog({super.key, this.width, this.maxWidth});

  @override
  ConsumerState<CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends ConsumerState<CreateAccountDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _confirmFieldKey = GlobalKey<FormFieldState<String>>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmFocusNode = FocusNode();

  bool _submitted = false;

  bool _isSigningIn = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }


  // Sign in with email and password
  // Returns AuthDto on success or null on failure.
  Future<AuthDto?> _signInWithEmailPassword() async {
    bool valid = false;
    try {
      valid = _formKey.currentState?.validate() ?? false;
    } catch (e, st) {
      debugPrint('[CreateAccountDialog] validator threw: $e\n$st');
      setState(() => _errorMessage = 'Validation error. Please check your input.');
      return null;
    }

    if (!valid) {
      // focus first invalid field and show a summary
      final emailErr = _emailFieldKey.currentState?.errorText;
      final passErr = _passwordFieldKey.currentState?.errorText;
      final confirmErr = _confirmFieldKey.currentState?.errorText;

      if (emailErr != null) {
        try {
          FocusScope.of(context).requestFocus(_emailFocusNode);
        } catch (_) {}
      } else if (passErr != null) {
        try {
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        } catch (_) {}
      } else if (confirmErr != null) {
        try {
          FocusScope.of(context).requestFocus(_confirmFocusNode);
        } catch (_) {}
      }

      setState(() {
        _errorMessage = emailErr ?? passErr ?? confirmErr ?? 'Please fix the errors above.';
      });
      return null;
    }

    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Always create a new user in this dialog via the AuthRepository
      final auth = await ref.read(authRepositoryProvider).createUserWithEmail(email: email, password: password);
      return auth;
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
      return null;
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
      debugPrint('Email/Password auth error: $e');
      return null;
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  // Sign in with Google
  // Returns AuthDto on success or null on failure.
  Future<AuthDto?> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final auth = await ref.read(authRepositoryProvider).signInWithGoogle();
      return auth;
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'popup-closed-by-user' || e.code == 'cancelled') {
          _errorMessage = null;
        } else {
          _errorMessage = e.message ?? 'Google sign-in failed.';
        }
      });
      return null;
    } catch (e, st) {
      setState(() {
        _errorMessage = 'Google sign-in error. Please try again.';
      });
      debugPrint('Google sign-in error: $e\n$st');
      return null;
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }
  
  // AuthRepository handles Google sign-in exceptions and Firestore upsert.
  
  @override
  Widget build(BuildContext context) {
    // Determine width: use explicit widget.width if provided,
    // otherwise use 85% of screen width as a sensible default.
    final double computedWidth = widget.width ?? MediaQuery.of(context).size.width * 0.85;
    final double computedMaxWidth = widget.maxWidth ?? 600;

    return AlertDialog(
      title: const Text('Create Account'),
      // Wrap content with constraints so caller can control dialog size.
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: computedMaxWidth),
        child: SizedBox(
          width: computedWidth,
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            TextFormField(
              key: _emailFieldKey,
              focusNode: _emailFocusNode,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: _passwordFieldKey,
              focusNode: _passwordFocusNode,
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: _confirmFieldKey,
              focusNode: _confirmFocusNode,
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            // Show auth/validation summary
            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            OutlinedButton.icon(
              onPressed: _isSigningIn
                  ? null
                  : () async {
                      // Capture Navigator before awaiting so we don't use the
                      // BuildContext across an async gap.
                      final navigator = Navigator.of(context);
                      final auth = await _signInWithGoogle();
                      if (!mounted) return;
                      if (auth != null) navigator.pop(auth);
                    },
              icon: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                height: 20,
                width: 20,
              ),
              label: Text(
                'Continue with Google', 
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ), // Column
      ), // Form
        ), // SizedBox
      ), // ConstrainedBox
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSigningIn
                  ? null
                  : () async {
                      setState(() {
                        _submitted = true;
                        _errorMessage = null;
                      });
                      // Capture navigator before the async call below.
                      final navigator = Navigator.of(context);
                      final auth = await _signInWithEmailPassword();
                      if (!mounted) return;
                      if (auth != null) navigator.pop(auth);
                    },
              child: _isSigningIn
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary),
                      ),
                    )
                  : const Text('Create Account'),
            ),
          ],
        )
      ],
    );
  }
}
