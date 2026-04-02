import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/patient_provider.dart';
import '../../../data/models/patient_model.dart';

class HealthPriorityScreen extends ConsumerStatefulWidget {
  const HealthPriorityScreen({super.key});
  @override
  ConsumerState<HealthPriorityScreen> createState() =>
      _HealthPriorityScreenState();
}

class _HealthPriorityScreenState extends ConsumerState<HealthPriorityScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(patientProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Priorité Santé',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(patientProvider.notifier).loadProfile(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.patient == null
              ? _ErrorView(
                  onRetry: () =>
                      ref.read(patientProvider.notifier).loadProfile())
              : _HealthContent(patient: state.patient!),
    );
  }
}

class _HealthContent extends StatelessWidget {
  final PatientModel patient;
  const _HealthContent({required this.patient});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête patient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF009688), Color(0xFF00796B)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 34, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(patient.fullName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  if (patient.dateOfBirth != null)
                    Text(
                      _age(patient.dateOfBirth!),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Groupe sanguin (priorité critique)
          _Section(
            title: '🩸 Groupe Sanguin',
            color: const Color(0xFFE53935),
            child: _InfoRow(
              label: 'Type',
              value: patient.bloodGroup?.isNotEmpty == true
                  ? patient.bloodGroup!
                  : 'Non renseigné',
              highlighted: patient.bloodGroup?.isNotEmpty == true,
            ),
          ),
          const SizedBox(height: 16),

          // Allergies (priorité haute)
          _Section(
            title: '⚠️ Allergies',
            color: const Color(0xFFFF9800),
            child: patient.allergies?.isNotEmpty == true
                ? _TagList(
                    items: patient.allergies!
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList(),
                    color: const Color(0xFFFF9800),
                  )
                : const _EmptyInfo(text: 'Aucune allergie connue'),
          ),
          const SizedBox(height: 16),

          // Maladies chroniques
          _Section(
            title: '🏥 Maladies Chroniques',
            color: const Color(0xFF9C27B0),
            child: patient.chronicConditions?.isNotEmpty == true
                ? _TagList(
                    items: patient.chronicConditions!
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList(),
                    color: const Color(0xFF9C27B0),
                  )
                : const _EmptyInfo(text: 'Aucune maladie chronique'),
          ),
          const SizedBox(height: 16),

          // Contact d'urgence
          _Section(
            title: '📞 Contact d\'Urgence',
            color: const Color(0xFF2196F3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (patient.emergencyContactName?.isNotEmpty == true)
                  _InfoRow(
                      label: 'Nom',
                      value: patient.emergencyContactName!),
                if (patient.emergencyContactPhone?.isNotEmpty == true)
                  _InfoRow(
                      label: 'Téléphone',
                      value: patient.emergencyContactPhone!,
                      highlighted: true),
                if ((patient.emergencyContactName == null ||
                        patient.emergencyContactName!.isEmpty) &&
                    (patient.emergencyContactPhone == null ||
                        patient.emergencyContactPhone!.isEmpty))
                  const _EmptyInfo(text: 'Aucun contact d\'urgence défini'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notes d'urgence
          if (patient.emergencyNotes?.isNotEmpty == true)
            _Section(
              title: '📋 Notes d\'Urgence',
              color: const Color(0xFF607D8B),
              child: Text(
                patient.emergencyNotes!,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          const SizedBox(height: 20),

          // Avertissement QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              Icon(Icons.qr_code_2, color: Colors.red.shade700, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ces informations sont encodées dans votre QR Code d\'urgence. '
                  'Gardez-le accessible.',
                  style: TextStyle(
                      color: Colors.red.shade700, fontSize: 13,
                      height: 1.4),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _age(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return '$age ans';
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;
  const _Section(
      {required this.title, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 4, height: 20,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;
  const _InfoRow(
      {required this.label,
      required this.value,
      this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontWeight: highlighted
                      ? FontWeight.bold
                      : FontWeight.w500,
                  fontSize: 15)),
        ),
      ]),
    );
  }
}

class _TagList extends StatelessWidget {
  final List<String> items;
  final Color color;
  const _TagList({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(item,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ))
          .toList(),
    );
  }
}

class _EmptyInfo extends StatelessWidget {
  final String text;
  const _EmptyInfo({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
            fontSize: 14));
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('Impossible de charger les données',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      ]),
    );
  }
}
