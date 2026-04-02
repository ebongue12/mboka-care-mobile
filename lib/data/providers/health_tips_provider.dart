import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_tip_model.dart';
import '../../core/network/api_client.dart';
import 'auth_provider.dart'; // pour apiClientProvider

class HealthTipsState {
  final List<HealthTipModel> tips;
  final bool isLoading;
  final String? error;

  HealthTipsState({this.tips = const [], this.isLoading = false, this.error});

  HealthTipsState copyWith({List<HealthTipModel>? tips, bool? isLoading, String? error}) =>
      HealthTipsState(
        tips: tips ?? this.tips,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class HealthTipsNotifier extends StateNotifier<HealthTipsState> {
  final ApiClient _api;

  HealthTipsNotifier(this._api) : super(HealthTipsState());

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final r = await _api.getHealthTipsFeed();
      if (r.statusCode == 200) {
        final data = r.data is List ? r.data as List : (r.data['results'] ?? []) as List;
        state = state.copyWith(
          tips: data.map((e) => HealthTipModel.fromJson(Map<String, dynamic>.from(e))).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Erreur chargement');
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Vérifiez votre connexion');
    }
  }

  // ─── Staff : mes astuces ────────────────────────────────────────────────────

  Future<List<HealthTipModel>> loadMyTips() async {
    try {
      final r = await _api.getMyHealthTips();
      if (r.statusCode == 200) {
        final data = r.data is List ? r.data as List : (r.data['results'] ?? []) as List;
        return data.map((e) => HealthTipModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> publishTip(Map<String, dynamic> data) async {
    try {
      final r = await _api.publishHealthTip(data);
      return r.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTip(String id) async {
    try {
      final r = await _api.deleteHealthTip(id);
      return r.statusCode == 204 || r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> markTipViewed(String tipId) async {
    try {
      await _api.markTipViewed(tipId);
    } catch (_) {}
  }
}

final healthTipsProvider = StateNotifierProvider<HealthTipsNotifier, HealthTipsState>(
  (ref) => HealthTipsNotifier(ref.watch(apiClientProvider)),
);
