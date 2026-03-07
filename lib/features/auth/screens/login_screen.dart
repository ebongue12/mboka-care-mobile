import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).login(phone: _phoneCtrl.text.trim(), password: _passCtrl.text);
    if (ok && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ref.read(authProvider).errorMessage ?? 'Erreur'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).status == AuthStatus.loading;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.health_and_safety, size: 45, color: Colors.white),
                )),
                const SizedBox(height: 24),
                const Center(child: Text('Connexion', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                const SizedBox(height: 40),
                const Text('Numéro de téléphone', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: '+237 6XX XXX XXX', prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 20),
                const Text('Mot de passe', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••', prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : _login,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: loading ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Se connecter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                  child: const Text("Pas de compte ? S'inscrire", style: TextStyle(color: Color(0xFF2196F3))),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
