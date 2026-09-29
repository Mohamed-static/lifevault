class VaultItem {
  final String id;
  final String userId;
  final String? categoryId;
  final String title;
  final String? description;
  final DateTime? expirationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  VaultItem({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.title,
    this.description,
    this.expirationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    return VaultItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'category_id': categoryId,
      'title': title,
      'description': description,
      'expiration_date': expirationDate?.toIso8601String().split('T').first,
    };
  }

  int? get daysUntilExpiration {
    if (expirationDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return expirationDate!.difference(today).inDays;
  }

  bool get isExpiringSoon {
    final days = daysUntilExpiration;
    return days != null && days >= 0 && days <= 30;
  }

  bool get isExpired {
    final days = daysUntilExpiration;
    return days != null && days < 0;
  }
}
