import 'package:ev_app/const/constants.dart';
import 'package:ev_app/screens/home_screen.dart';
import 'package:ev_app/screens/login_screen.dart';
import 'package:ev_app/screens/registration_screen.dart';
import 'package:ev_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Supabase with your unique URL and anon key
  await Supabase.initialize(
      url: supabaseUrl, // Replace with your Supabase project URL.
      anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/home': (context) => const HomePage(), // Ensure HomeScreen is defined
      },
    );
  }
}
