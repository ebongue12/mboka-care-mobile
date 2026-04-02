class FamilyMemberModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? relation;
  final String? phone;
  final String? email;
  final String? bloodGroup;
  final String? allergies;
  final String? chronicConditions;
  final String? emergencyNotes;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String? countryOfBirth;
  final String? countryResidence;
  final String? cityResidence;
  final String? districtResidence;

  FamilyMemberModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.relation,
    this.phone,
    this.email,
    this.bloodGroup,
    this.allergies,
    this.chronicConditions,
    this.emergencyNotes,
    this.dateOfBirth,
    this.placeOfBirth,
    this.countryOfBirth,
    this.countryResidence,
    this.cityResidence,
    this.districtResidence,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get relationLabel {
    switch (relation?.toUpperCase()) {
      case 'CHILD':   return 'Enfant';
      case 'SPOUSE':  return 'Conjoint(e)';
      case 'PARENT':  return 'Parent';
      case 'SIBLING': return 'Frère/Sœur';
      default:        return 'Autre';
    }
  }

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    DateTime? dob;
    try {
      if (json['date_of_birth'] != null) {
        dob = DateTime.parse(json['date_of_birth'].toString());
      }
    } catch (_) {}
    return FamilyMemberModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      relation: json['relation']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      allergies: json['allergies']?.toString(),
      chronicConditions: json['chronic_conditions']?.toString(),
      emergencyNotes: json['emergency_notes']?.toString(),
      dateOfBirth: dob,
      placeOfBirth: json['place_of_birth']?.toString(),
      countryOfBirth: json['country_of_birth']?.toString(),
      countryResidence: json['country_residence']?.toString(),
      cityResidence: json['city_residence']?.toString(),
      districtResidence: json['district_residence']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final country = countryResidence ?? countryOfBirth ?? '';
    final city = cityResidence ?? '';
    return {
      'first_name': firstName,
      'last_name': lastName,
      'relation': relation ?? 'OTHER',
      'blood_group': bloodGroup ?? '',
      'allergies': allergies ?? '',
      'chronic_conditions': chronicConditions ?? '',
      'emergency_notes': emergencyNotes ?? '',
      'place_of_birth': placeOfBirth ?? city,
      'country_of_birth': countryOfBirth ?? country,
      'country_residence': countryResidence ?? country,
      'city_residence': cityResidence ?? city,
      'district_residence': districtResidence ?? '',
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth!.toIso8601String().split('T')[0],
    };
  }
}
