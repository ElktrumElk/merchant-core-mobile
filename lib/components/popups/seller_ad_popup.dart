import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerAdPopup extends StatelessWidget {
  const SellerAdPopup({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SellerAdPopup(),
    );
  }

  Future<void> _launchWeb() async {
    final Uri url = Uri.parse('https://merchantcore.netlify.app');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF2D2D2D),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Abstract background elements for "premium" look
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withAlpha(20),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(20)),
                      ),
                      child: const Icon(
                        Icons.rocket_launch_outlined,
                        size: 48,
                        color: Color(0xFF4793FF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Scale Your Business',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ready to become a seller? Create your organization today and manage everything from our professional web suite.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(160),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _launchWeb();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4793FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Start Organization Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Maybe Later',
                        style: TextStyle(
                          color: Colors.white.withAlpha(100),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Close button
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white.withAlpha(100)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
