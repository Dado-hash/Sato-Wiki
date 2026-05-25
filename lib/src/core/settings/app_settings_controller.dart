import 'package:flutter/foundation.dart';

import '../content/reading_level.dart';
import '../localization/app_locale.dart';
import '../navigation/sato_wiki_tab.dart';
import 'app_settings_repository.dart';

final class AppSettingsController extends ChangeNotifier {
  AppSettingsController._({
    required AppSettingsRepository repository,
    required SatoWikiTab lastTab,
    required ReadingLevel readingLevel,
    required AppLocalePreference localePreference,
  }) : _repository = repository,
       _lastTab = lastTab,
       _readingLevel = readingLevel,
       _localePreference = localePreference;

  final AppSettingsRepository _repository;

  SatoWikiTab _lastTab;
  ReadingLevel _readingLevel;
  AppLocalePreference _localePreference;

  SatoWikiTab get lastTab => _lastTab;

  ReadingLevel get readingLevel => _readingLevel;

  AppLocalePreference get localePreference => _localePreference;

  static Future<AppSettingsController> load(
    AppSettingsRepository repository,
  ) async {
    final lastTab = await repository.loadLastTab() ?? SatoWikiTab.wiki;
    final readingLevel =
        await repository.loadReadingLevel() ?? ReadingLevel.base;
    final localePreference = await repository.loadLocalePreference();

    return AppSettingsController._(
      repository: repository,
      lastTab: lastTab,
      readingLevel: readingLevel,
      localePreference: localePreference,
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

  Future<void> setLocalePreference(AppLocalePreference preference) async {
    if (_localePreference == preference) {
      return;
    }

    _localePreference = preference;
    notifyListeners();
    await _persist(() => _repository.saveLocalePreference(preference));
  }

  Future<void> _persist(Future<void> Function() write) async {
    try {
      await write();
    } on Object {
      // Preference writes should not break the reader experience.
    }
  }
}
