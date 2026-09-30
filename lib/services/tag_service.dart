import "package:supabase_flutter/supabase_flutter.dart";
import "../models/tag.dart";
import "supabase_service.dart";

class TagService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Tag>> getTags() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception("Utilisateur non authentifie");
    final data = await _client.from("tags").select().eq("user_id", userId).order("name");
    return (data as List).map((e) => Tag.fromJson(e)).toList();
  }

  Future<Tag> createTag(String name) async {
    final data = await _client.from("tags").insert({"name": name.trim()}).select().single();
    return Tag.fromJson(data);
  }

  Future<void> deleteTag(String id) async {
    await _client.from("tags").delete().eq("id", id);
  }

  Future<List<Tag>> getTagsForItem(String vaultItemId) async {
    final data = await _client.from("vault_item_tags").select("tag_id, tags(*)").eq("vault_item_id", vaultItemId);
    return (data as List).map((e) => Tag.fromJson(e["tags"])).toList();
  }

  Future<void> attachTagToItem({required String vaultItemId, required String tagId}) async {
    await _client.from("vault_item_tags").insert({"vault_item_id": vaultItemId, "tag_id": tagId});
  }

  Future<void> detachTagFromItem({required String vaultItemId, required String tagId}) async {
    await _client.from("vault_item_tags").delete().eq("vault_item_id", vaultItemId).eq("tag_id", tagId);
  }

  Future<void> setTagsForItem({required String vaultItemId, required List<String> tagIds}) async {
    await _client.from("vault_item_tags").delete().eq("vault_item_id", vaultItemId);
    for (final tagId in tagIds) {
      await attachTagToItem(vaultItemId: vaultItemId, tagId: tagId);
    }
  }
}