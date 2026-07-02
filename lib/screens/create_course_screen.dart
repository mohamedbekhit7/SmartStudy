import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../services/local_database.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/smart_text_field.dart';

class CreateCourseScreen extends StatefulWidget {
  final AppUser currentUser;

  const CreateCourseScreen({super.key, required this.currentUser});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _database = LocalDatabase();

  bool _isLoading = false;
  String? _inlineMessage;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

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
    _nameController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createCourse() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() => _inlineMessage = null);

    if (name.length < 3) {
      setState(() {
        _inlineMessage = 'Course name must be at least 3 characters.';
      });
      return;
    }

    if (code.length < 3) {
      setState(() {
        _inlineMessage = 'Course code must be at least 3 characters.';
      });
      return;
    }

    if (password.length < 4) {
      setState(() {
        _inlineMessage = 'Course password must be at least 4 characters.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final existingCourse = await _database.findCourseByCode(code);

    if (!mounted) return;

    if (existingCourse != null) {
      setState(() {
        _isLoading = false;
        _inlineMessage =
            'This course code already exists. Please choose another code.';
      });
      return;
    }

    final course = Course(
      id: const Uuid().v4(),
      name: name,
      code: code,
      password: password,
      description: description,
      instructorId: widget.currentUser.id,
      instructorName: widget.currentUser.name,
      createdAt: DateTime.now(),
      studentIds: const [],
    );

    await _database.addCourse(course);

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name was created successfully.')));

    Navigator.of(context).pop();
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
                    const SizedBox(height: 26),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    GlassCard(
                      child: Column(
                        children: [
                          SmartTextField(
                            controller: _nameController,
                            hint: 'Course name',
                            icon: Icons.auto_stories_rounded,
                          ),
                          const SizedBox(height: 14),
                          SmartTextField(
                            controller: _codeController,
                            hint: 'Class code, for example SE101',
                            icon: Icons.qr_code_2_rounded,
                          ),
                          const SizedBox(height: 14),
                          SmartTextField(
                            controller: _passwordController,
                            hint: 'Course password',
                            icon: Icons.lock_rounded,
                            isPassword: true,
                          ),
                          const SizedBox(height: 14),
                          SmartTextField(
                            controller: _descriptionController,
                            hint: 'Short course description',
                            icon: Icons.notes_rounded,
                            maxLines: 4,
                          ),
                          if (_inlineMessage != null) ...[
                            const SizedBox(height: 16),
                            _buildInlineMessage(_inlineMessage!),
                          ],
                          const SizedBox(height: 22),
                          GradientButton(
                            text: _isLoading ? 'Creating...' : 'Create Course',
                            icon: Icons.add_rounded,
                            onPressed: _isLoading ? () {} : _createCourse,
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
          height: 86,
          width: 86,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryIndigo, AppTheme.violet, AppTheme.pink],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.violet.withValues(alpha: 0.24),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_business_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Build a new course',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.primaryIndigo,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Students will join using the class code and password.',
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
