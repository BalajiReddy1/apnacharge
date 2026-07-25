// splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Brief splash, then route based on whether a session already exists.
    // A logged-in user skips the login screen entirely.
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      Navigator.pushReplacementNamed(
        context,
        session != null ? '/home' : '/login',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Customize the background color as needed.
      body: Center(
        child: Image.asset(
          'assets/icons/new_logo.jpg', // Make sure this path is correct and declared in pubspec.yaml.
          fit: BoxFit.contain,
          width: 300, // Adjust the dimensions if needed.
          height: 300,
        ),
      ),
    );
  }
}
