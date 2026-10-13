abstract final class AppSpacing {
  static const double xs = 4,
      sm = 8,
      md = 12,
      lg = 16,
      gutter = 20,
      xl = 24,
      section = 28;

  /// Gap between the last content of a tab screen and the floating tab bar.
  static const double tabBarGap = 24;

  /// Space between the floating tab bar and the bottom system inset.
  static const double tabBarLift = 12;
}

abstract final class AppRadii {
  static const double thumb = 12, tile = 14, card = 20, media = 24, pill = 999;
}

abstract final class AppFonts {
  static const display = 'Space Grotesk';
  static const body = 'Inter';
  static const mono = 'JetBrains Mono';
}
