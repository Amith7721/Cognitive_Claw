// All text styles used across the app
import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../../core/theme/app_theme.dart';

class AppTypography {
  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.teal,
  );

  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static const caption = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  static const mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    color: AppColors.teal,
  );
}
