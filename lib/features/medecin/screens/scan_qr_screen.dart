import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/network/api_client.dart';
import 'patient_full_dossier_screen.dart';

class MedecinScanQrScreen extends ConsumerStatefulWidget {
  const MedecinScanQrScreen({super.key});
  @override
  ConsumerState<MedecinScanQrScreen> createState() =>
      _MedecinScanQrScreenState();
}

class _MedecinScanQrScreenState
    extends ConsumerState<MedecinScanQrScreen> {
  final _auth = LocalAuthentication();
  final _controller = MobileScannerController();

  // Étapes : 0=biometrie, 1=motif, 2=scan, 3=chargement
  int _step = 0;
  String _motif = 'CONSULTATION';
  bool _torchOn = false;
  bool _loading = false;
  bool _scanned = false;

  static const _motifs = [
    {'value': 'URGENCE',      'label': 'Urgence',       'icon': Icons.emergency},
    {'value': 'CONSULTATION', 'label': 'Consultation',  'icon': Icons.medical_services},
    {'value': 'SUIVI',        'label': 'Suivi',         'icon': Icons.monitor_heart},
    {'value': 'AUTRE',        'label': 'Autre',         'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _startBiometric();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isAvailable = await _auth.isDeviceSupported();

      if (!canCheck && !isAvailable) {
        // Pas de biométrie dispo → passer directement au motif
        setState(() => _step = 1);
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason:
            'Confirmez votre identité pour scanner le QR du patient',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        setState(() => _step = 1);
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (_) {
      // En cas d'erreur biométrique → motif directement
      setState(() => _step = 1);
    }
  }

  Future<void> _onQrDetected(String? qrValue) async {
    if (_scanned || qrValue == null || _loading) return;
    _scanned = true;
    _controller.stop();
    setState(() => _loading = true);

    try {
      // Extraire patient_id depuis le QR
      String? patientId;
      try {
        final data = Map<String, dynamic>.from(
            (qrValue.startsWith('{')
                ? (throw ''
                    ) // parse via API
                : {'id': qrValue}) as Map);
        patientId = data['id']?.toString() ?? data['patient_id']?.toString();
      } catch (_) {
        patientId = qrValue;
      }

      final response = await ApiClient().doctorScanQR({
        'patient_id': patientId,
        'motif': _motif,
      });

      if (mounted) {
        final dossier =
            Map<String, dynamic>.from(response.data as Map);
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  PatientFullDossierScreen(dossier: dossier, motif: _motif)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() { _loading = false; _scanned = false; });
        _controller.start();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_stepTitle(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 0: return 'Authentification';
      case 1: return 'Motif de consultation';
      case 2: return 'Scanner le QR Patient';
      default: return 'Chargement...';
    }
  }

  Widget _buildBody() {
    if (_step == 0) return _BiometricStep();
    if (_step == 1) return _MotifStep();
    if (_loading) return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircularProgressIndicator(color: Colors.white),
      SizedBox(height: 16),
      Text('Récupération du dossier...',
          style: TextStyle(color: Colors.white)),
    ]));
    return _ScannerStep();
  }

  Widget _BiometricStep() => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.fingerprint, size: 80, color: Colors.white54),
          SizedBox(height: 20),
          Text('Authentification en cours...',
              style: TextStyle(color: Colors.white70, fontSize: 16)),
        ]),
      );

  Widget _MotifStep() => Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text('Motif de la consultation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Sélectionnez le motif avant de scanner',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ..._motifs.map((m) {
              final sel = _motif == m['value'];
              return InkWell(
                onTap: () => setState(() => _motif = m['value'] as String),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF1565C0).withOpacity(0.08)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: sel
                            ? const Color(0xFF1565C0)
                            : Colors.grey.shade200,
                        width: sel ? 2 : 1),
                  ),
                  child: Row(children: [
                    Icon(m['icon'] as IconData,
                        color: sel
                            ? const Color(0xFF1565C0)
                            : Colors.grey),
                    const SizedBox(width: 14),
                    Text(m['label'] as String,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: sel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: sel
                                ? const Color(0xFF1565C0)
                                : Colors.black87)),
                    const Spacer(),
                    if (sel)
                      const Icon(Icons.check_circle,
                          color: Color(0xFF1565C0)),
                  ]),
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _step = 2),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text('Scanner maintenant',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ]),
        ),
      );

  Widget _ScannerStep() => Stack(children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            if (barcode?.rawValue != null) {
              _onQrDetected(barcode!.rawValue);
            }
          },
        ),
        // Overlay viseur
        Center(
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned(
          bottom: 40, left: 0, right: 0,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Motif : $_motif',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            IconButton(
              icon: Icon(
                  _torchOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white, size: 32),
              onPressed: () {
                _controller.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
            ),
          ]),
        ),
      ]);
}
