import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../models/course_item.dart';
import '../models/submission.dart';
import '../services/local_database.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/course_item_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import 'create_course_item_screen.dart';
import 'submit_course_item_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final AppUser currentUser;
  final Course course;

  const CourseDetailScreen({
    super.key,
    required this.currentUser,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  final _database = LocalDatabase();

  List<CourseItem> _items = [];
  List<AppUser> _users = [];

  List<AssignmentSubmission> _assignmentSubmissions = [];
  List<QuizSubmission> _quizSubmissions = [];

  bool _isLoading = true;

  late final TabController _tabController;

  List<CourseItem> get _materials =>
      _items.where((item) => item.type == CourseItemType.material).toList();

  List<CourseItem> get _assignments =>
      _items.where((item) => item.type == CourseItemType.assignment).toList();

  List<CourseItem> get _quizzes =>
      _items.where((item) => item.type == CourseItemType.quiz).toList();

  List<AppUser> get _students {
    return _users
        .where((user) => widget.course.studentIds.contains(user.id))
        .toList();
  }

  AppUser? get _instructor {
    for (final user in _users) {
      if (user.id == widget.course.instructorId) return user;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final items = await _database.getItemsForCourse(widget.course.id);
    final users = await _database.getUsers();
    final assignmentSubmissions = await _database.getSubmissions();
    final quizSubmissions = await _database.getQuizSubmissions();

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (!mounted) return;

    setState(() {
      _items = items;
      _users = users;
      _assignmentSubmissions = assignmentSubmissions;
      _quizSubmissions = quizSubmissions;
      _isLoading = false;
    });
  }

  Future<void> _openCreateItem() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateCourseItemScreen(
          currentUser: widget.currentUser,
          course: widget.course,
        ),
      ),
    );

    await _loadData();
  }

  AssignmentSubmission? _assignmentSubmissionForCurrentStudent(String itemId) {
    for (final submission in _assignmentSubmissions) {
      if (submission.assignmentId == itemId &&
          submission.studentId == widget.currentUser.id) {
        return submission;
      }
    }

    return null;
  }

  QuizSubmission? _quizSubmissionForCurrentStudent(String itemId) {
    for (final submission in _quizSubmissions) {
      if (submission.quizId == itemId &&
          submission.studentId == widget.currentUser.id) {
        return submission;
      }
    }

    return null;
  }

  int _submissionCountForItem(CourseItem item) {
    if (item.isAssignment) {
      return _assignmentSubmissions
          .where((submission) => submission.assignmentId == item.id)
          .length;
    }

    if (item.isQuiz) {
      return _quizSubmissions
          .where((submission) => submission.quizId == item.id)
          .length;
    }

    return 0;
  }

  bool _studentSubmittedItem(CourseItem item) {
    if (item.isAssignment) {
      return _assignmentSubmissionForCurrentStudent(item.id) != null;
    }

    if (item.isQuiz) {
      return _quizSubmissionForCurrentStudent(item.id) != null;
    }

    return false;
  }

  Future<void> _openAttachedFile(CourseItem item) async {
    if (item.filePath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No local file path is available for this attachment.'),
        ),
      );
      return;
    }

    final result = await OpenFilex.open(item.filePath);

    if (!mounted) return;

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: ${result.message}')),
      );
    }
  }

  Future<void> _openSubmissionFile({required String filePath}) async {
    if (filePath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No local file path is available for this submission.'),
        ),
      );
      return;
    }

    final result = await OpenFilex.open(filePath);

    if (!mounted) return;

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open submission file: ${result.message}'),
        ),
      );
    }
  }

  Future<void> _showGradeDialog({
    required String submissionId,
    required bool isQuiz,
    required String studentName,
    double? currentGrade,
    double? currentMaxGrade,
    String currentFeedback = '',
  }) async {
    final gradeController = TextEditingController(
      text: currentGrade == null ? '' : _formatGradeInput(currentGrade),
    );
    final maxGradeController = TextEditingController(
      text: currentMaxGrade == null
          ? '100'
          : _formatGradeInput(currentMaxGrade),
    );
    final feedbackController = TextEditingController(text: currentFeedback);

    String? errorMessage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Grade $studentName',
                style: const TextStyle(
                  color: AppTheme.primaryIndigo,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: gradeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        prefixIcon: Icon(Icons.grade_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: maxGradeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Maximum grade',
                        prefixIcon: Icon(Icons.scoreboard_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Feedback',
                        prefixIcon: Icon(Icons.feedback_rounded),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: AppTheme.pink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final grade = double.tryParse(gradeController.text.trim());
                    final maxGrade = double.tryParse(
                      maxGradeController.text.trim(),
                    );

                    if (grade == null || maxGrade == null) {
                      setDialogState(() {
                        errorMessage = 'Please enter valid numbers.';
                      });
                      return;
                    }

                    if (maxGrade <= 0) {
                      setDialogState(() {
                        errorMessage =
                            'Maximum grade must be greater than zero.';
                      });
                      return;
                    }

                    if (grade < 0 || grade > maxGrade) {
                      setDialogState(() {
                        errorMessage =
                            'Grade must be between 0 and the maximum grade.';
                      });
                      return;
                    }

                    if (isQuiz) {
                      await _database.gradeQuizSubmission(
                        submissionId: submissionId,
                        grade: grade,
                        maxGrade: maxGrade,
                        feedback: feedbackController.text.trim(),
                      );
                    } else {
                      await _database.gradeAssignmentSubmission(
                        submissionId: submissionId,
                        grade: grade,
                        maxGrade: maxGrade,
                        feedback: feedbackController.text.trim(),
                      );
                    }

                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }

                    if (!mounted) return;

                    await Future.delayed(const Duration(milliseconds: 120));

                    if (!mounted) return;

                    await _loadData();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$studentName was graded successfully.'),
                      ),
                    );
                  },
                  child: const Text('Save Grade'),
                ),
              ],
            );
          },
        );
      },
    );

    gradeController.dispose();
    maxGradeController.dispose();
    feedbackController.dispose();
  }

  void _showInstructorSubmissions(CourseItem item) {
    final isQuiz = item.isQuiz;

    final submissions = isQuiz
        ? _quizSubmissions
              .where((submission) => submission.quizId == item.id)
              .toList()
        : _assignmentSubmissions
              .where((submission) => submission.assignmentId == item.id)
              .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.72,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.fact_check_rounded,
                        color: AppTheme.primaryIndigo,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${item.title} Submissions',
                          style: const TextStyle(
                            color: AppTheme.primaryIndigo,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (submissions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No students have submitted this ${isQuiz ? 'quiz' : 'assignment'} yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.darkText.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: submissions.length,
                        itemBuilder: (context, index) {
                          final submission = submissions[index];

                          if (submission is QuizSubmission) {
                            return _SubmissionReviewCard(
                              studentName: submission.studentName,
                              fileName: submission.fileName,
                              submittedAt: submission.submittedAt,
                              gradeLabel: submission.gradeLabel,
                              isGraded: submission.isGraded,
                              studentNote: submission.note,
                              feedback: submission.feedback,
                              onOpenFile: () => _openSubmissionFile(
                                filePath: submission.filePath,
                              ),
                              onGrade: () {
                                Navigator.of(context).pop();

                                Future.delayed(
                                  const Duration(milliseconds: 180),
                                  () {
                                    if (!mounted) return;

                                    _showGradeDialog(
                                      submissionId: submission.id,
                                      isQuiz: true,
                                      studentName: submission.studentName,
                                      currentGrade: submission.grade,
                                      currentMaxGrade: submission.maxGrade,
                                      currentFeedback: submission.feedback,
                                    );
                                  },
                                );
                              },
                            );
                          }

                          final assignmentSubmission =
                              submission as AssignmentSubmission;

                          return _SubmissionReviewCard(
                            studentName: assignmentSubmission.studentName,
                            fileName: assignmentSubmission.fileName,
                            submittedAt: assignmentSubmission.submittedAt,
                            gradeLabel: assignmentSubmission.gradeLabel,
                            isGraded: assignmentSubmission.isGraded,
                            studentNote: assignmentSubmission.answerText,
                            feedback: assignmentSubmission.feedback,
                            onOpenFile: () => _openSubmissionFile(
                              filePath: assignmentSubmission.filePath,
                            ),
                            onGrade: () {
                              Navigator.of(context).pop();

                              Future.delayed(
                                const Duration(milliseconds: 180),
                                () {
                                  if (!mounted) return;

                                  _showGradeDialog(
                                    submissionId: assignmentSubmission.id,
                                    isQuiz: false,
                                    studentName:
                                        assignmentSubmission.studentName,
                                    currentGrade: assignmentSubmission.grade,
                                    currentMaxGrade:
                                        assignmentSubmission.maxGrade,
                                    currentFeedback:
                                        assignmentSubmission.feedback,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatGradeInput(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  Future<void> _submitItem(CourseItem item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SubmitCourseItemScreen(
          currentUser: widget.currentUser,
          course: widget.course,
          item: item,
        ),
      ),
    );

    if (changed == true) {
      await _loadData();
    }
  }

  void _showItemDetails(CourseItem item) {
    final createdDate = DateFormat(
      'MMM d, yyyy - h:mm a',
    ).format(item.createdAt);

    final hasStudentSubmitted = _studentSubmittedItem(item);
    final submissionCount = _submissionCountForItem(item);
    final assignmentSubmission = item.isAssignment
        ? _assignmentSubmissionForCurrentStudent(item.id)
        : null;
    final quizSubmission = item.isQuiz
        ? _quizSubmissionForCurrentStudent(item.id)
        : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.typeLabel,
                    style: const TextStyle(
                      color: AppTheme.violet,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.description.isEmpty
                        ? 'No description was added.'
                        : item.description,
                    style: TextStyle(
                      color: AppTheme.darkText.withValues(alpha: 0.68),
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: Icons.calendar_month_rounded,
                    label: 'Created',
                    value: createdDate,
                  ),
                  if (item.dueDate.isNotEmpty)
                    _DetailRow(
                      icon: Icons.timer_rounded,
                      label: 'Due date',
                      value: item.dueDate,
                    ),
                  if (item.hasFile)
                    _DetailRow(
                      icon: Icons.attach_file_rounded,
                      label: 'Attached file',
                      value: item.fileName,
                    ),
                  if (widget.currentUser.isInstructor &&
                      (item.isAssignment || item.isQuiz))
                    _DetailRow(
                      icon: Icons.people_alt_rounded,
                      label: 'Submissions',
                      value: '$submissionCount received',
                    ),
                  if (widget.currentUser.isStudent &&
                      (item.isAssignment || item.isQuiz))
                    _DetailRow(
                      icon: hasStudentSubmitted
                          ? Icons.check_circle_rounded
                          : Icons.pending_actions_rounded,
                      label: 'Your status',
                      value: hasStudentSubmitted
                          ? 'Submitted'
                          : 'Not submitted yet',
                    ),
                  if (assignmentSubmission != null)
                    _DetailRow(
                      icon: Icons.upload_file_rounded,
                      label: 'Your file',
                      value: assignmentSubmission.fileName,
                    ),
                  if (quizSubmission != null)
                    _DetailRow(
                      icon: Icons.upload_file_rounded,
                      label: 'Your file',
                      value: quizSubmission.fileName,
                    ),
                  if (assignmentSubmission != null)
                    _DetailRow(
                      icon: Icons.grade_rounded,
                      label: 'Grade',
                      value: assignmentSubmission.gradeLabel,
                    ),
                  if (assignmentSubmission != null &&
                      assignmentSubmission.feedback.trim().isNotEmpty)
                    _DetailRow(
                      icon: Icons.feedback_rounded,
                      label: 'Feedback',
                      value: assignmentSubmission.feedback,
                    ),
                  if (quizSubmission != null)
                    _DetailRow(
                      icon: Icons.grade_rounded,
                      label: 'Grade',
                      value: quizSubmission.gradeLabel,
                    ),
                  if (quizSubmission != null &&
                      quizSubmission.feedback.trim().isNotEmpty)
                    _DetailRow(
                      icon: Icons.feedback_rounded,
                      label: 'Feedback',
                      value: quizSubmission.feedback,
                    ),
                  const SizedBox(height: 18),
                  if (item.hasFile)
                    _ActionButton(
                      text: 'Open Attached File',
                      icon: Icons.visibility_rounded,
                      isPrimary: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        _openAttachedFile(item);
                      },
                    ),

                  if (widget.currentUser.isInstructor &&
                      (item.isAssignment || item.isQuiz)) ...[
                    const SizedBox(height: 10),
                    _ActionButton(
                      text: 'Review Submissions',
                      icon: Icons.fact_check_rounded,
                      isPrimary: !item.hasFile,
                      onTap: () {
                        Navigator.of(context).pop();
                        _showInstructorSubmissions(item);
                      },
                    ),
                  ],

                  if (widget.currentUser.isStudent &&
                      (item.isAssignment || item.isQuiz)) ...[
                    const SizedBox(height: 10),
                    _ActionButton(
                      text: hasStudentSubmitted
                          ? 'Replace Submission'
                          : 'Upload Submission',
                      icon: Icons.cloud_upload_rounded,
                      isPrimary: !item.hasFile,
                      onTap: () {
                        Navigator.of(context).pop();
                        _submitItem(item);
                      },
                    ),
                  ],
                  if (assignmentSubmission != null) ...[
                    const SizedBox(height: 10),
                    _ActionButton(
                      text: 'Open My Submission',
                      icon: Icons.file_open_rounded,
                      isPrimary: false,
                      onTap: () {
                        Navigator.of(context).pop();
                        _openSubmissionFile(
                          filePath: assignmentSubmission.filePath,
                        );
                      },
                    ),
                  ],
                  if (quizSubmission != null) ...[
                    const SizedBox(height: 10),
                    _ActionButton(
                      text: 'Open My Submission',
                      icon: Icons.file_open_rounded,
                      isPrimary: false,
                      onTap: () {
                        Navigator.of(context).pop();
                        _openSubmissionFile(filePath: quizSubmission.filePath);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final createdDate = DateFormat(
      'MMM d, yyyy',
    ).format(widget.course.createdAt);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        floatingActionButton: widget.currentUser.isInstructor
            ? FloatingActionButton.extended(
                onPressed: _openCreateItem,
                backgroundColor: AppTheme.primaryIndigo,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add Content',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              )
            : null,
        body: AnimatedBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: _buildTopBar(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
                          children: [
                            _buildCourseHeader(createdDate),
                            const SizedBox(height: 16),
                            _buildStableTabBar(),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.55,
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildStreamTab(),
                                        _buildItemsTab(
                                          items: _materials,
                                          icon: Icons.menu_book_rounded,
                                          title: 'No materials yet',
                                          message:
                                              widget.currentUser.isInstructor
                                              ? 'Tap Add Content to post your first lecture or note.'
                                              : 'Your instructor has not posted materials yet.',
                                        ),
                                        _buildItemsTab(
                                          items: _assignments,
                                          icon: Icons
                                              .assignment_turned_in_rounded,
                                          title: 'No assignments yet',
                                          message:
                                              widget.currentUser.isInstructor
                                              ? 'Tap Add Content to create the first assignment.'
                                              : 'There are no assignments for this course yet.',
                                        ),
                                        _buildItemsTab(
                                          items: _quizzes,
                                          icon: Icons.quiz_rounded,
                                          title: 'No quizzes yet',
                                          message:
                                              widget.currentUser.isInstructor
                                              ? 'Tap Add Content to create a quiz.'
                                              : 'There are no quizzes available yet.',
                                        ),
                                        _buildPeopleTab(),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStableTabBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.68),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryIndigo, AppTheme.violet],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.violet.withValues(alpha: 0.24),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.darkText.withValues(alpha: 0.54),
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
        tabs: const [
          Tab(
            iconMargin: EdgeInsets.only(bottom: 2),
            icon: Icon(Icons.dynamic_feed_rounded, size: 17),
            text: 'Stream',
          ),
          Tab(
            iconMargin: EdgeInsets.only(bottom: 2),
            icon: Icon(Icons.menu_book_rounded, size: 17),
            text: 'Materials',
          ),
          Tab(
            iconMargin: EdgeInsets.only(bottom: 2),
            icon: Icon(Icons.assignment_turned_in_rounded, size: 17),
            text: 'Tasks',
          ),
          Tab(
            iconMargin: EdgeInsets.only(bottom: 2),
            icon: Icon(Icons.quiz_rounded, size: 17),
            text: 'Quizzes',
          ),
          Tab(
            iconMargin: EdgeInsets.only(bottom: 2),
            icon: Icon(Icons.groups_rounded, size: 17),
            text: 'People',
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppTheme.primaryIndigo,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.course.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.primaryIndigo,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseHeader(String createdDate) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'course-${widget.course.id}',
                child: Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryIndigo,
                        AppTheme.violet,
                        AppTheme.pink,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.violet.withValues(alpha: 0.22),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.name,
                      style: const TextStyle(
                        color: AppTheme.primaryIndigo,
                        fontWeight: FontWeight.w900,
                        fontSize: 23,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Professor ${widget.course.instructorName}',
                      style: TextStyle(
                        color: AppTheme.darkText.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            widget.course.description.isEmpty
                ? 'No course description was added yet.'
                : widget.course.description,
            style: TextStyle(
              color: AppTheme.darkText.withValues(alpha: 0.64),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderPill(
                icon: Icons.qr_code_2_rounded,
                label: widget.course.code,
                color: AppTheme.primaryIndigo,
              ),
              _HeaderPill(
                icon: Icons.calendar_month_rounded,
                label: createdDate,
                color: AppTheme.pink,
              ),
              _HeaderPill(
                icon: Icons.groups_rounded,
                label: '${widget.course.studentIds.length} Students',
                color: AppTheme.violet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreamTab() {
    if (_items.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.dynamic_feed_rounded,
          title: 'Course stream is quiet',
          message: widget.currentUser.isInstructor
              ? 'Post materials, assignments or quizzes and they will appear here.'
              : 'New materials, assignments and quizzes will appear here once posted.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        _buildStreamIntro(),
        const SizedBox(height: 14),
        ..._items.map(
          (item) =>
              CourseItemCard(item: item, onTap: () => _showItemDetails(item)),
        ),
      ],
    );
  }

  Widget _buildStreamIntro() {
    return GlassCard(
      padding: const EdgeInsets.all(17),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.cyan, AppTheme.primaryIndigo],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.campaign_rounded, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              'Latest course activity appears here in one timeline.',
              style: TextStyle(
                color: AppTheme.darkText.withValues(alpha: 0.64),
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTab({
    required List<CourseItem> items,
    required IconData icon,
    required String title,
    required String message,
  }) {
    if (items.isEmpty) {
      return Center(
        child: EmptyState(icon: icon, title: title, message: message),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: items
          .map(
            (item) =>
                CourseItemCard(item: item, onTap: () => _showItemDetails(item)),
          )
          .toList(),
    );
  }

  Widget _buildPeopleTab() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        _buildPersonSectionTitle('Instructor'),
        _PersonCard(
          name: _instructor?.name ?? widget.course.instructorName,
          role: 'Course Instructor',
          icon: Icons.co_present_rounded,
          color: AppTheme.primaryIndigo,
        ),
        const SizedBox(height: 20),
        _buildPersonSectionTitle('Students'),
        if (_students.isEmpty)
          EmptyState(
            icon: Icons.groups_2_rounded,
            title: 'No students enrolled yet',
            message: 'Students will appear here after joining the course.',
          )
        else
          ..._students.map(
            (student) => _PersonCard(
              name: student.name,
              role: 'Student',
              icon: Icons.school_rounded,
              color: AppTheme.pink,
            ),
          ),
      ],
    );
  }

  Widget _buildPersonSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.darkText,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.violet, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppTheme.darkText, height: 1.35),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: AppTheme.darkText.withValues(alpha: 0.68),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeaderPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final String name;
  final String role;
  final IconData icon;
  final Color color;

  const _PersonCard({
    required this.name,
    required this.role,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      borderRadius: 22,
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppTheme.primaryIndigo,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  role,
                  style: TextStyle(
                    color: AppTheme.darkText.withValues(alpha: 0.54),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isPrimary
        ? const LinearGradient(
            colors: [AppTheme.primaryIndigo, AppTheme.violet],
          )
        : LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.88),
              Colors.white.withValues(alpha: 0.62),
            ],
          );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(17),
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.75)),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppTheme.violet.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.primaryIndigo,
              size: 20,
            ),
            const SizedBox(width: 9),
            Text(
              text,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppTheme.primaryIndigo,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionReviewCard extends StatelessWidget {
  final String studentName;
  final String fileName;
  final DateTime submittedAt;
  final String gradeLabel;
  final bool isGraded;
  final String studentNote;
  final String feedback;
  final VoidCallback onOpenFile;
  final VoidCallback onGrade;

  const _SubmissionReviewCard({
    required this.studentName,
    required this.fileName,
    required this.submittedAt,
    required this.gradeLabel,
    required this.isGraded,
    required this.studentNote,
    required this.feedback,
    required this.onOpenFile,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    final submittedDate = DateFormat(
      'MMM d, yyyy - h:mm a',
    ).format(submittedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryIndigo, AppTheme.violet],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(
                        color: AppTheme.primaryIndigo,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      submittedDate,
                      style: TextStyle(
                        color: AppTheme.darkText.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isGraded
                      ? AppTheme.cyan.withValues(alpha: 0.13)
                      : AppTheme.pink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  gradeLabel,
                  style: TextStyle(
                    color: isGraded ? AppTheme.primaryIndigo : AppTheme.pink,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                color: AppTheme.violet,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  fileName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.darkText.withValues(alpha: 0.64),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.3,
                  ),
                ),
              ),
            ],
          ),
          if (studentNote.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        color: AppTheme.primaryIndigo,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Student note',
                        style: TextStyle(
                          color: AppTheme.primaryIndigo,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    studentNote,
                    style: TextStyle(
                      color: AppTheme.darkText.withValues(alpha: 0.66),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (feedback.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppTheme.cyan.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.cyan.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.feedback_rounded,
                        color: AppTheme.primaryIndigo,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Instructor feedback',
                        style: TextStyle(
                          color: AppTheme.primaryIndigo,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    feedback,
                    style: TextStyle(
                      color: AppTheme.darkText.withValues(alpha: 0.66),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmallSubmissionButton(
                  text: 'Open File',
                  icon: Icons.file_open_rounded,
                  isPrimary: false,
                  onTap: onOpenFile,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallSubmissionButton(
                  text: isGraded ? 'Edit Grade' : 'Grade',
                  icon: Icons.grade_rounded,
                  isPrimary: true,
                  onTap: onGrade,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallSubmissionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SmallSubmissionButton({
    required this.text,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppTheme.primaryIndigo, AppTheme.violet],
                )
              : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.85)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isPrimary ? Colors.white : AppTheme.primaryIndigo,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppTheme.primaryIndigo,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
