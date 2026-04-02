import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/family_provider.dart';
import '../../../data/models/family_member_model.dart';
import 'add_family_member_screen.dart';
import 'family_member_detail_screen.dart';

class FamilyListScreen extends ConsumerStatefulWidget {
  const FamilyListScreen({super.key});
  @override
  ConsumerState<FamilyListScreen> createState() => _FamilyListScreenState();
}

class _FamilyListScreenState extends ConsumerState<FamilyListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(familyProvider.notifier).loadMembers());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ma Famille',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('${state.members.length}/10 membres',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(familyProvider.notifier).loadMembers(),
          ),
        ],
      ),
      floatingActionButton: state.members.length < 10
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddFamilyMemberScreen()));
                if (context.mounted) {
                  ref.read(familyProvider.notifier).loadMembers();
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Ajouter'),
              backgroundColor: const Color(0xFF009688),
            )
          : null,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.members.isEmpty
              ? _EmptyFamily(
                  onAdd: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddFamilyMemberScreen()));
                    if (context.mounted) {
                      ref.read(familyProvider.notifier).loadMembers();
                    }
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.members.length,
                  itemBuilder: (_, i) =>
                      _MemberCard(member: state.members[i]),
                ),
    );
  }
}

class _MemberCard extends ConsumerWidget {
  final FamilyMemberModel member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => FamilyMemberDetailScreen(member: member))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  const Color(0xFF009688).withOpacity(0.15),
              child: Text(
                member.firstName.isNotEmpty
                    ? member.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF009688)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(member.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF009688).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(member.relationLabel,
                        style: const TextStyle(
                            color: Color(0xFF009688),
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ),
                  if (member.bloodGroup?.isNotEmpty == true) ...[
                    const SizedBox(width: 8),
                    Text('🩸 ${member.bloodGroup}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ]),
                if (member.phone?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(member.phone!,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ],
              ]),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer ${member.fullName} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(familyProvider.notifier).deleteMember(member.id);
    }
  }
}

class _EmptyFamily extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyFamily({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF009688).withOpacity(0.1),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.group_outlined,
              size: 50, color: Color(0xFF009688)),
        ),
        const SizedBox(height: 20),
        const Text('Aucun membre de famille',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Ajoutez jusqu\'à 10 membres\npour gérer leur santé',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5)),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.person_add),
          label: const Text('Ajouter un membre'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF009688),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    );
  }
}
