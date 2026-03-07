class ReminderModel {
  final String id;
  final String title;
  final String? medicationName;
  final String frequency;
  final List<String> timeSlots;
  final bool isActive;

  ReminderModel({required this.id, required this.title, this.medicationName,
    required this.frequency, required this.timeSlots, required this.isActive});

  String get frequencyDisplay {
    switch (frequency) {
      case 'DAILY': return 'Quotidien';
      case 'WEEKLY': return 'Hebdomadaire';
      default: return 'Une fois';
    }
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
    id: json['id'], title: json['title'], medicationName: json['medication_name'],
    frequency: json['frequency'] ?? 'DAILY',
    timeSlots: List<String>.from(json['time_slots'] ?? []),
    isActive: json['is_active'] ?? true,
  );
}
