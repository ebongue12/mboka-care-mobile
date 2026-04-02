import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/healthcare_staff_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes.dart';
import 'scan_qr_screen.dart';
import 'followed_patients_screen.dart';
import 'statistics_screen.dart';
import 'staff_register_screen.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState
    extends ConsumerState<StaffDashboardScreen> {
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(healthcareStaffProvider.notifier).loadProfile();
      await _loadStats();
    });
  }

  Future<void> _loadStats() async {
    try {
      final stats =
          await ref.read(healthcareStaffProvider.notifier).getStatistics();
      if (mounted) setState(() => _stats = stats);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(healthcareStaffProvider);
    final staff = staffState.staff;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // ─── DRAWER ──────────────────────────────────────────────────────
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)]),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.medical_services,
                    size: 40, color: Colors.green.shade700),
              ),
              accountName: Text(
                staff?.fullName ?? 'Personnel de santé',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17),
              ),
              accountEmail: Text(
                staff != null
                    ? '${staff.staffTypeDisplay} • ${staff.establishment}'
                    : '',
                style: const TextStyle(fontSize: 12),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF10B981)),
              title: const Text('Accueil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.qr_code_scanner, color: Color(0xFF3B82F6)),
              title: const Text('Scanner QR Patient'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StaffScanQRScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF8B5CF6)),
              title: const Text('Patients Suivis'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FollowedPatientsScreen()));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.bar_chart, color: Color(0xFFEF4444)),
              title: const Text('Statistiques de Garde'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StatisticsScreen()));
              },
            ),

            const Divider(indent: 16, endIndent: 16),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text('Mboka Care v1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // ─── APP BAR ─────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('Mboka Care - Personnel',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),

      // ─── CORPS ───────────────────────────────────────────────────────
      body: staffState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : staffState.error != null && staff == null
              ? _ErrorState(message: staffState.error!)
              : staff == null
                  ? const Center(child: CircularProgressIndicator())
                  : !staff.verified
                      ? _PendingVerification(staff: staff)
                      : _Dashboard(staff: staff, stats: _stats, onRefresh: _loadStats),
    );
  }
}

// ─── En attente vérification ─────────────────────────────────────────────────

class _PendingVerification extends StatelessWidget {
  final dynamic staff;
  const _PendingVerification({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.pending_actions,
                  size: 60, color: Colors.orange.shade700),
            ),
            const SizedBox(height: 24),
            const Text('Compte en attente de vérification',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              'Notre équipe vérifiera vos documents dans les 48h.',
              style: TextStyle(
                  fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vous serez notifié par email : ${staff.email}',
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard principal ──────────────────────────────────────────────────────

class _Dashboard extends StatelessWidget {
  final dynamic staff;
  final Map<String, dynamic>? stats;
  final Future<void> Function() onRefresh;

  const _Dashboard(
      {required this.staff, required this.stats, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final todayScans = stats?['today']?['scans'] ?? 0;
    final todayUrgences = stats?['today']?['urgences'] ?? 0;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salutation
            Text(
              '👋 Bonjour ${staff.firstName}',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${staff.staffTypeDisplay} • ${staff.establishment}',
              style:
                  TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 28),

            // Stats aujourd'hui
            Text("AUJOURD'HUI",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _MiniStat(
                    icon: Icons.qr_code_scanner,
                    label: 'Scans',
                    value: '$todayScans',
                    color: const Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                    icon: Icons.emergency,
                    label: 'Urgences',
                    value: '$todayUrgences',
                    color: const Color(0xFFEF4444)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                    icon: Icons.people,
                    label: 'Suivis',
                    value: '${staff.totalPatientsFollowed}',
                    color: const Color(0xFF10B981)),
              ),
            ]),
            const SizedBox(height: 32),

            // Actions rapides
            Text('ACTIONS RAPIDES',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.qr_code_scanner,
              title: 'Scanner QR Patient',
              subtitle: 'Accès instant au dossier médical complet',
              color: const Color(0xFF10B981),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StaffScanQRScreen())),
            ),
            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.people_outline,
              title:
                  'Patients Suivis (${staff.totalPatientsFollowed})',
              subtitle: 'Voir la liste de vos patients',
              color: const Color(0xFF8B5CF6),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FollowedPatientsScreen())),
            ),
            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.bar_chart,
              title: 'Statistiques de Garde',
              subtitle: 'Suivez votre activité et vos rapports',
              color: const Color(0xFFEF4444),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StatisticsScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 15, color: Colors.grey.shade400),
          ]),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
