class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String role;
  final String country;
  final String city;
  final String district;

  UserModel({required this.id, required this.phone, this.email, required this.role,
    required this.country, required this.city, required this.district});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    email: json['email']?.toString(),
    role: json['role']?.toString() ?? 'PATIENT',
    country: json['country']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    district: json['district']?.toString() ?? '',
  );
}
