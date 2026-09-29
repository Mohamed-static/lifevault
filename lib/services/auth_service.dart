import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> deleteAccount() async {
    // La suppression reelle du compte (auth.users) necessite un appel
    // a une Edge Function Supabase avec la service_role key, cote serveur.
    // Ne jamais faire cet appel directement depuis l'app avec une cle admin.
    // -> A implementer en Phase 10 (Securite approfondie) via Edge Function.
    throw UnimplementedError(
      'La suppression de compte necessite une Edge Function serveur (Phase 10).',
    );
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
