import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/patient_provider.dart';
import '../../../data/providers/reminder_provider.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/providers/document_provider.dart';
import '../../../data/providers/family_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/qr_update_provider.dart';
import '../../../app/routes.dart';

class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});
  @override
  ConsumerState<PatientDashboardScreen> createState() =>
      _PatientDashboardScreenState();
}

class _PatientDashboardScreenState
    extends ConsumerState<PatientDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(patientProvider.notifier).loadProfile();
      ref.read(reminderProvider.notifier).loadReminders();
      ref.read(notificationProvider.notifier).loadNotifications();
      ref.read(documentProvider.notifier).loadDocuments();
      ref.read(familyProvider.notifier).loadMembers();
      // Popup mise à jour QR tous les 15 jours
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        final should =
            await ref.read(qrUpdateProvider.notifier).shouldShowUpdatePrompt();
        if (should && mounted) {
          await Navigator.pushNamed(context, AppRoutes.qrUpdatePrompt);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(patientProvider).patient;
    final firstName = patient?.firstName ?? '';
    final fullName = patient?.fullName ?? 'Mon profil';
    final phone = patient?.emergencyContactPhone ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // ─── DRAWER MENU GAUCHE ───────────────────────────────────────────
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── En-tête Drawer ───────────────────────────────────────
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person,
                    size: 40, color: Colors.blue.shade700),
              ),
              accountName: Text(
                fullName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17),
              ),
              accountEmail: Text(
                phone.isNotEmpty ? phone : 'Mboka Care',
                style: const TextStyle(fontSize: 13),
              ),
            ),

            // ── Items menu ───────────────────────────────────────────
            _DrawerItem(
              icon: Icons.home,
              iconColor: const Color(0xFF3B82F6),
              label: 'Accueil',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.people,
              iconColor: const Color(0xFF3B82F6),
              label: 'Ma Famille',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.family);
              },
            ),
            _DrawerItem(
              icon: Icons.alarm,
              iconColor: const Color(0xFF10B981),
              label: 'Rappels',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.reminders);
              },
            ),
            _DrawerItem(
              icon: Icons.medical_services,
              iconColor: const Color(0xFFEF4444),
              label: 'Ma Santé - Priorité',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.healthPriority);
              },
            ),
            _DrawerItem(
              icon: Icons.qr_code_2,
              iconColor: const Color(0xFF8B5CF6),
              label: 'Mon QR Code',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.qrCode);
              },
            ),
            _DrawerItem(
              icon: Icons.credit_card_outlined,
              iconColor: const Color(0xFF1565C0),
              label: 'Carte QR Médicale',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.qrCard);
              },
            ),
            _DrawerItem(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFFE91E63),
              label: 'Mes Documents',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.documents);
              },
            ),
            _DrawerItem(
              icon: Icons.people_outline,
              iconColor: const Color(0xFF673AB7),
              label: 'Mes Suiveurs',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.followers);
              },
            ),
            _DrawerItem(
              icon: Icons.history,
              iconColor: const Color(0xFFFF9800),
              label: 'Historique Consultations',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.consultHistory);
              },
            ),
            _DrawerItem(
              icon: Icons.update,
              iconColor: const Color(0xFF9C27B0),
              label: 'Mettre à jour QR',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.qrUpdatePrompt);
              },
            ),

            const Divider(indent: 16, endIndent: 16),

            // ── Déconnexion ──────────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red, size: 26),
              title: const Text(
                'Déconnexion',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Mboka Care v1.0.0 — Tout gratuit ✓',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // ─── APP BAR ────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Mboka Care',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF3B82F6).withOpacity(0.15),
              child: const Icon(Icons.person,
                  color: Color(0xFF3B82F6), size: 22),
            ),
          ),
        ],
      ),

      // ─── CORPS : Grille 2×2 ──────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Salutation ───────────────────────────────────────────
            Text(
              firstName.isNotEmpty
                  ? 'Bienvenue $firstName 👋'
                  : 'Bienvenue 👋',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Prenez soin de ce qui compte vraiment',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            // ── Ligne 1 : Famille + Rappels ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ModernCard(
                    emoji: '👥',
                    label: 'FAMILLE',
                    color: const Color(0xFF3B82F6),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.family),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ModernCard(
                    emoji: '💊',
                    label: 'RAPPELS',
                    color: const Color(0xFF10B981),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.reminders),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Ligne 2 : Ma Santé + Mon QR ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ModernCard(
                    emoji: '🏥',
                    label: 'MA SANTÉ',
                    color: const Color(0xFFEF4444),
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.healthPriority),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ModernCard(
                    emoji: '',
                    label: 'MON QR',
                    color: const Color(0xFF8B5CF6),
                    icon: Icons.qr_code_2,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.qrCode),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Accès rapide ─────────────────────────────────────────
            Text(
              'Accès rapide',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),

            _QuickTile(
              icon: Icons.file_upload_outlined,
              iconColor: const Color(0xFF4CAF50),
              title: 'Ajouter un document',
              subtitle: 'Analyses, ordonnances...',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.uploadDocument),
            ),
            const SizedBox(height: 10),
            _QuickTile(
              icon: Icons.credit_card_outlined,
              iconColor: const Color(0xFF1565C0),
              title: 'Carte QR Médicale',
              subtitle: 'Aperçu carte imprimable',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.qrCard),
            ),
            const SizedBox(height: 10),
            _QuickTile(
              icon: Icons.history,
              iconColor: const Color(0xFFFF9800),
              title: 'Historique Consultations',
              subtitle: 'Qui a consulté mon dossier',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.consultHistory),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Carte grille 2×2 ─────────────────────────────────────────────────────────

class _ModernCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  const _ModernCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, size: 48, color: color)
              else
                Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tuile accès rapide ────────────────────────────────────────────────────────

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
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
                          fontSize: 12, color: Colors.grey.shade600)),
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

// ─── Item Drawer ──────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}
