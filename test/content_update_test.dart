import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_errors.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
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

  test(
    'updater installs bundle text when a referenced media file fails',
    () async {
      final mediaRoot = await Directory.systemTemp.createTemp(
        'satowiki_media_failure',
      );
      addTearDown(() {
        if (mediaRoot.existsSync()) {
          mediaRoot.deleteSync(recursive: true);
        }
      });
      final okUrl =
          'https://example.com/content/en/2026.05.26/'
          'media/wiki/utxo-model/utxo-flow.png';
      final updateJson = _bundleJson(
        version: '2026.05.26',
        wikiBody:
            '![UTXO diagram](media/wiki/utxo-model/utxo-flow.png)\n\n'
            '![Missing](media/wiki/utxo-model/missing.png)',
      );
      final fixture = await _updaterFixtureFor(
        manifest: _manifest(version: '2026.05.26', json: updateJson),
        downloadJson: updateJson,
        mediaStore: ContentMediaStore(
          rootDirectory: mediaRoot,
          downloader: _FakeMediaDownloader({
            okUrl: [1, 2, 3],
          }),
        ),
      );

      final result = await fixture.updater.checkForUpdates('en');

      expect(result?.bundle.version, '2026.05.26');
      expect(
        (await fixture.repository.load('en')).bundle.version,
        '2026.05.26',
      );
      expect(
        File(
          '${mediaRoot.path}/en/2026.05.26/'
          'media/wiki/utxo-model/utxo-flow.png',
        ).readAsBytesSync(),
        [1, 2, 3],
      );
      expect(
        File(
          '${mediaRoot.path}/en/2026.05.26/'
          'media/wiki/utxo-model/missing.png',
        ).existsSync(),
        isFalse,
      );
    },
  );

  test('updater reports work start only before a real download', () async {
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_work_start',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final updateJson = _bundleJson(version: '2026.05.26');
    final updater = await _updaterFor(
      manifest: _manifest(version: '2026.05.26', json: updateJson),
      downloadJson: updateJson,
      mediaStore: ContentMediaStore(rootDirectory: mediaRoot),
    );
    final sameVersion = await _updaterFor(
      manifest: _manifest(
        version: '2026.05.25',
        json: _bundleJson(version: '2026.05.25'),
      ),
      downloadJson: _bundleJson(version: '2026.05.25'),
    );
    var sameVersionStarted = false;
    var updateStarted = false;

    await sameVersion.checkForUpdates(
      'en',
      onWorkStarted: () => sameVersionStarted = true,
    );
    await updater.checkForUpdates(
      'en',
      onWorkStarted: () => updateStarted = true,
    );

    expect(sameVersionStarted, isFalse);
    expect(updateStarted, isTrue);
  });

  test(
    'updater repairs missing media when manifest version is unchanged',
    () async {
      final mediaRoot = await Directory.systemTemp.createTemp(
        'satowiki_updater_repair',
      );
      addTearDown(() {
        if (mediaRoot.existsSync()) {
          mediaRoot.deleteSync(recursive: true);
        }
      });
      final currentJson = _bundleJson(
        version: '2026.05.25',
        wikiBody: '![Flow](media/wiki/utxo-model/repair-test.png)',
      );
      final fixture = await _updaterFixtureFor(
        seedJson: currentJson,
        manifest: _manifest(version: '2026.05.25', json: currentJson),
        mediaStore: ContentMediaStore(
          rootDirectory: mediaRoot,
          downloader: _FakeMediaDownloader({
            'https://example.com/content/en/2026.05.25/'
                'media/wiki/utxo-model/repair-test.png': [
              4,
              5,
              6,
            ],
          }),
        ),
      );

      final result = await fixture.updater.checkForUpdates('en');

      expect(result?.bundle.version, '2026.05.25');
      expect(
        File(
          '${mediaRoot.path}/en/2026.05.25/'
          'media/wiki/utxo-model/repair-test.png',
        ).readAsBytesSync(),
        [4, 5, 6],
      );
    },
  );

  test('controller repairs same-version media and reports the work', () async {
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_controller_repair',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final currentJson = _bundleJson(
      version: '2026.05.25',
      wikiBody: '![Flow](media/wiki/utxo-model/repair-test.png)',
    );
    final repository = LocalFirstContentBundleRepository(
      preferences: preferences,
      assetBundle: _FakeAssetBundle(currentJson),
    );
    final mediaStore = ContentMediaStore(
      rootDirectory: mediaRoot,
      downloader: _FakeMediaDownloader({
        'https://example.com/content/en/2026.05.25/'
            'media/wiki/utxo-model/repair-test.png': [
          4,
          5,
          6,
        ],
      }),
    );
    final controller = await AppContentController.load(
      repository: repository,
      languageCode: 'en',
      mediaStore: mediaStore,
      updater: VerifiedBackgroundContentUpdater(
        localRepository: repository,
        manifestRepository: _FakeManifestRepository(
          _manifest(version: '2026.05.25', json: currentJson),
        ),
        downloader: const _FakeDownloader(null),
        mediaStore: mediaStore,
      ),
    );
    final states = <UpdateState>[];
    controller.addListener(() => states.add(controller.updateProgress.state));

    await controller.checkForUpdates();

    expect(states, contains(UpdateState.downloadingBundle));
    expect(controller.updateProgress.state, UpdateState.done);
    expect(
      File(
        '${mediaRoot.path}/en/2026.05.25/'
        'media/wiki/utxo-model/repair-test.png',
      ).readAsBytesSync(),
      [4, 5, 6],
    );
  });

  test('controller never shows download state when nothing changed', () async {
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_controller_idle',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final currentJson = _bundleJson(
      version: '2026.05.25',
      wikiBody: '![Flow](media/wiki/utxo-model/present.png)',
    );
    final presentFile = File(
      '${mediaRoot.path}/en/2026.05.25/media/wiki/utxo-model/present.png',
    );
    await presentFile.create(recursive: true);
    await presentFile.writeAsBytes([1]);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalFirstContentBundleRepository(
      preferences: preferences,
      assetBundle: _FakeAssetBundle(currentJson),
    );
    final mediaStore = ContentMediaStore(rootDirectory: mediaRoot);
    final controller = await AppContentController.load(
      repository: repository,
      languageCode: 'en',
      mediaStore: mediaStore,
      updater: VerifiedBackgroundContentUpdater(
        localRepository: repository,
        manifestRepository: _FakeManifestRepository(
          _manifest(version: '2026.05.25', json: currentJson),
        ),
        downloader: const _FakeDownloader(null),
        mediaStore: mediaStore,
      ),
    );
    final states = <UpdateState>[];
    controller.addListener(() => states.add(controller.updateProgress.state));

    await controller.checkForUpdates();

    expect(states, isNot(contains(UpdateState.downloadingBundle)));
    expect(controller.updateProgress.state, UpdateState.idle);
  });

  test('controller fetches the manifest only once per check', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final updateJson = _bundleJson(version: '2026.05.26');
    final repository = LocalFirstContentBundleRepository(
      preferences: preferences,
      assetBundle: _FakeAssetBundle(_bundleJson(version: '2026.05.25')),
    );
    final manifests = _CountingManifestRepository(
      _manifest(version: '2026.05.26', json: updateJson),
    );
    final controller = await AppContentController.load(
      repository: repository,
      languageCode: 'en',
      updater: VerifiedBackgroundContentUpdater(
        localRepository: repository,
        manifestRepository: manifests,
        downloader: _FakeDownloader(updateJson),
      ),
    );

    await controller.checkForUpdates();

    expect(manifests.fetchCount, 1);
    expect(controller.updateProgress.state, UpdateState.done);
    expect(controller.content.store.bundle.version, '2026.05.26');
  });

  test(
    'updater rejects media whose bytes do not match the manifest hash',
    () async {
      final mediaRoot = await Directory.systemTemp.createTemp(
        'satowiki_media_hash',
      );
      addTearDown(() {
        if (mediaRoot.existsSync()) {
          mediaRoot.deleteSync(recursive: true);
        }
      });
      final updateJson = _bundleJson(
        version: '2026.05.26',
        wikiBody: '![Flow](media/wiki/utxo-model/tampered.png)',
      );
      final expectedHash = sha256.convert([1, 2, 3]).toString();
      final fixture = await _updaterFixtureFor(
        manifest: _manifest(
          version: '2026.05.26',
          json: updateJson,
          mediaHashes: {'media/wiki/utxo-model/tampered.png': expectedHash},
        ),
        downloadJson: updateJson,
        mediaStore: ContentMediaStore(
          rootDirectory: mediaRoot,
          downloader: _FakeMediaDownloader({
            'https://example.com/content/en/2026.05.26/'
                'media/wiki/utxo-model/tampered.png': [
              9,
              9,
            ],
          }),
        ),
      );

      final result = await fixture.updater.checkForUpdates('en');

      expect(result?.bundle.version, '2026.05.26');
      expect(
        File(
          '${mediaRoot.path}/en/2026.05.26/'
          'media/wiki/utxo-model/tampered.png',
        ).existsSync(),
        isFalse,
      );
    },
  );

  test('startup discards a stored update whose media is invalid', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalFirstContentBundleRepository(
      preferences: preferences,
      assetBundle: _FakeAssetBundle(_bundleJson(version: '2026.05.25')),
    );
    await repository.saveUpdatedBundleJson(
      'en',
      _bundleJson(
        version: '2026.05.26',
        wikiBody: '![Remote](https://example.com/remote.png)',
      ),
    );
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_startup_invalid',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });

    final controller = await AppContentController.load(
      repository: repository,
      languageCode: 'en',
      mediaStore: ContentMediaStore(rootDirectory: mediaRoot),
    );

    expect(controller.content.store.bundle.version, '2026.05.25');
    expect(preferences.getString('content.updatedBundleJson.en'), isNull);
  });

  test('startup keeps seed text when seed media is invalid', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalFirstContentBundleRepository(
      preferences: preferences,
      assetBundle: _FakeAssetBundle(
        _bundleJson(
          version: '2026.05.25',
          wikiBody: '![Remote](https://example.com/remote.png)',
        ),
      ),
    );
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_startup_seed',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });

    final controller = await AppContentController.load(
      repository: repository,
      languageCode: 'en',
      mediaStore: ContentMediaStore(rootDirectory: mediaRoot),
    );

    expect(controller.content.store.bundle.version, '2026.05.25');
    expect(controller.content.store.bundle.wiki, hasLength(1));
  });

  test('controller logs parser warnings in debug builds', () async {
    final messages = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      messages.add(message ?? '');
    };
    addTearDown(() => debugPrint = originalDebugPrint);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalFirstContentBundleRepository(
      preferences: preferences,
      assetBundle: _FakeAssetBundle('''
{
  "schemaVersion": 1,
  "version": "2026.05.25",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [{"id": "wiki.invalid"}],
  "news": [],
  "history": [],
  "bips": [],
  "changelogs": []
}
'''),
    );

    final controller = await AppContentController.load(
      repository: repository,
      languageCode: 'en',
    );

    expect(controller.content.warnings, isNotEmpty);
    expect(messages.any((message) => message.contains('wiki[0]')), isTrue);
  });

  test('overlapping language loads apply only the latest request', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = _GatedContentRepository(
      LocalFirstContentBundleRepository(
        preferences: preferences,
        assetBundle: _FakeAssetBundle(
          _bundleJson(version: '2026.05.25'),
          itJson: _bundleJson(version: '2026.05.25', language: 'it'),
        ),
      ),
    );
    final controller = await AppContentController.load(
      repository: repository,
      languageCode: 'en',
    );
    final itGate = Completer<void>();
    repository.gates['it'] = itGate;

    final itLoad = controller.loadLanguage('it');
    await controller.loadLanguage('en');
    itGate.complete();
    await itLoad;

    expect(controller.languageCode, 'en');
    expect(controller.content.store.bundle.language, 'en');
  });

  test(
    'update result is dropped when the language changed meanwhile',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = LocalFirstContentBundleRepository(
        preferences: preferences,
        assetBundle: _FakeAssetBundle(
          _bundleJson(version: '2026.05.25'),
          itJson: _bundleJson(version: '2026.05.25', language: 'it'),
        ),
      );
      final downloader = _GatedDownloader();
      final controller = await AppContentController.load(
        repository: repository,
        languageCode: 'en',
        updater: VerifiedBackgroundContentUpdater(
          localRepository: repository,
          manifestRepository: _FakeManifestRepository(
            _manifest(
              version: '2026.05.26',
              json: _bundleJson(version: '2026.05.26'),
            ),
          ),
          downloader: downloader,
        ),
      );

      final check = controller.checkForUpdates();
      await downloader.started.future;
      await controller.loadLanguage('it');
      downloader.gate.complete(_bundleJson(version: '2026.05.26'));
      await check;

      expect(controller.languageCode, 'it');
      expect(controller.content.store.bundle.language, 'it');
      expect(controller.content.store.bundle.version, '2026.05.25');
      expect(controller.updateProgress.state, UpdateState.idle);
    },
  );

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

  group('response deadlines', () {
    late HttpServer server;
    late HttpOverrides? previousOverrides;

    setUp(() async {
      // flutter_test replaces HttpClient with a mock; these tests need the
      // real one to talk to a local server.
      previousOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    });

    tearDown(() async {
      await server.close(force: true);
      HttpOverrides.global = previousOverrides;
    });

    test('manifest request gives up when the server never answers', () async {
      server.listen((request) {});
      final repository = GitHubPagesContentManifestRepository(
        baseUri: 'http://127.0.0.1:${server.port}',
        responseTimeout: const Duration(milliseconds: 300),
      );

      expect(await repository.fetchManifest('en'), isNull);
    });

    test('bundle download gives up when the server never answers', () async {
      server.listen((request) {});
      const downloader = HttpContentBundleDownloader(
        responseTimeout: Duration(milliseconds: 300),
      );

      await expectLater(
        downloader.downloadBundle(
          Uri.parse('http://127.0.0.1:${server.port}/bundle.json'),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('media download gives up when the body stalls', () async {
      server.listen((request) {
        request.response
          ..statusCode = HttpStatus.ok
          ..contentLength = 100
          ..add([1, 2, 3]);
        // The response is never completed, so the body read stalls.
      });
      const downloader = HttpContentMediaDownloader(
        responseTimeout: Duration(milliseconds: 300),
      );

      await expectLater(
        downloader.downloadMedia(
          Uri.parse('http://127.0.0.1:${server.port}/media.png'),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('media download returns the full body', () async {
      server.listen((request) {
        request.response
          ..statusCode = HttpStatus.ok
          ..add([10, 20, 30, 40])
          ..close();
      });
      const downloader = HttpContentMediaDownloader(
        responseTimeout: Duration(seconds: 5),
      );

      final bytes = await downloader.downloadMedia(
        Uri.parse('http://127.0.0.1:${server.port}/media.png'),
      );

      expect(bytes, [10, 20, 30, 40]);
    });
  });
}

final class _CountingManifestRepository
    implements RemoteContentManifestRepository {
  _CountingManifestRepository(this.manifest);

  final ContentManifest manifest;
  int fetchCount = 0;

  @override
  Future<ContentManifest?> fetchManifest(String languageCode) async {
    fetchCount++;

    return manifest;
  }
}

/// Holds a bundle download open until the test completes [gate].
final class _GatedDownloader implements ContentBundleDownloader {
  final started = Completer<void>();
  final gate = Completer<String>();

  @override
  Future<String> downloadBundle(Uri bundleUrl) {
    if (!started.isCompleted) {
      started.complete();
    }

    return gate.future;
  }
}

/// Delays [load] for a language while its gate is open.
final class _GatedContentRepository implements ContentBundleRepository {
  _GatedContentRepository(this._inner);

  final ContentBundleRepository _inner;
  final gates = <String, Completer<void>>{};

  @override
  Future<ContentBundleParseResult> load(String languageCode) async {
    final gate = gates[languageCode];
    if (gate != null) {
      await gate.future;
    }

    return _inner.load(languageCode);
  }

  @override
  Future<void> saveUpdatedBundleJson(String languageCode, String json) {
    return _inner.saveUpdatedBundleJson(languageCode, json);
  }
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
