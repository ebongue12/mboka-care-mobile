import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/health_tips_provider.dart';
import '../../../data/models/health_tip_model.dart';

class HealthTipsScreen extends ConsumerStatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  ConsumerState<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends ConsumerState<HealthTipsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(healthTipsProvider.notifier).loadFeed());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthTipsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('💡', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Astuces Santé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorView(onRetry: () => ref.read(healthTipsProvider.notifier).loadFeed())
              : state.tips.isEmpty
                  ? _EmptyView()
                  : RefreshIndicator(
                      onRefresh: () => ref.read(healthTipsProvider.notifier).loadFeed(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.tips.length,
                        itemBuilder: (_, i) => _TipCard(tip: state.tips[i]),
                      ),
                    ),
    );
  }
}

class _TipCard extends ConsumerStatefulWidget {
  final HealthTipModel tip;
  const _TipCard({required this.tip});

  @override
  ConsumerState<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends ConsumerState<_TipCard> {
  @override
  void initState() {
    super.initState();
    // Marque la vue une fois quand la carte apparaît dans la liste
    Future.microtask(
      () => ref.read(healthTipsProvider.notifier).markTipViewed(widget.tip.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tip = widget.tip;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête coloré avec catégorie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(tip.categoryEmoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip.categoryDisplay,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                  ),
                ),
                Text(tip.timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(tip.content, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${tip.staffType} • ${tip.staffEstablishment}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💡', style: TextStyle(fontSize: 60)),
            SizedBox(height: 16),
            Text('Aucune astuce disponible pour le moment',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Les professionnels de santé publieront bientôt des conseils pour vous.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Impossible de charger les astuces'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
