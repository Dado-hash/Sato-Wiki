import '../content/reading_level.dart';
import '../localization/app_locale.dart';
import '../navigation/sato_wiki_tab.dart';

abstract interface class AppSettingsRepository {
  Future<SatoWikiTab?> loadLastTab();

  Future<void> saveLastTab(SatoWikiTab tab);

  Future<ReadingLevel?> loadReadingLevel();

  Future<void> saveReadingLevel(ReadingLevel level);

  Future<AppLocalePreference> loadLocalePreference();

  Future<void> saveLocalePreference(AppLocalePreference preference);
}

final class InMemoryAppSettingsRepository implements AppSettingsRepository {
  InMemoryAppSettingsRepository({
    SatoWikiTab? lastTab,
    ReadingLevel? readingLevel,
    AppLocalePreference localePreference = const AppLocalePreference.system(),
  }) : _lastTab = lastTab,
       _readingLevel = readingLevel,
       _localePreference = localePreference;

  SatoWikiTab? _lastTab;
  ReadingLevel? _readingLevel;
  AppLocalePreference _localePreference;

  @override
  Future<SatoWikiTab?> loadLastTab() async => _lastTab;

  @override
  Future<void> saveLastTab(SatoWikiTab tab) async {
    _lastTab = tab;
  }

  @override
  Future<ReadingLevel?> loadReadingLevel() async => _readingLevel;

  @override
  Future<void> saveReadingLevel(ReadingLevel level) async {
    _readingLevel = level;
  }

  @override
  Future<AppLocalePreference> loadLocalePreference() async {
    return _localePreference;
  }

  @override
  Future<void> saveLocalePreference(AppLocalePreference preference) async {
    _localePreference = preference;
  }
}
