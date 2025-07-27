class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String profileImage;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.role = 'user', // Set default role to 'user'
    required this.profileImage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'phone': phone,
    'role': role,
    'profileImage': profileImage,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["uid"] ?? "",
    name: json["name"] ?? "",
    email: json["email"] ?? "",
    phone: json["phone"] ?? "",
    role: json["role"] ?? 'user', // Default to 'user'
    profileImage: json["profileImage"] ?? "",
  );
}