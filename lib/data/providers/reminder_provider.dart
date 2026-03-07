import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/reminder_model.dart';
import 'auth_provider.dart';

class ReminderState {
  final List<ReminderModel> reminders;
  final bool isLoading;
  ReminderState({this.reminders = const [], this.isLoading = false});
  ReminderState copyWith({List<ReminderModel>? reminders, bool? isLoading}) =>
    ReminderState(reminders: reminders ?? this.reminders, isLoading: isLoading ?? this.isLoading);
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ApiClient _api;
  ReminderNotifier(this._api) : super(ReminderState());

  Future<void> loadReminders() async {
    try {
      state = state.copyWith(isLoading: true);
      final r = await _api.getReminders();
      if (r.statusCode == 200) {
        final data = r.data is List ? r.data as List : r.data['results'] as List;
        state = state.copyWith(reminders: data.map((e) => ReminderModel.fromJson(e)).toList(), isLoading: false);
      }
    } catch (e) { state = state.copyWith(isLoading: false); }
  }

  Future<bool> createReminder(Map<String, dynamic> data) async {
    try {
      final r = await _api.createReminder(data);
      if (r.statusCode == 201) {
        state = state.copyWith(reminders: [...state.reminders, ReminderModel.fromJson(r.data)]);
        return true;
      }
      return false;
    } catch (e) { return false; }
  }
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, ReminderState>((ref) => ReminderNotifier(ref.watch(apiClientProvider)));
