import 'package:flutter/material.dart' show ThemeMode;

enum ThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  const ThemePreference(this.storageValue);

  final String storageValue;

  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };

  static ThemePreference fromStorageValue(String? value) {
    for (final preference in ThemePreference.values) {
      if (preference.storageValue == value) {
        return preference;
      }
    }

    return ThemePreference.dark;
  }
}
