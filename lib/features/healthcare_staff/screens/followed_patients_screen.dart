import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/healthcare_staff_provider.dart';

class FollowedPatientsScreen extends ConsumerStatefulWidget {
  const FollowedPatientsScreen({super.key});

  @override
  ConsumerState<FollowedPatientsScreen> createState() =>
      _FollowedPatientsScreenState();
}

class _FollowedPatientsScreenState
    extends ConsumerState<FollowedPatientsScreen> {
  List<dynamic> _patients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ref
          .read(healthcareStaffProvider.notifier)
          .getFollowedPatients();
      if (mounted) setState(() { _patients = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erreur: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Patients Suivis',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _patients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 72, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('Aucun patient suivi',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600)),
                          const SizedBox(height: 8),
                          Text(
                            'Scannez le QR d\'un patient pour l\'ajouter',
                            style: TextStyle(color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _patients.length,
                      itemBuilder: (_, i) {
                        final p = _patients[i] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF8B5CF6)
                                  .withOpacity(0.12),
                              child: const Icon(Icons.person,
                                  color: Color(0xFF8B5CF6), size: 26),
                            ),
                            title: Text(
                              p['patient_name']?.toString() ?? 'Patient',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                            subtitle: p['added_at'] != null
                                ? Text(
                                    'Ajouté le ${p['added_at'].toString().substring(0, 10)}',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12),
                                  )
                                : null,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Actif',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
