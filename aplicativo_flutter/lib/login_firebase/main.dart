import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';

import 'package:firebase_storage/firebase_storage.dart';

// https://isaacadariku.medium.com/google-sign-in-flutter-migration-guide-pre-7-0-versions-to-v7-version-cdc9efd7f182

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize GoogleSignIn for non-web platforms (v7.0+ requirement)
  if (!kIsWeb) {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint('Failed to initialize Google Sign-In: $e');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Login Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // wait for auth initialization
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return HomePage();
        }
        return const LoginScreen();
      },
    );
  }
}

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

  String? _googleSignInExceptionToMessage(GoogleSignInException exception) {
    switch (exception.code.name) {
      case 'canceled':
        return null; // User cancelled, don't show error
      case 'interrupted':
        return 'Sign-in was interrupted. Please try again.';
      case 'clientConfigurationError':
        return 'Configuration issue with Google Sign-In. Please contact support.';
      case 'providerConfigurationError':
        return 'Google Sign-In is currently unavailable. Please try again later.';
      case 'uiUnavailable':
        return 'Google Sign-In is currently unavailable. Please try again later.';
      case 'userMismatch':
        return 'Account mismatch. Please sign out and try again.';
      default:
        return 'An unexpected error occurred during Google Sign-In.';
    }
  }

  Future<void> _upsertUserToFirestore(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
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

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      // Use default project domain (no ActionCodeSettings)
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      setState(() => _isSigningIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(24),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isSignUpMode ? 'Create Account' : 'Sign In',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.email),
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
                      enabled: !_isSigningIn,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (_isSignUpMode && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      enabled: !_isSigningIn,
                    ),
                    const SizedBox(height: 20),

                    // Email/Password Sign In/Up Button
                    ElevatedButton(
                      onPressed: _isSigningIn ? null : _signInWithEmailPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: _isSigningIn
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isSignUpMode ? 'Sign Up' : 'Sign In'),
                    ),
                    const SizedBox(height: 12),

                    // Toggle Sign Up/Sign In
                    TextButton(
                      onPressed: _isSigningIn
                          ? null
                          : () {
                              setState(() {
                                _isSignUpMode = !_isSignUpMode;
                                _errorMessage = null;
                              });
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isSignUpMode
                            ? 'Already have an account? Sign In'
                            : 'Don\'t have an account? Sign Up',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Google Sign In Button
                    OutlinedButton.icon(
                      onPressed: _isSigningIn ? null : _signInWithGoogle,
                      icon: Image.network(
                        'https://example.com/path/to/google_icon.png',
                        height: 20,
                        width: 20,
                      ),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),

                    // Password reset link
                    if (!_isSignUpMode) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isSigningIn ? null : _resetPassword,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _dataController = TextEditingController();
  TextEditingController _pictureController = TextEditingController();

  ImageProvider? _avatarProvider; // cache the image provider

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('GoogleSignIn signOut error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Initialize once per session to avoid recreating the NetworkImage every build
    if (_avatarProvider == null &&
        user?.photoURL != null &&
        user!.photoURL!.isNotEmpty) {
      _avatarProvider = NetworkImage(user.photoURL!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _signOut();
          },
        ),
      ),
      body: Center(
        child: user == null
            ? const Text('No user signed in.')
            : FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('shared')
                    .doc(user.uid)
                    .get(),
                builder: (context, snapshot) {
                  String info = '';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    info = data?['info'] ?? 'No info';
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_avatarProvider != null)
                        // Use the cached provider, with a fallback on error
                        ClipOval(
                          child: Image(
                            image: _avatarProvider!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue.shade200,
                              child: Text(
                                (user.displayName ?? user.email ?? 'U')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      else
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade200,
                          child: Text(
                            (user.displayName ?? user.email ?? 'U')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        'Hello, ${user.displayName ?? user.email?.split('@').first ?? 'User'}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 20),
                      Text(user.email ?? ''),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signOut,
                        child: const Text('Sign Out'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Add Info'),
                                content: TextField(
                                  controller: _dataController,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter info',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('shared')
                                          .doc(user.uid)
                                          .set({
                                        'info': _dataController.text,
                                      }, SetOptions(merge: true));
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Add'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Add Info'),
                      ),
                      const SizedBox(height: 20),

                      /// Show current info from collection shared\uid using StreamBuilder
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('shared')
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text('No info available.');
                          }
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Info: ${data['info'] ?? 'No info'}'),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 250,
                                child: SelectableText(
                                    'Picture URL: ${data['pictureUrl'] ?? 'No picture'}'),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Using shared/user.uid/get[\'info\']: $info',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Choose picture'),
                                content: TextField(
                                  controller: _pictureController,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter picture URL',
                                  ),
                                  enableInteractiveSelection: true,
                                  autocorrect: false,
                                  keyboardType: TextInputType.url,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        /// load file from _pictureController.text using http
                                        final pictureUrl =
                                            _pictureController.text;
                                        try {
                                          await uploadFirebase(
                                              user.uid,
                                              pictureUrl,
                                              '${user.uid}/picture.jpg');
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Failed to upload picture to Firebase Storage')),
                                          );
                                        }
                                        if (mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Failed to load picture from URL')),
                                        );
                                      }
                                    },
                                    child: const Text('Upload'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Add picture'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Picture'),
                                content: FutureBuilder<String>(
                                  future: () async {
                                    final doc = await FirebaseFirestore.instance
                                        .collection('shared')
                                        .doc(user.uid)
                                        .get();
                                    final data = doc.data();
                                    final url = data?['pictureUrl'] as String?;
                                    if (url == null || url.isEmpty) {
                                      throw Exception('No pictureUrl saved.');
                                    }
                                    return url;
                                  }(),
                                  builder: (context, urlSnap) {
                                    if (urlSnap.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                        width: 300,
                                        height: 300,
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }
                                    if (urlSnap.hasError) {
                                      return SizedBox(
                                        width: 300,
                                        height: 300,
                                        child: Center(
                                          child: SelectableText(
                                            'Failed to load picture URL: ${urlSnap.error}',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                          ),
                                        ),
                                      );
                                    }

                                    String url = urlSnap.data!;
                                    if (url[0] == '"') {
                                      // Clean up quotes if any
                                      url = url.substring(1, url.length - 1);
                                    }
                                    // Web: load via network to avoid JS interop/getData issues.
                                    if (kIsWeb) {
                                      return SizedBox(
                                        width: 300,
                                        height: 300,
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) =>
                                              Center(
                                            child: Text(
                                              'Failed to load picture (web).',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    // Mobile/Desktop: fetch bytes from Storage.
                                    return FutureBuilder<Uint8List?>(
                                      future: FirebaseStorage.instance
                                          .refFromURL(url)
                                          .getData(5 * 1024 * 1024), // 5MB
                                      builder: (context, bytesSnap) {
                                        if (bytesSnap.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            width: 300,
                                            height: 300,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          );
                                        }
                                        if (bytesSnap.hasError ||
                                            bytesSnap.data == null) {
                                          // Fallback to network if getData fails
                                          return SizedBox(
                                            width: 300,
                                            height: 300,
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, st) =>
                                                  Center(
                                                child: Text(
                                                  'Failed to load picture.',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return SizedBox(
                                          width: 300,
                                          height: 300,
                                          child: Image.memory(bytesSnap.data!,
                                              fit: BoxFit.cover),
                                        );
                                      },
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Show picture'),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

/// create a folder in firebase for each student email in the list. Use the email
/// till the @ as the folder name.
void createFolderForEachStudent(List<String> emails) {
  final firestore = FirebaseFirestore.instance;

  for (final email in emails) {
    final folderName = email.split('@').first;
    firestore.collection('students').doc(folderName).set({
      'email': email,
    });
    print('Created folder for $folderName');
  }
}

void createNewLoginForUser(String newEmail, String newPassword) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: newEmail,
      password: newPassword,
    );
    print('New user created: ${userCredential.user?.uid}');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    } else {
      print(e);
    }
  } catch (e) {
    print(e);
  }
}

/// Uploads the bytes downloaded from an external URL directly to Firebase Storage.
/// Avoids base64; uploads raw bytes with proper content-type metadata.
///
/// Returns the public download URL of the uploaded object.
Future<String> uploadFirebase(
  String userId,
  String pictureUrl,
  String pathInStorage, {
  Duration httpTimeout = const Duration(seconds: 10),
  Duration uploadTimeout = const Duration(seconds: 10),
  Duration urlTimeout = const Duration(seconds: 10),
  void Function(int bytesTransferred, int totalBytes)? onProgress,
}) async {
  final uri = Uri.parse(pictureUrl);

  // Download the resource into memory
  final response = await http.get(uri).timeout(httpTimeout);
  if (response.statusCode != 200) {
    throw Exception(
        'Failed to GET resource: ${response.statusCode} ${response.reasonPhrase}');
  }

  final Uint8List bytes = response.bodyBytes;
  final contentType = response.headers['content-type'] ?? 'image/jpeg';

  // Upload to Firebase Storage
  final ref = FirebaseStorage.instance.ref(pathInStorage);
  final task = ref.putData(
    bytes,
    SettableMetadata(contentType: contentType),
  );

  if (onProgress != null) {
    task.snapshotEvents.listen((s) {
      final total = s.totalBytes;
      final transferred = s.bytesTransferred;
      onProgress(transferred, total);
    });
  }

  // Wait for completion with timeout
  await task.timeout(uploadTimeout);

  // Get the download URL
  final downloadUrl = await ref.getDownloadURL().timeout(urlTimeout);

  // Save the URL (String) to Firestore, not the bytes
  await FirebaseFirestore.instance.collection('shared').doc(userId).set({
    'pictureUrl': downloadUrl, // Save URL string, not bytes
  }, SetOptions(merge: true));

  return downloadUrl;
}

/// Downloads bytes from Firebase Storage at the given path.
///
/// maxSize limits the number of bytes to fetch to protect memory usage.
Future<Uint8List> downloadFirebase(
  String pathInStorage, {
  int maxSize = 10 * 1024 * 1024, // 10 MB default
}) async {
  final ref = FirebaseStorage.instance.ref(pathInStorage);
  final data = await ref.getData(maxSize);
  if (data == null) {
    throw Exception('No data found at $pathInStorage');
  }
  return data;
}
