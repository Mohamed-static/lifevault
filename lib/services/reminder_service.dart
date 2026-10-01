import "package:supabase_flutter/supabase_flutter.dart";
import "../models/reminder.dart";
import "../models/vault_item.dart";
import "supabase_service.dart";
import "notification_service.dart";

class ReminderService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Reminder>> getReminders() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception("Utilisateur non authentifie");
    final data = await _client.from("reminders").select().eq("user_id", userId).order("scheduled_date", ascending: true);
    return (data as List).map((e) => Reminder.fromJson(e)).toList();
  }

  Future<List<Reminder>> getUpcomingReminders() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception("Utilisateur non authentifie");
    final today = DateTime.now().toIso8601String().split("T").first;
    final data = await _client.from("reminders").select().eq("user_id", userId).eq("is_sent", false).gte("scheduled_date", today).order("scheduled_date", ascending: true);
    return (data as List).map((e) => Reminder.fromJson(e)).toList();
  }

  Future<Reminder> createReminder({required String vaultItemId, required int daysBefore, required DateTime expirationDate}) async {
    final scheduledDate = expirationDate.subtract(Duration(days: daysBefore));
    final data = await _client.from("reminders").insert({
      "vault_item_id": vaultItemId,
      "days_before": daysBefore,
      "scheduled_date": scheduledDate.toIso8601String().split("T").first,
    }).select().single();
    return Reminder.fromJson(data);
  }

  Future<void> createDefaultReminders({required String vaultItemId, required DateTime expirationDate, VaultItem? item}) async {
    final reminder30 = await createReminder(vaultItemId: vaultItemId, daysBefore: 30, expirationDate: expirationDate);
    final reminder7 = await createReminder(vaultItemId: vaultItemId, daysBefore: 7, expirationDate: expirationDate);
    if (item != null) {
      await NotificationService.scheduleReminderNotification(reminder: reminder30, item: item);
      await NotificationService.scheduleReminderNotification(reminder: reminder7, item: item);
    }
  }

  Future<void> markAsSent(String reminderId) async {
    await _client.from("reminders").update({"is_sent": true}).eq("id", reminderId);
  }

  Future<void> deleteReminder(String reminderId) async {
    await _client.from("reminders").delete().eq("id", reminderId);
    await NotificationService.cancelNotification(reminderId);
  }

  Future<void> deleteRemindersForItem(String vaultItemId) async {
    final existing = await _client.from("reminders").select("id").eq("vault_item_id", vaultItemId);
    for (final row in (existing as List)) {
      await NotificationService.cancelNotification(row["id"]);
    }
    await _client.from("reminders").delete().eq("vault_item_id", vaultItemId);
  }
}