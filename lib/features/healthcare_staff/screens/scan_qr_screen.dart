import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/healthcare_staff_provider.dart';
import '../widgets/motif_selection_dialog.dart';
import 'patient_full_dossier_screen.dart';

class StaffScanQRScreen extends ConsumerStatefulWidget {
  const StaffScanQRScreen({super.key});

  @override
  ConsumerState<StaffScanQRScreen> createState() => _StaffScanQRScreenState();
}

class _StaffScanQRScreenState extends ConsumerState<StaffScanQRScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onQRDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final patientId = barcodes.first.rawValue;
    if (patientId == null || patientId.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // 1. Biométrie
      final authenticated = await _authenticateUser();
      if (!authenticated) {
        _showError('Authentification échouée');
        setState(() => _isProcessing = false);
        return;
      }

      // 2. Motif
      if (!mounted) return;
      final motif = await showDialog<String>(
        context: context,
        builder: (_) => const MotifSelectionDialog(),
      );
      if (motif == null) {
        setState(() => _isProcessing = false);
        return;
      }

      // 3. Appel API
      final dossier = await ref
          .read(healthcareStaffProvider.notifier)
          .scanPatientQR(patientId, motif);

      // 4. Afficher dossier
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PatientFullDossierScreen(dossier: dossier),
        ),
      );
    } catch (e) {
      _showError('Erreur: $e');
      setState(() => _isProcessing = false);
    }
  }

  Future<bool> _authenticateUser() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      if (!canCheck && !supported) return true;
      return await _localAuth.authenticate(
        localizedReason: 'Confirmez votre identité pour scanner le QR Code',
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Patient'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onQRDetected,
          ),

          // Overlay chargement
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Chargement dossier patient...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Barre info bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Scannez le QR Code du patient',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Accès COMPLET au dossier médical',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
