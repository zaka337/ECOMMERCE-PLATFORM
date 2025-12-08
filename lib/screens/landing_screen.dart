import 'package:flutter/material.dart';
import 'auth_screen.dart'; // CONNECTS TO THE FILE ABOVE

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _hoverController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideTextAnimation;
  late Animation<Offset> _slideCardAnimation;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideTextAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));

    _slideCardAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
    ));

    _hoverAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOutSine),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFEFF3E6);
    const cardDark = Color(0xFF181816);
    const accentGreen = Color(0xFFB0FFA3);
    const textDark = Color(0xFF222222);

    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: bgCream,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // LAYER 1: Background Typography
          Positioned(
            top: screenHeight * 0.10,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                   Transform.rotate(
                    angle: -0.05,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: const BoxDecoration(color: textDark),
                      child: const Text(
                        "UNLOCKING THE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "CREATIVE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Impact', // Make sure this font is in pubspec or remove this line
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: textDark.withOpacity(0.8),
                      letterSpacing: -2,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    "MINDSET",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Impact',
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: textDark.withOpacity(0.2),
                      letterSpacing: -2,
                      height: 0.9,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LAYER 2: Hero Image
          Positioned(
            top: screenHeight * 0.22,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideTextAnimation,
              child: AnimatedBuilder(
                animation: _hoverAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _hoverAnimation.value),
                    child: child,
                  );
                },
                child: Center(
                  child: SizedBox(
                    height: screenHeight * 0.45,
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image: NetworkImage("https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=1000&auto=format&fit=crop"), 
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: textDark.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            "DIGITAL\nFUTURE\nREADY",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // LAYER 3: Bottom Card with Navigation Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * (isSmallScreen ? 0.50 : 0.45),
            child: SlideTransition(
              position: _slideCardAnimation,
              child: Container(
                decoration: const BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Explore your\n",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: "Creativity",
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Enjoy lifetime access to courses on the go through your learning app.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // Navigation Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              context,
                              text: "Log In",
                              isPrimary: false,
                              accentColor: accentGreen,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen(initialIsLogin: true))),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildButton(
                              context,
                              text: "Sign Up",
                              isPrimary: true,
                              accentColor: accentGreen,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen(initialIsLogin: false))),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String text, required bool isPrimary, required Color accentColor, required VoidCallback onTap}) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? accentColor : Colors.transparent,
          foregroundColor: isPrimary ? Colors.black : Colors.white,
          elevation: 0,
          side: isPrimary ? BorderSide.none : const BorderSide(color: Colors.white24, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPrimary ? Colors.black : Colors.white)),
      ),
    );
  }
}