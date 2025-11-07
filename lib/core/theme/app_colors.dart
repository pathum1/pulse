import 'package:flutter/material.dart';

/// App Color Palette for Pulse Track
/// Designed specifically for hospital surgery management
class AppColors {
  // Primary Brand Colors
  static const Color surgicalTeal = Color(0xFF009CA6);
  static const Color deepIndigo = Color(0xFF2F3C7E);
  static const Color warmCoral = Color(0xFFF45B69);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF1A1D1F);
  static const Color lightSecondaryText = Color(0xFF4B5563);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightButtonText = Color(0xFFFFFFFF);
  static const Color lightSuccess = Color(0xFF28C76F);
  static const Color lightError = Color(0xFFE11D48);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0E1116);
  static const Color darkSurface = Color(0xFF1C1F26);
  static const Color darkPrimaryText = Color(0xFFE4E7EB);
  static const Color darkSecondaryText = Color(0xFF9CA3AF);
  static const Color darkDivider = Color(0xFF2D323B);
  static const Color darkButtonPrimary = Color(0xFF00B4BF);
  static const Color darkButtonText = Color(0xFFFFFFFF);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkError = Color(0xFFF87171);

  // Status Colors
  static const Color available = Color(0xFF28C76F);
  static const Color busy = Color(0xFFF45B69);
  static const Color onLeave = Color(0xFF9CA3AF);
  static const Color inSurgery = Color(0xFFFF8C00);
  
  // Surgery Status Colors
  static const Color scheduled = Color(0xFF3B82F6);
  static const Color inProgress = Color(0xFFFF8C00);
  static const Color completed = Color(0xFF28C76F);
  static const Color overdue = Color(0xFFE11D48);
  static const Color cancelled = Color(0xFF9CA3AF);
}