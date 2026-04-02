class HealthcareStaff {
  final String id;
  final String staffType;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String city;
  final String establishment;
  final String? specialty;
  final int yearsExperience;
  final String patientsTreatedRange;
  final bool verified;
  final String verificationStatus;
  final int totalScans;
  final int totalPatientsFollowed;
  final DateTime createdAt;

  HealthcareStaff({
    required this.id,
    required this.staffType,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.city,
    required this.establishment,
    this.specialty,
    required this.yearsExperience,
    required this.patientsTreatedRange,
    required this.verified,
    required this.verificationStatus,
    required this.totalScans,
    required this.totalPatientsFollowed,
    required this.createdAt,
  });

  factory HealthcareStaff.fromJson(Map<String, dynamic> json) {
    return HealthcareStaff(
      id: json['id'].toString(),
      staffType: json['staff_type']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      establishment: json['establishment']?.toString() ?? '',
      specialty: json['specialty']?.toString(),
      yearsExperience: json['years_experience'] ?? 0,
      patientsTreatedRange: json['patients_treated_range']?.toString() ?? '0-100',
      verified: json['verified'] ?? false,
      verificationStatus: json['verification_status']?.toString() ?? 'PENDING',
      totalScans: json['total_scans'] ?? 0,
      totalPatientsFollowed: json['total_patients_followed'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get staffTypeDisplay {
    switch (staffType) {
      case 'MEDECIN': return 'Médecin';
      case 'INFIRMIER': return 'Infirmier/Infirmière';
      case 'SECOURISTE': return 'Secouriste';
      case 'AIDE_SOIGNANT': return 'Aide-soignant(e)';
      case 'SAGE_FEMME': return 'Sage-femme';
      default: return staffType;
    }
  }
}
