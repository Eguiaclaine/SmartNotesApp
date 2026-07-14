import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

class SupabaseService {
  static bool _initialized = false;

  static bool get isReady => _initialized;

  static SupabaseClient? get client =>
      _initialized ? Supabase.instance.client : null;

  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      if (!Env.isConfigured) return false;

      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
      _initialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }
}
