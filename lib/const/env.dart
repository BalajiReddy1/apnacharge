import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized, type-safe access to runtime configuration.
///
/// All secrets live in a `.env` file at the project root (see `.env.example`)
/// and are loaded once in `main()` via `dotenv.load()`. Nothing sensitive is
/// hard-coded in source anymore, so the repository is safe to publish/push.
class Env {
  static String _get(String key) => dotenv.env[key] ?? '';

  /// Supabase project URL.
  static String get supabaseUrl => _get('SUPABASE_URL');

  /// Supabase anonymous (public) key.
  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY');

  /// Google Maps / Places / Directions API key (Android manifest is separate).
  static String get googleMapsApiKey => _get('GOOGLE_MAPS_API_KEY');

  /// Open Charge Map API key (free — register at openchargemap.org).
  static String get openChargeMapApiKey => _get('OPEN_CHARGE_MAP_API_KEY');

  /// Mapbox public access token (used once we migrate the map layer).
  static String get mapboxAccessToken => _get('MAPBOX_ACCESS_TOKEN');

  /// Google OAuth Web client ID — used as the Supabase server client ID for
  /// native Google Sign-In (required on both Android and iOS).
  static String get googleWebClientId => _get('GOOGLE_WEB_CLIENT_ID');

  /// Google OAuth iOS client ID — required for Google Sign-In on iOS only.
  static String get googleIosClientId => _get('GOOGLE_IOS_CLIENT_ID');
}
