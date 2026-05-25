import 'package:shared_preferences/shared_preferences.dart';

import '../content/reading_level.dart';
import '../localization/app_locale.dart';
import '../navigation/sato_wiki_tab.dart';
import 'app_settings_repository.dart';

final class SharedPreferencesAppSettingsRepository
    implements AppSettingsRepository {
  const SharedPreferencesAppSettingsRepository(this._preferences);

  static const _lastTabKey = 'settings.lastTab';
  static const _readingLevelKey = 'settings.readingLevel';
  static const _localePreferenceKey = 'settings.localePreference';

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
}
