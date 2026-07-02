class AssignmentSubmission {
  final String id;
  final String assignmentId;
  final String courseId;
  final String studentId;
  final String studentName;
  final String answerText;
  final String fileName;
  final String filePath;
  final double? grade;
  final double? maxGrade;
  final String feedback;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  const AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.courseId,
    required this.studentId,
    required this.studentName,
    required this.answerText,
    required this.fileName,
    required this.filePath,
    required this.grade,
    required this.maxGrade,
    required this.feedback,
    required this.submittedAt,
    required this.gradedAt,
  });

  bool get hasFile => fileName.trim().isNotEmpty;
  bool get isGraded => grade != null && maxGrade != null;

  String get gradeLabel {
    if (!isGraded) return 'Not graded yet';
    return '${_formatNumber(grade!)} / ${_formatNumber(maxGrade!)}';
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  AssignmentSubmission copyWith({
    String? id,
    String? assignmentId,
    String? courseId,
    String? studentId,
    String? studentName,
    String? answerText,
    String? fileName,
    String? filePath,
    double? grade,
    double? maxGrade,
    String? feedback,
    DateTime? submittedAt,
    DateTime? gradedAt,
    bool clearGrade = false,
  }) {
    return AssignmentSubmission(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      courseId: courseId ?? this.courseId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      answerText: answerText ?? this.answerText,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      grade: clearGrade ? null : grade ?? this.grade,
      maxGrade: clearGrade ? null : maxGrade ?? this.maxGrade,
      feedback: feedback ?? this.feedback,
      submittedAt: submittedAt ?? this.submittedAt,
      gradedAt: clearGrade ? null : gradedAt ?? this.gradedAt,
    );
  }

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
      'grade': grade,
      'maxGrade': maxGrade,
      'feedback': feedback,
      'submittedAt': submittedAt.toIso8601String(),
      'gradedAt': gradedAt?.toIso8601String(),
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
      grade: _doubleFromJson(json['grade']),
      maxGrade: _doubleFromJson(json['maxGrade']),
      feedback: json['feedback'] as String? ?? '',
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      gradedAt: json['gradedAt'] == null || json['gradedAt'].toString().isEmpty
          ? null
          : DateTime.parse(json['gradedAt'] as String),
    );
  }

  static double? _doubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString());
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
  final double? grade;
  final double? maxGrade;
  final String feedback;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  const QuizSubmission({
    required this.id,
    required this.quizId,
    required this.courseId,
    required this.studentId,
    required this.studentName,
    required this.note,
    required this.fileName,
    required this.filePath,
    required this.grade,
    required this.maxGrade,
    required this.feedback,
    required this.submittedAt,
    required this.gradedAt,
  });

  bool get hasFile => fileName.trim().isNotEmpty;
  bool get isGraded => grade != null && maxGrade != null;

  String get gradeLabel {
    if (!isGraded) return 'Not graded yet';
    return '${_formatNumber(grade!)} / ${_formatNumber(maxGrade!)}';
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  QuizSubmission copyWith({
    String? id,
    String? quizId,
    String? courseId,
    String? studentId,
    String? studentName,
    String? note,
    String? fileName,
    String? filePath,
    double? grade,
    double? maxGrade,
    String? feedback,
    DateTime? submittedAt,
    DateTime? gradedAt,
    bool clearGrade = false,
  }) {
    return QuizSubmission(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      courseId: courseId ?? this.courseId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      note: note ?? this.note,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      grade: clearGrade ? null : grade ?? this.grade,
      maxGrade: clearGrade ? null : maxGrade ?? this.maxGrade,
      feedback: feedback ?? this.feedback,
      submittedAt: submittedAt ?? this.submittedAt,
      gradedAt: clearGrade ? null : gradedAt ?? this.gradedAt,
    );
  }

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
      'grade': grade,
      'maxGrade': maxGrade,
      'feedback': feedback,
      'submittedAt': submittedAt.toIso8601String(),
      'gradedAt': gradedAt?.toIso8601String(),
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
      grade: _doubleFromJson(json['grade']),
      maxGrade: _doubleFromJson(json['maxGrade']),
      feedback: json['feedback'] as String? ?? '',
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      gradedAt: json['gradedAt'] == null || json['gradedAt'].toString().isEmpty
          ? null
          : DateTime.parse(json['gradedAt'] as String),
    );
  }

  static double? _doubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString());
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
