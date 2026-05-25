import 'dart:convert';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_errors.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
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
        'en',
      );
    },
  );

  test('local repository stores updates with language-specific keys', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalFirstContentBundleRepository(
      preferences: preferences,
      assetBundle: _FakeAssetBundle(_bundleJson(version: '2026.05.25')),
    );

    await repository.saveUpdatedBundleJson(
      'en',
      _bundleJson(version: '2026.05.26'),
    );

    final result = await repository.load('en');
    final fallbackResult = await repository.load('it');

    expect(result.bundle.version, '2026.05.26');
    expect(fallbackResult.bundle.language, 'en');
  });

  test('updater installs newer valid bundle', () async {
    final updateJson = _bundleJson(version: '2026.05.26');
    final updater = await _updaterFor(
      manifest: _manifest(version: '2026.05.26', json: updateJson),
      downloadJson: updateJson,
    );

    final result = await updater.checkForUpdates('en');

    expect(result?.bundle.version, '2026.05.26');
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
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final localRepository = LocalFirstContentBundleRepository(
    preferences: preferences,
    assetBundle: _FakeAssetBundle(_bundleJson(version: '2026.05.25')),
  );

  return VerifiedBackgroundContentUpdater(
    localRepository: localRepository,
    manifestRepository: _FakeManifestRepository(manifest),
    downloader: _FakeDownloader(downloadJson),
  );
}

ContentManifest _manifest({
  required String version,
  required String json,
  int schemaVersion = 1,
  String? sha256Override,
}) {
  return ContentManifest(
    version: version,
    schemaVersion: schemaVersion,
    language: 'en',
    bundleUrl: Uri.parse('https://example.com/content/en/$version/bundle.json'),
    sha256: sha256Override ?? sha256.convert(utf8.encode(json)).toString(),
  );
}

String _bundleJson({
  required String version,
  String language = 'en',
  int schemaVersion = 1,
}) {
  return '''
{
  "schemaVersion": $schemaVersion,
  "version": "$version",
  "language": "$language",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [],
  "news": [],
  "history": [],
  "bips": [],
  "changelogs": []
}
''';
}

final class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this.json);

  final String json;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(json));

    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
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
