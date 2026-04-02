import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/sharing_provider.dart';
import '../../../data/models/follower_model.dart';
import 'add_follower_screen.dart';

class FollowersListScreen extends ConsumerStatefulWidget {
  const FollowersListScreen({super.key});
  @override
  ConsumerState<FollowersListScreen> createState() =>
      _FollowersListScreenState();
}

class _FollowersListScreenState
    extends ConsumerState<FollowersListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(sharingProvider.notifier).loadFollowers());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sharingProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Mes Suiveurs',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('${state.followers.length}/3 proches autorisés',
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(sharingProvider.notifier).loadFollowers(),
          ),
        ],
      ),
      floatingActionButton: state.followers.length < 3
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddFollowerScreen()));
                if (context.mounted) {
                  ref.read(sharingProvider.notifier).loadFollowers();
                }
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Inviter'),
              backgroundColor: const Color(0xFF673AB7),
            )
          : null,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.followers.isEmpty
              ? _EmptyFollowers(
                  onAdd: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddFollowerScreen()));
                    if (context.mounted) {
                      ref.read(sharingProvider.notifier).loadFollowers();
                    }
                  },
                )
              : Column(children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF673AB7).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              const Color(0xFF673AB7).withOpacity(0.2)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFF673AB7), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vos suiveurs peuvent consulter votre QR Code d\'urgence',
                          style: TextStyle(
                              color: Color(0xFF673AB7), fontSize: 13),
                        ),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.followers.length,
                      itemBuilder: (_, i) =>
                          _FollowerCard(follower: state.followers[i]),
                    ),
                  ),
                ]),
    );
  }
}

class _FollowerCard extends ConsumerWidget {
  final FollowerModel follower;
  const _FollowerCard({required this.follower});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                const Color(0xFF673AB7).withOpacity(0.15),
            child: Text(
              follower.displayName.isNotEmpty
                  ? follower.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(follower.displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              Text(follower.followerPhone,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, children: [
                if (follower.canViewQr) _Chip('QR Code'),
                if (follower.canViewDocuments) _Chip('Documents'),
                if (follower.canViewReminders) _Chip('Rappels'),
              ]),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.person_remove_outlined,
                color: Colors.red),
            onPressed: () => _confirmRemove(context, ref),
          ),
        ]),
      ),
    );
  }

  Widget _Chip(String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF673AB7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF673AB7),
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      );

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Retirer'),
        content: Text('Retirer ${follower.displayName} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Retirer',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(sharingProvider.notifier).removeFollower(follower.id);
    }
  }
}

class _EmptyFollowers extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyFollowers({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF673AB7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.people_outline,
                size: 50, color: Color(0xFF673AB7)),
          ),
          const SizedBox(height: 20),
          const Text('Aucun suiveur',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Invitez 3 proches à suivre\nvotre état de santé',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5)),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Inviter un proche'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      );
}
