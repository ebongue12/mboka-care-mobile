class HealthTipModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String categoryDisplay;
  final String visibility;
  final String staffName;
  final String staffType;
  final String staffEstablishment;
  final int viewsCount;
  final DateTime createdAt;

  HealthTipModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.categoryDisplay,
    required this.visibility,
    required this.staffName,
    required this.staffType,
    required this.staffEstablishment,
    required this.viewsCount,
    required this.createdAt,
  });

  factory HealthTipModel.fromJson(Map<String, dynamic> json) {
    return HealthTipModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString() ?? 'AUTRE',
      categoryDisplay: json['category_display']?.toString() ?? '',
      visibility: json['visibility']?.toString() ?? 'ALL',
      staffName: json['staff_name']?.toString() ?? '',
      staffType: json['staff_type']?.toString() ?? '',
      staffEstablishment: json['staff_establishment']?.toString() ?? '',
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get categoryEmoji {
    switch (category) {
      case 'NUTRITION': return '🥗';
      case 'SPORT': return '🏃';
      case 'SANTE_MENTALE': return '🧠';
      case 'PREVENTION': return '🔬';
      case 'MEDICAMENT': return '💊';
      case 'HYGIENE': return '🧼';
      case 'GROSSESSE': return '🤰';
      case 'ENFANT': return '👶';
      default: return '💡';
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
