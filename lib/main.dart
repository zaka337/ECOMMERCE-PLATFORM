import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';

// 1. Mark main as 'async'
void main() async {
  // 2. Ensure Flutter bindings are initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Initialize Firebase inside the function
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: AZMartApp()));
}

class AZMartApp extends ConsumerWidget {
  const AZMartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    // FIXED: Removed '?' because the compiler knows authState cannot be null
    final bool isLoggedIn = authState['isLoggedIn'] ?? false;
    final String username = authState['username'] ?? "Guest";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A&Z Mart',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: isLoggedIn
          ? HomeScreen(username: username)
          : const LandingScreen(),
    );
  }
}