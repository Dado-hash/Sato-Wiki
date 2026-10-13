import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand colours that have no slot in [ColorScheme].
@immutable
final class SatoColors extends ThemeExtension<SatoColors> {
  const SatoColors({
    required this.accentTint,
    required this.statusDeployed,
    required this.statusComplete,
    required this.statusDraft,
    required this.statusClosed,
    required this.borderStrong,
    required this.fieldAmber,
    required this.fieldBlue,
    required this.fieldGreen,
    required this.fieldViolet,
  });

  static const dark = SatoColors(
    accentTint: AppColors.darkAccentTint,
    statusDeployed: AppColors.darkStatusDeployed,
    statusComplete: AppColors.darkStatusComplete,
    statusDraft: AppColors.darkStatusDraft,
    statusClosed: AppColors.darkStatusClosed,
    borderStrong: AppColors.darkBorderStrong,
    fieldAmber: AppColors.darkFieldAmber,
    fieldBlue: AppColors.darkFieldBlue,
    fieldGreen: AppColors.darkFieldGreen,
    fieldViolet: AppColors.darkFieldViolet,
  );

  static const light = SatoColors(
    accentTint: AppColors.lightAccentTint,
    statusDeployed: AppColors.lightStatusDeployed,
    statusComplete: AppColors.lightStatusComplete,
    statusDraft: AppColors.lightStatusDraft,
    statusClosed: AppColors.lightStatusClosed,
    borderStrong: AppColors.lightBorderStrong,
    fieldAmber: AppColors.lightFieldAmber,
    fieldBlue: AppColors.lightFieldBlue,
    fieldGreen: AppColors.lightFieldGreen,
    fieldViolet: AppColors.lightFieldViolet,
  );

  /// Soft orange background for the active tab and icon tiles.
  final Color accentTint;
  final Color statusDeployed;
  final Color statusComplete;
  final Color statusDraft;
  final Color statusClosed;

  /// Tab bar border.
  final Color borderStrong;

  /// Soft backgrounds for the parts of hex data (tools and explorer). They
  /// keep the text readable in both themes.
  final Color fieldAmber;
  final Color fieldBlue;
  final Color fieldGreen;
  final Color fieldViolet;

  @override
  SatoColors copyWith({
    Color? accentTint,
    Color? statusDeployed,
    Color? statusComplete,
    Color? statusDraft,
    Color? statusClosed,
    Color? borderStrong,
    Color? fieldAmber,
    Color? fieldBlue,
    Color? fieldGreen,
    Color? fieldViolet,
  }) {
    return SatoColors(
      accentTint: accentTint ?? this.accentTint,
      statusDeployed: statusDeployed ?? this.statusDeployed,
      statusComplete: statusComplete ?? this.statusComplete,
      statusDraft: statusDraft ?? this.statusDraft,
      statusClosed: statusClosed ?? this.statusClosed,
      borderStrong: borderStrong ?? this.borderStrong,
      fieldAmber: fieldAmber ?? this.fieldAmber,
      fieldBlue: fieldBlue ?? this.fieldBlue,
      fieldGreen: fieldGreen ?? this.fieldGreen,
      fieldViolet: fieldViolet ?? this.fieldViolet,
    );
  }

  @override
  SatoColors lerp(ThemeExtension<SatoColors>? other, double t) {
    if (other is! SatoColors) {
      return this;
    }

    return SatoColors(
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      statusDeployed: Color.lerp(statusDeployed, other.statusDeployed, t)!,
      statusComplete: Color.lerp(statusComplete, other.statusComplete, t)!,
      statusDraft: Color.lerp(statusDraft, other.statusDraft, t)!,
      statusClosed: Color.lerp(statusClosed, other.statusClosed, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      fieldAmber: Color.lerp(fieldAmber, other.fieldAmber, t)!,
      fieldBlue: Color.lerp(fieldBlue, other.fieldBlue, t)!,
      fieldGreen: Color.lerp(fieldGreen, other.fieldGreen, t)!,
      fieldViolet: Color.lerp(fieldViolet, other.fieldViolet, t)!,
    );
  }
}

extension SatoColorsContext on BuildContext {
  SatoColors get sato =>
      Theme.of(this).extension<SatoColors>() ?? SatoColors.dark;
}
