import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth state holds both login status and username
final authStateProvider =
    StateProvider<Map<String, dynamic>>((ref) => {
          "isLoggedIn": false,
          "username": "",
        });
