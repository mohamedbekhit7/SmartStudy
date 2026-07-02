class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String courseId;
  final String studentId;
  final String studentName;
  final String answerText;
  final String fileName;
  final String filePath;
  final DateTime submittedAt;

  const AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.courseId,
    required this.studentId,
    required this.studentName,
    required this.answerText,
    required this.fileName,
    required this.filePath,
    required this.submittedAt,
  });

  bool get hasFile => fileName.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'courseId': courseId,
      'studentId': studentId,
      'studentName': studentName,
      'answerText': answerText,
      'fileName': fileName,
      'filePath': filePath,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      id: json['id'] as String,
      assignmentId: json['assignmentId'] as String,
      courseId: json['courseId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      answerText: json['answerText'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }
}

class QuizSubmission {
  final String id;
  final String quizId;
  final String courseId;
  final String studentId;
  final String studentName;
  final String note;
  final String fileName;
  final String filePath;
  final DateTime submittedAt;

  const QuizSubmission({
    required this.id,
    required this.quizId,
    required this.courseId,
    required this.studentId,
    required this.studentName,
    required this.note,
    required this.fileName,
    required this.filePath,
    required this.submittedAt,
  });

  bool get hasFile => fileName.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'courseId': courseId,
      'studentId': studentId,
      'studentName': studentName,
      'note': note,
      'fileName': fileName,
      'filePath': filePath,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory QuizSubmission.fromJson(Map<String, dynamic> json) {
    return QuizSubmission(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      courseId: json['courseId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      note: json['note'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }
}

class QuizResult {
  final String id;
  final String quizId;
  final String courseId;
  final String studentId;
  final String studentName;
  final int score;
  final int total;
  final DateTime submittedAt;

  const QuizResult({
    required this.id,
    required this.quizId,
    required this.courseId,
    required this.studentId,
    required this.studentName,
    required this.score,
    required this.total,
    required this.submittedAt,
  });

  String get scoreLabel => '$score / $total';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'courseId': courseId,
      'studentId': studentId,
      'studentName': studentName,
      'score': score,
      'total': total,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      courseId: json['courseId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      score: json['score'] as int,
      total: json['total'] as int,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }
}
