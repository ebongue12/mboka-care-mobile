import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/reminder_provider.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reminderProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Rappels')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-reminder'),
        child: const Icon(Icons.add),
      ),
      body: state.reminders.isEmpty
        ? const Center(child: Text('Aucun rappel'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.reminders.length,
            itemBuilder: (_, i) {
              final r = state.reminders[i];
              return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
                leading: const Icon(Icons.medication, color: Color(0xFF9C27B0)),
                title: Text(r.title),
                subtitle: Text(r.timeSlots.isNotEmpty ? r.timeSlots.join(' • ') : r.frequencyDisplay),
                trailing: Switch(value: r.isActive, onChanged: (_) {}),
              ));
            }),
    );
  }
}
