import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/healthcare_staff_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final stats =
          await ref.read(healthcareStaffProvider.notifier).getStatistics();
      if (mounted) setState(() { _stats = stats; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(healthcareStaffProvider).staff;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Statistiques de Garde',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Aujourd'hui ──────────────────────────────────
                  _SectionLabel("AUJOURD'HUI"),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.qr_code_scanner,
                        label: 'Scans QR',
                        value: _stat('today.scans'),
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emergency,
                        label: 'Urgences',
                        value: _stat('today.urgences'),
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // ── Cette semaine ──────────────────────────────
                  _SectionLabel('CETTE SEMAINE'),
                  const SizedBox(height: 12),
                  _BigStatCard(
                    icon: Icons.date_range,
                    label: 'Scans QR',
                    value: _stat('week.scans'),
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 28),

                  // ── Ce mois ────────────────────────────────────
                  _SectionLabel('CE MOIS'),
                  const SizedBox(height: 12),
                  _BigStatCard(
                    icon: Icons.calendar_month,
                    label: 'Scans QR',
                    value: _stat('month.scans'),
                    color: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 28),

                  // ── Total ──────────────────────────────────────
                  _SectionLabel('TOTAL CUMULÉ'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.all_inclusive,
                        label: 'Scans total',
                        value: staff?.totalScans.toString() ?? '0',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people,
                        label: 'Patients suivis',
                        value:
                            staff?.totalPatientsFollowed.toString() ?? '0',
                        color: const Color(0xFF673AB7),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
    );
  }

  String _stat(String path) {
    if (_stats == null) return '0';
    final parts = path.split('.');
    dynamic val = _stats;
    for (final p in parts) {
      if (val is Map && val.containsKey(p)) {
        val = val[p];
      } else {
        return '0';
      }
    }
    return val?.toString() ?? '0';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 0.5),
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _BigStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600)),
          Text(value,
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ]),
      ]),
    );
  }
}
