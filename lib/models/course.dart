class Course {
  final String id;
  final String name;
  final String code;
  final String password;
  final String description;
  final String instructorId;
  final String instructorName;
  final DateTime createdAt;
  final List<String> studentIds;

  const Course({
    required this.id,
    required this.name,
    required this.code,
    required this.password,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.createdAt,
    required this.studentIds,
  });

  Course copyWith({
    String? id,
    String? name,
    String? code,
    String? password,
    String? description,
    String? instructorId,
    String? instructorName,
    DateTime? createdAt,
    List<String>? studentIds,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      password: password ?? this.password,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      createdAt: createdAt ?? this.createdAt,
      studentIds: studentIds ?? this.studentIds,
    );
  }

  bool isStudentEnrolled(String userId) {
    return studentIds.contains(userId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'password': password,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'createdAt': createdAt.toIso8601String(),
      'studentIds': studentIds,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      password: json['password'] as String,
      description: json['description'] as String? ?? '',
      instructorId: json['instructorId'] as String,
      instructorName: json['instructorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      studentIds: List<String>.from(json['studentIds'] as List? ?? []),
    );
  }
}
