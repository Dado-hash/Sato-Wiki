import 'dart:ui';

final class AppLocalePreference {
  const AppLocalePreference.system() : languageCode = null;

  const AppLocalePreference.language(this.languageCode);

  static const systemStorageValue = 'system';

  final String? languageCode;

  bool get usesSystemLocale => languageCode == null;

  Locale? get explicitLocale =>
      languageCode == null ? null : Locale(languageCode!);

  String get storageValue => languageCode ?? systemStorageValue;

  static AppLocalePreference fromStorageValue(String? value) {
    if (value == null || value == systemStorageValue) {
      return const AppLocalePreference.system();
    }

    if (AppLocale.isSupportedLanguageCode(value)) {
      return AppLocalePreference.language(value);
    }

    return const AppLocalePreference.system();
  }

  @override
  bool operator ==(Object other) {
    return other is AppLocalePreference && other.languageCode == languageCode;
  }

  @override
  int get hashCode => languageCode.hashCode;
}

abstract final class AppLocale {
  static const fallbackLanguageCode = 'en';
  static const supportedLanguageCodes = <String>{fallbackLanguageCode};
  static const supportedLocales = <Locale>[Locale(fallbackLanguageCode)];

  static bool isSupportedLanguageCode(String languageCode) {
    return supportedLanguageCodes.contains(languageCode.toLowerCase());
  }

  static String normalizeLanguageCode(String languageCode) {
    final normalized = languageCode.toLowerCase();

    return isSupportedLanguageCode(normalized)
        ? normalized
        : fallbackLanguageCode;
  }

  static String resolveLanguageCode(
    AppLocalePreference preference,
    List<Locale> platformLocales,
  ) {
    final explicitLanguageCode = preference.languageCode;
    if (explicitLanguageCode != null) {
      return normalizeLanguageCode(explicitLanguageCode);
    }

    for (final locale in platformLocales) {
      final languageCode = locale.languageCode.toLowerCase();
      if (isSupportedLanguageCode(languageCode)) {
        return languageCode;
      }
    }

    return fallbackLanguageCode;
  }

  static Locale resolveLocale(Locale? locale, Iterable<Locale> supported) {
    if (locale == null) {
      return supported.first;
    }

    for (final supportedLocale in supported) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    return supported.first;
  }
}
