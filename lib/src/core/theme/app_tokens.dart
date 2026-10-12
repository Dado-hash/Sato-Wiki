abstract final class AppSpacing {
  static const double xs = 4,
      sm = 8,
      md = 12,
      lg = 16,
      gutter = 20,
      xl = 24,
      section = 28;

  /// Bottom padding for scrollable tab bodies so content clears the floating tab bar.
  static const double tabBarClearance = 120;
}

abstract final class AppRadii {
  static const double thumb = 12, tile = 14, card = 20, media = 24, pill = 999;
}

abstract final class AppFonts {
  static const display = 'Space Grotesk';
  static const body = 'Inter';
  static const mono = 'JetBrains Mono';
}
