import 'package:flutter/material.dart';

class PatientFullDossierScreen extends StatelessWidget {
  final Map<String, dynamic> dossier;

  const PatientFullDossierScreen({super.key, required this.dossier});

  @override
  Widget build(BuildContext context) {
    final patient = dossier['patient'] as Map<String, dynamic>? ?? {};
    final medicalRecords = (dossier['medical_records'] as List?) ?? [];
    final documents = (dossier['documents'] as List?) ?? [];
    final reminders = (dossier['reminders'] as List?) ?? [];

    final name =
        '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}'.trim();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          title: Text(name.isEmpty ? 'Dossier Patient' : name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF2196F3),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2196F3),
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Infos'),
              Tab(icon: Icon(Icons.medical_services), text: 'Médical'),
              Tab(icon: Icon(Icons.description), text: 'Documents'),
              Tab(icon: Icon(Icons.alarm), text: 'Rappels'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InfosTab(patient: patient),
            _MedicalTab(records: medicalRecords),
            _DocumentsTab(documents: documents),
            _RemindersTab(reminders: reminders),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Infos ────────────────────────────────────────────────────────────────

class _InfosTab extends StatelessWidget {
  final Map<String, dynamic> patient;
  const _InfosTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    final fields = [
      {'label': 'Prénom', 'value': patient['first_name']},
      {'label': 'Nom', 'value': patient['last_name']},
      {'label': 'Groupe sanguin', 'value': patient['blood_group']},
      {'label': 'Allergies', 'value': patient['allergies']},
      {'label': 'Conditions chroniques', 'value': patient['chronic_conditions']},
      {'label': 'Notes urgence', 'value': patient['emergency_notes']},
      {'label': 'Contact urgence', 'value': patient['emergency_contact_name']},
      {'label': 'Tél. urgence', 'value': patient['emergency_contact_phone']},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Carte récap rapide
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 36, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                if (patient['blood_group'] != null)
                  Text('🩸 ${patient['blood_group']}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
              ]),
            ),
          ]),
        ),

        ...fields
            .where((f) =>
                f['value'] != null && f['value'].toString().isNotEmpty)
            .map((f) => _InfoRow(
                  label: f['label'].toString(),
                  value: f['value'].toString(),
                )),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Médical ──────────────────────────────────────────────────────────────

class _MedicalTab extends StatelessWidget {
  final List records;
  const _MedicalTab({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _EmptyState(
          icon: Icons.medical_services_outlined,
          message: 'Aucun dossier médical');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (_, i) {
        final r = records[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment,
                  color: Color(0xFF2196F3), size: 24),
            ),
            title: Text(r['title']?.toString() ?? 'Dossier médical',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: r['created_at'] != null
                ? Text(r['created_at'].toString().substring(0, 10))
                : null,
          ),
        );
      },
    );
  }
}

// ─── Tab Documents ────────────────────────────────────────────────────────────

class _DocumentsTab extends StatelessWidget {
  final List documents;
  const _DocumentsTab({required this.documents});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return _EmptyState(
          icon: Icons.description_outlined, message: 'Aucun document');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (_, i) {
        final doc = documents[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description,
                  color: Color(0xFFE91E63), size: 24),
            ),
            title: Text(doc['title']?.toString() ?? 'Document',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(doc['document_type']?.toString() ?? ''),
            trailing: Icon(Icons.open_in_new,
                size: 18, color: Colors.grey.shade400),
          ),
        );
      },
    );
  }
}

// ─── Tab Rappels ──────────────────────────────────────────────────────────────

class _RemindersTab extends StatelessWidget {
  final List reminders;
  const _RemindersTab({required this.reminders});

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return _EmptyState(
          icon: Icons.alarm_off_outlined, message: 'Aucun rappel');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (_, i) {
        final r = reminders[i] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medication,
                  color: Color(0xFF9C27B0), size: 24),
            ),
            title: Text(r['title']?.toString() ?? 'Rappel',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: r['frequency'] != null
                ? Text(r['frequency'].toString())
                : null,
          ),
        );
      },
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
