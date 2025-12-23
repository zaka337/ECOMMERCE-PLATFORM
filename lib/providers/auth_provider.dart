import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Auth state holds both login status and username
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, Map<String, dynamic>>((ref) {
  return AuthStateNotifier();
});

class AuthStateNotifier extends StateNotifier<Map<String, dynamic>> {
  AuthStateNotifier() : super({
    "isLoggedIn": false,
    "username": "",
    "uid": "",
    "email": "",
    "isStoreOwner": false,
  }) {
    // Listen to Firebase Auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in
        // Get username from displayName, or fallback to email username, or "User"
        String username = user.displayName ?? 
                         (user.email != null ? user.email!.split('@')[0] : "User");
        state = {
          "isLoggedIn": true,
          "username": username,
          "uid": user.uid,
          "email": user.email ?? "",
          "isStoreOwner": false, // Will be updated by store provider
        };
      } else {
        // User is signed out
        state = {
          "isLoggedIn": false,
          "username": "",
          "uid": "",
          "email": "",
          "isStoreOwner": false,
        };
      }
    });
  }

  // Initialize auth state on app startup
  Future<void> initializeAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get username from displayName, or fallback to email username, or "User"
      String username = user.displayName ?? 
                       (user.email != null ? user.email!.split('@')[0] : "User");
      state = {
        "isLoggedIn": true,
        "username": username,
        "uid": user.uid,
        "email": user.email ?? "",
        "isStoreOwner": false, // Will be updated by store provider
      };
    } else {
      state = {
        "isLoggedIn": false,
        "username": "",
        "uid": "",
        "email": "",
        "isStoreOwner": false,
      };
    }
  }

  // Manual logout
  Future<void> logout() async {
    // Clear SharedPreferences (remember me data)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.setBool('remember_me', false);
    } catch (e) {
      // Ignore errors when clearing preferences
    }
    
    // Sign out from Google Sign-In if user was signed in with Google
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      // Ignore errors if user wasn't signed in with Google
    }
    
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();
    state = {
      "isLoggedIn": false,
      "username": "",
      "uid": "",
      "email": "",
    };
  }
}
