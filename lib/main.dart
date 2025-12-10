import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart'; // Make sure this file exists from your Firebase setup

// Screen Imports
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    
    // Check login state (Default to false/Guest if null)
    final bool isLoggedIn = authState['isLoggedIn'] ?? false;
    final String username = authState['username'] ?? "Guest";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A&Z Mart',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F5EB), // Parchment color default
      ),
      // Logic: If logged in, show Home, else show Landing
      home: isLoggedIn
          ? HomeScreen(username: username)
          : const LandingScreen(), 
    );
  }
}