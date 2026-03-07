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
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  DateTime? _dob;
  String _role = 'PATIENT';

  Future<void> _submit() async {
    if (_dob == null) return;
    final ok = await ref.read(authProvider.notifier).register({
      'phone': _phoneCtrl.text.trim(), 'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text, 'password_confirm': _confirmCtrl.text,
      'role': _role, 'country': _countryCtrl.text.trim(), 'city': _cityCtrl.text.trim(),
      'district': _districtCtrl.text.trim(), 'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(), 'date_of_birth': _dob!.toIso8601String().split('T')[0],
      'country_residence': _countryCtrl.text.trim(), 'city_residence': _cityCtrl.text.trim(),
      'district_residence': _districtCtrl.text.trim(),
    });
    if (ok && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ref.read(authProvider).errorMessage ?? 'Erreur'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).status == AuthStatus.loading;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Inscription'), backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          Row(children: List.generate(3, (i) => Expanded(child: Container(
            height: 4, margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: i <= _step ? const Color(0xFF2196F3) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2)),
          )))),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(key: _formKey, child: _step == 0 ? _step1() : _step == 1 ? _step2() : _step3()),
          )),
          Padding(padding: const EdgeInsets.all(24), child: Row(
            children: [
              if (_step > 0) ...[
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Précédent'))),
                const SizedBox(width: 16),
              ],
              Expanded(child: ElevatedButton(
                onPressed: loading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    if (_step < 2) { setState(() => _step++); } else { _submit(); }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: loading ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_step < 2 ? 'Suivant' : 'Créer mon compte',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ],
          )),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint, IconData icon,
    {TextInputType kb = TextInputType.text, bool obs = false, String? Function(String?)? val}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(controller: c, keyboardType: kb, obscureText: obs,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        validator: val),
    ]);
  }

  Widget _step1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Identifiants', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 24),
    Row(children: [
      Expanded(child: _roleBtn('PATIENT', 'Patient', Icons.person)),
      const SizedBox(width: 12),
      Expanded(child: _roleBtn('DOCTOR', 'Médecin', Icons.medical_services)),
    ]),
    const SizedBox(height: 16),
    _field(_phoneCtrl, 'Téléphone', '+237 6XX XXX XXX', Icons.phone, kb: TextInputType.phone, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 12),
    _field(_emailCtrl, 'Email', 'votre@email.com', Icons.email, kb: TextInputType.emailAddress),
    const SizedBox(height: 12),
    _field(_passCtrl, 'Mot de passe', '••••••••', Icons.lock, obs: true, val: (v) => v!.length < 8 ? 'Min 8 caractères' : null),
    const SizedBox(height: 12),
    _field(_confirmCtrl, 'Confirmer', '••••••••', Icons.lock_outline, obs: true,
      val: (v) => v != _passCtrl.text ? 'Ne correspond pas' : null),
  ]);

  Widget _step2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Identité', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 24),
    _field(_firstNameCtrl, 'Prénom', 'Jean', Icons.person, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 12),
    _field(_lastNameCtrl, 'Nom', 'DUPONT', Icons.person_outline, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 12),
    const Text('Date de naissance', style: TextStyle(fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: DateTime(1990), firstDate: DateTime(1900), lastDate: DateTime.now());
        if (d != null) setState(() => _dob = d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.calendar_today, color: Colors.grey), const SizedBox(width: 12),
          Text(_dob == null ? 'Sélectionner la date' : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
            style: TextStyle(color: _dob == null ? Colors.grey : Colors.black)),
        ]),
      ),
    ),
  ]);

  Widget _step3() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Localisation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 24),
    _field(_countryCtrl, 'Pays', 'Cameroun', Icons.flag, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 12),
    _field(_cityCtrl, 'Ville', 'Douala', Icons.location_city, val: (v) => v!.isEmpty ? 'Requis' : null),
    const SizedBox(height: 12),
    _field(_districtCtrl, 'Quartier', 'Akwa', Icons.map, val: (v) => v!.isEmpty ? 'Requis' : null),
  ]);

  Widget _roleBtn(String role, String label, IconData icon) {
    final sel = _role == role;
    return InkWell(
      onTap: () => setState(() => _role = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF2196F3) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? const Color(0xFF2196F3) : Colors.grey.shade300),
        ),
        child: Column(children: [
          Icon(icon, color: sel ? Colors.white : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
