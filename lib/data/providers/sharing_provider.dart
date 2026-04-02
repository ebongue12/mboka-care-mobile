import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/follower_model.dart';
import 'auth_provider.dart';

class SharingState {
  final List<FollowerModel> followers;
  final List<ConsultationLogModel> consultations;
  final bool isLoading;
  final String? error;

  SharingState({
    this.followers = const [],
    this.consultations = const [],
    this.isLoading = false,
    this.error,
  });

  SharingState copyWith({
    List<FollowerModel>? followers,
    List<ConsultationLogModel>? consultations,
    bool? isLoading,
    String? error,
  }) => SharingState(
    followers: followers ?? this.followers,
    consultations: consultations ?? this.consultations,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class SharingNotifier extends StateNotifier<SharingState> {
  final ApiClient _api;
  SharingNotifier(this._api) : super(SharingState());

  Future<void> loadFollowers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final r = await _api.getFollowers();
      final data = r.data;
      List<FollowerModel> list = [];
      if (data is List) {
        list = data
            .map((e) => FollowerModel.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      } else if (data is Map && data['results'] is List) {
        list = (data['results'] as List)
            .map((e) => FollowerModel.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      }
      state = state.copyWith(followers: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Impossible de charger les suiveurs');
    }
  }

  Future<bool> addFollower(Map<String, dynamic> data) async {
    if (state.followers.length >= 3) return false;
    try {
      await _api.addFollower(data);
      await loadFollowers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeFollower(String id) async {
    try {
      await _api.removeFollower(id);
      state = state.copyWith(
          followers: state.followers.where((f) => f.id != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadConsultations() async {
    state = state.copyWith(isLoading: true);
    try {
      final r = await _api.getConsultationHistory();
      final data = r.data;
      List<ConsultationLogModel> list = [];
      if (data is List) {
        list = data
            .map((e) => ConsultationLogModel.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      } else if (data is Map && data['results'] is List) {
        list = (data['results'] as List)
            .map((e) => ConsultationLogModel.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      }
      state = state.copyWith(consultations: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final sharingProvider =
    StateNotifierProvider<SharingNotifier, SharingState>(
  (ref) => SharingNotifier(ref.watch(apiClientProvider)),
);
