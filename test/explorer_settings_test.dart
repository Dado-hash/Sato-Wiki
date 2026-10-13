import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/theme_preference.dart';
import 'package:sato_wiki/src/core/navigation/sato_wiki_tab.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/settings/shared_preferences_app_settings_repository.dart';
import 'package:sato_wiki/src/features/tools/data/esplora_client.dart';
import 'package:sato_wiki/src/features/tools/presentation/explorer_session.dart';

import 'explorer_test_support.dart';

void main() {
  group('explorer settings', () {
    test('the explorer is off at install, with the public server', () async {
      final controller = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );

      expect(controller.explorerEnabled, isFalse);
      expect(controller.explorerServer, 'https://mempool.space/api');
      expect(
        AppSettingsController.defaultExplorerServer,
        defaultEsploraBaseUrl,
      );
    });

    test('the switch and the server survive a restart', () async {
      final repository = InMemoryAppSettingsRepository();
      final first = await AppSettingsController.load(repository);

      await first.setExplorerServer('https://example.org/api');
      await first.setExplorerEnabled(true);
      final second = await AppSettingsController.load(repository);

      expect(second.explorerEnabled, isTrue);
      expect(second.explorerServer, 'https://example.org/api');
    });

    test(
      'settings are stored under explorer keys in shared preferences',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final preferences = await SharedPreferences.getInstance();
        final controller = await AppSettingsController.load(
          SharedPreferencesAppSettingsRepository(preferences),
        );

        // Loading writes nothing: the explorer stays off and no key exists.
        expect(preferences.getKeys(), isEmpty);

        await controller.setExplorerServer('http://localhost:3000/api');
        await controller.setExplorerEnabled(true);

        expect(preferences.getBool('settings.explorerEnabled'), isTrue);
        expect(
          preferences.getString('settings.explorerServer'),
          'http://localhost:3000/api',
        );

        final reloaded = await AppSettingsController.load(
          SharedPreferencesAppSettingsRepository(preferences),
        );
        expect(reloaded.explorerEnabled, isTrue);
        expect(reloaded.explorerServer, 'http://localhost:3000/api');
      },
    );

    test('turning the explorer off again is stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'settings.explorerEnabled': true,
      });
      final preferences = await SharedPreferences.getInstance();
      final controller = await AppSettingsController.load(
        SharedPreferencesAppSettingsRepository(preferences),
      );

      expect(controller.explorerEnabled, isTrue);
      await controller.setExplorerEnabled(false);

      expect(preferences.getBool('settings.explorerEnabled'), isFalse);
    });
  });

  group('server URL rules', () {
    test('https servers and local http servers are accepted', () {
      for (final server in const [
        'https://mempool.space/api',
        'https://example.org/api/',
        'http://localhost:3000/api',
        'http://127.0.0.1:3000/api',
        'http://abc.onion/api',
        'http://node.local/api',
      ]) {
        expect(parseExplorerServer(server), isNotNull, reason: server);
      }
    });

    test('other servers, empty text and URLs with secrets are refused', () {
      for (final server in const [
        'http://example.com/api',
        'ftp://example.org/api',
        'https://user:pass@example.org/api',
        'https://example.org/api?key=1',
        'https://example.org/api#frag',
        '',
        '   ',
        'not a url',
      ]) {
        expect(parseExplorerServer(server), isNull, reason: server);
      }
    });
  });

  testWidgets('a search writes nothing to the stored settings', (tester) async {
    final repository = _SpyRepository(
      explorerEnabled: true,
      explorerServer: 'https://example.org/api',
    );
    final api = FakeExplorerApi()
      ..addresses[addressValue] = cannedAddress()
      ..addressTxs[addressValue] = [cannedTransaction()]
      ..transactions[txHash] = cannedTransaction();

    for (final query in [addressValue, txHash]) {
      // A fresh tree, so the navigator does not keep the previous search.
      await tester.pumpWidget(const SizedBox());
      await pumpExplorer(
        tester,
        route: '/code/explorer',
        repository: repository,
        api: api,
      );
      // Setting up the route may write the last tab. Only the search counts.
      repository.writes.clear();
      await tester.enterText(find.byType(TextField), query);
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Search'));
      await tester.pumpAndSettle();
      expect(repository.writes, isEmpty, reason: 'searches must not be stored');
    }

    expect(api.calls, isNotEmpty);
  });
}

/// Records every write to the settings, so a search can be checked for
/// stored data. Reads and writes go to an in-memory repository.
final class _SpyRepository implements AppSettingsRepository {
  _SpyRepository({
    required bool explorerEnabled,
    required String explorerServer,
  }) : _inner = InMemoryAppSettingsRepository(
         explorerEnabled: explorerEnabled,
         explorerServer: explorerServer,
       );

  final InMemoryAppSettingsRepository _inner;
  final List<String> writes = <String>[];

  @override
  Future<SatoWikiTab?> loadLastTab() => _inner.loadLastTab();

  @override
  Future<void> saveLastTab(SatoWikiTab tab) async {
    writes.add('lastTab');
    await _inner.saveLastTab(tab);
  }

  @override
  Future<ReadingLevel?> loadReadingLevel() => _inner.loadReadingLevel();

  @override
  Future<void> saveReadingLevel(ReadingLevel level) async {
    writes.add('readingLevel');
    await _inner.saveReadingLevel(level);
  }

  @override
  Future<AppLocalePreference> loadLocalePreference() =>
      _inner.loadLocalePreference();

  @override
  Future<void> saveLocalePreference(AppLocalePreference preference) async {
    writes.add('localePreference');
    await _inner.saveLocalePreference(preference);
  }

  @override
  Future<ThemePreference> loadThemePreference() => _inner.loadThemePreference();

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    writes.add('themePreference');
    await _inner.saveThemePreference(preference);
  }

  @override
  Future<double?> loadReaderTextScale() => _inner.loadReaderTextScale();

  @override
  Future<void> saveReaderTextScale(double scale) async {
    writes.add('readerTextScale');
    await _inner.saveReaderTextScale(scale);
  }

  @override
  Future<List<String>> loadBookmarks() => _inner.loadBookmarks();

  @override
  Future<void> saveBookmarks(List<String> bookmarks) async {
    writes.add('bookmarks');
    await _inner.saveBookmarks(bookmarks);
  }

  @override
  Future<Map<String, double>> loadReadingProgress() =>
      _inner.loadReadingProgress();

  @override
  Future<void> saveReadingProgress(Map<String, double> progress) async {
    writes.add('readingProgress');
    await _inner.saveReadingProgress(progress);
  }

  @override
  Future<List<String>> loadLastRead() => _inner.loadLastRead();

  @override
  Future<void> saveLastRead(List<String> ids) async {
    writes.add('lastRead');
    await _inner.saveLastRead(ids);
  }

  @override
  Future<List<String>> loadRecentSearches() => _inner.loadRecentSearches();

  @override
  Future<void> saveRecentSearches(List<String> queries) async {
    writes.add('recentSearches');
    await _inner.saveRecentSearches(queries);
  }

  @override
  Future<bool?> loadExplorerEnabled() => _inner.loadExplorerEnabled();

  @override
  Future<void> saveExplorerEnabled(bool enabled) async {
    writes.add('explorerEnabled');
    await _inner.saveExplorerEnabled(enabled);
  }

  @override
  Future<String?> loadExplorerServer() => _inner.loadExplorerServer();

  @override
  Future<void> saveExplorerServer(String server) async {
    writes.add('explorerServer');
    await _inner.saveExplorerServer(server);
  }
}
