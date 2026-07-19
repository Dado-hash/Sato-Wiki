import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_errors.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/content/data/content_media_store.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/shared_preferences_app_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'locale preference persists system and explicit language values',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = SharedPreferencesAppSettingsRepository(preferences);
      final controller = await AppSettingsController.load(repository);

      expect(controller.localePreference, const AppLocalePreference.system());
      expect(
        AppLocale.resolveLanguageCode(controller.localePreference, const []),
        'en',
      );

      await controller.setLocalePreference(
        const AppLocalePreference.language('en'),
      );

      expect(
        await repository.loadLocalePreference(),
        const AppLocalePreference.language('en'),
      );
      expect(
        AppLocale.resolveLanguageCode(
          const AppLocalePreference.system(),
          const [Locale('it')],
        ),
        'it',
      );
    },
  );

  test('local repository stores updates with language-specific keys', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalFirstContentBundleRepository(
      preferences: preferences,
      assetBundle: _FakeAssetBundle(
        _bundleJson(version: '2026.05.25'),
        itJson: _bundleJson(version: '2026.05.25', language: 'it'),
      ),
    );

    await repository.saveUpdatedBundleJson(
      'en',
      _bundleJson(version: '2026.05.26'),
    );

    final result = await repository.load('en');
    final fallbackResult = await repository.load('it');

    expect(result.bundle.version, '2026.05.26');
    expect(fallbackResult.bundle.language, 'it');
  });

  test(
    'local repository prefers newer bundled seed over older update',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = LocalFirstContentBundleRepository(
        preferences: preferences,
        assetBundle: _FakeAssetBundle(
          _bundleJson(version: '2026.06.01'),
          itJson: _bundleJson(version: '2026.06.01', language: 'it'),
        ),
      );

      await repository.saveUpdatedBundleJson(
        'en',
        _bundleJson(version: '2026.05.26'),
      );

      final result = await repository.load('en');

      expect(result.bundle.version, '2026.06.01');
    },
  );

  test('updater installs newer valid bundle', () async {
    final updateJson = _bundleJson(version: '2026.05.26');
    final updater = await _updaterFor(
      manifest: _manifest(version: '2026.05.26', json: updateJson),
      downloadJson: updateJson,
    );

    final result = await updater.checkForUpdates('en');

    expect(result?.bundle.version, '2026.05.26');
  });

  test('updater downloads referenced media before installing bundle', () async {
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_media_success',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final updateJson = _bundleJson(
      version: '2026.05.26',
      wikiBody:
          '![UTXO diagram](media/wiki/utxo-model/utxo-flow.png "UTXO flow")',
    );
    final mediaUrl =
        'https://example.com/content/en/2026.05.26/'
        'media/wiki/utxo-model/utxo-flow.png';
    final updater = await _updaterFor(
      manifest: _manifest(version: '2026.05.26', json: updateJson),
      downloadJson: updateJson,
      mediaStore: ContentMediaStore(
        rootDirectory: mediaRoot,
        downloader: _FakeMediaDownloader({
          mediaUrl: [1, 2, 3],
        }),
      ),
    );

    final result = await updater.checkForUpdates('en');

    expect(result?.bundle.version, '2026.05.26');
    expect(
      File(
        '${mediaRoot.path}/en/2026.05.26/'
        'media/wiki/utxo-model/utxo-flow.png',
      ).readAsBytesSync(),
      [1, 2, 3],
    );
  });

  test(
    'updater reuses unchanged media across versions using manifest hashes',
    () async {
      final mediaRoot = await Directory.systemTemp.createTemp(
        'satowiki_media_reuse',
      );
      addTearDown(() {
        if (mediaRoot.existsSync()) {
          mediaRoot.deleteSync(recursive: true);
        }
      });

      const mediaBytes = [7, 8, 9];
      final mediaHash = sha256.convert(mediaBytes).toString();
      final existingFile = File(
        '${mediaRoot.path}/en/2026.05.25/'
        'media/wiki/utxo-model/utxo-flow.png',
      );
      await existingFile.create(recursive: true);
      await existingFile.writeAsBytes(mediaBytes);

      final updateJson = _bundleJson(
        version: '2026.05.26',
        wikiBody:
            '![UTXO diagram](media/wiki/utxo-model/utxo-flow.png "UTXO flow")',
      );

      final fixture = await _updaterFixtureFor(
        manifest: _manifest(
          version: '2026.05.26',
          json: updateJson,
          mediaHashes: {'media/wiki/utxo-model/utxo-flow.png': mediaHash},
        ),
        downloadJson: updateJson,
        mediaStore: ContentMediaStore(
          rootDirectory: mediaRoot,
          downloader: const _FakeMediaDownloader({}),
        ),
      );

      final result = await fixture.updater.checkForUpdates('en');

      expect(result?.bundle.version, '2026.05.26');
      expect(
        File(
          '${mediaRoot.path}/en/2026.05.26/'
          'media/wiki/utxo-model/utxo-flow.png',
        ).readAsBytesSync(),
        mediaBytes,
      );
    },
  );

  test('updater repairs missing media for current bundle version', () async {
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_media_repair',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final currentJson = _bundleJson(
      version: '2026.05.25',
      wikiBody: '![Mining loop](media/wiki/proof-of-work/pow-mining-loop.svg)',
    );
    final mediaUrl =
        'https://example.com/content/en/2026.05.25/'
        'media/wiki/proof-of-work/pow-mining-loop.svg';
    final fixture = await _updaterFixtureFor(
      seedJson: currentJson,
      manifest: _manifest(version: '2026.05.25', json: currentJson),
      mediaStore: ContentMediaStore(
        rootDirectory: mediaRoot,
        downloader: _FakeMediaDownloader({
          mediaUrl: [4, 5, 6],
        }),
      ),
    );

    final result = await fixture.updater.checkForUpdates('en');

    expect(result?.bundle.version, '2026.05.25');
    expect(
      File(
        '${mediaRoot.path}/en/2026.05.25/'
        'media/wiki/proof-of-work/pow-mining-loop.svg',
      ).readAsBytesSync(),
      [4, 5, 6],
    );
  });

  test('updater keeps previous bundle when referenced media fails', () async {
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_media_failure',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final fixture = await _updaterFixtureFor(
      manifest: _manifest(
        version: '2026.05.26',
        json: _bundleJson(
          version: '2026.05.26',
          wikiBody: '![UTXO diagram](media/wiki/utxo-model/missing.png)',
        ),
      ),
      downloadJson: _bundleJson(
        version: '2026.05.26',
        wikiBody: '![UTXO diagram](media/wiki/utxo-model/missing.png)',
      ),
      mediaStore: ContentMediaStore(
        rootDirectory: mediaRoot,
        downloader: const _FakeMediaDownloader({}),
      ),
    );

    await expectLater(
      fixture.updater.checkForUpdates('en'),
      throwsA(isA<ContentBundleParseException>()),
    );

    final current = await fixture.repository.load('en');
    expect(current.bundle.version, '2026.05.25');
  });

  test(
    'updater ignores same version, missing manifest and future schema',
    () async {
      final sameVersion = await _updaterFor(
        manifest: _manifest(
          version: '2026.05.25',
          json: _bundleJson(version: '2026.05.25'),
        ),
        downloadJson: _bundleJson(version: '2026.05.25'),
      );
      final missingManifest = await _updaterFor(manifest: null);
      final futureSchema = await _updaterFor(
        manifest: _manifest(
          version: '2026.05.26',
          schemaVersion: 99,
          json: _bundleJson(version: '2026.05.26'),
        ),
        downloadJson: _bundleJson(version: '2026.05.26'),
      );

      expect(await sameVersion.checkForUpdates('en'), isNull);
      expect(await missingManifest.checkForUpdates('en'), isNull);
      expect(await futureSchema.checkForUpdates('en'), isNull);
    },
  );

  test('updater rejects bad hash, bad JSON and wrong language', () async {
    final badHash = await _updaterFor(
      manifest: _manifest(
        version: '2026.05.26',
        json: _bundleJson(version: '2026.05.26'),
        sha256Override: 'not-a-real-hash',
      ),
      downloadJson: _bundleJson(version: '2026.05.26'),
    );
    final badJson = await _updaterFor(
      manifest: _manifest(version: '2026.05.26', json: '{'),
      downloadJson: '{',
    );
    final wrongLanguageJson = _bundleJson(
      version: '2026.05.26',
      language: 'fr',
    );
    final wrongLanguage = await _updaterFor(
      manifest: _manifest(version: '2026.05.26', json: wrongLanguageJson),
      downloadJson: wrongLanguageJson,
    );

    await expectLater(
      badHash.checkForUpdates('en'),
      throwsA(isA<ContentBundleParseException>()),
    );
    await expectLater(
      badJson.checkForUpdates('en'),
      throwsA(isA<ContentBundleParseException>()),
    );
    await expectLater(
      wrongLanguage.checkForUpdates('en'),
      throwsA(isA<ContentBundleParseException>()),
    );
  });
}

