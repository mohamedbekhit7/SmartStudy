import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../models/course_item.dart';
import '../models/submission.dart';
import '../services/local_database.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/smart_text_field.dart';

class SubmitCourseItemScreen extends StatefulWidget {
  final AppUser currentUser;
  final Course course;
  final CourseItem item;

  const SubmitCourseItemScreen({
    super.key,
    required this.currentUser,
    required this.course,
    required this.item,
  });

  @override
  State<SubmitCourseItemScreen> createState() => _SubmitCourseItemScreenState();
}

class _SubmitCourseItemScreenState extends State<SubmitCourseItemScreen>
    with SingleTickerProviderStateMixin {
  final _noteController = TextEditingController();
  final _database = LocalDatabase();

  bool _isLoading = false;
  String? _inlineMessage;

  String _selectedFileName = '';
  String _selectedFilePath = '';

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool get _isQuiz => widget.item.type == CourseItemType.quiz;

  String get _submissionTypeLabel => _isQuiz ? 'Quiz Answer' : 'Assignment';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _inlineMessage = null);

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;

    setState(() {
      _selectedFileName = file.name;
      _selectedFilePath = file.path ?? '';
    });
  }

  void _removeSelectedFile() {
    setState(() {
      _selectedFileName = '';
      _selectedFilePath = '';
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() => _inlineMessage = null);

    if (_selectedFileName.isEmpty) {
      setState(() {
        _inlineMessage = 'Please upload your answer file before submitting.';
      });
      return;
    }

    setState(() => _isLoading = true);

    if (_isQuiz) {
      final submission = QuizSubmission(
        id: const Uuid().v4(),
        quizId: widget.item.id,
        courseId: widget.course.id,
        studentId: widget.currentUser.id,
        studentName: widget.currentUser.name,
        note: _noteController.text.trim(),
        fileName: _selectedFileName,
        filePath: _selectedFilePath,
        grade: null,
        maxGrade: null,
        feedback: '',
        submittedAt: DateTime.now(),
        gradedAt: null,
      );

      await _database.addQuizSubmission(submission);
    } else {
      final submission = AssignmentSubmission(
        id: const Uuid().v4(),
        assignmentId: widget.item.id,
        courseId: widget.course.id,
        studentId: widget.currentUser.id,
        studentName: widget.currentUser.name,
        answerText: _noteController.text.trim(),
        fileName: _selectedFileName,
        filePath: _selectedFilePath,
        grade: null,
        maxGrade: null,
        feedback: '',
        submittedAt: DateTime.now(),
        gradedAt: null,
      );

      await _database.addSubmission(submission);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$_submissionTypeLabel submitted successfully.')),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 22),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildItemSummary(),
                          const SizedBox(height: 16),
                          _buildFileUploadBox(),
                          const SizedBox(height: 14),
                          SmartTextField(
                            controller: _noteController,
                            hint: _isQuiz
                                ? 'Optional note for the instructor'
                                : 'Optional answer note',
                            icon: Icons.notes_rounded,
                            maxLines: 4,
                          ),
                          if (_inlineMessage != null) ...[
                            const SizedBox(height: 16),
                            _buildInlineMessage(_inlineMessage!),
                          ],
                          const SizedBox(height: 22),
                          GradientButton(
                            text: _isLoading ? 'Submitting...' : 'Submit File',
                            icon: Icons.cloud_upload_rounded,
                            onPressed: _isLoading ? () {} : _submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.primaryIndigo.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryIndigo.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isQuiz
                    ? const [AppTheme.cyan, AppTheme.primaryIndigo]
                    : const [AppTheme.pink, AppTheme.violet],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _isQuiz ? Icons.quiz_rounded : Icons.assignment_turned_in_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primaryIndigo,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.item.dueDate.isEmpty
                      ? 'No due date added.'
                      : 'Due: ${widget.item.dueDate}',
                  style: TextStyle(
                    color: AppTheme.darkText.withValues(alpha: 0.56),
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

  Widget _buildFileUploadBox() {
    return GestureDetector(
      onTap: _pickFile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _selectedFileName.isEmpty
              ? Colors.white.withValues(alpha: 0.58)
              : AppTheme.cyan.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _selectedFileName.isEmpty
                ? Colors.white.withValues(alpha: 0.75)
                : AppTheme.cyan.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
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
              child: const Icon(Icons.upload_file_rounded, color: Colors.white),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFileName.isEmpty
                        ? 'Upload answer file'
                        : _selectedFileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _selectedFileName.isEmpty
                        ? 'Pick your completed answer file.'
                        : 'Answer file selected successfully.',
                    style: TextStyle(
                      color: AppTheme.darkText.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                      fontSize: 11.8,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedFileName.isNotEmpty)
              IconButton(
                onPressed: _removeSelectedFile,
                icon: const Icon(Icons.close_rounded, color: AppTheme.pink),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppTheme.violet),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppTheme.primaryIndigo,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            _isQuiz ? 'Submit Quiz' : 'Submit Assignment',
            style: const TextStyle(
              color: AppTheme.primaryIndigo,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 84,
          width: 84,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isQuiz
                  ? const [AppTheme.cyan, AppTheme.primaryIndigo]
                  : const [AppTheme.pink, AppTheme.violet],
            ),
            borderRadius: BorderRadius.circular(29),
            boxShadow: [
              BoxShadow(
                color: AppTheme.violet.withValues(alpha: 0.24),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Icon(
            _isQuiz ? Icons.quiz_rounded : Icons.assignment_turned_in_rounded,
            color: Colors.white,
            size: 39,
          ),
        ),
        const SizedBox(height: 17),
        Text(
          _isQuiz ? 'Upload quiz answers' : 'Upload assignment',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.primaryIndigo,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isQuiz
              ? 'Attach your completed quiz answer file before the due date.'
              : 'Attach your completed assignment file for instructor review.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.darkText.withValues(alpha: 0.62),
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInlineMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.pink.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.pink.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: AppTheme.pink, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.pink,
                fontWeight: FontWeight.w700,
                fontSize: 12.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
