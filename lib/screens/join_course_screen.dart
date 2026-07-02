import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/local_database.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/smart_text_field.dart';

class JoinCourseScreen extends StatefulWidget {
  final AppUser currentUser;

  const JoinCourseScreen({super.key, required this.currentUser});

  @override
  State<JoinCourseScreen> createState() => _JoinCourseScreenState();
}

class _JoinCourseScreenState extends State<JoinCourseScreen>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

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
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _joinCourse() async {
    FocusScope.of(context).unfocus();

    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _inlineMessage = null);

    if (code.isEmpty || password.isEmpty) {
      setState(() {
        _inlineMessage = 'Please enter both class code and password.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final course = await _database.findCourseByCode(code);

    if (!mounted) return;

    if (course == null) {
      setState(() {
        _isLoading = false;
        _inlineMessage = 'No course was found with this class code.';
      });
      return;
    }

    if (course.password != password) {
      setState(() {
        _isLoading = false;
        _inlineMessage = 'The course password is incorrect.';
      });
      return;
    }

    if (course.studentIds.contains(widget.currentUser.id)) {
      setState(() {
        _isLoading = false;
        _inlineMessage = 'You are already registered in this course.';
      });
      return;
    }

    await _database.enrollStudent(
      courseId: course.id,
      studentId: widget.currentUser.id,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You joined ${course.name} successfully.')),
    );

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
                    const SizedBox(height: 30),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    GlassCard(
                      child: Column(
                        children: [
                          SmartTextField(
                            controller: _codeController,
                            hint: 'Class code',
                            icon: Icons.qr_code_2_rounded,
                          ),
                          const SizedBox(height: 14),
                          SmartTextField(
                            controller: _passwordController,
                            hint: 'Course password',
                            icon: Icons.lock_rounded,
                            isPassword: true,
                          ),
                          if (_inlineMessage != null) ...[
                            const SizedBox(height: 16),
                            _buildInlineMessage(_inlineMessage!),
                          ],
                          const SizedBox(height: 22),
                          GradientButton(
                            text: _isLoading ? 'Joining...' : 'Join Course',
                            icon: Icons.login_rounded,
                            onPressed: _isLoading ? () {} : _joinCourse,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildHintCard(),
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
          height: 88,
          width: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.pink, AppTheme.violet],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.pink.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Register in a course',
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
          'Ask your instructor for the class code and course password.',
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

  Widget _buildHintCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppTheme.violet),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Example demo code: SE101. The actual code depends on what the instructor creates.',
              style: TextStyle(
                color: AppTheme.darkText.withValues(alpha: 0.62),
                fontWeight: FontWeight.w700,
                height: 1.35,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
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
