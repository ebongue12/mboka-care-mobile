import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../data/models/reminder_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Canal dédié aux alarmes médicaments (son système d'alarme)
  static const _channelId = 'mboka_reminders_alarm';
  static const _channelName = 'Rappels Médicaments';

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    // Créer le canal avec son d'alarme système
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Sonnerie alarme pour les rappels de médicaments',
      importance: Importance.max,
      playSound: true,
      sound: UriAndroidNotificationSound(
        'content://settings/system/alarm_alert',
      ),
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Programme les alarmes pour un rappel (une alarme par créneau horaire)
  static Future<void> scheduleReminder(ReminderModel reminder) async {
    if (!reminder.isActive) return;

    for (int i = 0; i < reminder.timeSlots.length; i++) {
      final timeStr = reminder.timeSlots[i]; // ex: "08:30"
      final parts = timeStr.split(':');
      if (parts.length < 2) continue;

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final notifId = _buildNotifId(reminder.id, i);

      final body = reminder.medicationName != null
          ? 'Prenez ${reminder.medicationName} maintenant'
          : 'Heure de votre rappel médicament';

      await _plugin.zonedSchedule(
        notifId,
        '💊 ${reminder.title}',
        body,
        _nextInstanceOfTime(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Sonnerie alarme médicaments',
            importance: Importance.max,
            priority: Priority.high,
            sound: const UriAndroidNotificationSound(
              'content://settings/system/alarm_alert',
            ),
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            icon: '@mipmap/ic_launcher',
            ticker: 'Rappel médicament',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // Répéter chaque jour à la même heure si DAILY
        matchDateTimeComponents: reminder.frequency == 'DAILY'
            ? DateTimeComponents.time
            : null,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Annule toutes les alarmes d'un rappel
  static Future<void> cancelReminder(
      String reminderId, int slotCount) async {
    for (int i = 0; i < slotCount; i++) {
      await _plugin.cancel(_buildNotifId(reminderId, i));
    }
  }

  /// Annule toutes les alarmes
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Calcule le prochain déclenchement (aujourd'hui si l'heure n'est pas passée,
  /// sinon demain)
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now.add(const Duration(seconds: 5)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Génère un ID entier unique par combinaison reminderId + slotIndex
  static int _buildNotifId(String reminderId, int slotIndex) {
    return (reminderId.hashCode.abs() * 10 + slotIndex) % 2147483647;
  }
}
