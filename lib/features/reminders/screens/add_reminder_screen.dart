import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/reminder_provider.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  const AddReminderScreen({super.key});
  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _medCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(reminderProvider.notifier).createReminder({
      'title': _titleCtrl.text, 'medication_name': _medCtrl.text,
      'dosage': _dosageCtrl.text, 'reminder_type': 'MEDICATION',
      'frequency': 'DAILY', 'time_slots': ['08:00'],
      'start_date': DateTime.now().toIso8601String().split('T')[0],
      'notify_patient': true,
    });
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nouveau Rappel')),
    body: Form(key: _formKey, child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextFormField(controller: _titleCtrl, decoration: const InputDecoration(
          labelText: 'Titre', prefixIcon: Icon(Icons.title), border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextFormField(controller: _medCtrl, decoration: const InputDecoration(
          labelText: 'Médicament', prefixIcon: Icon(Icons.medication), border: OutlineInputBorder())),
        const SizedBox(height: 16),
        TextFormField(controller: _dosageCtrl, decoration: const InputDecoration(
          labelText: 'Dosage', prefixIcon: Icon(Icons.scale), border: OutlineInputBorder())),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 56,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
            child: const Text('Créer le rappel', style: TextStyle(color: Colors.white, fontSize: 16)),
          )),
      ]),
    )),
  );
}
