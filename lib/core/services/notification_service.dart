import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../app/constants.dart';
import '../../core/storage/local_storage.dart';
import '../../data/models/reminder_model.dart';

// ─── Instance partagée (accessible par le callback background) ─────────────

final _plugin = FlutterLocalNotificationsPlugin();

// ─── Callback arrière-plan — doit être une fonction top-level ──────────────

/// Appelé quand l'utilisateur interagit avec une notification alors que
/// l'application est fermée ou en arrière-plan.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) async {
  // Initialiser SharedPreferences dans l'isolat background
  await LocalStorage.init();
  // Initialiser le plugin (sans callbacks pour éviter la récursion)
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await _plugin.initialize(const InitializationSettings(android: androidSettings));
  await _processConfirmationResponse(response);
}

// ─── Gestionnaire de réponse (foreground + background) ────────────────────

Future<void> _processConfirmationResponse(NotificationResponse response) async {
  final payload = response.payload ?? '';
  final parts = payload.split('|');
  if (parts.length < 3) return;

  final reminderId = parts[0];
  final scheduledTime = parts[1]; // "HH:MM"
  final slotIndex = int.tryParse(parts[2]) ?? 0;
  final isTimeout = parts.length > 3 && parts[3] == 'TIMEOUT';

  // Déterminer le statut
  String? confirmStatus;
  if (response.actionId == 'ACTION_TAKEN') {
    confirmStatus = 'TAKEN';
  } else if (response.actionId == 'ACTION_SKIPPED') {
    confirmStatus = 'SKIPPED';
  } else if (isTimeout) {
    confirmStatus = 'MISSED';
  }

  if (confirmStatus == null) return;

  // Annuler la notification de timeout si l'utilisateur a répondu à temps
  if (confirmStatus != 'MISSED') {
    await _plugin.cancel(_timeoutId(reminderId, slotIndex));
    // Annuler aussi la confirmation (si encore visible)
    await _plugin.cancel(_confirmId(reminderId, slotIndex));
  }

  // Appel API backend
  try {
    final token = LocalStorage.getAccessToken();
    if (token == null) return;

    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Authorization': 'Bearer $token'},
    ));

    await dio.post('/reminders/confirm/', data: {
      'reminder_id': reminderId,
      'scheduled_time': scheduledTime,
      'status': confirmStatus,
    });
  } catch (_) {
    // Silencieux — l'app synchro au prochain démarrage
  }
}

// ─── Service principal ────────────────────────────────────────────────────

class NotificationService {
  static bool _initialized = false;

  static const _alarmChannelId = 'mboka_reminders_alarm';
  static const _alarmChannelName = 'Rappels Médicaments';

  static const _confirmChannelId = 'mboka_confirmation';
  static const _confirmChannelName = 'Confirmation de prise';

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _processConfirmationResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
    );

    // Canal alarme (son système)
    const alarmChannel = AndroidNotificationChannel(
      _alarmChannelId,
      _alarmChannelName,
      description: 'Sonnerie alarme pour les rappels de médicaments',
      importance: Importance.max,
      playSound: true,
      sound: UriAndroidNotificationSound('content://settings/system/alarm_alert'),
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    // Canal confirmation (boutons OUI / NON)
    const confirmChannel = AndroidNotificationChannel(
      _confirmChannelId,
      _confirmChannelName,
      description: 'Demande de confirmation de prise de médicament',
      importance: Importance.high,
      enableVibration: true,
      showBadge: true,
    );

    final impl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await impl?.createNotificationChannel(alarmChannel);
    await impl?.createNotificationChannel(confirmChannel);

    _initialized = true;
  }

  /// Programme l'alarme principale + la confirmation à T+2min + le timeout à T+12min.
  static Future<void> scheduleReminder(ReminderModel reminder) async {
    if (!reminder.isActive) return;

    for (int i = 0; i < reminder.timeSlots.length; i++) {
      final timeStr = reminder.timeSlots[i]; // "HH:MM"
      final parts = timeStr.split(':');
      if (parts.length < 2) continue;

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final alarmTime = _nextInstanceOfTime(hour, minute);
      final medLabel = reminder.medicationName ?? reminder.title;

      // Payload commun : reminderId|HH:MM|slotIndex
      final payload = '${reminder.id}|$timeStr|$i';

      // ── 1. Alarme principale ────────────────────────────────────────────
      await _plugin.zonedSchedule(
        _alarmId(reminder.id, i),
        '💊 ${reminder.title}',
        reminder.medicationName != null
            ? 'Prenez ${reminder.medicationName} maintenant'
            : 'Heure de votre rappel médicament',
        alarmTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _alarmChannelId, _alarmChannelName,
            importance: Importance.max,
            priority: Priority.high,
            sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            icon: '@mipmap/ic_launcher',
            ticker: 'Rappel médicament',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            reminder.frequency == 'DAILY' ? DateTimeComponents.time : null,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // ── 2. Confirmation à T+2min (avec boutons OUI / NON) ───────────────
      await _plugin.zonedSchedule(
        _confirmId(reminder.id, i),
        '❓ Avez-vous pris $medLabel ?',
        'Confirmez votre prise pour informer vos proches.',
        alarmTime.add(const Duration(minutes: 2)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _confirmChannelId, _confirmChannelName,
            importance: Importance.high,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction(
                'ACTION_TAKEN',
                '✅  OUI, je l\'ai pris',
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                'ACTION_SKIPPED',
                '❌  NON, pas encore',
                cancelNotification: true,
              ),
            ],
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            reminder.frequency == 'DAILY' ? DateTimeComponents.time : null,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      // ── 3. Timeout à T+12min (si aucune réponse) ────────────────────────
      await _plugin.zonedSchedule(
        _timeoutId(reminder.id, i),
        '⚠️ Aucune réponse reçue',
        '$medLabel prévu à $timeStr — vos proches seront informés.',
        alarmTime.add(const Duration(minutes: 12)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _confirmChannelId, _confirmChannelName,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            reminder.frequency == 'DAILY' ? DateTimeComponents.time : null,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$payload|TIMEOUT', // flag pour distinguer du timeout
      );
    }
  }

  /// Annule toutes les notifications liées à un rappel.
  static Future<void> cancelReminder(String reminderId, int slotCount) async {
    for (int i = 0; i < slotCount; i++) {
      await _plugin.cancel(_alarmId(reminderId, i));
      await _plugin.cancel(_confirmId(reminderId, i));   // top-level
      await _plugin.cancel(_timeoutId(reminderId, i));   // top-level
    }
  }

  static Future<void> cancelAll() async => _plugin.cancelAll();

  // ─── Helpers privés ──────────────────────────────────────────────────────

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now.add(const Duration(seconds: 5)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static int _alarmId(String reminderId, int slotIndex) =>
      (reminderId.hashCode.abs() * 10 + slotIndex) % 2000000;
}

// ─── Helpers top-level (partagés avec _processConfirmationResponse) ──────────

int _confirmId(String reminderId, int slotIndex) =>
    ((reminderId.hashCode.abs() * 10 + slotIndex) % 2000000 + 2000000) %
    2147483647;

int _timeoutId(String reminderId, int slotIndex) =>
    ((reminderId.hashCode.abs() * 10 + slotIndex) % 2000000 + 4000000) %
    2147483647;
