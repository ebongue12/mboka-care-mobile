import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/patient_provider.dart';
import '../../../data/providers/reminder_provider.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes.dart';

class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});
  @override
  ConsumerState<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends ConsumerState<PatientDashboardScreen> {
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(patientProvider.notifier).loadProfile();
      ref.read(reminderProvider.notifier).loadReminders();
      ref.read(notificationProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(index: _idx, children: const [_HomeTab(), _RemindersTab(), _DocumentsTab(), _ProfileTab()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.alarm_outlined), selectedIcon: Icon(Icons.alarm), label: 'Rappels'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Documents'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientProvider).patient;
    final reminders = ref.watch(reminderProvider).reminders;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bonjour 👋', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              Text(patient?.firstName ?? 'Chargement...', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, color: Colors.green, size: 8),
                SizedBox(width: 6),
                Text('En ligne', style: TextStyle(color: Colors.green, fontSize: 12)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.qrCode),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('🆘 QR Code d\'Urgence', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(patient?.fullName ?? '...', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('🩸 ${patient?.bloodGroup ?? "Non renseigné"}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Voir mon QR Code', style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ])),
                const Icon(Icons.qr_code_2, size: 80, color: Colors.white54),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Actions rapides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            children: [
              _action(context, Icons.qr_code, 'Mon QR', const Color(0xFF2196F3), AppRoutes.qrCode),
              _action(context, Icons.qr_code_scanner, 'Scanner', const Color(0xFF4CAF50), AppRoutes.scanner),
              _action(context, Icons.alarm_add, 'Rappel', const Color(0xFF9C27B0), AppRoutes.addReminder),
              _action(context, Icons.upload_file, 'Document', const Color(0xFFE91E63), AppRoutes.uploadDocument),
              _action(context, Icons.folder, 'Documents', const Color(0xFFFF9800), AppRoutes.documents),
              _action(context, Icons.health_and_safety, 'Santé', const Color(0xFF009688), AppRoutes.healthPriority),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Rappels d'aujourd'hui", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (reminders.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Aucun rappel', style: TextStyle(color: Colors.grey))),
            )
          else
            ...reminders.take(3).map((r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFF9C27B0).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.medication, color: Color(0xFF9C27B0)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(r.timeSlots.isNotEmpty ? r.timeSlots.join(' • ') : r.frequencyDisplay,
                    style: const TextStyle(color: Color(0xFF2196F3), fontSize: 13)),
                ])),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  child: const Text('Pris ✓', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ]),
            )),
        ]),
      ),
    );
  }

  Widget _action(BuildContext context, IconData icon, String label, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _RemindersTab extends StatelessWidget {
  const _RemindersTab();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mes Rappels')),
    floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, AppRoutes.addReminder),
      child: const Icon(Icons.add),
    ),
    body: const Center(child: Text('Rappels')),
  );
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Documents')),
    body: const Center(child: Text('Documents')),
  );
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientProvider).patient;
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const CircleAvatar(radius: 50, backgroundColor: Color(0xFF2196F3),
          child: Icon(Icons.person, size: 50, color: Colors.white)),
        const SizedBox(height: 16),
        Center(child: Text(patient?.fullName ?? '...', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 32),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await ref.read(authProvider.notifier).logout();
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          },
        ),
      ]),
    );
  }
}
