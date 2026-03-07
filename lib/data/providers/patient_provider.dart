import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../models/patient_model.dart';
import 'auth_provider.dart';

class PatientState {
  final PatientModel? patient;
  final bool isLoading;
  final String? error;
  PatientState({this.patient, this.isLoading = false, this.error});
  PatientState copyWith({PatientModel? patient, bool? isLoading, String? error}) =>
    PatientState(patient: patient ?? this.patient, isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
}

class PatientNotifier extends StateNotifier<PatientState> {
  final ApiClient _api;
  PatientNotifier(this._api) : super(PatientState());

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(isLoading: true);
      final r = await _api.getPatientProfile();
      if (r.statusCode == 200) state = state.copyWith(patient: PatientModel.fromJson(r.data), isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur chargement');
    }
  }
}

final patientProvider = StateNotifierProvider<PatientNotifier, PatientState>((ref) => PatientNotifier(ref.watch(apiClientProvider)));
