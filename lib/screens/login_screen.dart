import 'package:ev_app/const/colors.dart';
import 'package:ev_app/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  void _forgotPassword() {
    // Handle forgot password action (dummy for now)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Forgot Password tapped')),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Call Supabase to sign in with email and password.
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // On successful sign in, navigate to Home screen.
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(232, 255, 255, 255),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title for login screen
            ClipPath(
              clipper: TopClipper(),
              child: Container(
                height: 220,
                width: double.infinity,
                color: AppColors.medgreen,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Log into \nyour account',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.arima(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email TextField
                  Text(' E-mail',
                      style: GoogleFonts.arima(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: ' Enter email',
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white38,
                      hintStyle: GoogleFonts.arima(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password TextField with "Forgot?" link to the right.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(' Password',
                          style: GoogleFonts.arima(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _forgotPassword,
                        child: Text(
                          'Forgot?',
                          style: GoogleFonts.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: ' Enter password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white38,
                      hintStyle: GoogleFonts.arima(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  // "Remember me" Checkbox
                  Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        activeColor: AppColors.medgreen,
                        value: _rememberMe,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _rememberMe = newValue ?? false;
                          });
                        },
                      ),
                      Text("Remember me",
                          style: GoogleFonts.arimo(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.7,
                              color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 100),
            // "Go" Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70.0),
              child: Container(
                height: 65,
                width: 80,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.medgreen,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.arima(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Navigation link to Registration Screen
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: GoogleFonts.arima(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationScreen()),
                    );
                  },
                  child: Text('Sign up',
                      style: GoogleFonts.arima(
                          color: AppColors.medgreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.medgreen)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom clipper for the top curved design.
class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Draw a straight line from top left to near bottom left.
    path.lineTo(0, size.height - 40);
    // Create a smooth curve toward the middle and then to the right.
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 100);
    // Draw the line to top right.
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
