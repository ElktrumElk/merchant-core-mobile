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

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _autoRouteIfLoggedIn();
  }

  Future<void> _autoRouteIfLoggedIn() async {
    final loggedIn = await checkIsLogin();
    if (!mounted) return;

    if (loggedIn) {

      await _fetchUserDetails();
      if (mounted) {
        isSplashScreen.value = false;
      }
    }
    else {
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
    final theme = Theme.of(context);
    return Container(
      decoration:  BoxDecoration(
        gradient:  LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeNotifier.isDarkMode ? [
            theme.scaffoldBackgroundColor,
            theme.cardColor,
          ]: [
            Color(0xFFFFFFFF),
            Color(0xFFF4F5F7),
          ],
        ),
      ),
      height: double.maxFinite,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.leaderboard, size: 48, color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              'Merchant Core',

              style: TextStyle(
                color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                fontFamily: 'sanserif'
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your business in one place',
              style: TextStyle(
                color: Colors.grey,
                decoration: TextDecoration.none,
                fontSize: 15,
                fontFamily: 'sanserif'
              ),
            ),
            const SizedBox(height: 40),
            if (showGetStartedButton)
              SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  onPressed: _openAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: const Color(0xFF379AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black38,
                  ),
                  child:  const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            else
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              )
          ],
        ),
      ),
    );
  }
}
