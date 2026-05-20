import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Offline local reminders for khata / udhar collections.
abstract final class ReminderService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static bool _ready = false;

  static int notificationIdFor(String invoiceId) => invoiceId.hashCode & 0x7fffffff;

  static Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    _ready = true;
  }

  static Future<void> cancelForInvoice(String invoiceId) async {
    await _plugin.cancel(notificationIdFor(invoiceId));
  }

  static Future<void> scheduleInvoiceReminder({
    required String invoiceId,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (!_ready) await init();
    if (!when.isAfter(DateTime.now())) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'khata_reminders',
        'Khata reminders',
        channelDescription: 'Payment reminders for udhar / khata invoices',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      notificationIdFor(invoiceId),
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: invoiceId,
    );
  }
}
