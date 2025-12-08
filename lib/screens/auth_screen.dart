import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart'; 
import 'home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool initialIsLogin;
  const AuthScreen({Key? key, this.initialIsLogin = true}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  // State
  late bool isLogin;
  bool isLoading = false;
  bool isPasswordVisible = false;

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  
  // Animation for the toggle
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    isLogin = widget.initialIsLogin;
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

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      // Reset animation to trigger fade effect for fields
      _animationController.reset();
      _animationController.forward();
    });
  }

  Future<void> handleAuth() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (!isLogin && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your full name")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential;
      String displayName = name;

      if (isLogin) {
        // LOGIN LOGIC
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, 
          password: password
        );
        displayName = userCredential.user?.displayName ?? "User";
      } else {
        // SIGNUP LOGIC
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, 
          password: password
        );
        await userCredential.user?.updateDisplayName(name);
      }

      // Update Riverpod
      ref.read(authStateProvider.notifier).state = {
        'isLoggedIn': true,
        'username': displayName,
        'uid': userCredential.user?.uid,
      };

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLogin ? "Login Successful 🎉" : "Account Created Successfully! 🎉")),
      );

      // Navigate
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen(username: displayName)),
        (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'user-not-found') message = 'No user found for that email.';
      else if (e.code == 'wrong-password') message = 'Wrong password provided.';
      else if (e.code == 'weak-password') message = 'The password provided is too weak.';
      else if (e.code == 'email-already-in-use') message = 'The account already exists for that email.';
      else if (e.code == 'invalid-email') message = 'The email address is invalid.';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Streetwear Palette
    const bgCream = Color(0xFFEFF3E6);
    const cardDark = Color(0xFF181816);

    return Scaffold(
      backgroundColor: cardDark, // Top half is dark
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
          // 1. Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLogin ? "Welcome back!" : "Create Account",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin ? "Enter your credential to continue" : "Sign up to get started!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 2. Main Card Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: bgCream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // --- TOGGLE SWITCH ---
                    Container(
                      height: 55,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cardDark,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          _buildToggleBtn("Log in", true, bgCream, cardDark),
                          _buildToggleBtn("Sign up", false, bgCream, cardDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- FORM FIELDS ---
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isLogin) ...[
                             _buildLabel("Full Name"),
                            _buildTextField(
                              controller: nameController,
                              hint: "Enter Full Name",
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 20),
                          ],

                          _buildLabel("Email id"),
                          _buildTextField(
                            controller: emailController,
                            hint: "Enter Email",
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          _buildLabel("Password"),
                          _buildTextField(
                            controller: passController,
                            hint: "Enter password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          
                          if (isLogin) ...[
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_box_outline_blank, size: 20, color: cardDark.withOpacity(0.5)),
                                    const SizedBox(width: 8),
                                    Text("Remember me", style: TextStyle(color: cardDark.withOpacity(0.6))),
                                  ],
                                ),
                                Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                    color: cardDark.withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- MAIN ACTION BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24, 
                                width: 24, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : Text(
                                isLogin ? "Log In" : "Sign up",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Bottom Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: TextStyle(color: cardDark.withOpacity(0.6)),
                        ),
                        GestureDetector(
                          onTap: toggleAuthMode,
                          child: Text(
                            isLogin ? "Sign Up" : "Log In",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cardDark,
                            ),
                          ),
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

  // Helper: Toggle Button
  Widget _buildToggleBtn(String text, bool isBtnLogin, Color activeColor, Color inactiveColor) {
    final bool isActive = isLogin == isBtnLogin;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isLogin != isBtnLogin) toggleAuthMode();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? inactiveColor : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // Helper: Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF181816).withOpacity(0.7),
        ),
      ),
    );
  }

  // Helper: Input Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.black54),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}