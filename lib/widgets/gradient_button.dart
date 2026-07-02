import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isSecondary;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isSecondary = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.isSecondary
        ? [
            Colors.white.withValues(alpha: 0.86),
            Colors.white.withValues(alpha: 0.62),
          ]
        : const [
            AppTheme.pink,
            AppTheme.violet,
          ];

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 130),
        scale: _pressed ? 0.97 : 1,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.isSecondary
                    ? Colors.black.withValues(alpha: 0.05)
                    : AppTheme.violet.withValues(alpha: 0.26),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
            border: widget.isSecondary
                ? Border.all(color: Colors.white.withValues(alpha: 0.75))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.isSecondary
                      ? AppTheme.primaryIndigo
                      : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.isSecondary
                      ? AppTheme.primaryIndigo
                      : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}