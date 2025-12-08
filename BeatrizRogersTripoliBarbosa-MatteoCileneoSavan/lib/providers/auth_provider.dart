import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_dto.dart';
import '../models/routine.dart';

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
      final routines = await _fetchRoutinesForUser(user.uid);
      return AuthDto(uid: user.uid, email: user.email, displayName: user.displayName, photoUrl: user.photoURL, routines: routines);
    }
    return null;
  }

  /// Public helper to fetch routines for a user and convert them into
  /// `Routine` model instances. Returns an empty list when none found.
  Future<List<Routine>> fetchRoutinesForUserAsModels(String uid) async {
    final maps = await _fetchRoutinesForUser(uid);
    if (maps == null) return <Routine>[];
    try {
      return maps.map((m) => Routine.fromJson(m)).toList();
    } catch (e) {
      debugPrint('Failed to convert routine maps to models: $e');
      return <Routine>[];
    }
  }

  Future<AuthDto?> createUserWithEmail({required String email, required String password, String? displayName}) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final createdUser = userCredential.user;
    if (createdUser == null) return null;

    User updatedUser = createdUser;
    // If a displayName was provided, set it on the Firebase user before
    // upserting to Firestore so the stored 'name' value is populated.
    if (displayName != null && displayName.isNotEmpty) {
      try {
        await updatedUser.updateDisplayName(displayName);
        // Reload user to ensure the local User object has latest values.
        await updatedUser.reload();
        updatedUser = _auth.currentUser ?? updatedUser;
      } catch (e) {
        debugPrint('Failed to set displayName: $e');
      }
    }

    // When creating a new user, ensure they have an initial empty routines list.
    await _upsertUserToFirestore(updatedUser, routines: <Map<String, dynamic>>[]);
    final routines = await _fetchRoutinesForUser(updatedUser.uid);
    return AuthDto(uid: updatedUser.uid, email: updatedUser.email, displayName: updatedUser.displayName, photoUrl: updatedUser.photoURL, routines: routines);
  }

  Future<AuthDto?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(provider);
      final user = userCredential.user;
      if (user != null) {
        await _upsertUserToFirestore(user);
        final routines = await _fetchRoutinesForUser(user.uid);
        return AuthDto(uid: user.uid, email: user.email, displayName: user.displayName, photoUrl: user.photoURL, routines: routines);
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
      final routines = await _fetchRoutinesForUser(user.uid);
      return AuthDto(uid: user.uid, email: user.email, displayName: user.displayName, photoUrl: user.photoURL, routines: routines);
    }
    return null;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Update the current user's displayName and upsert the user's Firestore doc.
  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No signed-in user');
    try {
      await user.updateDisplayName(displayName);
      await user.reload();
      final latest = _auth.currentUser ?? user;
      await _upsertUserToFirestore(latest);
    } catch (e) {
      debugPrint('Failed to update displayName: $e');
      rethrow;
    }
  }

  /// Add a routine (as structured map) to a user's routines array.
  Future<void> addRoutineForUser(String uid, Routine routine) async {
    final docRef = _firestore.collection('users').doc(uid);
    try {
      await docRef.update({
        'routines': FieldValue.arrayUnion([routine.toJson()]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // If update fails (e.g., doc doesn't exist), use set with merge.
      try {
        await docRef.set({
          'routines': FieldValue.arrayUnion([routine.toJson()]),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e2) {
        debugPrint('Failed to add routine for user $uid: $e2');
        rethrow;
      }
    }
  }

  /// Remove a routine by id from a user's routines array.
  Future<void> removeRoutineForUser(String uid, String routineId) async {
    final docRef = _firestore.collection('users').doc(uid);
    final maps = await _fetchRoutinesForUser(uid);
    if (maps == null) return;
    final filtered = maps.where((m) => (m['id'] ?? '') != routineId).toList();
    try {
      await docRef.set({'routines': filtered, 'lastUpdated': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to remove routine $routineId for user $uid: $e');
      rethrow;
    }
  }

  /// Migrate legacy string-encoded routines for a single user to structured maps.
  /// This reads user's routines, normalizes them using the same decoding logic,
  /// and writes back the normalized list of maps.
  Future<void> migrateLegacyRoutinesForUser(String uid) async {
    final docRef = _firestore.collection('users').doc(uid);
    final normalized = await _fetchRoutinesForUser(uid);
    if (normalized == null) return;
    try {
      await docRef.set({'routines': normalized, 'lastUpdated': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to migrate routines for user $uid: $e');
      rethrow;
    }
  }

  /// Migrate legacy routines for all users in the `users` collection.
  /// Use with care (may read/write many documents).
  Future<void> migrateAllUsers() async {
    try {
      final snap = await _firestore.collection('users').get();
      for (final doc in snap.docs) {
        await migrateLegacyRoutinesForUser(doc.id);
      }
    } catch (e) {
      debugPrint('Failed to migrate all users: $e');
      rethrow;
    }
  }

  /// Clear all routines for a user (sets an empty list). Useful for delete-all.
  Future<void> clearRoutinesForUser(String uid) async {
    final docRef = _firestore.collection('users').doc(uid);
    try {
      await docRef.set({'routines': <Map<String, dynamic>>[], 'lastUpdated': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to clear routines for user $uid: $e');
      rethrow;
    }
  }

  // ==================== SCHEDULE METHODS ====================

  /// Save weekly schedule to Firestore
  Future<void> saveScheduleForUser(String uid, Map<String, dynamic> scheduleJson) async {
    final docRef = _firestore.collection('users').doc(uid);
    try {
      await docRef.set({
        'schedule': scheduleJson,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('📅 Schedule saved to Firestore for user $uid');
    } catch (e) {
      debugPrint('❌ Failed to save schedule for user $uid: $e');
      rethrow;
    }
  }

  /// Fetch weekly schedule from Firestore
  Future<Map<String, dynamic>?> fetchScheduleForUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      final schedule = data['schedule'];
      if (schedule is Map) {
        return Map<String, dynamic>.from(schedule);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to fetch schedule for user $uid: $e');
      return null;
    }
  }

  // ==================== COMPLETED ROUTINES METHODS ====================

  /// Save completed routines to Firestore (with automatic cleanup of entries older than 2 months)
  Future<void> saveCompletedRoutinesForUser(String uid, Map<String, List<String>> completedRoutines) async {
    final docRef = _firestore.collection('users').doc(uid);
    
    // Cleanup: Remove dates older than 2 months
    final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
    final cleanedData = <String, List<String>>{};
    
    completedRoutines.forEach((routineId, dates) {
      final filteredDates = dates.where((dateStr) {
        try {
          final date = DateTime.parse(dateStr);
          return date.isAfter(twoMonthsAgo);
        } catch (e) {
          return false; // Remove invalid dates
        }
      }).toList();
      
      if (filteredDates.isNotEmpty) {
        cleanedData[routineId] = filteredDates;
      }
    });
    
    try {
      await docRef.set({
        'completedRoutines': cleanedData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ Completed routines saved to Firestore for user $uid (cleaned old entries)');
    } catch (e) {
      debugPrint('❌ Failed to save completed routines for user $uid: $e');
      rethrow;
    }
  }

  /// Fetch completed routines from Firestore (automatically filters out entries older than 2 months)
  Future<Map<String, Set<String>>?> fetchCompletedRoutinesForUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      final completedRoutines = data['completedRoutines'];
      
      if (completedRoutines is! Map) return null;
      
      // Cleanup: Remove dates older than 2 months
      final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
      final result = <String, Set<String>>{};
      
      completedRoutines.forEach((key, value) {
        if (value is List) {
          final filteredDates = value
              .whereType<String>()
              .where((dateStr) {
                try {
                  final date = DateTime.parse(dateStr);
                  return date.isAfter(twoMonthsAgo);
                } catch (e) {
                  return false;
                }
              })
              .toSet();
          
          if (filteredDates.isNotEmpty) {
            result[key.toString()] = filteredDates;
          }
        }
      });
      
      debugPrint('📊 Completed routines fetched from Firestore for user $uid');
      return result;
    } catch (e) {
      debugPrint('❌ Failed to fetch completed routines for user $uid: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> _fetchRoutinesForUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      final routinesRaw = data['routines'];
      if (routinesRaw is! List) return null;

      final List<Map<String, dynamic>> routines = [];
      for (final item in routinesRaw) {
        if (item is Map) {
          routines.add(Map<String, dynamic>.from(item));
          continue;
        }

        if (item is String) {
          // Try multiple robust decoding strategies for legacy string entries.
          Map<String, dynamic>? tryDecodeString(String s) {
            // 1) direct JSON decode
            try {
              final d = jsonDecode(s);
              if (d is Map<String, dynamic>) return d;
              if (d is Map) return Map<String, dynamic>.from(d);
            } catch (_) {}

            // 2) URL-decoded string (in case it was encoded)
            try {
              final u = Uri.decodeComponent(s);
              final d = jsonDecode(u);
              if (d is Map<String, dynamic>) return d;
              if (d is Map) return Map<String, dynamic>.from(d);
            } catch (_) {}

            // 3) Extract JSON-like substring between first '{' and last '}'
            try {
              final start = s.indexOf('{');
              final end = s.lastIndexOf('}');
              if (start != -1 && end != -1 && end > start) {
                final sub = s.substring(start, end + 1);
                final d = jsonDecode(sub);
                if (d is Map<String, dynamic>) return d;
                if (d is Map) return Map<String, dynamic>.from(d);
              }
            } catch (_) {}

            // 4) Naive single-quote -> double-quote fallback (best-effort)
            try {
              final replaced = s.replaceAll("'", '"');
              final d = jsonDecode(replaced);
              if (d is Map<String, dynamic>) return d;
              if (d is Map) return Map<String, dynamic>.from(d);
            } catch (_) {}

            return null;
          }

          final decodedMap = tryDecodeString(item);
          if (decodedMap != null) {
            routines.add(decodedMap);
            continue;
          }

          // Last-resort: preserve the raw string inside a map so the
          // application can still construct a Routine from it (e.g.
          // put raw JSON into the `name` field or a `legacy_raw` key).
          routines.add({'legacy_raw': item});
        }
      }

      return routines;
    } catch (e) {
      debugPrint('Failed to fetch routines for user $uid: $e');
      return null;
    }
  }

  Future<void> _upsertUserToFirestore(User user, {List<Map<String, dynamic>>? routines}) async {
    try {
      final data = {
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      };
      // Only include routines if provided. This avoids overwriting existing lists unintentionally.
      if (routines != null) {
        data['routines'] = routines;
      }
      await _firestore.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to upsert user: $e');
    }
  }
}
