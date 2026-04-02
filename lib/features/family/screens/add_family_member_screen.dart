import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/family_provider.dart';

class AddFamilyMemberScreen extends ConsumerStatefulWidget {
  const AddFamilyMemberScreen({super.key});
  @override
  ConsumerState<AddFamilyMemberScreen> createState() =>
      _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState
    extends ConsumerState<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl   = TextEditingController();
  final _lastCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _bloodCtrl   = TextEditingController();
  final _allerCtrl   = TextEditingController();
  final _chronicCtrl = TextEditingController();
  String _relation = 'enfant';
  DateTime? _dob;
  bool _loading = false;

  static const _relations = [
    {'value': 'parent',   'label': 'Parent'},
    {'value': 'enfant',   'label': 'Enfant'},
    {'value': 'conjoint', 'label': 'Conjoint(e)'},
    {'value': 'frere',    'label': 'Frère/Sœur'},
    {'value': 'autre',    'label': 'Autre'},
  ];

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _bloodCtrl.dispose(); _allerCtrl.dispose();
    _chronicCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'first_name': _firstCtrl.text.trim(),
      'last_name': _lastCtrl.text.trim(),
      'relation': _relation,
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'blood_group': _bloodCtrl.text.trim(),
      'allergies': _allerCtrl.text.trim(),
      'chronic_conditions': _chronicCtrl.text.trim(),
      if (_dob != null)
        'date_of_birth': _dob!.toIso8601String().split('T')[0],
    };
    final ok = await ref.read(familyProvider.notifier).addMember(data);
    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur lors de l\'ajout'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ajouter un membre',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Relation
            const Text('Relation *',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _relations.map((r) {
                final sel = _relation == r['value'];
                return ChoiceChip(
                  label: Text(r['label']!),
                  selected: sel,
                  onSelected: (_) =>
                      setState(() => _relation = r['value']!),
                  selectedColor: const Color(0xFF009688),
                  labelStyle: TextStyle(
                      color: sel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _field(_firstCtrl, 'Prénom *', Icons.person,
                val: (v) => v!.isEmpty ? 'Requis' : null),
            _field(_lastCtrl, 'Nom *', Icons.person_outline,
                val: (v) => v!.isEmpty ? 'Requis' : null),
            _field(_phoneCtrl, 'Téléphone', Icons.phone,
                kb: TextInputType.phone),
            _field(_emailCtrl, 'Email', Icons.email,
                kb: TextInputType.emailAddress),
            _field(_bloodCtrl, 'Groupe sanguin', Icons.bloodtype),
            _field(_allerCtrl, 'Allergies', Icons.warning_amber),
            _field(_chronicCtrl, 'Maladies chroniques', Icons.medical_services),
            const SizedBox(height: 8),
            // Date naissance
            const Text('Date de naissance',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _dob = d);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: _dob != null
                          ? const Color(0xFF009688)
                          : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today,
                      color:
                          _dob != null ? const Color(0xFF009688) : Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    _dob == null
                        ? 'Sélectionner'
                        : '${_dob!.day.toString().padLeft(2, '0')}/'
                            '${_dob!.month.toString().padLeft(2, '0')}/'
                            '${_dob!.year}',
                    style: TextStyle(
                        color: _dob == null ? Colors.grey : Colors.black87),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009688),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Ajouter le membre',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType kb = TextInputType.text,
      String? Function(String?)? val}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          keyboardType: kb,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
          validator: val,
        ),
      ]),
    );
  }
}
