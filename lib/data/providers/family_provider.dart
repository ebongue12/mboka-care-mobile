import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/family_member_model.dart';
import 'auth_provider.dart';

class FamilyState {
  final List<FamilyMemberModel> members;
  final bool isLoading;
  final String? error;

  FamilyState({this.members = const [], this.isLoading = false, this.error});

  FamilyState copyWith({
    List<FamilyMemberModel>? members,
    bool? isLoading,
    String? error,
  }) => FamilyState(
    members: members ?? this.members,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class FamilyNotifier extends StateNotifier<FamilyState> {
  final ApiClient _api;
  FamilyNotifier(this._api) : super(FamilyState());

  Future<void> loadMembers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final r = await _api.getFamilyMembers();
      final data = r.data;
      List<FamilyMemberModel> list = [];
      if (data is List) {
        list = data
            .map((e) => FamilyMemberModel.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      } else if (data is Map && data['results'] is List) {
        list = (data['results'] as List)
            .map((e) => FamilyMemberModel.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      }
      state = state.copyWith(members: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(
          isLoading: false,
          error: 'Impossible de charger les membres');
    }
  }

  Future<bool> addMember(Map<String, dynamic> data) async {
    try {
      await _api.addFamilyMember(data);
      await loadMembers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMember(String id) async {
    try {
      await _api.deleteFamilyMember(id);
      state = state.copyWith(
          members: state.members.where((m) => m.id != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final familyProvider =
    StateNotifierProvider<FamilyNotifier, FamilyState>(
  (ref) => FamilyNotifier(ref.watch(apiClientProvider)),
);
