// models/user_model.dart

class User {
  final String id;
  final String name;
  final String? rollNumber; // Can be null for teachers/admins
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    this.rollNumber,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      rollNumber: json['rollNumber'], // Will be null if not present
      email: json['email'],
      role: json['role'],
    );
  }
}