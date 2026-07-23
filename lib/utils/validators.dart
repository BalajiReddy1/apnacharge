import 'package:supabase_flutter/supabase_flutter.dart';

/// Input validation and safe error messaging for the auth flows.
///
/// Keeping this logic in one place means login and registration validate
/// identically, and raw backend errors are never shown to end users (which
/// can leak implementation details).
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// Returns an error message for an invalid email, or null if valid.
  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  /// Returns an error message for a weak/empty password, or null if valid.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    final hasLetter = v.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = v.contains(RegExp(r'\d'));
    if (!hasLetter || !hasDigit) {
      return 'Use at least one letter and one number';
    }
    return null;
  }

  /// Returns an error message for an empty name, or null if valid.
  static String? name(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Enter your full name';
    return null;
  }

  /// Maps a caught auth error to a friendly, non-leaky message.
  static String authError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login') ||
          msg.contains('invalid credentials')) {
        return 'Incorrect email or password';
      }
      if (msg.contains('already registered') ||
          msg.contains('already exists')) {
        return 'An account with this email already exists';
      }
      if (msg.contains('email not confirmed')) {
        return 'Please confirm your email before signing in';
      }
      if (msg.contains('rate limit') || msg.contains('too many')) {
        return 'Too many attempts. Please try again later';
      }
      // Fall back to Supabase's message for other auth cases — it is
      // user-facing by design and doesn't expose internals.
      return error.message;
    }
    // Anything else (network, parsing, etc.) stays generic.
    return 'Something went wrong. Please check your connection and try again';
  }
}
