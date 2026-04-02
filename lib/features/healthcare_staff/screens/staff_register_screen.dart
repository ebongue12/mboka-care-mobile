import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes.dart';

class StaffRegisterScreen extends ConsumerStatefulWidget {
  const StaffRegisterScreen({super.key});

  @override
  ConsumerState<StaffRegisterScreen> createState() =>
      _StaffRegisterScreenState();
}

class _StaffRegisterScreenState extends ConsumerState<StaffRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  bool _isLoading = false;

  // Step 1 - Identité
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _staffType = 'MEDECIN';

  // Step 2 - Établissement
  final _cityCtrl = TextEditingController();
  final _establishmentCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  String _yearsExp = '0-5';
  String _patientsRange = '0-100';

  // Step 3 - Sécurité + Document
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  bool _obscurePass = true;
  PlatformFile? _diplomaFile;

  final List<Map<String, String>> _staffTypes = [
    {'value': 'MEDECIN', 'label': 'Médecin'},
    {'value': 'INFIRMIER', 'label': 'Infirmier/Infirmière'},
    {'value': 'SECOURISTE', 'label': 'Secouriste'},
    {'value': 'AIDE_SOIGNANT', 'label': 'Aide-soignant(e)'},
    {'value': 'SAGE_FEMME', 'label': 'Sage-femme'},
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _establishmentCtrl.dispose();
    _specialtyCtrl.dispose();
    _passCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDiploma() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _diplomaFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_diplomaFile == null) {
      _showError('Veuillez joindre votre diplôme');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final formData = FormData.fromMap({
        'staff_type': _staffType,
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'establishment': _establishmentCtrl.text.trim(),
        'specialty': _specialtyCtrl.text.trim(),
        'years_experience': int.tryParse(_yearsExp.split('-').first) ?? 0,
        'patients_treated_range': _patientsRange,
        'password': _passCtrl.text,
        'password_confirm': _passConfirmCtrl.text,
        'diploma_document': await MultipartFile.fromFile(
          _diplomaFile!.path!,
          filename: _diplomaFile!.name,
        ),
      });

      await ApiClient().registerHealthcareStaff(formData);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Inscription réussie !'),
            content: const Text(
                'Votre compte sera vérifié sous 48h. Vous serez notifié par email.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('Inscription Personnel de Santé',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: Column(
        children: [
          // Indicateur étapes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(children: [
              _StepDot(index: 0, current: _step, label: 'Identité'),
              _StepLine(active: _step >= 1),
              _StepDot(index: 1, current: _step, label: 'Établissement'),
              _StepLine(active: _step >= 2),
              _StepDot(index: 2, current: _step, label: 'Sécurité'),
            ]),
          ),

          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ][_step],
              ),
            ),
          ),

          // Boutons navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Retour'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_step < 2) {
                            setState(() => _step++);
                          } else {
                            _submit();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_step < 2 ? 'Suivant' : 'S\'inscrire',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Type de personnel',
          style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _staffType,
        decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: _staffTypes
            .map((t) => DropdownMenuItem(
                value: t['value'], child: Text(t['label']!)))
            .toList(),
        onChanged: (v) => setState(() => _staffType = v!),
      ),
      const SizedBox(height: 20),
      _Field(controller: _firstNameCtrl, label: 'Prénom', icon: Icons.person),
      const SizedBox(height: 16),
      _Field(controller: _lastNameCtrl, label: 'Nom', icon: Icons.person_outline),
      const SizedBox(height: 16),
      _Field(
          controller: _phoneCtrl,
          label: 'Téléphone',
          icon: Icons.phone,
          keyboardType: TextInputType.phone),
      const SizedBox(height: 16),
      _Field(
          controller: _emailCtrl,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress),
    ]);
  }

  Widget _buildStep2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Field(controller: _cityCtrl, label: 'Ville', icon: Icons.location_city),
      const SizedBox(height: 16),
      _Field(
          controller: _establishmentCtrl,
          label: 'Établissement de santé',
          icon: Icons.local_hospital),
      const SizedBox(height: 16),
      _Field(
          controller: _specialtyCtrl,
          label: 'Spécialité (optionnel)',
          icon: Icons.medical_services,
          required: false),
      const SizedBox(height: 20),
      const Text("Années d'expérience",
          style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _yearsExp,
        decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: const [
          DropdownMenuItem(value: '0-5', child: Text('Moins de 5 ans')),
          DropdownMenuItem(value: '5-10', child: Text('5 à 10 ans')),
          DropdownMenuItem(value: '10-20', child: Text('10 à 20 ans')),
          DropdownMenuItem(value: '20+', child: Text('Plus de 20 ans')),
        ],
        onChanged: (v) => setState(() => _yearsExp = v!),
      ),
      const SizedBox(height: 20),
      const Text('Patients traités (estimation)',
          style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _patientsRange,
        decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: const [
          DropdownMenuItem(value: '0-100', child: Text('Moins de 100')),
          DropdownMenuItem(value: '100-500', child: Text('100 à 500')),
          DropdownMenuItem(value: '500-1000', child: Text('500 à 1000')),
          DropdownMenuItem(value: '1000+', child: Text('Plus de 1000')),
        ],
        onChanged: (v) => setState(() => _patientsRange = v!),
      ),
    ]);
  }

  Widget _buildStep3() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Diplôme
      const Text('Justificatif diplôme *',
          style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      InkWell(
        onTap: _pickDiploma,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
                color: _diplomaFile != null
                    ? Colors.green
                    : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(
              _diplomaFile != null
                  ? Icons.check_circle
                  : Icons.upload_file,
              color: _diplomaFile != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _diplomaFile?.name ?? 'Choisir un fichier (PDF, JPG, PNG)',
                style: TextStyle(
                    color: _diplomaFile != null
                        ? Colors.green
                        : Colors.grey.shade600),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 24),

      // Mot de passe
      TextFormField(
        controller: _passCtrl,
        obscureText: _obscurePass,
        decoration: InputDecoration(
          labelText: 'Mot de passe',
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
                _obscurePass ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v == null || v.length < 8
            ? 'Minimum 8 caractères'
            : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passConfirmCtrl,
        obscureText: _obscurePass,
        decoration: InputDecoration(
          labelText: 'Confirmer le mot de passe',
          prefixIcon: const Icon(Icons.lock_outline),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v != _passCtrl.text
            ? 'Les mots de passe ne correspondent pas'
            : null,
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Votre compte sera vérifié sous 48h. Vous pourrez accéder à l\'application une fois la vérification complétée.',
                style:
                    TextStyle(color: Colors.blue.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool required;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: required ? (v) => v!.isEmpty ? 'Requis' : null : null,
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final int current;
  final String label;

  const _StepDot(
      {required this.index, required this.current, required this.label});

  @override
  Widget build(BuildContext context) {
    final active = index <= current;
    return Column(children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2196F3) : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: active && index < current
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text('${index + 1}',
                  style: TextStyle(
                      color: active ? Colors.white : Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: TextStyle(
              fontSize: 10,
              color: active ? const Color(0xFF2196F3) : Colors.grey)),
    ]);
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: active ? const Color(0xFF2196F3) : Colors.grey.shade300,
      ),
    );
  }
}
