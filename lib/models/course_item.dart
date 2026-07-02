enum CourseItemType { material, assignment, quiz }

class CourseItem {
  final String id;
  final String courseId;
  final CourseItemType type;
  final String title;
  final String description;
  final String link;
  final String dueDate;
  final String fileName;
  final String filePath;
  final String question;
  final List<String> choices;
  final int correctChoiceIndex;
  final String createdBy;
  final DateTime createdAt;

  const CourseItem({
    required this.id,
    required this.courseId,
    required this.type,
    required this.title,
    required this.description,
    required this.link,
    required this.dueDate,
    required this.fileName,
    required this.filePath,
    required this.question,
    required this.choices,
    required this.correctChoiceIndex,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isMaterial => type == CourseItemType.material;
  bool get isAssignment => type == CourseItemType.assignment;
  bool get isQuiz => type == CourseItemType.quiz;
  bool get hasFile => fileName.trim().isNotEmpty;

  String get typeLabel {
    switch (type) {
      case CourseItemType.material:
        return 'Material';
      case CourseItemType.assignment:
        return 'Assignment';
      case CourseItemType.quiz:
        return 'Quiz';
    }
  }

  CourseItem copyWith({
    String? id,
    String? courseId,
    CourseItemType? type,
    String? title,
    String? description,
    String? link,
    String? dueDate,
    String? fileName,
    String? filePath,
    String? question,
    List<String>? choices,
    int? correctChoiceIndex,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CourseItem(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      dueDate: dueDate ?? this.dueDate,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      question: question ?? this.question,
      choices: choices ?? this.choices,
      correctChoiceIndex: correctChoiceIndex ?? this.correctChoiceIndex,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'type': type.name,
      'title': title,
      'description': description,
      'link': link,
      'dueDate': dueDate,
      'fileName': fileName,
      'filePath': filePath,
      'question': question,
      'choices': choices,
      'correctChoiceIndex': correctChoiceIndex,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      type: _typeFromString(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      link: json['link'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      question: json['question'] as String? ?? '',
      choices: List<String>.from(json['choices'] as List? ?? []),
      correctChoiceIndex: json['correctChoiceIndex'] as int? ?? 0,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static CourseItemType _typeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'assignment':
        return CourseItemType.assignment;
      case 'quiz':
        return CourseItemType.quiz;
      case 'material':
      default:
        return CourseItemType.material;
    }
  }
}
