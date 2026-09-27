class Reminder {
  final String id;
  final String vaultItemId;
  final String userId;
  final int daysBefore;
  final bool isSent;
  final DateTime? scheduledDate;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.vaultItemId,
    required this.userId,
    required this.daysBefore,
    this.isSent = false,
    this.scheduledDate,
    required this.createdAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      vaultItemId: json['vault_item_id'] as String,
      userId: json['user_id'] as String,
      daysBefore: json['days_before'] as int,
      isSent: json['is_sent'] as bool? ?? false,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson(String vaultItemId) {
    return {
      'vault_item_id': vaultItemId,
      'days_before': daysBefore,
      'scheduled_date': scheduledDate?.toIso8601String().split('T').first,
    };
  }
}
