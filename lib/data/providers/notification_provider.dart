import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import 'auth_provider.dart';

class NotificationState {
  final int unreadCount;
  NotificationState({this.unreadCount = 0});
  NotificationState copyWith({int? unreadCount}) => NotificationState(unreadCount: unreadCount ?? this.unreadCount);
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final ApiClient _api;
  NotificationNotifier(this._api) : super(NotificationState());

  Future<void> loadNotifications() async {
    try {
      final r = await _api.getNotifications();
      if (r.statusCode == 200) {
        final data = r.data is List ? r.data as List : r.data['results'] as List;
        state = state.copyWith(unreadCount: data.where((n) => n['read'] == false).length);
      }
    } catch (_) {}
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => NotificationNotifier(ref.watch(apiClientProvider)));
