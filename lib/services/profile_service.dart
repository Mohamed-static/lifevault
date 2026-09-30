import "package:supabase_flutter/supabase_flutter.dart";
import "../models/user_profile.dart";
import "supabase_service.dart";

class ProfileService {
  final SupabaseClient _client = SupabaseService.client;

  Future<UserProfile> getProfile() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception("Utilisateur non authentifie");
    final data = await _client.from("profiles").select().eq("id", userId).single();
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateProfile({required String fullName}) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception("Utilisateur non authentifie");
    final data = await _client.from("profiles").update({"full_name": fullName}).eq("id", userId).select().single();
    return UserProfile.fromJson(data);
  }
}