import 'package:ev_app/const/colors.dart';
import 'package:ev_app/screens/legal_document_screen.dart';
import 'package:ev_app/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AccountService _accountService = AccountService();
  String _version = '';
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      // Version display is best-effort.
    }
  }

  void _openLegal(String title, String assetPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LegalDocumentScreen(title: title, assetPath: assetPath),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account and all associated data, '
          'including your community reports. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    setState(() => _deleting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await _accountService.deleteAccount();
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete your account right now. Please try again or '
            'contact support.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);
    await _accountService.signOut();
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.arimo(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          _sectionHeader('Account'),
          if (_accountService.currentEmail != null)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Signed in as'),
              subtitle: Text(_accountService.currentEmail!),
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: _signOut,
          ),

          const Divider(),
          _sectionHeader('Legal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                _openLegal('Privacy Policy', 'PRIVACY_POLICY.md'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                _openLegal('Terms of Service', 'TERMS_OF_SERVICE.md'),
          ),

          const Divider(),
          _sectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App version'),
            subtitle: Text(_version.isEmpty ? '—' : _version),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Open-source licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Apna Charge',
              applicationVersion: _version,
            ),
          ),

          const Divider(),
          _sectionHeader('Danger zone'),
          ListTile(
            leading: _deleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete account',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text(
                'Permanently delete your account and all your data'),
            onTap: _deleting ? null : _confirmDeleteAccount,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.medgreen,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
