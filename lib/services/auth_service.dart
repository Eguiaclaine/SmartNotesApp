import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  SupabaseClient? get _client => SupabaseService.client;

  Stream<AuthState> get authStateChanges {
    final client = _client;
    if (client == null) {
      return const Stream.empty();
    }
    return client.auth.onAuthStateChange;
  }

  User? get currentUser => _client?.auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase is not configured for this build.');
    }
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase is not configured for this build.');
    }
    return client.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': fullName,
        'full_name': fullName,
      },
    );
  }

  Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      await client.auth.signOut();
    }
  }
}
