import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'landing_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppUser currentUser;

  const HomeScreen({super.key, required this.currentUser});

  Future<void> _logout(BuildContext context) async {
    await SessionService().logout();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 28),
                GlassCard(
                  child: Column(
                    children: [
                      Container(
                        height: 82,
                        width: 82,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryIndigo,
                              AppTheme.violet,
                              AppTheme.pink,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          currentUser.isInstructor
                              ? Icons.co_present_rounded
                              : Icons.school_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Welcome, ${currentUser.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryIndigo,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Role: ${currentUser.roleLabel}',
                        style: TextStyle(
                          color: AppTheme.darkText.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Authentication is working. In the next phase, this page becomes the full role-aware course dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.darkText.withValues(alpha: 0.58),
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      GradientButton(
                        text: 'Logout',
                        icon: Icons.logout_rounded,
                        isSecondary: true,
                        onPressed: () => _logout(context),
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
}