Future<VerifiedBackgroundContentUpdater> _updaterFor({
  ContentManifest? manifest,
  String? downloadJson,
  ContentMediaStore? mediaStore,
}) async {
  final fixture = await _updaterFixtureFor(
    manifest: manifest,
    downloadJson: downloadJson,
    mediaStore: mediaStore,
  );

  return fixture.updater;
}

Future<_UpdaterFixture> _updaterFixtureFor({
  ContentManifest? manifest,
  String? downloadJson,
  ContentMediaStore? mediaStore,
  String? seedJson,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final localRepository = LocalFirstContentBundleRepository(
    preferences: preferences,
    assetBundle: _FakeAssetBundle(
      seedJson ?? _bundleJson(version: '2026.05.25'),
    ),
  );

  return _UpdaterFixture(
    repository: localRepository,
    updater: VerifiedBackgroundContentUpdater(
      localRepository: localRepository,
      manifestRepository: _FakeManifestRepository(manifest),
      downloader: _FakeDownloader(downloadJson),
      mediaStore: mediaStore,
    ),
  );
}

final class _UpdaterFixture {
  const _UpdaterFixture({required this.repository, required this.updater});

  final LocalFirstContentBundleRepository repository;
  final VerifiedBackgroundContentUpdater updater;
}

ContentManifest _manifest({
  required String version,
  required String json,
  int schemaVersion = 1,
  String? sha256Override,
  Map<String, String> mediaHashes = const {},
}) {
  return ContentManifest(
    version: version,
    schemaVersion: schemaVersion,
    language: 'en',
    bundleUrl: Uri.parse('https://example.com/content/en/$version/bundle.json'),
    sha256: sha256Override ?? sha256.convert(utf8.encode(json)).toString(),
    media: mediaHashes,
  );
}

String _bundleJson({
  required String version,
  String language = 'en',
  int schemaVersion = 1,
  String? wikiBody,
}) {
  final wiki = wikiBody == null
      ? '[]'
      : '''
[
  {
    "id": "wiki.test",
    "slug": "test",
    "language": "$language",
    "category": "protocol",
    "title": "Test",
    "description": "Test entry.",
    "readingLevels": {
      "base": {"bodyMarkdown": ${jsonEncode(wikiBody)}},
      "medium": {"bodyMarkdown": "Medium."},
      "advanced": {"bodyMarkdown": "Advanced."}
    },
    "difficulty": "base",
    "readTimeMinutes": 1,
    "tags": [],
    "sources": [],
    "related": [],
    "updatedAt": "2026-05-25T00:00:00Z"
  }
]''';

  return '''
{
  "schemaVersion": $schemaVersion,
  "version": "$version",
  "language": "$language",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": $wiki,
  "news": [],
  "history": [],
  "bips": [],
  "changelogs": []
}
''';
}

final class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this.json, {String? itJson}) : _itJson = itJson;

  final String json;
  final String? _itJson;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(json));

    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.endsWith('seed_bundle_it.json')) {
      return _itJson ?? json;
    }

    return json;
  }
}

final class _FakeManifestRepository implements RemoteContentManifestRepository {
  const _FakeManifestRepository(this.manifest);

  final ContentManifest? manifest;

  @override
  Future<ContentManifest?> fetchManifest(String languageCode) async {
    return manifest;
  }
}

final class _FakeDownloader implements ContentBundleDownloader {
  const _FakeDownloader(this.json);

  final String? json;

  @override
  Future<String> downloadBundle(Uri bundleUrl) async {
    final json = this.json;
    if (json == null) {
      throw const ContentBundleParseException('Bundle missing.');
    }

    return json;
  }
}

final class _FakeMediaDownloader implements ContentMediaDownloader {
  const _FakeMediaDownloader(this.media);

  final Map<String, List<int>> media;

  @override
  Future<List<int>> downloadMedia(Uri mediaUrl) async {
    final bytes = media[mediaUrl.toString()];
    if (bytes == null) {
      throw const ContentBundleParseException('Media missing.');
    }

    return bytes;
  }
}
