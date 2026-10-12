import '../content/reading_level.dart';
import '../localization/app_locale.dart';
import '../navigation/sato_wiki_tab.dart';
import 'theme_preference.dart';

abstract interface class AppSettingsRepository {
  Future<SatoWikiTab?> loadLastTab();

  Future<void> saveLastTab(SatoWikiTab tab);

  Future<ReadingLevel?> loadReadingLevel();

  Future<void> saveReadingLevel(ReadingLevel level);

  Future<AppLocalePreference> loadLocalePreference();

  Future<void> saveLocalePreference(AppLocalePreference preference);

  Future<ThemePreference> loadThemePreference();

  Future<void> saveThemePreference(ThemePreference preference);

  Future<double?> loadReaderTextScale();

  Future<void> saveReaderTextScale(double scale);

  Future<List<String>> loadBookmarks();

  Future<void> saveBookmarks(List<String> bookmarks);

  Future<Map<String, double>> loadReadingProgress();

  Future<void> saveReadingProgress(Map<String, double> progress);

  Future<List<String>> loadLastRead();

  Future<void> saveLastRead(List<String> ids);

  Future<List<String>> loadRecentSearches();

  Future<void> saveRecentSearches(List<String> queries);
}

final class InMemoryAppSettingsRepository implements AppSettingsRepository {
  InMemoryAppSettingsRepository({
    SatoWikiTab? lastTab,
    ReadingLevel? readingLevel,
    AppLocalePreference localePreference = const AppLocalePreference.system(),
    ThemePreference themePreference = ThemePreference.dark,
    double? readerTextScale,
    List<String> bookmarks = const [],
    Map<String, double> readingProgress = const {},
    List<String> lastRead = const [],
    List<String> recentSearches = const [],
  }) : _lastTab = lastTab,
       _readingLevel = readingLevel,
       _localePreference = localePreference,
       _themePreference = themePreference,
       _readerTextScale = readerTextScale,
       _bookmarks = List<String>.of(bookmarks),
       _readingProgress = Map<String, double>.of(readingProgress),
       _lastRead = List<String>.of(lastRead),
       _recentSearches = List<String>.of(recentSearches);

  SatoWikiTab? _lastTab;
  ReadingLevel? _readingLevel;
  AppLocalePreference _localePreference;
  ThemePreference _themePreference;
  double? _readerTextScale;
  List<String> _bookmarks;
  Map<String, double> _readingProgress;
  List<String> _lastRead;
  List<String> _recentSearches;

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

  @override
  Future<ThemePreference> loadThemePreference() async => _themePreference;

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    _themePreference = preference;
  }

  @override
  Future<double?> loadReaderTextScale() async => _readerTextScale;

  @override
  Future<void> saveReaderTextScale(double scale) async {
    _readerTextScale = scale;
  }

  @override
  Future<List<String>> loadBookmarks() async => List<String>.of(_bookmarks);

  @override
  Future<void> saveBookmarks(List<String> bookmarks) async {
    _bookmarks = List<String>.of(bookmarks);
  }

  @override
  Future<Map<String, double>> loadReadingProgress() async =>
      Map<String, double>.of(_readingProgress);

  @override
  Future<void> saveReadingProgress(Map<String, double> progress) async {
    _readingProgress = Map<String, double>.of(progress);
  }

  @override
  Future<List<String>> loadLastRead() async => List<String>.of(_lastRead);

  @override
  Future<void> saveLastRead(List<String> ids) async {
    _lastRead = List<String>.of(ids);
  }

  @override
  Future<List<String>> loadRecentSearches() async =>
      List<String>.of(_recentSearches);

  @override
  Future<void> saveRecentSearches(List<String> queries) async {
    _recentSearches = List<String>.of(queries);
  }
}
