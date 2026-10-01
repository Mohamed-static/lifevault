import "dart:io";
import "package:supabase_flutter/supabase_flutter.dart";
import "../models/user_profile.dart";
import "supabase_service.dart";

class ProfileService {
  final SupabaseClient _client = SupabaseService.client;
  static const String _bucket = "avatars";

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

  Future<String> uploadAvatar(File file) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception("Utilisateur non authentifie");

    final fileSize = await file.length();
    if (fileSize > 5 * 1024 * 1024) {
      throw Exception("Image trop volumineuse (max 5 Mo)");
    }

    final path = "$userId/avatar.jpg";
    await _client.storage.from(_bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(contentType: "image/jpeg", upsert: true),
        );

    final publicUrl = _client.storage.from(_bucket).getPublicUrl(path);
    final cacheBustedUrl = "$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}";

    await _client.from("profiles").update({"avatar_url": cacheBustedUrl}).eq("id", userId);
    return cacheBustedUrl;
  }
}