import '../content/reading_level.dart';
import '../navigation/sato_wiki_tab.dart';

abstract interface class AppSettingsRepository {
  Future<SatoWikiTab?> loadLastTab();

  Future<void> saveLastTab(SatoWikiTab tab);

  Future<ReadingLevel?> loadReadingLevel();

  Future<void> saveReadingLevel(ReadingLevel level);
}

final class InMemoryAppSettingsRepository implements AppSettingsRepository {
  InMemoryAppSettingsRepository({
    SatoWikiTab? lastTab,
    ReadingLevel? readingLevel,
  }) : _lastTab = lastTab,
       _readingLevel = readingLevel;

  SatoWikiTab? _lastTab;
  ReadingLevel? _readingLevel;

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
}
