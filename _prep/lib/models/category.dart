class Category {
  final String id;
  final String userId;
  final String name;
  final String? icon;
  final bool isDefault;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    this.icon,
    this.isDefault = false,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'icon': icon,
      'is_default': isDefault,
    };
  }
}
