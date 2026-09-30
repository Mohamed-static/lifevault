import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:timezone/timezone.dart" as tz;
import "package:timezone/data/latest.dart" as tz_data;
import "../models/reminder.dart";
import "../models/vault_item.dart";

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    const iosSettings = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  static Future<void> scheduleReminderNotification({required Reminder reminder, required VaultItem item}) async {
    if (reminder.scheduledDate == null) return;
    final scheduledDate = tz.TZDateTime.from(
      DateTime(reminder.scheduledDate!.year, reminder.scheduledDate!.month, reminder.scheduledDate!.day, 9, 0),
      tz.local,
    );
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      "lifevault_reminders",
      "Rappels LifeVault",
      channelDescription: "Rappels d expiration de vos elements",
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final notificationId = reminder.id.hashCode;
    await _plugin.zonedSchedule(
      notificationId,
      "LifeVault",
      "\"${item.title}\" expire dans ${reminder.daysBefore} jours",
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(String reminderId) async {
    await _plugin.cancel(reminderId.hashCode);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}