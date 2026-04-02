import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/qr_update_provider.dart';

class QrUpdatePromptScreen extends ConsumerStatefulWidget {
  const QrUpdatePromptScreen({super.key});
  @override
  ConsumerState<QrUpdatePromptScreen> createState() =>
      _QrUpdatePromptScreenState();
}

class _QrUpdatePromptScreenState
    extends ConsumerState<QrUpdatePromptScreen> {
  bool _consultedDoctor  = false;
  bool _newExams         = false;
  bool _newMedications   = false;
  bool _hospitalization  = false;
  String _generalState   = 'BON';

  static const _stateOptions = [
    'EXCELLENT', 'BON', 'MOYEN', 'FAIBLE', 'CRITIQUE',
  ];

  Color _stateColor(String s) {
    switch (s) {
      case 'EXCELLENT': return Colors.green.shade700;
      case 'BON':       return Colors.green;
      case 'MOYEN':     return Colors.orange;
      case 'FAIBLE':    return Colors.deepOrange;
      case 'CRITIQUE':  return Colors.red.shade700;
      default:          return Colors.grey;
    }
  }

  String _stateLabel(String s) {
    switch (s) {
      case 'EXCELLENT': return 'Excellent';
      case 'BON':       return 'Bon';
      case 'MOYEN':     return 'Moyen';
      case 'FAIBLE':    return 'Faible';
      case 'CRITIQUE':  return 'Critique ⚠️';
      default:          return s;
    }
  }

  Future<void> _submitUpdate() async {
    try {
      await ref.read(qrUpdateProvider.notifier).submitHealthUpdate(
        consultedDoctor: _consultedDoctor,
        newExams: _newExams,
        newMedications: _newMedications,
        hospitalization: _hospitalization,
        generalState: _generalState,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ QR Code actualisé avec succès'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        // L'erreur est déjà gérée dans le provider (sauvegarde locale)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Données sauvegardées localement'),
          backgroundColor: Colors.orange,
        ));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _dismiss() async {
    await ref.read(qrUpdateProvider.notifier).dismissForNow();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(qrUpdateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mise à jour Santé',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              const Icon(Icons.health_and_safety,
                  size: 56, color: Color(0xFF2196F3)),
              const SizedBox(height: 12),
              Text('Votre QR Code doit être actualisé',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text('Questions rapides (2 min)',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 20),

          // Questions Oui/Non
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Column(children: [
              _CheckItem(
                'Consulté un médecin récemment ?',
                _consultedDoctor,
                (v) => setState(() => _consultedDoctor = v),
              ),
              const Divider(height: 1),
              _CheckItem(
                'Nouveaux examens ou analyses ?',
                _newExams,
                (v) => setState(() => _newExams = v),
              ),
              const Divider(height: 1),
              _CheckItem(
                'Nouveaux médicaments ?',
                _newMedications,
                (v) => setState(() => _newMedications = v),
              ),
              const Divider(height: 1),
              _CheckItem(
                'Hospitalisation récente ?',
                _hospitalization,
                (v) => setState(() => _hospitalization = v),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // État général
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Comment évaluez-vous votre état général ?',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                ..._stateOptions.map((state) {
                  final sel = _generalState == state;
                  return InkWell(
                    onTap: () => setState(() => _generalState = state),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? _stateColor(state).withOpacity(0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: sel
                                ? _stateColor(state)
                                : Colors.grey.shade200,
                            width: sel ? 1.5 : 1),
                      ),
                      child: Row(children: [
                        Icon(
                            sel
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: sel
                                ? _stateColor(state)
                                : Colors.grey,
                            size: 20),
                        const SizedBox(width: 10),
                        Text(_stateLabel(state),
                            style: TextStyle(
                                fontWeight: sel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: sel
                                    ? _stateColor(state)
                                    : Colors.black87,
                                fontSize: 14)),
                      ]),
                    ),
                  );
                }),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Boutons
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Mettre à jour QR Code',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _dismiss,
              child: const Text('Rappeler plus tard',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CheckItem(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      activeColor: const Color(0xFF2196F3),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
