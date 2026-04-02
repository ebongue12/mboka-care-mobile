import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class UploadDocumentScreen extends ConsumerStatefulWidget {
  const UploadDocumentScreen({super.key});
  @override
  ConsumerState<UploadDocumentScreen> createState() =>
      _UploadDocumentScreenState();
}

class _UploadDocumentScreenState
    extends ConsumerState<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  String _docType = 'prescription';
  PlatformFile? _pickedFile;
  bool _loading = false;

  static const _types = [
    {'value': 'prescription', 'label': 'Ordonnance',     'icon': Icons.medication},
    {'value': 'report',       'label': 'Rapport médical', 'icon': Icons.summarize},
    {'value': 'lab_result',   'label': 'Résultat labo',  'icon': Icons.science},
    {'value': 'imaging',      'label': 'Imagerie',       'icon': Icons.image},
    {'value': 'other',        'label': 'Autre',          'icon': Icons.insert_drive_file},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez sélectionner un fichier'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    setState(() => _loading = true);
    try {
      final formData = FormData.fromMap({
        'title': _titleCtrl.text.trim(),
        'document_type': _docType,
        'file': await MultipartFile.fromFile(
          _pickedFile!.path!,
          filename: _pickedFile!.name,
        ),
      });
      await ApiClient().uploadDocument(formData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Document ajouté avec succès ✓'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erreur lors de l'envoi : $e"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ajouter un document',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              const Text('Titre du document *',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Ex: Ordonnance Dr. Martin',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 24),

              // Type de document
              const Text('Type de document *',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.map((t) {
                  final selected = _docType == t['value'];
                  return ChoiceChip(
                    avatar: Icon(t['icon'] as IconData,
                        size: 16,
                        color: selected
                            ? Colors.white
                            : const Color(0xFFE91E63)),
                    label: Text(t['label'] as String),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _docType = t['value'] as String),
                    selectedColor: const Color(0xFFE91E63),
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Sélection fichier
              const Text('Fichier *',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    border: Border.all(
                      color: _pickedFile != null
                          ? const Color(0xFFE91E63)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    Icon(
                      _pickedFile != null
                          ? Icons.check_circle
                          : Icons.cloud_upload_outlined,
                      size: 40,
                      color: _pickedFile != null
                          ? const Color(0xFFE91E63)
                          : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pickedFile != null
                          ? _pickedFile!.name
                          : 'Appuyez pour sélectionner',
                      style: TextStyle(
                        color: _pickedFile != null
                            ? Colors.black87
                            : Colors.grey,
                        fontWeight: _pickedFile != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (_pickedFile != null)
                      Text(
                        '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    const SizedBox(height: 4),
                    const Text('PDF, JPG, PNG acceptés',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                ),
              ),
              const SizedBox(height: 32),

              // Bouton envoyer
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _upload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Envoyer le document',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
