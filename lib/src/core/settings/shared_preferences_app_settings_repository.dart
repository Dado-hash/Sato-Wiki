import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../content/reading_level.dart';
import '../localization/app_locale.dart';
import '../navigation/sato_wiki_tab.dart';
import 'app_settings_repository.dart';
import 'theme_preference.dart';

final class SharedPreferencesAppSettingsRepository
    implements AppSettingsRepository {
  const SharedPreferencesAppSettingsRepository(this._preferences);

  static const _lastTabKey = 'settings.lastTab';
  static const _readingLevelKey = 'settings.readingLevel';
  static const _localePreferenceKey = 'settings.localePreference';
  static const _themePreferenceKey = 'settings.themePreference';
  static const _readerTextScaleKey = 'settings.readerTextScale';
  static const _bookmarksKey = 'settings.bookmarks';
  static const _readingProgressKey = 'settings.readingProgress';
  static const _lastReadKey = 'settings.lastRead';
  static const _recentSearchesKey = 'settings.recentSearches';

  final SharedPreferences _preferences;

  @override
  Future<SatoWikiTab?> loadLastTab() async {
    final routePath = _preferences.getString(_lastTabKey);

    return SatoWikiTab.fromRoutePath(routePath);
  }

  @override
  Future<void> saveLastTab(SatoWikiTab tab) async {
    await _preferences.setString(_lastTabKey, tab.routePath);
  }

  @override
  Future<ReadingLevel?> loadReadingLevel() async {
    final value = _preferences.getString(_readingLevelKey);

    return ReadingLevel.fromStorageValue(value);
  }

  @override
  Future<void> saveReadingLevel(ReadingLevel level) async {
    await _preferences.setString(_readingLevelKey, level.storageValue);
  }

  @override
  Future<AppLocalePreference> loadLocalePreference() async {
    final value = _preferences.getString(_localePreferenceKey);

    return AppLocalePreference.fromStorageValue(value);
  }

  @override
  Future<void> saveLocalePreference(AppLocalePreference preference) async {
    await _preferences.setString(_localePreferenceKey, preference.storageValue);
  }

  @override
  Future<ThemePreference> loadThemePreference() async {
    final value = _preferences.getString(_themePreferenceKey);

    return ThemePreference.fromStorageValue(value);
  }

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    await _preferences.setString(_themePreferenceKey, preference.storageValue);
  }

  @override
  Future<double?> loadReaderTextScale() async {
    try {
      return _preferences.getDouble(_readerTextScaleKey);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveReaderTextScale(double scale) async {
    await _preferences.setDouble(_readerTextScaleKey, scale);
  }

  @override
  Future<List<String>> loadBookmarks() async {
    return _readStringList(_bookmarksKey);
  }

  @override
  Future<void> saveBookmarks(List<String> bookmarks) async {
    await _preferences.setStringList(_bookmarksKey, bookmarks);
  }

  @override
  Future<Map<String, double>> loadReadingProgress() async {
    final value = _readString(_readingProgressKey);
    if (value == null) {
      return <String, double>{};
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map) {
        return <String, double>{};
      }

      final progress = <String, double>{};
      for (final entry in decoded.entries) {
        final key = entry.key;
        final number = entry.value;
        if (key is String && number is num) {
          progress[key] = number.toDouble();
        }
      }

      return progress;
    } on Object {
      return <String, double>{};
    }
  }

  @override
  Future<void> saveReadingProgress(Map<String, double> progress) async {
    await _preferences.setString(_readingProgressKey, jsonEncode(progress));
  }

  @override
  Future<List<String>> loadLastRead() async {
    return _readStringList(_lastReadKey);
  }

  @override
  Future<void> saveLastRead(List<String> ids) async {
    await _preferences.setStringList(_lastReadKey, ids);
  }

  @override
  Future<List<String>> loadRecentSearches() async {
    return _readStringList(_recentSearchesKey);
  }

  @override
  Future<void> saveRecentSearches(List<String> queries) async {
    await _preferences.setStringList(_recentSearchesKey, queries);
  }

  List<String> _readStringList(String key) {
    try {
      return _preferences.getStringList(key) ?? <String>[];
    } on Object {
      return <String>[];
    }
  }

  String? _readString(String key) {
    try {
      return _preferences.getString(key);
    } on Object {
      return null;
    }
  }
}
