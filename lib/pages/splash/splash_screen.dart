import 'package:first_flutter_project/components/settings/user.dart';
import 'package:first_flutter_project/global/auth_global.dart';
import 'package:first_flutter_project/global/theme_notifier.dart';
import 'package:first_flutter_project/main.dart';
import 'package:first_flutter_project/module/storage/device_storage.dart';
import 'package:first_flutter_project/network/authentication/user_authentication.dart';
import 'package:first_flutter_project/pages/authentication/login/user_login.dart';
import 'package:flutter/material.dart';

bool showGetStartedButton = false;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
    _autoRouteIfLoggedIn();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _autoRouteIfLoggedIn() async {
    final loggedIn = await checkIsLogin();
    if (!mounted) return;

    if (loggedIn) {
      await _fetchUserDetails();
      if (mounted) {
        isSplashScreen.value = false;
      }
    } else {
      setState(() {
        showGetStartedButton = true;
      });
    }
  }

  Future<void> _openAuth() async {
    final success = await AuthBottomSheet.show(context);
    if (success && mounted) {
      DeviceStorage.setKey('isLogin');
      await DeviceStorage.saveValue('true');
      await _fetchUserDetails();
      if (mounted) {
        isSplashScreen.value = false;
      }
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await UserService().getUserInfo();
      if (response != null && response.statusCode == 200 && mounted) {
        AuthUser().response(response.body);
      }
    } catch (e) {
      debugPrint('Failed to fetch user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDarkMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFFDFDFF),
        ),
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -150,
              left: -100,
              child: _CircularPattern(
                color: (isDark ? const Color(0xFF4793FF) : const Color(0xFF1565C0)).withAlpha(15),
                size: 400,
              ),
            ),
            
            Positioned(
              bottom: -100,
              right: -50,
              child: _CircularPattern(
                color: Colors.blue.withAlpha(10),
                size: 300,
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        
                        // Premium Logo Container
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(3),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (isDark)
                                BoxShadow(
                                  color: const Color(0xFF4793FF).withAlpha(20),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                            ],
                          ),
                          child: Icon(
                            Icons.leaderboard_rounded,
                            size: 48,
                            color: isDark ? const Color(0xFF4793FF) : const Color(0xFF1565C0),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Brand Name
                        const Text(
                          'Merchant Core',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            fontFamily: 'sanserif',
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Subtitle
                        Text(
                          'Empowering Your Global Business Presence',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.5,
                            height: 1.4,
                          ),
                        ),
                        
                        const Spacer(flex: 4),
                        
                        // Action Button or Loader
                        if (showGetStartedButton)
                          _buildPrimaryButton(isDark)
                        else
                          _buildLoader(),
                        
                        const SizedBox(height: 40),
                        
                        // Version Tag
                        Text(
                          'V 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3.0,
                            color: Colors.grey.withAlpha(60),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFFFFFFFF), const Color(0xFFE0E0E0)] 
              : [const Color(0xFF1A1A1A), const Color(0xFF000000)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black).withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openAuth,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Text(
              'Get Started',
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const SizedBox(
      height: 64,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4793FF)),
        ),
      ),
    );
  }
}

class _CircularPattern extends StatelessWidget {
  final Color color;
  final double size;

  const _CircularPattern({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Container(
          width: size * 0.7,
          height: size * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
