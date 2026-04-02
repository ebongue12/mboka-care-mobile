class PatientModel {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final String? chronicConditions;
  final String? allergies;
  final String? emergencyNotes;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final Map<String, dynamic>? qrPublicPayload;
  final String? accountType;       // INDIVIDUAL | FAMILY_CHIEF
  final String? countryResidence;
  final String? cityResidence;
  final String? districtResidence;

  PatientModel({required this.id, required this.userId, required this.firstName,
    required this.lastName, this.dateOfBirth, this.bloodGroup,
    this.chronicConditions, this.allergies, this.emergencyNotes,
    this.emergencyContactName, this.emergencyContactPhone, this.qrPublicPayload,
    this.accountType, this.countryResidence, this.cityResidence, this.districtResidence});

  String get fullName => '$firstName $lastName'.trim();

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    DateTime? dob;
    try {
      if (json['date_of_birth'] != null) dob = DateTime.parse(json['date_of_birth'].toString());
    } catch (_) {}

    return PatientModel(
      id: json['id']?.toString() ?? '',
      userId: json['user']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      dateOfBirth: dob,
      bloodGroup: json['blood_group']?.toString(),
      chronicConditions: json['chronic_conditions']?.toString(),
      allergies: json['allergies']?.toString(),
      emergencyNotes: json['emergency_notes']?.toString(),
      emergencyContactName: json['emergency_contact_name']?.toString(),
      emergencyContactPhone: json['emergency_contact_phone']?.toString(),
      qrPublicPayload: json['qr_public_payload'] is Map
        ? Map<String, dynamic>.from(json['qr_public_payload'])
        : null,
      accountType: json['account_type']?.toString(),
      countryResidence: json['country_residence']?.toString(),
      cityResidence: json['city_residence']?.toString(),
      districtResidence: json['district_residence']?.toString(),
    );
  }

  bool get isFamilyChief => accountType == 'FAMILY_CHIEF';
}
