import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- FIXED: Uncommented this line so the app can find LandingScreen ---
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
    // Watch auth state from Riverpod
    final authState = ref.watch(authStateProvider);
    
    // Safely access values
    final bool isLoggedIn = authState['isLoggedIn'] ?? false;
    final String username = authState['username'] ?? "Guest";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A&Z Mart',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        useMaterial3: true,
        fontFamily: 'Roboto', // Optional: Set a default font
      ),
      // If logged in -> Home, else -> Landing
      home: isLoggedIn
          ? HomeScreen(username: username)
          : const LandingScreen(),
    );
  }
}