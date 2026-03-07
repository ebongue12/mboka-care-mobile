class PatientModel {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? bloodGroup;
  final String? chronicConditions;
  final String? allergies;
  final String? emergencyNotes;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final Map<String, dynamic>? qrPublicPayload;

  PatientModel({required this.id, required this.userId, required this.firstName,
    required this.lastName, required this.dateOfBirth, this.bloodGroup,
    this.chronicConditions, this.allergies, this.emergencyNotes,
    this.emergencyContactName, this.emergencyContactPhone, this.qrPublicPayload});

  String get fullName => '$firstName $lastName';

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
    id: json['id'], userId: json['user'], firstName: json['first_name'],
    lastName: json['last_name'], dateOfBirth: DateTime.parse(json['date_of_birth']),
    bloodGroup: json['blood_group'], chronicConditions: json['chronic_conditions'],
    allergies: json['allergies'], emergencyNotes: json['emergency_notes'],
    emergencyContactName: json['emergency_contact_name'],
    emergencyContactPhone: json['emergency_contact_phone'],
    qrPublicPayload: json['qr_public_payload'],
  );
}
