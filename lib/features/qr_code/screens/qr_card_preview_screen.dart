import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../../data/providers/patient_provider.dart';
import '../../../data/models/patient_model.dart';

class QrCardPreviewScreen extends ConsumerWidget {
  const QrCardPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientProvider).patient;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Carte QR Médicale',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Text(
            'Aperçu de votre carte médicale',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Carte format bancaire
          if (patient != null) _CardWidget(patient: patient),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(children: [
              Icon(Icons.print, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Téléchargez et imprimez cette carte. '
                  'Gardez-la dans votre portefeuille pour les urgences.',
                  style: TextStyle(color: Colors.blue, fontSize: 13,
                      height: 1.4),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Génération PDF disponible via le backend'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('Télécharger la carte PDF',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final PatientModel patient;
  const _CardWidget({required this.patient});

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({
      'name': patient.fullName,
      'blood_group': patient.bloodGroup ?? '',
      'allergies': patient.allergies ?? '',
      'chronic_conditions': patient.chronicConditions ?? '',
      'emergency_contact': patient.emergencyContactPhone ?? '',
    });

    // Expiry = 1 an à partir d'aujourd'hui
    final expiry = DateTime.now().add(const Duration(days: 365));
    final expiryStr =
        '${expiry.month.toString().padLeft(2, '0')}/${expiry.year}';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            const Icon(Icons.health_and_safety,
                color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text('MBOKA CARE',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.5)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('URGENCE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ),
          ]),
          const SizedBox(height: 20),

          // Corps : QR + Infos
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // QR Code
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 100,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 16),

            // Informations patient
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _InfoLine(patient.fullName.toUpperCase(),
                    bold: true, size: 14),
                const SizedBox(height: 6),
                if (patient.dateOfBirth != null)
                  _InfoLine(
                      'Né(e) le : ${patient.dateOfBirth!.day.toString().padLeft(2, '0')}/'
                      '${patient.dateOfBirth!.month.toString().padLeft(2, '0')}/'
                      '${patient.dateOfBirth!.year}'),
                const SizedBox(height: 4),
                _InfoLine(
                    '🩸 Groupe : ${patient.bloodGroup ?? "Non renseigné"}',
                    bold: true),
                const SizedBox(height: 4),
                if (patient.emergencyContactPhone?.isNotEmpty == true)
                  _InfoLine(
                      '📞 Urgence : ${patient.emergencyContactPhone}'),
              ]),
            ),
          ]),
          const SizedBox(height: 16),

          // Footer
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Text('Valide jusqu\'au $expiryStr',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
            const Spacer(),
            const Text('mboka-care.com',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String text;
  final bool bold;
  final double size;
  const _InfoLine(this.text, {this.bold = false, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: Colors.white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: size));
  }
}
