import 'package:ev_app/const/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Native Google Sign-In wired into Supabase.
///
/// Uses the recommended mobile flow: obtain a Google ID token natively via the
/// `google_sign_in` plugin, then exchange it with Supabase through
/// `signInWithIdToken`. This avoids a browser round-trip and keeps the user in
/// the app.
///
/// Requires `GOOGLE_WEB_CLIENT_ID` (and `GOOGLE_IOS_CLIENT_ID` on iOS) in the
/// environment, the Google provider enabled in Supabase, and the platform
/// OAuth setup described in the README.
class GoogleAuthService {
  /// Starts the Google Sign-In flow.
  ///
  /// Returns `true` on success, `false` if the user cancelled. Throws a
  /// [GoogleAuthException] if sign-in is misconfigured or fails.
  Future<bool> signIn() async {
    final webClientId = Env.googleWebClientId;
    final iosClientId = Env.googleIosClientId;

    if (webClientId.isEmpty) {
      throw GoogleAuthException('Google Sign-In is not configured.');
    }

    final googleSignIn = GoogleSignIn(
      clientId: iosClientId.isEmpty ? null : iosClientId,
      serverClientId: webClientId,
    );

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // The user dismissed the account picker.
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw GoogleAuthException('No ID token returned by Google.');
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return true;
    } on GoogleAuthException {
      rethrow;
    } catch (e) {
      throw GoogleAuthException('Google Sign-In failed. Please try again.');
    }
  }
}

class GoogleAuthException implements Exception {
  final String message;
  GoogleAuthException(this.message);

  @override
  String toString() => message;
}
