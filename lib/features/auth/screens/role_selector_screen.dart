import 'package:flutter/material.dart';
import '../../../app/routes.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ── Logo ──────────────────────────────────────────────
              Image.asset('assets/images/logo.png', width: 110, height: 110),
              const SizedBox(height: 16),
              const Text(
                'MBOKA CARE',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prenez soin de ce qui compte vraiment',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 52),

              // ── Bouton Patient ───────────────────────────────────
              _RoleButton(
                emoji: '👤',
                label: 'SE CONNECTER EN TANT\nQUE PATIENT',
                sublabel: 'Famille, rappels, QR Code santé',
                color: const Color(0xFF2196F3),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.login,
                  arguments: {'role': 'PATIENT'},
                ),
              ),
              const SizedBox(height: 18),

              // ── Bouton Personnel de Santé ────────────────────────
              _RoleButton(
                emoji: '🩺',
                label: 'SE CONNECTER EN TANT\nQUE PERSONNEL DE SANTÉ',
                sublabel: 'Scanner QR, dossiers, statistiques',
                color: const Color(0xFF10B981),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.login,
                  arguments: {'role': 'MEDECIN'},
                ),
              ),
              const SizedBox(height: 18),

              // ── Bouton Hôpital ───────────────────────────────────
              _RoleButton(
                emoji: '🏥',
                label: 'SE CONNECTER EN TANT\nQU\'HÔPITAL',
                sublabel: 'Gestion établissement (bientôt disponible)',
                color: const Color(0xFF8B5CF6),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Bientôt disponible'),
                    content: const Text(
                        'L\'interface Hôpital sera disponible dans une prochaine version.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: color.withOpacity(0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      sublabel,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
