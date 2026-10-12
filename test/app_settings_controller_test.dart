import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/core/navigation/sato_wiki_tab.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/settings/theme_preference.dart';

void main() {
  group('defaults', () {
    test('start on the today tab with dark theme and no saved data', () async {
      final controller = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );

      expect(controller.lastTab, SatoWikiTab.today);
      expect(controller.themePreference, ThemePreference.dark);
      expect(controller.readerTextScale, 1.0);
      expect(controller.bookmarks, isEmpty);
      expect(controller.recentSearches, isEmpty);
      expect(controller.continueReadingId, isNull);
      expect(controller.progressFor('wiki.utxo'), 0.0);
    });

    test('unknown stored text scale falls back to 1.0', () async {
      final controller = await AppSettingsController.load(
        InMemoryAppSettingsRepository(readerTextScale: 2.5),
      );

      expect(controller.readerTextScale, 1.0);
    });
  });

  group('bookmarks', () {
    test(
      'toggle adds new ids at the front and removes existing ones',
      () async {
        final controller = await AppSettingsController.load(
          InMemoryAppSettingsRepository(),
        );

        await controller.toggleBookmark('wiki.a');
        await controller.toggleBookmark('wiki.b');
        expect(controller.bookmarks, ['wiki.b', 'wiki.a']);
        expect(controller.isBookmarked('wiki.a'), isTrue);

        await controller.toggleBookmark('wiki.a');
        expect(controller.bookmarks, ['wiki.b']);
        expect(controller.isBookmarked('wiki.a'), isFalse);
      },
    );

    test('bookmarks getter is unmodifiable', () async {
      final controller = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );
      await controller.toggleBookmark('wiki.a');

      expect(() => controller.bookmarks.add('wiki.b'), throwsUnsupportedError);
    });
  });

  group('reading progress', () {
    test('keeps the maximum and ignores a change below 0.02', () async {
      final controller = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );

      await controller.setReadingProgress('wiki.a', 0.5);
      await controller.setReadingProgress('wiki.a', 0.51);
      expect(controller.progressFor('wiki.a'), 0.5);

      await controller.setReadingProgress('wiki.a', 0.3);
      expect(controller.progressFor('wiki.a'), 0.5);

      await controller.setReadingProgress('wiki.a', 0.6);
      expect(controller.progressFor('wiki.a'), 0.6);
    });

    test('clamps values to 0..1', () async {
      final controller = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );

      await controller.setReadingProgress('wiki.a', 3);
      expect(controller.progressFor('wiki.a'), 1.0);
    });

    test(
      'continue reading skips finished ids and picks the latest unfinished',
      () async {
        final controller = await AppSettingsController.load(
          InMemoryAppSettingsRepository(),
        );

        await controller.setReadingProgress('wiki.a', 0.4);
        await controller.setReadingProgress('wiki.b', 0.2);
        expect(controller.continueReadingId, 'wiki.b');

        await controller.setReadingProgress('wiki.b', 1.0);
        expect(controller.continueReadingId, 'wiki.a');

        await controller.setReadingProgress('wiki.c', 0.1);
        expect(controller.continueReadingId, 'wiki.c');
      },
    );
  });

  group('recent searches', () {
    test('dedupe ignoring case, newest first', () async {
      final controller = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );

      await controller.addRecentSearch('  Taproot ');
      await controller.addRecentSearch('mempool');
      await controller.addRecentSearch('taproot');
      await controller.addRecentSearch('   ');

      expect(controller.recentSearches, ['taproot', 'mempool']);
    });

    test('keep at most six entries', () async {
      final controller = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );

      for (var i = 1; i <= 8; i++) {
        await controller.addRecentSearch('query $i');
      }

      expect(controller.recentSearches.length, 6);
      expect(controller.recentSearches.first, 'query 8');
      expect(controller.recentSearches.last, 'query 3');
    });
  });

  group('reader text scale', () {
    test('cycle wraps back to the first scale', () async {
      final controller = await AppSettingsController.load(
        InMemoryAppSettingsRepository(),
      );

      expect(controller.readerTextScale, 1.0);
      await controller.cycleReaderTextScale();
      expect(controller.readerTextScale, 1.15);
      await controller.cycleReaderTextScale();
      expect(controller.readerTextScale, 1.3);
      await controller.cycleReaderTextScale();
      expect(controller.readerTextScale, 0.9);
      await controller.cycleReaderTextScale();
      expect(controller.readerTextScale, 1.0);
    });
  });

  test('values survive a second load on the same repository', () async {
    final repository = InMemoryAppSettingsRepository();
    final first = await AppSettingsController.load(repository);

    await first.setLastTab(SatoWikiTab.code);
    await first.setThemePreference(ThemePreference.light);
    await first.setReaderTextScale(1.3);
    await first.toggleBookmark('code.bip.341');
    await first.setReadingProgress('code.bip.341', 0.4);
    await first.addRecentSearch('segwit');

    final second = await AppSettingsController.load(repository);

    expect(second.lastTab, SatoWikiTab.code);
    expect(second.themePreference, ThemePreference.light);
    expect(second.readerTextScale, 1.3);
    expect(second.bookmarks, ['code.bip.341']);
    expect(second.progressFor('code.bip.341'), 0.4);
    expect(second.continueReadingId, 'code.bip.341');
    expect(second.recentSearches, ['segwit']);
  });
}
