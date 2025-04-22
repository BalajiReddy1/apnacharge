// splash_screen.dart

import 'dart:async';
import 'package:ev_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Make sure you have a HomeScreen widget created in home_screen.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 2 seconds before navigating to the HomeScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
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
