import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SmartTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const SmartTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLines: isPassword ? 1 : maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppTheme.darkText,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        prefixIcon: Icon(icon, color: AppTheme.violet),
        hintStyle: TextStyle(
          color: AppTheme.darkText.withValues(alpha: 0.42),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
