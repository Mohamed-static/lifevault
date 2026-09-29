import "package:supabase_flutter/supabase_flutter.dart";
import "../models/attachment.dart";
import "supabase_service.dart";

class AttachmentService {
  final SupabaseClient _client = SupabaseService.client;

  Future<Attachment?> getAttachmentForItem(String vaultItemId) async {
    final data = await _client.from("attachments").select().eq("vault_item_id", vaultItemId).limit(1);
    final list = data as List;
    if (list.isEmpty) return null;
    return Attachment.fromJson(list.first);
  }

  Future<Attachment> createAttachment({required String vaultItemId, required String filePath, required String fileName, required String mimeType, required int fileSize}) async {
    final data = await _client.from("attachments").insert({
      "vault_item_id": vaultItemId,
      "file_path": filePath,
      "file_name": fileName,
      "mime_type": mimeType,
      "file_size": fileSize,
    }).select().single();
    return Attachment.fromJson(data);
  }

  Future<void> deleteAttachment(String id) async {
    await _client.from("attachments").delete().eq("id", id);
  }
}
