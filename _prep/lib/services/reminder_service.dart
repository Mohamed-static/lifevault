import "package:supabase_flutter/supabase_flutter.dart";
import "../models/reminder.dart";
import "supabase_service.dart";

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
    final data = await _client.from("reminders").insert({"vault_item_id": vaultItemId, "days_before": daysBefore, "scheduled_date": scheduledDate.toIso8601String().split("T").first}).select().single();
    return Reminder.fromJson(data);
  }

  Future<void> createDefaultReminders({required String vaultItemId, required DateTime expirationDate}) async {
    await createReminder(vaultItemId: vaultItemId, daysBefore: 30, expirationDate: expirationDate);
    await createReminder(vaultItemId: vaultItemId, daysBefore: 7, expirationDate: expirationDate);
  }

  Future<void> markAsSent(String reminderId) async {
    await _client.from("reminders").update({"is_sent": true}).eq("id", reminderId);
  }

  Future<void> deleteReminder(String reminderId) async {
    await _client.from("reminders").delete().eq("id", reminderId);
  }

  Future<void> deleteRemindersForItem(String vaultItemId) async {
    await _client.from("reminders").delete().eq("vault_item_id", vaultItemId);
  }
}
