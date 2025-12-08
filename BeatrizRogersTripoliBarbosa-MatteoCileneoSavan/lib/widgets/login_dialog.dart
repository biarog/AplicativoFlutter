import 'package:flutter/material.dart';
// no direct use of flutter/foundation here; material covers needed symbols
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_dto.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

// Deprecated: `LoginResult` removed — dialog now returns `AuthDto` (non-sensitive user info).

/// A reusable login dialog widget.
///
/// Use with `showDialog<AuthDto?>(context: context, builder: (_) => LoginDialog())`.
class LoginDialog extends ConsumerStatefulWidget {
  /// Optional dialog width in logical pixels. If null, a responsive
  /// width based on screen size will be used.
  final double? width;

  /// Optional maximum width for the dialog. Defaults to 600 if null.
  final double? maxWidth;

  const LoginDialog({super.key, this.width, this.maxWidth});

  @override
  ConsumerState<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends ConsumerState<LoginDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isSigningIn = false;
  String? _errorMessage;
  bool _submitted = false;

  late Color forgotPasswordColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize color that depends on the current Theme/BuildContext
    forgotPasswordColor = Theme.of(context).colorScheme.secondary;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }


  // Sign in with email and password
  // Returns the signed-in [AuthDto] on success, or null on failure/cancel.
  Future<AuthDto?> _signInWithEmailPassword() async {
    // Run validators inside try/catch to catch any unexpected errors coming from
    // validator code and avoid unhandled exceptions that can hang the UI.
    bool valid = false;
    try {
      debugPrint('[LoginDialog] validating form...');
  valid = _formKey.currentState?.validate() ?? false;
      debugPrint('[LoginDialog] form valid: $valid');
    } catch (e, st) {
      debugPrint('[LoginDialog] validator threw: $e\n$st');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.validationError;
      });
      return null;
    }

    if (!valid) {
      // Don't proceed if validation failed. Grab field-level error texts and
      // focus the first invalid field so the user sees where to fix input.
      debugPrint('[LoginDialog] validation failed; aborting sign-in.');
      final emailErr = _emailFieldKey.currentState?.errorText;
      final passErr = _passwordFieldKey.currentState?.errorText;

      // Focus the first invalid field
      if (emailErr != null) {
        try {
          FocusScope.of(context).requestFocus(_emailFocusNode);
        } catch (_) {}
      } else if (passErr != null) {
        try {
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        } catch (_) {}
      }

      setState(() {
        // Show a combined message (prefer field messages when available)
        _errorMessage = emailErr ?? passErr ?? AppLocalizations.of(context)!.pleaseFixErrors;
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

      debugPrint('[LoginDialog] starting sign-in for $email');
      final auth = await ref.read(authRepositoryProvider).signInWithEmail(email: email, password: password);
      return auth;
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = AppLocalizations.of(context)!.userNotFound;
            break;
          case 'wrong-password':
            _errorMessage = AppLocalizations.of(context)!.wrongPassword;
            break;
          case 'email-already-in-use':
            _errorMessage = AppLocalizations.of(context)!.emailAlreadyInUse;
            break;
          case 'weak-password':
            _errorMessage = AppLocalizations.of(context)!.weakPassword;
            break;
          case 'invalid-email':
            _errorMessage = AppLocalizations.of(context)!.invalidEmail;
            break;
          default:
            _errorMessage = e.message ?? AppLocalizations.of(context)!.authenticationFailed;
        }
      });
      return null;
    } catch (e, st) {
      setState(() {
        // Surface the actual exception message to help debugging.
        _errorMessage = e.toString();
      });
      debugPrint('Email/Password auth error: $e\n$st');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
  }
  }

  // Sign in with Google
  // Returns the signed-in [AuthDto] on success, or null on failure/cancel.
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
        _errorMessage = e.message ?? AppLocalizations.of(context)!.googleSignInFailed;
      });
      return null;
    } catch (e, st) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.googleSignInError;
      });
      debugPrint('Google sign-in error: $e\n$st');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
  }
  }
  
  

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.pleaseEnterValidEmailForReset);
      return;
    }

    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      // Capture Messenger before the async call to avoid using context after await.
      final messenger = ScaffoldMessenger.of(context);
      // Use AuthRepository for password reset
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email: email);

      if (!mounted) return;
      setState(() => _isSigningIn = false);
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordResetSent(email))),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _errorMessage = e.message ?? e.code;
      });
      debugPrint('sendPasswordResetEmail error: ${e.code} ${e.message}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Determine width: use explicit widget.width if provided,
    // otherwise use 85% of screen width as a sensible default.
    final double computedWidth = widget.width ?? MediaQuery.of(context).size.width * 0.85;
    final double computedMaxWidth = widget.maxWidth ?? 600;

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.login),
      // Wrap content with constraints so caller can control dialog size.
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: computedMaxWidth),
        child: SizedBox(
          width: computedWidth,
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            TextFormField(
            key: _emailFieldKey,
            focusNode: _emailFocusNode,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.email,
              hintText: AppLocalizations.of(context)!.emailHint,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterEmail;
              }
              if (!value.contains('@')) {
                return AppLocalizations.of(context)!.pleaseEnterValidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: _passwordFieldKey,
            focusNode: _passwordFocusNode,
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterPassword;
              }
              if (value.length < 6) {
                return AppLocalizations.of(context)!.passwordMinLength;
              }
              return null;
            },
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: _isSigningIn ? null : _resetPassword,
              child: Text(
                AppLocalizations.of(context)!.forgotPassword,
                style: TextStyle(
                  color: forgotPasswordColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onHover: (value) {
                setState(() {
                  forgotPasswordColor = value
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary;
                });
              },
          ),
          SizedBox(height: 20),
          // Show authentication/validation error messages (if any)
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
                    // Capture Navigator before the async gap so we don't use
                    // the BuildContext after an await.
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
              AppLocalizations.of(context)!.continueWithGoogle, 
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
              style: ButtonStyle(
                side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.primary))
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: _isSigningIn
                    ? null
                    : () async {
                        debugPrint('[LoginDialog] Login button pressed');
                        // Set submitted so validators will display errors, then try sign-in.
                        setState(() {
                          _submitted = true;
                          _errorMessage = null; // clear previous auth errors
                        });

                        // Capture navigator before awaiting the async sign-in.
                        final navigator = Navigator.of(context);
                        final auth = await _signInWithEmailPassword();
                        if (!mounted) return;
                        if (auth != null) navigator.pop(auth);
                      },
              style: ButtonStyle(
                side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.primary)),
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary),
              ),
              child: _isSigningIn
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onSecondary),
                      ),
                    )
                  : Text(AppLocalizations.of(context)!.login,
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  ),
            ),
          ],
        )
      ],
    );
  }
}
