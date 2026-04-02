class HealthStatusUpdate {
  final String id;
  final DateTime timestamp;
  final bool consultedDoctor;
  final bool newExams;
  final bool newMedications;
  final bool hospitalization;
  final String generalState; // EXCELLENT, BON, MOYEN, FAIBLE, CRITIQUE

  HealthStatusUpdate({
    required this.id,
    required this.timestamp,
    required this.consultedDoctor,
    required this.newExams,
    required this.newMedications,
    required this.hospitalization,
    required this.generalState,
  });

  factory HealthStatusUpdate.fromJson(Map<String, dynamic> json) {
    return HealthStatusUpdate(
      id: json['id']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      consultedDoctor: json['consulted_doctor'] as bool? ?? false,
      newExams: json['new_exams'] as bool? ?? false,
      newMedications: json['new_medications'] as bool? ?? false,
      hospitalization: json['hospitalization'] as bool? ?? false,
      generalState: json['general_state']?.toString() ?? 'BON',
    );
  }

  Map<String, dynamic> toJson() => {
    'consulted_doctor': consultedDoctor,
    'new_exams': newExams,
    'new_medications': newMedications,
    'hospitalization': hospitalization,
    'general_state': generalState,
  };
}
