import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/services/notification_service.dart';
import '../models/reminder_model.dart';
import 'auth_provider.dart';

class ReminderState {
  final List<ReminderModel> reminders;
  final bool isLoading;
  ReminderState({this.reminders = const [], this.isLoading = false});
  ReminderState copyWith({List<ReminderModel>? reminders, bool? isLoading}) =>
      ReminderState(
          reminders: reminders ?? this.reminders,
          isLoading: isLoading ?? this.isLoading);
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ApiClient _api;
  ReminderNotifier(this._api) : super(ReminderState());

  Future<void> loadReminders() async {
    try {
      state = state.copyWith(isLoading: true);
      final r = await _api.getReminders();
      if (r.statusCode == 200) {
        final data =
            r.data is List ? r.data as List : r.data['results'] as List;
        final reminders =
            data.map((e) => ReminderModel.fromJson(e)).toList();
        state = state.copyWith(reminders: reminders, isLoading: false);

        // Programmer une alarme pour chaque rappel actif
        await NotificationService.cancelAll();
        for (final reminder in reminders) {
          if (reminder.isActive) {
            await NotificationService.scheduleReminder(reminder);
          }
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> createReminder(Map<String, dynamic> data) async {
    try {
      final r = await _api.createReminder(data);
      if (r.statusCode == 201) {
        final reminder = ReminderModel.fromJson(r.data);
        state = state.copyWith(reminders: [...state.reminders, reminder]);
        // Programmer l'alarme immédiatement
        await NotificationService.scheduleReminder(reminder);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Active ou désactive les alarmes d'un rappel
  Future<void> toggleReminder(ReminderModel reminder) async {
    if (reminder.isActive) {
      await NotificationService.cancelReminder(
          reminder.id, reminder.timeSlots.length);
    } else {
      await NotificationService.scheduleReminder(reminder);
    }
    // Mettre à jour localement (la synchro API peut être ajoutée plus tard)
    final updated = state.reminders.map((r) {
      if (r.id == reminder.id) return r.copyWith(isActive: !r.isActive);
      return r;
    }).toList();
    state = state.copyWith(reminders: updated);
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, ReminderState>(
        (ref) => ReminderNotifier(ref.watch(apiClientProvider)));
