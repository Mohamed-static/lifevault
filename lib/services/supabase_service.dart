import 'package:supabase_flutter/supabase_flutter.dart';

/// Point d'acces unique au client Supabase.
/// Jamais de service_role key ici : uniquement la cle publique (anon/publishable),
/// protegee par les policies RLS definies en base.
class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => client.auth.currentUser?.id;
  static bool get isLoggedIn => client.auth.currentUser != null;
}
