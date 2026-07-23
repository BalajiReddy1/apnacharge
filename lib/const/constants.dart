// Deprecated: configuration now lives in `.env` and is accessed via `Env`
// (see lib/const/env.dart). Kept only to avoid breaking stale imports.
//
// Use `Env.supabaseUrl` / `Env.supabaseAnonKey` instead of these constants.

import 'package:ev_app/const/env.dart';

@Deprecated('Use Env.supabaseUrl instead')
String get supabaseUrl => Env.supabaseUrl;

@Deprecated('Use Env.supabaseAnonKey instead')
String get supabaseAnonKey => Env.supabaseAnonKey;
