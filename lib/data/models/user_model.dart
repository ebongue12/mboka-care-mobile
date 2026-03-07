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
    id: json['id'], phone: json['phone'], email: json['email'],
    role: json['role'], country: json['country'], city: json['city'], district: json['district'],
  );
}
