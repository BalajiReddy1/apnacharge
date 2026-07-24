import 'package:ev_app/services/favorites_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Account-level operations, including the account deletion required by the
/// DPDP Act, GDPR, and Google Play's User Data policy.
class AccountService {
  final SupabaseClient _client;

  AccountService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  String? get currentEmail => _client.auth.currentUser?.email;

  bool get isSignedIn => _client.auth.currentUser != null;

  /// Permanently delete the signed-in user's account and all associated data.
  ///
  /// The privileged `auth.admin.deleteUser` call cannot be made from the
  /// client, so this invokes the `delete-account` Supabase Edge Function
  /// (which runs with the service-role key). Deleting the auth user cascades
  /// to the user's `station_reports` rows via the foreign key. Local favorites
  /// are cleared here, and the session is ended.
  ///
  /// Throws if the user isn't signed in or the deletion fails.
  Future<void> deleteAccount() async {
    if (!isSignedIn) {
      throw StateError('You must be signed in to delete your account.');
    }

    final response = await _client.functions.invoke('delete-account');
    if (response.status != 200) {
      throw Exception('Account deletion failed (status ${response.status}).');
    }

    await FavoritesManager.clear();
    await _client.auth.signOut();
  }

  Future<void> signOut() => _client.auth.signOut();
}
