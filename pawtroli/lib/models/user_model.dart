// lib/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;

  UserModel({required this.id, required this.email, required this.name, required this.phone});

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'phone': phone,
    'role': 'user', // Default role
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    email: json["type"] ?? "",
    phone: json["age"] ?? "",
  );
}