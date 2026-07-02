import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<_Particle> _particles = List.generate(
    22,
    (index) => _Particle.random(index),
  );

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Alignment _floatingAlignment(
    double startX,
    double startY,
    double endX,
    double endY,
  ) {
    return Alignment(
      lerpDouble(startX, endX, _controller.value)!,
      lerpDouble(startY, endY, _controller.value)!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF7F2FF),
                    Color(0xFFEAF7FF),
                  ],
                ),
              ),
            ),
            _GlowEllipse(
              alignment: _floatingAlignment(-1.25, -1.15, -0.85, -0.95),
              size: 280,
              color: AppTheme.purple,
              opacity: 0.34,
            ),
            _GlowEllipse(
              alignment: _floatingAlignment(1.25, 0.85, 0.82, 1.08),
              size: 260,
              color: AppTheme.pink,
              opacity: 0.28,
            ),
            _GlowEllipse(
              alignment: _floatingAlignment(0.95, -0.55, 0.55, -0.78),
              size: 220,
              color: AppTheme.cyan,
              opacity: 0.24,
            ),
            CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
              size: Size.infinite,
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _GlowEllipse extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;
  final double opacity;

  const _GlowEllipse({
    required this.alignment,
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0.03),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.color,
  });

  factory _Particle.random(int index) {
    final random = Random(index * 97 + 13);
    final colors = [
      AppTheme.primaryIndigo,
      AppTheme.violet,
      AppTheme.pink,
      AppTheme.cyan,
    ];

    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: 2.2 + random.nextDouble() * 4.4,
      speed: 0.08 + random.nextDouble() * 0.16,
      opacity: 0.08 + random.nextDouble() * 0.18,
      color: colors[index % colors.length],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final shiftedY = (particle.y + progress * particle.speed) % 1.0;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, shiftedY * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
