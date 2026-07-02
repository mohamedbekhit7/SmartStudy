enum UserRole { student, instructor }

class AppUser {
  final String id;
  final String name;
  final String password;
  final UserRole role;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  bool get isStudent => role == UserRole.student;
  bool get isInstructor => role == UserRole.instructor;

  String get roleLabel {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.instructor:
        return 'Instructor';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      role: _roleFromString(json['role'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static UserRole _roleFromString(String value) {
    switch (value.toLowerCase()) {
      case 'instructor':
        return UserRole.instructor;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}
