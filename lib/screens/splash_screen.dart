import 'dart:async';
import 'package:flutter/material.dart';
import 'package:paydiddy/providers/user_provider.dart';
import 'package:paydiddy/screens/admin/admin_home_screen.dart';
import 'package:paydiddy/screens/auth/login_screen.dart';
import 'package:paydiddy/screens/customer/customer_home_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // Simulate loading time for splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Initialize user from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initUser();

    if (!mounted) return;

    // Navigate based on auth state and role
    if (userProvider.isLoggedIn) {
      if (userProvider.isAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/paydiddy-logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if logo.png isn't available yet
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'PayDiddy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // App Name
            const Text(
              'PayDiddy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Tagline
            const Text(
              'Top Up Game Lebih Mudah',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}