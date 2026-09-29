class Attachment {
  final String id;
  final String vaultItemId;
  final String userId;
  final String filePath;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.vaultItemId,
    required this.userId,
    required this.filePath,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json["id"] as String,
      vaultItemId: json["vault_item_id"] as String,
      userId: json["user_id"] as String,
      filePath: json["file_path"] as String,
      fileName: json["file_name"] as String,
      mimeType: json["mime_type"] as String,
      fileSize: json["file_size"] as int,
      createdAt: DateTime.parse(json["created_at"] as String),
    );
  }

  bool get isImage => mimeType.startsWith("image/");
}
