import 'package:ev_app/const/env.dart';
import 'package:ev_app/screens/home_screen.dart';
import 'package:ev_app/screens/login_screen.dart';
import 'package:ev_app/screens/registration_screen.dart';
import 'package:ev_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Load secrets from the git-ignored `.env` file (see `.env.example`).
  /// Tolerant of a missing file so the app still boots during setup.
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // No .env bundled — Env.* getters will return empty strings.
  }

  /// Initialize Supabase with credentials from the environment.
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

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
        '/home': (context) => const HomePage(),
      },
    );
  }
}
