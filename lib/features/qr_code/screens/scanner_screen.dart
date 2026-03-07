import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) { return; }
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) { return; }
    setState(() => _scanned = true);
    _ctrl.stop();
    try {
      final payload = jsonDecode(barcode!.rawValue!) as Map<String, dynamic>;
      _showData(payload);
    } catch (e) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code invalide'), backgroundColor: Colors.red)); }
      setState(() => _scanned = false);
      _ctrl.start();
    }
  }

  void _showData(Map<String, dynamic> p) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Container(
            margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200)),
            child: Row(children: [
              Icon(Icons.emergency, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('INFORMATIONS D\'URGENCE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                Text(p['name'] ?? 'Inconnu', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('${p['age'] ?? '?'} ans'),
              ])),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              _card('🩸 Groupe Sanguin', p['blood_group'] ?? 'Non renseigné', Colors.red),
              _card('⚠️ Allergies', p['allergies']?.isNotEmpty == true ? p['allergies'] : 'Aucune', Colors.orange),
              _card('🏥 Maladies', p['chronic_conditions']?.isNotEmpty == true ? p['chronic_conditions'] : 'Aucune', Colors.blue),
              _card('📞 Contact', '${p['emergency_contact_name'] ?? ''}\n${p['emergency_contact'] ?? 'Non renseigné'}', Colors.green),
            ]),
          )),
          Padding(padding: const EdgeInsets.all(16), child: SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_circle),
              label: const Text('OK'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          )),
        ]),
      ),
    ).then((_) { setState(() => _scanned = false); _ctrl.start(); });
  }

  Widget _card(String label, String value, Color color) => Container(
    width: double.infinity, margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    ]),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: const Text('Scanner QR Code', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [IconButton(icon: const Icon(Icons.flash_on, color: Colors.white), onPressed: () => _ctrl.toggleTorch())],
    ),
    body: Stack(children: [
      MobileScanner(controller: _ctrl, onDetect: _onDetect),
      Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 250, height: 250,
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4CAF50), width: 3),
            borderRadius: BorderRadius.circular(16))),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
          child: const Text('Placez le QR Code dans le cadre', style: TextStyle(color: Colors.white)),
        ),
      ])),
    ]),
  );
}
