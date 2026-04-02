import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/sharing_provider.dart';
import '../../../data/models/follower_model.dart';
import '../../../core/network/api_client.dart';

class ConsultationHistoryScreen extends ConsumerStatefulWidget {
  const ConsultationHistoryScreen({super.key});
  @override
  ConsumerState<ConsultationHistoryScreen> createState() =>
      _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState
    extends ConsumerState<ConsultationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(sharingProvider.notifier).loadConsultations());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sharingProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Historique Consultations',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(sharingProvider.notifier).loadConsultations(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.consultations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(Icons.history,
                            size: 50, color: Color(0xFF2196F3)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Aucune consultation',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                          'Les médecins qui consultent votre dossier\napparaîtront ici',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey, height: 1.5)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.consultations.length,
                  itemBuilder: (_, i) =>
                      _ConsultCard(log: state.consultations[i]),
                ),
    );
  }
}

class _ConsultCard extends StatelessWidget {
  final ConsultationLogModel log;
  const _ConsultCard({required this.log});

  Color _motifColor() {
    switch (log.motif.toUpperCase()) {
      case 'URGENCE':     return Colors.red;
      case 'CONSULTATION': return const Color(0xFF2196F3);
      case 'SUIVI':       return Colors.green;
      default:            return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _motifColor();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.local_hospital, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(log.doctorName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(log.motif,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 4),
              Text(log.formattedDate,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
              if (log.location?.isNotEmpty == true)
                Text('📍 ${log.location}',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Colors.orange),
            tooltip: 'Signaler',
            onPressed: () => _showReportDialog(context, log.id),
          ),
        ]),
      ),
    );
  }

  Future<void> _showReportDialog(BuildContext context, String logId) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.flag, color: Colors.orange),
          SizedBox(width: 8),
          Text('Signaler un accès suspect'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Décrivez pourquoi cet accès vous semble suspect :'),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Je ne reconnais pas ce médecin...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Signaler',
                  style: TextStyle(color: Colors.orange))),
        ],
      ),
    );
    if (ok == true && ctrl.text.isNotEmpty) {
      try {
        await ApiClient().reportAbuse({
          'scan_log_id': logId,
          'reason': ctrl.text,
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Signalement envoyé. Merci.'),
            backgroundColor: Colors.green,
          ));
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Erreur lors du signalement'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }
}
