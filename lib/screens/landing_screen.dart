import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/feature_pill.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 50,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildLogo(),
                          const SizedBox(height: 34),
                          _buildHeroCard(),
                          const SizedBox(height: 24),
                          _buildFeaturePills(),
                          const SizedBox(height: 26),
                          _buildActions(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          height: 78,
          width: 78,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryIndigo, AppTheme.violet, AppTheme.pink],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppTheme.violet.withValues(alpha: 0.34),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SmartStudy',
          style: TextStyle(
            fontSize: 36,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.1,
            color: AppTheme.primaryIndigo,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Learn smarter. Teach faster. Stay organized.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.5,
            height: 1.4,
            color: AppTheme.darkText.withValues(alpha: 0.68),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.violet.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'Online Learning Management System',
              style: TextStyle(
                color: AppTheme.violet,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'A beautiful space for courses, assignments, quizzes and progress.',
            style: TextStyle(
              fontSize: 26,
              height: 1.18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'SmartStudy helps instructors create learning content quickly while students join courses, submit assignments and complete quizzes from one clean mobile experience.',
            style: TextStyle(
              fontSize: 14.8,
              height: 1.55,
              color: AppTheme.darkText.withValues(alpha: 0.66),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _buildMiniMetric('4', 'Core Modules'),
              const SizedBox(width: 12),
              _buildMiniMetric('2', 'User Roles'),
              const SizedBox(width: 12),
              _buildMiniMetric('100%', 'Local Demo'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryIndigo,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                color: AppTheme.darkText.withValues(alpha: 0.58),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePills() {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        FeaturePill(
          icon: Icons.menu_book_rounded,
          label: 'Courses',
          color: AppTheme.primaryIndigo,
        ),
        FeaturePill(
          icon: Icons.assignment_turned_in_rounded,
          label: 'Assignments',
          color: AppTheme.pink,
        ),
        FeaturePill(
          icon: Icons.quiz_rounded,
          label: 'Quizzes',
          color: AppTheme.violet,
        ),
        FeaturePill(
          icon: Icons.groups_rounded,
          label: 'People',
          color: AppTheme.cyan,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        GradientButton(
          text: 'Sign Up',
          icon: Icons.person_add_alt_1_rounded,
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
          },
        ),
        const SizedBox(height: 13),
        GradientButton(
          text: 'Login',
          icon: Icons.login_rounded,
          isSecondary: true,
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
        ),
      ],
    );
  }
}
