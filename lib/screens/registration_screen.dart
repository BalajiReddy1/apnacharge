import 'package:ev_app/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _agreeTerms = false;
  bool _isLoading = false;
  String _errorMessage = '';

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Forgot Password tapped")),
    );
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Basic validation check.
    if (name.isEmpty || email.isEmpty || password.isEmpty || !_agreeTerms) {
      setState(() {
        _errorMessage =
            "Please fill all fields and agree to the Terms and Conditions.";
        _isLoading = false;
      });
      return;
    }

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      // If successful, navigate to the login screen.
      Navigator.pushReplacementNamed(context, '/login');
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
      // Wrap content in a SingleChildScrollView to support smaller screens.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top curved header with a title.
            ClipPath(
              clipper: TopClipper(),
              child: Container(
                height: 220,
                width: double.infinity,
                color: AppColors.medgreen,
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text(
                    'Create \nyour Account',
                    style: GoogleFonts.arima(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),

            // Registration form fields.
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(' Name',
                      style: GoogleFonts.arima(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                  // Name field.
                  SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: ' Enter name',
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
                  const SizedBox(height: 10),
                  // Email field.
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
                      hintText: ' Enter e-mail',
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
                  const SizedBox(height: 10),
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
                              color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                  // Password field with "Forgot?" link.
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
                  const SizedBox(height: 10),
                  // Terms and Conditions checkbox.
                  Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        activeColor: AppColors.medgreen,
                        value: _agreeTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreeTerms = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to the Terms and Conditions',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Bottom section: Use a fixed-height container with a Stack.
            Container(
              height: 240, // Fixed height for the bottom section.
              child: Stack(
                children: [
                  // Bottom curved design as the background.
                  Align(
                    alignment: Alignment.center,
                    child: ClipPath(
                      clipper: BottomClipper(),
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        color: AppColors.medgreen,
                      ),
                    ),
                  ),
                  // "Go" button and Sign-In row positioned above the bottom clipper.
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circular Go button.
                        Container(
                          height: 65,
                          width: 220,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkestbg,
                              padding: const EdgeInsets.all(20),
                            ),
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.arima(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // "Already have an account? Sign in" row.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.arima(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 70,
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate back to the login screen.
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Sign in',
                                style: GoogleFonts.arima(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        size.width / 2, size.height, size.width, size.height - 40);
    // Draw the line to top right.
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Custom clipper for the bottom curved design.
class BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Start at a point on the left.
    path.moveTo(0, 40);
    // Draw a curve from left to right.
    path.quadraticBezierTo(size.width / 2, 0, size.width, 40);
    // Complete the rectangle for the bottom clip.
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
