import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../models/course_item.dart';
import '../services/local_database.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/smart_text_field.dart';

class CreateCourseItemScreen extends StatefulWidget {
  final AppUser currentUser;
  final Course course;

  const CreateCourseItemScreen({
    super.key,
    required this.currentUser,
    required this.course,
  });

  @override
  State<CreateCourseItemScreen> createState() => _CreateCourseItemScreenState();
}

class _CreateCourseItemScreenState extends State<CreateCourseItemScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _database = LocalDatabase();

  CourseItemType _selectedType = CourseItemType.material;
  bool _isLoading = false;
  String? _inlineMessage;

  String _selectedFileName = '';
  String _selectedFilePath = '';
  DateTime? _selectedDueDate;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool get _needsDueDate =>
      _selectedType == CourseItemType.assignment ||
      _selectedType == CourseItemType.quiz;

  String get _selectedTypeTitle {
    switch (_selectedType) {
      case CourseItemType.material:
        return 'Material';
      case CourseItemType.assignment:
        return 'Assignment';
      case CourseItemType.quiz:
        return 'Quiz';
    }
  }

  String get _formattedDueDate {
    if (_selectedDueDate == null) return '';
    return DateFormat('MMM d, yyyy').format(_selectedDueDate!);
  }

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
    _titleController.dispose();
    _descriptionController.dispose();
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

  Future<void> _pickDueDate() async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 3, now.month, now.day),
      helpText: _selectedType == CourseItemType.assignment
          ? 'Select assignment due date'
          : 'Select quiz due date',
      cancelText: 'Cancel',
      confirmText: 'Choose',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppTheme.primaryIndigo,
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppTheme.darkText.withValues(alpha: 0.25);
                }
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppTheme.darkText;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryIndigo;
                }
                return null;
              }),
              todayForegroundColor: WidgetStateProperty.all(AppTheme.pink),
              todayBorder: const BorderSide(color: AppTheme.pink),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryIndigo,
              secondary: AppTheme.violet,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDueDate = pickedDate;
      _inlineMessage = null;
    });
  }

  Future<void> _saveItem() async {
    FocusScope.of(context).unfocus();

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() => _inlineMessage = null);

    if (title.length < 3) {
      setState(() {
        _inlineMessage =
            'Please enter a clear title with at least 3 characters.';
      });
      return;
    }

    if (description.length < 6) {
      setState(() {
        _inlineMessage = 'Please add a short but useful description.';
      });
      return;
    }

    if (_selectedFileName.isEmpty) {
      setState(() {
        _inlineMessage = 'Please upload a file for this $_selectedTypeTitle.';
      });
      return;
    }

    if (_needsDueDate && _selectedDueDate == null) {
      setState(() {
        _inlineMessage = 'Please choose a future due date.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final item = CourseItem(
      id: const Uuid().v4(),
      courseId: widget.course.id,
      type: _selectedType,
      title: title,
      description: description,
      link: '',
      dueDate: _needsDueDate ? _formattedDueDate : '',
      fileName: _selectedFileName,
      filePath: _selectedFilePath,
      question: '',
      choices: const [],
      correctChoiceIndex: 0,
      createdBy: widget.currentUser.id,
      createdAt: DateTime.now(),
    );

    await _database.addCourseItem(item);

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.typeLabel} was added successfully.')),
    );

    Navigator.of(context).pop();
  }

  void _changeType(CourseItemType type) {
    setState(() {
      _selectedType = type;
      _inlineMessage = null;

      if (type == CourseItemType.material) {
        _selectedDueDate = null;
      }
    });
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
                          _buildTypeSelector(),
                          const SizedBox(height: 16),
                          SmartTextField(
                            controller: _titleController,
                            hint: _selectedType == CourseItemType.material
                                ? 'Material title'
                                : _selectedType == CourseItemType.assignment
                                ? 'Assignment title'
                                : 'Quiz title',
                            icon: Icons.title_rounded,
                          ),
                          const SizedBox(height: 14),
                          SmartTextField(
                            controller: _descriptionController,
                            hint: _selectedType == CourseItemType.material
                                ? 'Material description'
                                : _selectedType == CourseItemType.assignment
                                ? 'Assignment instructions'
                                : 'Quiz instructions',
                            icon: Icons.notes_rounded,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 14),
                          _buildFileUploadBox(),
                          if (_needsDueDate) ...[
                            const SizedBox(height: 14),
                            _buildDueDatePickerBox(),
                          ],
                          if (_inlineMessage != null) ...[
                            const SizedBox(height: 16),
                            _buildInlineMessage(_inlineMessage!),
                          ],
                          const SizedBox(height: 22),
                          GradientButton(
                            text: _isLoading ? 'Saving...' : 'Save Content',
                            icon: Icons.check_rounded,
                            onPressed: _isLoading ? () {} : _saveItem,
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
                        ? 'Upload $_selectedTypeTitle file'
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
                        ? 'Pick a PDF, document, image or presentation file.'
                        : 'File selected successfully.',
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

  Widget _buildDueDatePickerBox() {
    final hasDate = _selectedDueDate != null;

    return GestureDetector(
      onTap: _pickDueDate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: hasDate
              ? AppTheme.pink.withValues(alpha: 0.09)
              : Colors.white.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasDate
                ? AppTheme.pink.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.75),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.pink, AppTheme.violet],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasDate ? _formattedDueDate : 'Choose due date',
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasDate
                        ? 'Future due date selected.'
                        : 'Only future dates are allowed.',
                    style: TextStyle(
                      color: AppTheme.darkText.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                      fontSize: 11.8,
                    ),
                  ),
                ],
              ),
            ),
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
          onPressed: () => Navigator.of(context).pop(),
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
            gradient: const LinearGradient(
              colors: [AppTheme.primaryIndigo, AppTheme.violet, AppTheme.pink],
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
          child: const Icon(
            Icons.post_add_rounded,
            color: Colors.white,
            size: 39,
          ),
        ),
        const SizedBox(height: 17),
        const Text(
          'Create course content',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.primaryIndigo,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload lectures, assignments or quiz files for this course.',
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

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _typeButton(
            CourseItemType.material,
            'Material',
            Icons.menu_book_rounded,
          ),
          const SizedBox(width: 6),
          _typeButton(
            CourseItemType.assignment,
            'Task',
            Icons.assignment_turned_in_rounded,
          ),
          const SizedBox(width: 6),
          _typeButton(CourseItemType.quiz, 'Quiz', Icons.quiz_rounded),
        ],
      ),
    );
  }

  Widget _typeButton(CourseItemType type, String label, IconData icon) {
    final selected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => _changeType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [AppTheme.primaryIndigo, AppTheme.violet],
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.violet.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 19,
                color: selected
                    ? Colors.white
                    : AppTheme.darkText.withValues(alpha: 0.52),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : AppTheme.darkText.withValues(alpha: 0.58),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
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
