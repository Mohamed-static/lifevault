import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Gestion des fichiers dans le bucket prive 'vault-files'.
/// Chaque fichier est range sous {user_id}/{filename}, ce qui correspond
/// exactement aux policies RLS du bucket : impossible d'acceder au
/// dossier d'un autre utilisateur.
class StorageService {
  final SupabaseClient _client = SupabaseService.client;
  static const String _bucket = 'vault-files';
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 Mo
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'application/pdf',
  ];

  Future<String> uploadFile({
    required File file,
    required String fileName,
    required String mimeType,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Utilisateur non authentifie');

    final fileSize = await file.length();
    if (fileSize > maxFileSizeBytes) {
      throw Exception('Fichier trop volumineux (max 10 Mo)');
    }

    if (!allowedMimeTypes.contains(mimeType)) {
      throw Exception('Type de fichier non autorise: \');
    }

    final path = '\/\_\';

    await _client.storage.from(_bucket).upload(
          path,
          file,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );

    return path;
  }

  Future<String> getSignedUrl(String path, {int expiresInSeconds = 3600}) async {
    return await _client.storage.from(_bucket).createSignedUrl(
          path,
          expiresInSeconds,
        );
  }

  Future<void> deleteFile(String path) async {
    await _client.storage.from(_bucket).remove([path]);
  }
}
