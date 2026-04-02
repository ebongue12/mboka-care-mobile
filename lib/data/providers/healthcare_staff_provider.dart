import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../features/healthcare_staff/models/healthcare_staff.dart';
import 'auth_provider.dart';

class HealthcareStaffState {
  final HealthcareStaff? staff;
  final bool isLoading;
  final String? error;

  HealthcareStaffState({this.staff, this.isLoading = false, this.error});

  HealthcareStaffState copyWith({
    HealthcareStaff? staff,
    bool? isLoading,
    String? error,
  }) =>
      HealthcareStaffState(
        staff: staff ?? this.staff,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

class HealthcareStaffNotifier extends StateNotifier<HealthcareStaffState> {
  final ApiClient _api;

  HealthcareStaffNotifier(this._api) : super(HealthcareStaffState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.getHealthcareProfile();
      final staff = HealthcareStaff.fromJson(response.data);
      state = state.copyWith(staff: staff, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Impossible de charger le profil',
        isLoading: false,
      );
    }
  }

  Future<Map<String, dynamic>> scanPatientQR(
      String patientId, String motif) async {
    final response = await _api.healthcareScanQR({
      'patient_id': patientId,
      'motif': motif,
    });
    await loadProfile(); // refresh stats
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getFollowedPatients() async {
    final response = await _api.getHealthcareFollowedPatients();
    final data = response.data;
    if (data is Map && data.containsKey('results')) return data['results'] as List;
    if (data is List) return data;
    return [];
  }

  Future<void> addPatientToFollow(String patientId, String notes) async {
    await _api.healthcareFollowPatient({
      'patient_id': patientId,
      'notes': notes,
    });
    await loadProfile();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final response = await _api.getHealthcareStats();
    return Map<String, dynamic>.from(response.data);
  }
}

final healthcareStaffProvider =
    StateNotifierProvider<HealthcareStaffNotifier, HealthcareStaffState>(
  (ref) => HealthcareStaffNotifier(ref.watch(apiClientProvider)),
);
