import 'package:flutter/foundation.dart';

import '../content/reading_level.dart';
import '../localization/app_locale.dart';
import '../navigation/sato_wiki_tab.dart';
import 'app_settings_repository.dart';
import 'theme_preference.dart';

final class AppSettingsController extends ChangeNotifier {
  AppSettingsController._({
    required AppSettingsRepository repository,
    required SatoWikiTab lastTab,
    required ReadingLevel readingLevel,
    required AppLocalePreference localePreference,
    required ThemePreference themePreference,
    required double readerTextScale,
    required List<String> bookmarks,
    required Map<String, double> readingProgress,
    required List<String> lastRead,
    required List<String> recentSearches,
  }) : _repository = repository,
       _lastTab = lastTab,
       _readingLevel = readingLevel,
       _localePreference = localePreference,
       _themePreference = themePreference,
       _readerTextScale = readerTextScale,
       _bookmarks = bookmarks,
       _readingProgress = readingProgress,
       _lastRead = lastRead,
       _recentSearches = recentSearches;

  static const readerTextScales = <double>[0.9, 1.0, 1.15, 1.3];

  static const _maxRecentSearches = 6;
  static const _maxLastRead = 20;
  static const _minProgressStep = 0.02;

  /// Reading progress from which a record counts as finished.
  static const finishedProgress = 0.98;

  final AppSettingsRepository _repository;

  SatoWikiTab _lastTab;
  ReadingLevel _readingLevel;
  AppLocalePreference _localePreference;
  ThemePreference _themePreference;
  double _readerTextScale;
  List<String> _bookmarks;
  final Map<String, double> _readingProgress;
  List<String> _lastRead;
  List<String> _recentSearches;

  SatoWikiTab get lastTab => _lastTab;

  ReadingLevel get readingLevel => _readingLevel;

  AppLocalePreference get localePreference => _localePreference;

  ThemePreference get themePreference => _themePreference;

  double get readerTextScale => _readerTextScale;

  List<String> get bookmarks => List.unmodifiable(_bookmarks);

  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  bool isBookmarked(String contentId) => _bookmarks.contains(contentId);

  double progressFor(String contentId) => _readingProgress[contentId] ?? 0.0;

  /// The most recently read id that is started but not finished.
  String? get continueReadingId {
    for (final id in _lastRead) {
      final progress = _readingProgress[id];
      if (progress != null && progress > 0 && progress < finishedProgress) {
        return id;
      }
    }

    return null;
  }

  static Future<AppSettingsController> load(
    AppSettingsRepository repository,
  ) async {
    final lastTab = await repository.loadLastTab() ?? SatoWikiTab.today;
    final readingLevel =
        await repository.loadReadingLevel() ?? ReadingLevel.base;
    final localePreference = await repository.loadLocalePreference();
    final themePreference = await repository.loadThemePreference();
    final storedScale = await repository.loadReaderTextScale();
    final readerTextScale =
        storedScale != null && readerTextScales.contains(storedScale)
        ? storedScale
        : 1.0;
    final bookmarks = await repository.loadBookmarks();
    final readingProgress = await repository.loadReadingProgress();
    final lastRead = await repository.loadLastRead();
    final recentSearches = await repository.loadRecentSearches();

    return AppSettingsController._(
      repository: repository,
      lastTab: lastTab,
      readingLevel: readingLevel,
      localePreference: localePreference,
      themePreference: themePreference,
      readerTextScale: readerTextScale,
      bookmarks: bookmarks,
      readingProgress: readingProgress,
      lastRead: lastRead,
      recentSearches: recentSearches,
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

  Future<void> setThemePreference(ThemePreference preference) async {
    if (_themePreference == preference) {
      return;
    }

    _themePreference = preference;
    notifyListeners();
    await _persist(() => _repository.saveThemePreference(preference));
  }

  Future<void> setReaderTextScale(double scale) async {
    if (_readerTextScale == scale) {
      return;
    }

    _readerTextScale = scale;
    notifyListeners();
    await _persist(() => _repository.saveReaderTextScale(scale));
  }

  Future<void> cycleReaderTextScale() async {
    final currentIndex = readerTextScales.indexOf(_readerTextScale);
    final nextIndex = (currentIndex + 1) % readerTextScales.length;

    await setReaderTextScale(readerTextScales[nextIndex]);
  }

  Future<void> toggleBookmark(String contentId) async {
    if (_bookmarks.contains(contentId)) {
      _bookmarks = [
        for (final id in _bookmarks)
          if (id != contentId) id,
      ];
    } else {
      _bookmarks = [contentId, ..._bookmarks];
    }

    notifyListeners();
    final bookmarks = List<String>.of(_bookmarks);
    await _persist(() => _repository.saveBookmarks(bookmarks));
  }

  Future<void> setReadingProgress(String contentId, double progress) async {
    final value = progress.clamp(0.0, 1.0).toDouble();
    final current = _readingProgress[contentId];

    if (current != null) {
      // Finishing an entry is always stored once; otherwise only meaningful
      // forward movement is kept.
      final isFinishing =
          value >= finishedProgress && current < finishedProgress;
      if (!isFinishing && value < current + _minProgressStep) {
        return;
      }
    }

    _readingProgress[contentId] = value;
    _lastRead = [
      contentId,
      for (final id in _lastRead)
        if (id != contentId) id,
    ];

    if (_lastRead.length > _maxLastRead) {
      final dropped = _lastRead.sublist(_maxLastRead);
      _lastRead = _lastRead.sublist(0, _maxLastRead);
      for (final id in dropped) {
        _readingProgress.remove(id);
      }
    }

    notifyListeners();
    final progressSnapshot = Map<String, double>.of(_readingProgress);
    final lastReadSnapshot = List<String>.of(_lastRead);
    await _persist(() => _repository.saveReadingProgress(progressSnapshot));
    await _persist(() => _repository.saveLastRead(lastReadSnapshot));
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final lowerQuery = trimmed.toLowerCase();
    final updated = <String>[
      trimmed,
      for (final existing in _recentSearches)
        if (existing.toLowerCase() != lowerQuery) existing,
    ];
    if (updated.length > _maxRecentSearches) {
      updated.removeRange(_maxRecentSearches, updated.length);
    }

    if (listEquals(updated, _recentSearches)) {
      return;
    }

    _recentSearches = updated;
    notifyListeners();
    final snapshot = List<String>.of(_recentSearches);
    await _persist(() => _repository.saveRecentSearches(snapshot));
  }

  Future<void> clearRecentSearches() async {
    if (_recentSearches.isEmpty) {
      return;
    }

    _recentSearches = <String>[];
    notifyListeners();
    await _persist(() => _repository.saveRecentSearches(const <String>[]));
  }

  Future<void> _persist(Future<void> Function() write) async {
    try {
      await write();
    } on Object {
      // Preference writes should not break the reader experience.
    }
  }
}
