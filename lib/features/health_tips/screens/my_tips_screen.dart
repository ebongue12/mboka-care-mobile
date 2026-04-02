import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/health_tip_model.dart';
import '../../../data/providers/health_tips_provider.dart';
import 'publish_tip_screen.dart';

class MyTipsScreen extends ConsumerStatefulWidget {
  const MyTipsScreen({super.key});

  @override
  ConsumerState<MyTipsScreen> createState() => _MyTipsScreenState();
}

class _MyTipsScreenState extends ConsumerState<MyTipsScreen> {
  List<HealthTipModel> _tips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final tips = await ref.read(healthTipsProvider.notifier).loadMyTips();
      if (mounted) setState(() { _tips = tips; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(HealthTipModel tip) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer "${tip.title}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(healthTipsProvider.notifier).deleteTip(tip.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('Mes astuces publiées', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final published = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const PublishTipScreen()));
              if (published == true) _load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final published = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const PublishTipScreen()));
          if (published == true) _load();
        },
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Publier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tips.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('💡', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 16),
                        Text('Vous n\'avez pas encore publié d\'astuce',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text('Appuyez sur + pour partager un conseil santé avec vos patients.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tips.length,
                    itemBuilder: (_, i) {
                      final tip = _tips[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Text(tip.categoryEmoji, style: const TextStyle(fontSize: 28)),
                          title: Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(_visibilityIcon(tip.visibility), size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(tip.visibility == 'ALL' ? 'Tout le monde' : tip.visibility == 'CITY' ? 'Une ville' : 'Quartiers ciblés',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                const Spacer(),
                                Text('${tip.viewsCount} vues', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              ]),
                              const SizedBox(height: 2),
                              Text(tip.timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                            onPressed: () => _delete(tip),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _visibilityIcon(String v) {
    if (v == 'CITY') return Icons.location_city;
    if (v == 'DISTRICT') return Icons.place;
    return Icons.public;
  }
}
