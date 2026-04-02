import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/document_provider.dart';
import '../../../app/routes.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});
  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(documentProvider.notifier).loadDocuments());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Documents Médicaux',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(documentProvider.notifier).loadDocuments(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.uploadDocument);
          if (context.mounted) {
            ref.read(documentProvider.notifier).loadDocuments();
          }
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Ajouter'),
        backgroundColor: const Color(0xFFE91E63),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorView(
                  message: state.error!,
                  onRetry: () =>
                      ref.read(documentProvider.notifier).loadDocuments(),
                )
              : state.documents.isEmpty
                  ? _EmptyView(
                      onAdd: () =>
                          Navigator.pushNamed(context, AppRoutes.uploadDocument),
                    )
                  : _DocumentList(documents: state.documents),
    );
  }
}

class _DocumentList extends StatelessWidget {
  final List documents;
  const _DocumentList({required this.documents});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (_, i) => _DocumentCard(doc: documents[i]),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final dynamic doc;
  const _DocumentCard({required this.doc});

  IconData _iconFor(String? type) {
    switch (type?.toLowerCase()) {
      case 'prescription': return Icons.medication;
      case 'report':       return Icons.summarize;
      case 'lab_result':   return Icons.science;
      case 'imaging':      return Icons.image;
      default:             return Icons.insert_drive_file;
    }
  }

  Color _colorFor(String? type) {
    switch (type?.toLowerCase()) {
      case 'prescription': return const Color(0xFF9C27B0);
      case 'report':       return const Color(0xFF2196F3);
      case 'lab_result':   return const Color(0xFF4CAF50);
      case 'imaging':      return const Color(0xFFFF9800);
      default:             return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(doc.documentType);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_iconFor(doc.documentType), color: color, size: 28),
        ),
        title: Text(doc.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(doc.typeLabel,
                  style: TextStyle(color: color, fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
            if (doc.formattedDate.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Ajouté le ${doc.formattedDate}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ],
        ),
        trailing: doc.fileUrl != null
            ? IconButton(
                icon: const Icon(Icons.open_in_new, color: Color(0xFF2196F3)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ouverture : ${doc.fileUrl}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              )
            : const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(Icons.folder_open,
              size: 55, color: Color(0xFFE91E63)),
        ),
        const SizedBox(height: 24),
        const Text('Aucun document', style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Ajoutez vos documents médicaux\n(ordonnances, analyses, radios...)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14,
                height: 1.5)),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.upload_file),
          label: const Text('Ajouter un document'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      ]),
    );
  }
}
