import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../../data/providers/patient_provider.dart';
import '../../../core/network/api_client.dart';

class QrCodeScreen extends ConsumerStatefulWidget {
  const QrCodeScreen({super.key});
  @override
  ConsumerState<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends ConsumerState<QrCodeScreen> {
  bool _loading = false;
  Map<String, dynamic>? _payload;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ApiClient().generatePatientQR();
      if (r.statusCode == 200) setState(() { _payload = r.data['payload']; _loading = false; });
    } catch (e) {
      final p = ref.read(patientProvider).patient;
      if (p?.qrPublicPayload != null) {
        setState(() { _payload = p!.qrPublicPayload; _loading = false; });
      } else {
        setState(() { _error = 'Impossible de générer le QR Code'; _loading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(patientProvider).patient;
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code d'Urgence"),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200)),
            child: Row(children: [
              Icon(Icons.info_outline, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(child: Text('Montrez ce QR Code aux secouristes en cas d\'urgence.',
                style: TextStyle(color: Colors.red.shade700))),
            ]),
          ),
          const SizedBox(height: 32),
          if (_loading) const CircularProgressIndicator()
          else if (_error != null) Column(children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
          ])
          else if (_payload != null) Column(children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)]),
              child: QrImageView(data: jsonEncode(_payload), version: QrVersions.auto, size: 250, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(patient?.fullName ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('📋 Informations d\'urgence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _row('🩸 Groupe sanguin', _payload!['blood_group'] ?? 'Non renseigné'),
                _row('⚠️ Allergies', _payload!['allergies']?.isNotEmpty == true ? _payload!['allergies'] : 'Aucune'),
                _row('🏥 Maladies', _payload!['chronic_conditions']?.isNotEmpty == true ? _payload!['chronic_conditions'] : 'Aucune'),
                _row('📞 Contact urgence', _payload!['emergency_contact'] ?? 'Non renseigné'),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 150, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
    ]),
  );
}
