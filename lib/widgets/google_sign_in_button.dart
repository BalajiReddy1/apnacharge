import 'package:ev_app/services/google_auth_service.dart';
import 'package:flutter/material.dart';

/// "Continue with Google" button that runs the native Google Sign-In flow and
/// calls [onSignedIn] on success. Handles its own loading and error state, and
/// silently ignores user cancellation.
class GoogleSignInButton extends StatefulWidget {
  final VoidCallback onSignedIn;

  const GoogleSignInButton({super.key, required this.onSignedIn});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleAuthService _service = GoogleAuthService();
  bool _loading = false;

  Future<void> _handlePressed() async {
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final signedIn = await _service.signIn();
      if (signedIn && mounted) {
        widget.onSignedIn();
      }
    } on GoogleAuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Google Sign-In failed.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _handlePressed,
      icon: _loading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
      label: const Text('Continue with Google'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
