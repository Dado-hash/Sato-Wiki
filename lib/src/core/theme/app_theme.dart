import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'sato_colors.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.bitcoinOrange,
          brightness: Brightness.dark,
        ).copyWith(
          surface: AppColors.darkGround,
          surfaceContainerLowest: AppColors.darkGround,
          surfaceContainerLow: AppColors.darkCard,
          surfaceContainer: AppColors.darkCard,
          surfaceContainerHigh: AppColors.darkRaised,
          surfaceContainerHighest: AppColors.darkRaised,
          onSurface: AppColors.darkText,
          onSurfaceVariant: AppColors.darkTextSecondary,
          outlineVariant: AppColors.darkBorder,
          outline: AppColors.darkBorderStrong,
          primary: AppColors.darkAccent,
          onPrimary: AppColors.onAccent,
          primaryContainer: AppColors.bitcoinOrange,
          onPrimaryContainer: AppColors.onAccent,
          secondary: AppColors.darkTextSecondary,
          onSecondary: AppColors.darkGround,
          tertiary: AppColors.darkStatusDeployed,
          error: AppColors.error,
          surfaceTint: Colors.transparent,
        );

    return _buildTheme(colorScheme);
  }

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.bitcoinOrange,
          brightness: Brightness.light,
        ).copyWith(
          surface: AppColors.lightGround,
          surfaceContainerLowest: AppColors.lightGround,
          surfaceContainerLow: AppColors.lightCard,
          surfaceContainer: AppColors.lightCard,
          surfaceContainerHigh: AppColors.lightRaised,
          surfaceContainerHighest: AppColors.lightRaised,
          onSurface: AppColors.lightText,
          onSurfaceVariant: AppColors.lightTextSecondary,
          outlineVariant: AppColors.lightBorder,
          outline: AppColors.lightBorderStrong,
          primary: AppColors.lightAccentText,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.bitcoinOrange,
          onPrimaryContainer: AppColors.onAccent,
          secondary: AppColors.lightTextSecondary,
          onSecondary: AppColors.lightGround,
          tertiary: AppColors.lightStatusDeployed,
          error: AppColors.error,
          surfaceTint: Colors.transparent,
        );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final textTheme = _textTheme(colorScheme);
    final sato = colorScheme.brightness == Brightness.dark
        ? SatoColors.dark
        : SatoColors.light;

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.body,
      colorScheme: colorScheme,
      extensions: [sato],
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.onPrimaryContainer,
        labelStyle: textTheme.labelLarge,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: StadiumBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        showCheckmark: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          minimumSize: const Size(44, 52),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(44, 44),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.media),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.media),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.tile),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primaryContainer,
        linearTrackColor: colorScheme.outlineVariant,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerLow,
        ),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return TextTheme(
      displayLarge: _style(
        AppFonts.display,
        size: 44,
        lineHeight: 48,
        weight: FontWeight.w700,
        color: onSurface,
      ),
      displayMedium: _style(
        AppFonts.display,
        size: 40,
        lineHeight: 44,
        weight: FontWeight.w700,
        color: onSurface,
      ),
      displaySmall: _style(
        AppFonts.display,
        size: 36,
        lineHeight: 40,
        weight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.8,
      ),
      headlineLarge: _style(
        AppFonts.display,
        size: 32,
        lineHeight: 36,
        weight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.6,
      ),
      headlineMedium: _style(
        AppFonts.display,
        size: 28,
        lineHeight: 33,
        weight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.5,
      ),
      headlineSmall: _style(
        AppFonts.display,
        size: 24,
        lineHeight: 28,
        weight: FontWeight.w700,
        color: onSurface,
        letterSpacing: -0.3,
      ),
      titleLarge: _style(
        AppFonts.display,
        size: 17,
        lineHeight: 22,
        weight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: _style(
        AppFonts.display,
        size: 16,
        lineHeight: 20,
        weight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: _style(
        AppFonts.body,
        size: 15,
        lineHeight: 20,
        weight: FontWeight.w500,
        color: onSurface,
      ),
      bodyLarge: _style(
        AppFonts.body,
        size: 17,
        lineHeight: 28,
        weight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: _style(
        AppFonts.body,
        size: 15,
        lineHeight: 22,
        weight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: _style(
        AppFonts.body,
        size: 13,
        lineHeight: 18,
        weight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      labelLarge: _style(
        AppFonts.body,
        size: 14,
        lineHeight: 20,
        weight: FontWeight.w500,
        color: onSurface,
      ),
      labelMedium: _style(
        AppFonts.mono,
        size: 12,
        lineHeight: 16,
        weight: FontWeight.w500,
        color: onSurfaceVariant,
      ),
      labelSmall: _style(
        AppFonts.mono,
        size: 11,
        lineHeight: 14,
        weight: FontWeight.w700,
        color: onSurface,
      ),
    );
  }

  static TextStyle _style(
    String fontFamily, {
    required double size,
    required double lineHeight,
    required FontWeight weight,
    required Color color,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
