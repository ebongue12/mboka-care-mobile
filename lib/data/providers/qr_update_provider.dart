import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import 'auth_provider.dart';

const _kLastQrUpdateKey = 'last_qr_update';
const _kQrUpdateIntervalDays = 15;

final qrUpdateProvider =
    StateNotifierProvider<QRUpdateNotifier, AsyncValue<void>>(
  (ref) => QRUpdateNotifier(ref.watch(apiClientProvider)),
);

class QRUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiClient _api;

  QRUpdateNotifier(this._api) : super(const AsyncValue.data(null));

  /// Soumet la mise à jour de santé au backend et sauvegarde le timestamp.
  Future<void> submitHealthUpdate({
    required bool consultedDoctor,
    required bool newExams,
    required bool newMedications,
    required bool hospitalization,
    required String generalState,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _api.updateHealthStatus({
        'consulted_doctor': consultedDoctor,
        'new_exams': newExams,
        'new_medications': newMedications,
        'hospitalization': hospitalization,
        'general_state': generalState,
      });
      await _saveLastUpdate();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Même en cas d'erreur réseau, on sauvegarde localement
      await _saveLastUpdate();
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Vérifie si le popup doit être affiché (dernière MàJ > 15 jours).
  Future<bool> shouldShowUpdatePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_kLastQrUpdateKey);
    if (lastStr == null) return true;
    try {
      final last = DateTime.parse(lastStr);
      return DateTime.now().difference(last).inDays >= _kQrUpdateIntervalDays;
    } catch (_) {
      return true;
    }
  }

  /// Sauvegarde la date de la dernière MàJ (pour "Rappeler plus tard").
  Future<void> dismissForNow() => _saveLastUpdate();

  Future<void> _saveLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kLastQrUpdateKey, DateTime.now().toIso8601String());
  }
}
