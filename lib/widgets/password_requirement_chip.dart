import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PasswordRequirementChip extends StatelessWidget {
  final String label;
  final bool isValid;

  const PasswordRequirementChip({
    super.key,
    required this.label,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isValid
            ? AppTheme.cyan.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isValid
              ? AppTheme.cyan.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.82),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isValid
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              key: ValueKey(isValid),
              size: 16,
              color: isValid
                  ? AppTheme.primaryIndigo
                  : AppTheme.darkText.withValues(alpha: 0.38),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: isValid
                  ? AppTheme.primaryIndigo
                  : AppTheme.darkText.withValues(alpha: 0.58),
            ),
          ),
        ],
      ),
    );
  }
}
