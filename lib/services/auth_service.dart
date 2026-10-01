import "dart:async";
import "package:supabase_flutter/supabase_flutter.dart";
import "supabase_service.dart";

class AuthService {
  final SupabaseClient _client = SupabaseService.client;
  static const _timeout = Duration(seconds: 15);

  Future<AuthResponse> signUp({required String email, required String password, required String fullName}) async {
    return await _client.auth.signUp(email: email, password: password, data: {"full_name": fullName}).timeout(
      _timeout,
      onTimeout: () => throw Exception("Connexion lente, verifiez votre reseau et reessayez"),
    );
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password).timeout(
      _timeout,
      onTimeout: () => throw Exception("Connexion lente, verifiez votre reseau et reessayez"),
    );
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: "io.supabase.lifevault://login-callback",
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email).timeout(_timeout);
  }

  Future<void> deleteAccount() async {
    final response = await _client.functions.invoke("delete-account");
    if (response.status != 200) {
      throw Exception("Erreur lors de la suppression du compte");
    }
    await _client.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}