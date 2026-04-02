class FollowerModel {
  final String id;
  final String followerPhone;
  final String? followerName;
  final bool canViewQr;
  final bool canViewDocuments;
  final bool canViewReminders;
  final String? addedAt;

  FollowerModel({
    required this.id,
    required this.followerPhone,
    this.followerName,
    this.canViewQr = true,
    this.canViewDocuments = false,
    this.canViewReminders = false,
    this.addedAt,
  });

  String get displayName => followerName?.isNotEmpty == true
      ? followerName!
      : followerPhone;

  factory FollowerModel.fromJson(Map<String, dynamic> json) {
    return FollowerModel(
      id: json['id']?.toString() ?? '',
      followerPhone: json['follower_phone']?.toString() ??
                     json['phone']?.toString() ?? '',
      followerName: json['follower_name']?.toString() ??
                    json['name']?.toString(),
      canViewQr: json['can_view_qr'] as bool? ?? true,
      canViewDocuments: json['can_view_documents'] as bool? ?? false,
      canViewReminders: json['can_view_reminders'] as bool? ?? false,
      addedAt: json['added_at']?.toString() ??
               json['created_at']?.toString(),
    );
  }
}

class ConsultationLogModel {
  final String id;
  final String doctorName;
  final String motif;
  final String timestamp;
  final String? location;

  ConsultationLogModel({
    required this.id,
    required this.doctorName,
    required this.motif,
    required this.timestamp,
    this.location,
  });

  String get formattedDate {
    try {
      final d = DateTime.parse(timestamp);
      return '${d.day.toString().padLeft(2, '0')}/'
             '${d.month.toString().padLeft(2, '0')}/'
             '${d.year} à ${d.hour.toString().padLeft(2, '0')}h'
             '${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  factory ConsultationLogModel.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'];
    String doctorName = 'Dr Inconnu';
    if (doctor is Map) {
      final fn = doctor['first_name']?.toString() ?? '';
      final ln = doctor['last_name']?.toString() ?? '';
      doctorName = 'Dr $fn $ln'.trim();
    } else if (json['doctor_name'] != null) {
      doctorName = json['doctor_name'].toString();
    }
    return ConsultationLogModel(
      id: json['id']?.toString() ?? '',
      doctorName: doctorName,
      motif: json['motif']?.toString() ?? 'CONSULTATION',
      timestamp: json['timestamp']?.toString() ??
                 json['created_at']?.toString() ?? '',
      location: json['scan_location']?.toString(),
    );
  }
}
