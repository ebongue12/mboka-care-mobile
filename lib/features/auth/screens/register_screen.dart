import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  final _phoneCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _countryCtrl  = TextEditingController();
  final _cityCtrl     = TextEditingController();
  final _districtCtrl = TextEditingController();
  DateTime? _dob;

  @override
  void dispose() {
    _phoneCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _confirmCtrl.dispose(); _firstNameCtrl.dispose(); _lastNameCtrl.dispose();
    _countryCtrl.dispose(); _cityCtrl.dispose(); _districtCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner votre date de naissance'), backgroundColor: Colors.orange));
      return;
    }
    final ok = await ref.read(authProvider.notifier).register({
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text,
      'password_confirm': _confirmCtrl.text,
      'role': 'PATIENT',
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'date_of_birth': _dob!.toIso8601String().split('T')[0],
      'country': _countryCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'district': _districtCtrl.text.trim(),
      'country_residence': _countryCtrl.text.trim(),
      'city_residence': _cityCtrl.text.trim(),
      'district_residence': _districtCtrl.text.trim(),
    });
    if (ok && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ref.read(authProvider).errorMessage ?? 'Erreur inscription'),
        backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).status == AuthStatus.loading;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Inscription Patient'),
        backgroundColor: Colors.white, elevation: 0,
        leading: _step > 0
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _step--))
          : null,
      ),
      body: Column(
        children: [
          // Barre de progression
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: List.generate(3, (i) => Expanded(child: Container(
              height: 4, margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: i <= _step ? const Color(0xFF2196F3) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
            )))),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Étape ${_step + 1}/3', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text(['Identifiants', 'Identité', 'Localisation'][_step],
                style: const TextStyle(color: Color(0xFF2196F3), fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(key: _formKey, child: [_step1(), _step2(), _step3()][_step]),
          )),
          // Boutons nav
          Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), child: Column(children: [
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: loading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    if (_step < 2) { setState(() => _step++); } else { _submit(); }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_step < 2 ? 'Suivant →' : 'Créer mon compte',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            if (_step == 0) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                child: const Text('Déjà inscrit ? Se connecter',
                  style: TextStyle(color: Color(0xFF2196F3))),
              ),
            ],
          ])),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint, IconData icon,
    {TextInputType kb = TextInputType.text, bool obs = false, String? Function(String?)? val}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      TextFormField(
        controller: c, keyboardType: kb, obscureText: obs,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        validator: val),
    ]);
  }

  Widget _step1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Identifiants', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    const Text('Compte Patient', style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.w500)),
    const SizedBox(height: 24),
    _field(_phoneCtrl, 'Téléphone *', '+237 6XX XXX XXX', Icons.phone,
      kb: TextInputType.phone, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 14),
    _field(_emailCtrl, 'Email (optionnel)', 'votre@email.com', Icons.email, kb: TextInputType.emailAddress),
    const SizedBox(height: 14),
    _field(_passCtrl, 'Mot de passe *', '••••••••', Icons.lock,
      obs: true, val: (v) => v!.length < 8 ? 'Minimum 8 caractères' : null),
    const SizedBox(height: 14),
    _field(_confirmCtrl, 'Confirmer le mot de passe *', '••••••••', Icons.lock_outline,
      obs: true, val: (v) => v != _passCtrl.text ? 'Les mots de passe ne correspondent pas' : null),
  ]);

  Widget _step2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Identité', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 24),
    _field(_firstNameCtrl, 'Prénom *', 'Jean', Icons.person, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 14),
    _field(_lastNameCtrl, 'Nom *', 'DUPONT', Icons.person_outline, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 14),
    const Text('Date de naissance *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    const SizedBox(height: 8),
    InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime(1990),
          firstDate: DateTime(1900),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        );
        if (d != null) setState(() => _dob = d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: _dob == null ? Colors.grey.shade300 : const Color(0xFF2196F3)),
          borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.calendar_today, color: _dob == null ? Colors.grey : const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          Text(
            _dob == null
              ? 'Sélectionner la date de naissance'
              : '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}',
            style: TextStyle(color: _dob == null ? Colors.grey : Colors.black, fontSize: 15)),
        ]),
      ),
    ),
  ]);

  Widget _step3() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Localisation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 24),
    _field(_countryCtrl, 'Pays *', 'Cameroun', Icons.flag, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 14),
    _field(_cityCtrl, 'Ville *', 'Douala', Icons.location_city, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 14),
    _field(_districtCtrl, 'Quartier *', 'Akwa', Icons.map, val: (v) => v!.isEmpty ? 'Requis' : null),
  ]);
}
