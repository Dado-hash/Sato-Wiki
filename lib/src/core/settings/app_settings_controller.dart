import 'package:flutter/foundation.dart';

import '../content/reading_level.dart';
import '../navigation/sato_wiki_tab.dart';
import 'app_settings_repository.dart';

final class AppSettingsController extends ChangeNotifier {
  AppSettingsController._({
    required AppSettingsRepository repository,
    required SatoWikiTab lastTab,
    required ReadingLevel readingLevel,
  }) : _repository = repository,
       _lastTab = lastTab,
       _readingLevel = readingLevel;

  final AppSettingsRepository _repository;

  SatoWikiTab _lastTab;
  ReadingLevel _readingLevel;

  SatoWikiTab get lastTab => _lastTab;

  ReadingLevel get readingLevel => _readingLevel;

  static Future<AppSettingsController> load(
    AppSettingsRepository repository,
  ) async {
    final lastTab = await repository.loadLastTab() ?? SatoWikiTab.wiki;
    final readingLevel =
        await repository.loadReadingLevel() ?? ReadingLevel.base;

    return AppSettingsController._(
      repository: repository,
      lastTab: lastTab,
      readingLevel: readingLevel,
    );
  }

  Future<void> setLastTab(SatoWikiTab tab) async {
    if (_lastTab == tab) {
      return;
    }

    _lastTab = tab;
    notifyListeners();
    await _persist(() => _repository.saveLastTab(tab));
  }

  Future<void> setReadingLevel(ReadingLevel level) async {
    if (_readingLevel == level) {
      return;
    }

    _readingLevel = level;
    notifyListeners();
    await _persist(() => _repository.saveReadingLevel(level));
  }

  Future<void> _persist(Future<void> Function() write) async {
    try {
      await write();
    } on Object {
      // Preference writes should not break the reader experience.
    }
  }
}
