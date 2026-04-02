import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/sharing_provider.dart';

class AddFollowerScreen extends ConsumerStatefulWidget {
  const AddFollowerScreen({super.key});
  @override
  ConsumerState<AddFollowerScreen> createState() =>
      _AddFollowerScreenState();
}

class _AddFollowerScreenState extends ConsumerState<AddFollowerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _nameCtrl  = TextEditingController();
  bool _canViewQr   = true;
  bool _canViewDocs = false;
  bool _canViewRem  = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose(); _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await ref.read(sharingProvider.notifier).addFollower({
      'follower_phone': _phoneCtrl.text.trim(),
      'follower_name': _nameCtrl.text.trim(),
      'can_view_qr': _canViewQr,
      'can_view_documents': _canViewDocs,
      'can_view_reminders': _canViewRem,
    });
    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur ou limite de 3 suiveurs atteinte'),
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
        title: const Text('Inviter un suiveur',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF673AB7).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Le suiveur pourra consulter vos informations selon les '
                  'permissions que vous lui accordez.',
                  style: TextStyle(color: Color(0xFF673AB7), fontSize: 13,
                      height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              _label('Téléphone du proche *'),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+237 6XX XXX XXX',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              _label('Nom (optionnel)'),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Marie Dupont',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              _label('Permissions accordées'),
              const SizedBox(height: 8),
              _PermSwitch(
                  icon: Icons.qr_code_2,
                  label: 'QR Code d\'urgence',
                  value: _canViewQr,
                  onChanged: (v) => setState(() => _canViewQr = v)),
              _PermSwitch(
                  icon: Icons.folder,
                  label: 'Documents médicaux',
                  value: _canViewDocs,
                  onChanged: (v) => setState(() => _canViewDocs = v)),
              _PermSwitch(
                  icon: Icons.alarm,
                  label: 'Rappels médicaments',
                  value: _canViewRem,
                  onChanged: (v) => setState(() => _canViewRem = v)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _invite,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Envoyer l\'invitation',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
      );
}

class _PermSwitch extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PermSwitch(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFF673AB7).withOpacity(0.06)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value
                ? const Color(0xFF673AB7).withOpacity(0.3)
                : Colors.grey.shade200),
      ),
      child: Row(children: [
        Icon(icon,
            color: value ? const Color(0xFF673AB7) : Colors.grey,
            size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: value ? Colors.black87 : Colors.grey))),
        Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF673AB7)),
      ]),
    );
  }
}
