class DocumentModel {
  final String id;
  final String title;
  final String? documentType;
  final String? fileUrl;
  final String? uploadedAt;

  DocumentModel({
    required this.id,
    required this.title,
    this.documentType,
    this.fileUrl,
    this.uploadedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ??
             json['name']?.toString() ?? 'Document',
      documentType: json['document_type']?.toString() ??
                    json['type']?.toString(),
      fileUrl: json['file']?.toString() ?? json['file_url']?.toString(),
      uploadedAt: json['uploaded_at']?.toString() ??
                  json['created_at']?.toString(),
    );
  }

  String get typeLabel {
    switch (documentType?.toLowerCase()) {
      case 'prescription': return 'Ordonnance';
      case 'report':       return 'Rapport';
      case 'lab_result':   return 'Résultat labo';
      case 'imaging':      return 'Imagerie';
      default:             return documentType ?? 'Document';
    }
  }

  String get formattedDate {
    if (uploadedAt == null) return '';
    try {
      final d = DateTime.parse(uploadedAt!);
      return '${d.day.toString().padLeft(2, '0')}/'
             '${d.month.toString().padLeft(2, '0')}/'
             '${d.year}';
    } catch (_) {
      return uploadedAt!;
    }
  }
}
