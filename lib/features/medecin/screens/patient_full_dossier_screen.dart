import 'package:flutter/material.dart';

class PatientFullDossierScreen extends StatelessWidget {
  final Map<String, dynamic> dossier;
  final String motif;
  const PatientFullDossierScreen(
      {super.key, required this.dossier, required this.motif});

  @override
  Widget build(BuildContext context) {
    final patient = dossier['patient'] is Map
        ? Map<String, dynamic>.from(dossier['patient'] as Map)
        : <String, dynamic>{};
    final docs = dossier['documents'] is List
        ? dossier['documents'] as List
        : [];
    final reminders = dossier['reminders'] is List
        ? dossier['reminders'] as List
        : [];
    final family = dossier['family_members'] is List
        ? dossier['family_members'] as List
        : [];
    final health = dossier['health_status'] is Map
        ? Map<String, dynamic>.from(dossier['health_status'] as Map)
        : <String, dynamic>{};

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Identité'),
              Tab(text: 'Médical'),
              Tab(text: 'Documents'),
              Tab(text: 'Rappels'),
              Tab(text: 'Famille'),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(motif,
                  style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _IdentityTab(patient: patient),
            _MedicalTab(patient: patient, health: health),
            _DocumentsTab(docs: docs),
            _RemindersTab(reminders: reminders),
            _FamilyTab(family: family),
          ],
        ),
      ),
    );
  }
}

// ─── Onglet Identité ──────────────────────────────────────────────────────────
class _IdentityTab extends StatelessWidget {
  final Map<String, dynamic> patient;
  const _IdentityTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: const Color(0xFF1565C0).withOpacity(0.15),
          child: Text(
            (patient['first_name']?.toString().isNotEmpty == true
                ? patient['first_name'].toString()[0]
                : '?').toUpperCase(),
            style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}',
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _InfoCard(title: '📋 Coordonnées', rows: [
          if (patient['phone'] != null)
            _Row('Téléphone', patient['phone'].toString()),
          if (patient['email'] != null)
            _Row('Email', patient['email'].toString()),
          if (patient['date_of_birth'] != null)
            _Row('Naissance', patient['date_of_birth'].toString()),
          if (patient['country'] != null)
            _Row('Pays', patient['country'].toString()),
          if (patient['city'] != null)
            _Row('Ville', patient['city'].toString()),
        ]),
      ]),
    );
  }
}

// ─── Onglet Médical ───────────────────────────────────────────────────────────
class _MedicalTab extends StatelessWidget {
  final Map<String, dynamic> patient;
  final Map<String, dynamic> health;
  const _MedicalTab({required this.patient, required this.health});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _InfoCard(title: '🏥 Données médicales', rows: [
          _Row('Groupe sanguin',
              patient['blood_group']?.toString() ?? 'Non renseigné'),
          _Row('Allergies',
              patient['allergies']?.toString() ?? 'Aucune'),
          _Row('Maladies chroniques',
              patient['chronic_conditions']?.toString() ?? 'Aucune'),
          _Row('Notes urgence',
              patient['emergency_notes']?.toString() ?? '—'),
        ]),
        const SizedBox(height: 12),
        _InfoCard(title: '📞 Contact urgence', rows: [
          _Row('Nom',
              patient['emergency_contact_name']?.toString() ?? '—'),
          _Row('Téléphone',
              patient['emergency_contact_phone']?.toString() ?? '—'),
        ]),
        if (health.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(title: '📊 État de santé récent', rows: [
            _Row('État général',
                health['general_state']?.toString() ?? '—'),
            _Row('Mis à jour le',
                health['updated_at']?.toString() ?? '—'),
          ]),
        ],
        const SizedBox(height: 16),
        // Boutons actions médecin
        Row(children: [
          Expanded(child: _DocBtn('Ajouter diagnostic', Icons.note_add,
              const Color(0xFF1565C0), () {})),
          const SizedBox(width: 8),
          Expanded(child: _DocBtn('Prescrire', Icons.medication,
              const Color(0xFF00796B), () {})),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _DocBtn('Demander examen', Icons.science,
              const Color(0xFF6A1B9A), () {})),
          const SizedBox(width: 8),
          Expanded(child: _DocBtn('Ajouter note', Icons.edit_note,
              const Color(0xFFE65100), () {})),
        ]),
      ]),
    );
  }
}

Widget _DocBtn(
    String label, IconData icon, Color color, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ─── Onglet Documents ─────────────────────────────────────────────────────────
class _DocumentsTab extends StatelessWidget {
  final List docs;
  const _DocumentsTab({required this.docs});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const Center(
          child: Text('Aucun document', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (_, i) {
        final d = docs[i] is Map
            ? Map<String, dynamic>.from(docs[i] as Map)
            : <String, dynamic>{};
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file,
                color: Color(0xFFE91E63)),
            title: Text(d['title']?.toString() ?? 'Document'),
            subtitle: Text(d['document_type']?.toString() ?? ''),
          ),
        );
      },
    );
  }
}

// ─── Onglet Rappels ───────────────────────────────────────────────────────────
class _RemindersTab extends StatelessWidget {
  final List reminders;
  const _RemindersTab({required this.reminders});

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return const Center(
          child: Text('Aucun rappel', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (_, i) {
        final r = reminders[i] is Map
            ? Map<String, dynamic>.from(reminders[i] as Map)
            : <String, dynamic>{};
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.medication,
                color: Color(0xFF9C27B0)),
            title: Text(r['title']?.toString() ?? 'Rappel'),
            subtitle: Text(r['frequency']?.toString() ?? ''),
          ),
        );
      },
    );
  }
}

// ─── Onglet Famille ───────────────────────────────────────────────────────────
class _FamilyTab extends StatelessWidget {
  final List family;
  const _FamilyTab({required this.family});

  @override
  Widget build(BuildContext context) {
    if (family.isEmpty) {
      return const Center(
          child: Text('Aucun membre de famille',
              style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: family.length,
      itemBuilder: (_, i) {
        final m = family[i] is Map
            ? Map<String, dynamic>.from(family[i] as Map)
            : <String, dynamic>{};
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF009688),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            title: Text(
                '${m['first_name'] ?? ''} ${m['last_name'] ?? ''}'),
            subtitle: Text(m['relation']?.toString() ?? ''),
          ),
        );
      },
    );
  }
}

// ─── Widgets partagés ─────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final List<_Row> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        ...rows,
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13)),
        ),
      ]),
    );
  }
}
