import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  
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

    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            await _signOut();
          }, 
        ),
      ),
      body: Center(
        child: Text('Welcome $user! You have successfully logged in!'),
      ),
    );
  }
}