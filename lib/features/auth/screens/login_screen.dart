import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? roleFromSelector;

  const LoginScreen({super.key, this.roleFromSelector});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  late String _role;

  @override
  void initState() {
    super.initState();
    _role = widget.roleFromSelector ?? 'PATIENT';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String get _screenTitle {
    switch (_role) {
      case 'MEDECIN':
        return 'Connexion Personnel de Santé';
      case 'HOPITAL':
        return 'Connexion Hôpital';
      default:
        return 'Connexion Patient';
    }
  }

  Color get _accentColor {
    switch (_role) {
      case 'MEDECIN':
        return const Color(0xFF10B981);
      case 'HOPITAL':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF2196F3);
    }
  }

  IconData get _roleIcon {
    switch (_role) {
      case 'MEDECIN':
        return Icons.medical_services;
      case 'HOPITAL':
        return Icons.local_hospital;
      default:
        return Icons.person;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).login(
        phone: _phoneCtrl.text.trim(), password: _passCtrl.text);
    if (ok && mounted) {
      final role = ref.read(authProvider).user?.role ?? '';
      final route = role.toUpperCase() == 'MEDECIN'
          ? AppRoutes.medecinDashboard
          : AppRoutes.patientDashboard;
      Navigator.pushReplacementNamed(context, route);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(ref.read(authProvider).errorMessage ?? 'Erreur de connexion'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        ref.watch(authProvider).status == AuthStatus.loading;
    final color = _accentColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(_screenTitle,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Logo + slogan ────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.png', width: 80, height: 80),
                      const SizedBox(height: 8),
                      const Text(
                        'MBOKA CARE',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prenez soin de ce qui compte vraiment',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Titre rôle ──────────────────────────────────────
                Center(
                  child: Text(
                    _screenTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Champs ──────────────────────────────────────────
                const Text('Numéro de téléphone',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+237 6XX XXX XXX',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color, width: 2)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 20),
                const Text('Mot de passe',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color, width: 2)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 32),

                // ── Bouton connexion ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text('SE CONNECTER',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OU',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ]),
                const SizedBox(height: 16),

                // ── Bouton créer compte ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_role == 'MEDECIN') {
                        Navigator.pushNamed(
                            context, AppRoutes.staffRegister);
                      } else {
                        Navigator.pushNamed(context, AppRoutes.register);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _role == 'MEDECIN'
                          ? 'Créer un compte personnel de santé'
                          : 'Créer un compte patient',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: color),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
