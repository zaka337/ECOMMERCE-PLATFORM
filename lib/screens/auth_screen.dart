import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart'; // For PlatformException
import '../providers/auth_provider.dart';
import 'home_screen.dart';

// Google Sign-In Web Client ID
const String? _googleSignInWebClientId = '711521421896-1k14oohlm8jguk3v6gt0kets7np17n4j.apps.googleusercontent.com';

class AuthScreen extends ConsumerStatefulWidget {
  final bool initialIsLogin;
  const AuthScreen({Key? key, this.initialIsLogin = true}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late bool isLogin;
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool rememberMe = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    isLogin = widget.initialIsLogin;
    if (isLogin) _loadUserEmail();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _loadUserEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('saved_email');
      bool? savedRememberMe = prefs.getBool('remember_me');

      if (isLogin && savedRememberMe == true && savedEmail != null) {
        if (mounted) {
          setState(() {
            rememberMe = true;
            emailController.text = savedEmail;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user email: $e");
    }
  }

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      _animationController.reset();
      _animationController.forward();
    });

    if (isLogin) {
      nameController.clear();
      passController.clear();
      _loadUserEmail();
    } else {
      nameController.clear();
      emailController.clear();
      passController.clear();
      rememberMe = false;
    }
  }

  // --- GOOGLE SIGN IN LOGIC ---
  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);

    try {
      if (kIsWeb && _googleSignInWebClientId == null) {
        throw Exception("Google Client ID missing for Web. Check lib/screens/auth_screen.dart");
      }

      // 1. Configure Google Sign In
      // Using only 'email' scope to avoid People API requirement
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        clientId: kIsWeb ? _googleSignInWebClientId : null,
      );

      // 2. Start interactive sign-in (always show account picker for fresh flow)
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // User canceled the sign-in flow
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      // 4. Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw Exception("Missing Google Auth Tokens");
      }

      // 4. Create Credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Sign in to Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      // 6. Update Riverpod State (CRITICAL FIX)
      final username = user?.displayName ?? user?.email?.split('@')[0] ?? "User";
      
      ref.read(authStateProvider.notifier).state = {
        'isLoggedIn': true,
        'username': username,
        'uid': user?.uid,
      };

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In Successful 🎉"), backgroundColor: Colors.green),
      );

      // 7. Navigate
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
        (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      _showError("Firebase Error: ${e.message}");
    } on PlatformException catch (e) {
      String errorMsg = "Platform Error: ${e.message}";
      if (e.code == 'sign_in_failed') {
        errorMsg = "Sign-in failed. Check SHA-1 in Firebase Console for Android.";
      }
      _showError(errorMsg);
    } catch (e) {
      String errorStr = e.toString();
      // Check for People API error
      if (errorStr.contains('People API') || errorStr.contains('people.googleapis.com')) {
        _showError(
          "People API not enabled.\n"
          "Enable it here:\n"
          "https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=711521421896\n"
          "Or the code will work with email-only (no profile info)."
        );
      } else {
        _showError("Error: $e");
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- EMAIL/PASS AUTH LOGIC ---
  Future<void> handleAuth() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill all required fields");
      return;
    }
    if (!isLogin && name.isEmpty) {
      _showError("Please enter your full name");
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential;
      String displayName = name;

      if (isLogin) {
        // LOGIN
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
        );
        displayName = userCredential.user?.displayName ?? "User";

        // Remember Me
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (rememberMe) {
          await prefs.setString('saved_email', email);
          await prefs.setBool('remember_me', true);
        } else {
          await prefs.remove('saved_email');
          await prefs.setBool('remember_me', false);
        }

      } else {
        // SIGNUP
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
        );
        await userCredential.user?.updateDisplayName(name);
        await userCredential.user?.reload();
        displayName = FirebaseAuth.instance.currentUser?.displayName ?? name;
      }

      // Update Riverpod State
      ref.read(authStateProvider.notifier).state = {
        'isLoggedIn': true,
        'username': displayName,
        'uid': userCredential.user?.uid,
      };

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLogin ? "Login Successful 🎉" : "Account Created!"), backgroundColor: Colors.green),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen(username: displayName)),
        (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? "Authentication failed";
      if (e.code == 'user-not-found') msg = "No user found for that email.";
      else if (e.code == 'wrong-password') msg = "Wrong password.";
      else if (e.code == 'email-already-in-use') msg = "Email already in use.";
      _showError(msg);
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFEFF3E6);
    const cardDark = Color(0xFF181816);

    return Scaffold(
      backgroundColor: cardDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLogin ? "Welcome back!" : "Create Account",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin ? "Enter your credential to continue" : "Sign up to get started!",
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: bgCream,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  children: [
                    // TOGGLE
                    Container(
                      height: 55,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        children: [
                          _buildToggleBtn("Log in", true, bgCream, cardDark),
                          _buildToggleBtn("Sign up", false, bgCream, cardDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // FORM
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isLogin) ...[
                            _buildLabel("Full Name"),
                            _buildTextField(controller: nameController, hint: "Enter Full Name", icon: Icons.person_outline),
                            const SizedBox(height: 20),
                          ],
                          _buildLabel("Email id"),
                          _buildTextField(controller: emailController, hint: "Enter Email", icon: Icons.email_outlined, inputType: TextInputType.emailAddress),
                          const SizedBox(height: 20),
                          _buildLabel("Password"),
                          _buildTextField(controller: passController, hint: "Enter password", icon: Icons.lock_outline, isPassword: true),
                          
                          if (isLogin) ...[
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => rememberMe = !rememberMe),
                                  child: Row(
                                    children: [
                                      Icon(rememberMe ? Icons.check_box : Icons.check_box_outline_blank, size: 20, color: cardDark),
                                      const SizedBox(width: 8),
                                      Text("Remember me", style: TextStyle(color: cardDark.withOpacity(0.6))),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                                  child: Text("Forgot Password", style: TextStyle(color: cardDark.withOpacity(0.6), fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // AUTH BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(isLogin ? "Log In" : "Sign up", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DIVIDER
                    Row(
                      children: [
                        Expanded(child: Divider(color: cardDark.withOpacity(0.2))),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text("OR", style: TextStyle(color: cardDark.withOpacity(0.4)))),
                        Expanded(child: Divider(color: cardDark.withOpacity(0.2))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // GOOGLE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _handleGoogleSignIn,
                        icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.black),
                        label: const Text("Continue with Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cardDark)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cardDark.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BOTTOM TEXT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isLogin ? "Don't have an account? " : "Already have an account? ", style: TextStyle(color: cardDark.withOpacity(0.6))),
                        GestureDetector(
                          onTap: toggleAuthMode,
                          child: Text(isLogin ? "Sign Up" : "Log In", style: const TextStyle(fontWeight: FontWeight.bold, color: cardDark)),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isBtnLogin, Color active, Color inactive) {
    bool isActive = isLogin == isBtnLogin;
    return Expanded(
      child: GestureDetector(
        onTap: () { if (isLogin != isBtnLogin) toggleAuthMode(); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: isActive ? active : Colors.transparent, borderRadius: BorderRadius.circular(26)),
          child: Text(text, style: TextStyle(color: isActive ? inactive : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF181816))));

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.black54),
          border: InputBorder.none,
          suffixIcon: isPassword ? IconButton(icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black54), onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible)) : null,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _handleReset() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter email"), backgroundColor: Colors.red));
      return;
    }
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reset link sent!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error sending link"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const cardDark = Color(0xFF181816);
    return Scaffold(
      backgroundColor: cardDark,
      appBar: AppBar(backgroundColor: Colors.transparent, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Forgot Password", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: TextField(controller: emailController, decoration: const InputDecoration(hintText: "Enter Email", border: InputBorder.none, contentPadding: EdgeInsets.all(16))),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: isLoading ? null : _handleReset, child: isLoading ? const CircularProgressIndicator() : const Text("Send Link")),
            )
          ],
        ),
      ),
    );
  }
}