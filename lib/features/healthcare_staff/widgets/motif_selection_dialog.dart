import 'package:flutter/material.dart';

class MotifSelectionDialog extends StatelessWidget {
  const MotifSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final motifs = [
      {'value': 'URGENCE', 'label': 'Urgence', 'icon': Icons.emergency, 'color': Colors.red},
      {'value': 'CONSULTATION', 'label': 'Consultation', 'icon': Icons.medical_services, 'color': Colors.blue},
      {'value': 'SUIVI', 'label': 'Suivi', 'icon': Icons.assignment, 'color': Colors.green},
      {'value': 'AUTRE', 'label': 'Autre', 'icon': Icons.more_horiz, 'color': Colors.grey},
    ];

    return AlertDialog(
      title: const Text('Motif de consultation',
          style: TextStyle(fontWeight: FontWeight.bold)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: motifs.map((m) {
          return ListTile(
            leading: Icon(m['icon'] as IconData,
                color: m['color'] as Color, size: 28),
            title: Text(m['label'] as String,
                style: const TextStyle(fontSize: 16)),
            onTap: () => Navigator.pop(context, m['value']),
          );
        }).toList(),
      ),
    );
  }
}
