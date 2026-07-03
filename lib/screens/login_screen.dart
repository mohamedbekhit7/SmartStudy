import 'package:flutter/material.dart';

import '../services/local_database.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/smart_text_field.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _database = LocalDatabase();
  final _sessionService = SessionService();

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
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final password = _passwordController.text;

    setState(() => _inlineMessage = null);

    if (name.isEmpty || password.isEmpty) {
      setState(() {
        _inlineMessage = 'Please enter both username and password.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final user = await _database.login(name, password);

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _inlineMessage = 'Invalid username or password. Please try again.';
      });
      return;
    }

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
                    const SizedBox(height: 24),
                    GlassCard(
                      child: Column(
                        children: [
                          SmartTextField(
                            controller: _nameController,
                            hint: 'Username',
                            icon: Icons.person_rounded,
                          ),
                          const SizedBox(height: 14),
                          SmartTextField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_rounded,
                            isPassword: true,
                          ),
                          if (_inlineMessage != null) ...[
                            const SizedBox(height: 16),
                            _buildInlineMessage(_inlineMessage!),
                          ],
                          const SizedBox(height: 22),
                          GradientButton(
                            text: _isLoading ? 'Signing In...' : 'Sign In',
                            icon: Icons.login_rounded,
                            onPressed: _isLoading ? () {} : _login,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSignupRedirect(),
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
          height: 96,
          width: 96,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryIndigo.withValues(alpha: 0.12),
                blurRadius: 25,
                offset: const Offset(0, 13),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_circle_rounded,
            color: AppTheme.primaryIndigo,
            size: 72,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.primaryIndigo,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue learning and teaching.',
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

  Widget _buildSignupRedirect() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignupScreen()),
        );
      },
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: 'Do not have an account? '),
            TextSpan(
              text: 'Sign Up',
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
