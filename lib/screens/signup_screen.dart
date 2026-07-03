import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../services/local_database.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/password_requirement_chip.dart';
import '../widgets/smart_text_field.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _database = LocalDatabase();
  final _sessionService = SessionService();

  UserRole _selectedRole = UserRole.student;
  bool _isLoading = false;
  String? _inlineMessage;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  String get _password => _passwordController.text;
  String get _confirmPassword => _confirmPasswordController.text;

  bool get _hasMinLength => _password.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_password);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_password);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_password);
  bool get _hasSpecial =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\]').hasMatch(_password);
  bool get _passwordsMatch =>
      _password.isNotEmpty && _password == _confirmPassword;

  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecial &&
      _passwordsMatch;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();

    setState(() => _inlineMessage = null);

    if (name.length < 3) {
      setState(() {
        _inlineMessage = 'Please enter a username with at least 3 characters.';
      });
      return;
    }

    if (!_isPasswordValid) {
      setState(() {
        _inlineMessage = 'Please complete all password requirements first.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final existingUser = await _database.findUserByName(name);

    if (!mounted) return;

    if (existingUser != null) {
      setState(() {
        _isLoading = false;
        _inlineMessage =
            'This username is already taken. Please choose another one.';
      });
      return;
    }

    final user = AppUser(
      id: const Uuid().v4(),
      name: name,
      password: _password,
      role: _selectedRole,
      createdAt: DateTime.now(),
    );

    await _database.addUser(user);
    await _sessionService.saveCurrentUser(user);

    if (!mounted) return;

    setState(() => _isLoading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(currentUser: user)),
      (_) => false,
    );
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
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 22),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SmartTextField(
                            controller: _nameController,
                            hint: 'Choose a unique username',
                            icon: Icons.person_rounded,
                          ),
                          const SizedBox(height: 14),
                          _buildRoleSelector(),
                          const SizedBox(height: 14),
                          SmartTextField(
                            controller: _passwordController,
                            hint: 'Create password',
                            icon: Icons.lock_rounded,
                            isPassword: true,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 14),
                          SmartTextField(
                            controller: _confirmPasswordController,
                            hint: 'Confirm password',
                            icon: Icons.verified_user_rounded,
                            isPassword: true,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordBubbles(),
                          if (_inlineMessage != null) ...[
                            const SizedBox(height: 16),
                            _buildInlineMessage(_inlineMessage!),
                          ],
                          const SizedBox(height: 22),
                          GradientButton(
                            text: _isLoading
                                ? 'Creating Account...'
                                : 'Create Account',
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: _isLoading ? () {} : _signup,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildLoginRedirect(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
                color: AppTheme.violet.withValues(alpha: 0.26),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Create your account',
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
          'Join SmartStudy as a student or instructor.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.darkText.withValues(alpha: 0.62),
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildRoleButton(
            role: UserRole.student,
            label: 'Student',
            icon: Icons.menu_book_rounded,
          ),
          const SizedBox(width: 8),
          _buildRoleButton(
            role: UserRole.instructor,
            label: 'Instructor',
            icon: Icons.co_present_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final selected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [AppTheme.primaryIndigo, AppTheme.violet],
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : AppTheme.darkText.withValues(alpha: 0.56),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : AppTheme.darkText.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordBubbles() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        PasswordRequirementChip(label: '8+ characters', isValid: _hasMinLength),
        PasswordRequirementChip(label: 'Uppercase', isValid: _hasUppercase),
        PasswordRequirementChip(label: 'Lowercase', isValid: _hasLowercase),
        PasswordRequirementChip(label: 'Number', isValid: _hasNumber),
        PasswordRequirementChip(label: 'Special', isValid: _hasSpecial),
        PasswordRequirementChip(
          label: 'Passwords match',
          isValid: _passwordsMatch,
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

  Widget _buildLoginRedirect() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: 'Already have an account? '),
            TextSpan(
              text: 'Login',
              style: TextStyle(
                color: AppTheme.primaryIndigo,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
