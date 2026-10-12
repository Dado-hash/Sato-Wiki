import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_locale.dart';
import '../domain/content_models.dart';
import '../domain/content_version.dart';
import 'content_bundle_errors.dart';
import 'content_bundle_migrator.dart';
import 'content_bundle_parser.dart';
import 'content_http_deadline.dart';
import 'content_media_store.dart';

abstract interface class ContentBundleRepository {
  Future<ContentBundleParseResult> load(String languageCode);

  Future<void> saveUpdatedBundleJson(String languageCode, String json);
}

/// Repositories that can drop a stored update, so that the seed takes over.
abstract interface class DiscardableContentBundleRepository {
  Future<void> discardUpdatedBundle(String languageCode);
}

final class LocalFirstContentBundleRepository
    implements ContentBundleRepository, DiscardableContentBundleRepository {
  LocalFirstContentBundleRepository({
    required SharedPreferences preferences,
    AssetBundle? assetBundle,
  }) : _preferences = preferences,
       _assetBundle = assetBundle ?? rootBundle;

  static const defaultLanguageCode = AppLocale.fallbackLanguageCode;
  static const seedAssetPaths = <String, String>{
    defaultLanguageCode: 'assets/content/seed_bundle_en.json',
    'it': 'assets/content/seed_bundle_it.json',
  };
  static const _updatedBundleKeyPrefix = 'content.updatedBundleJson';

  final SharedPreferences _preferences;
  final AssetBundle _assetBundle;

  @override
  Future<ContentBundleParseResult> load(String languageCode) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    final seedResult = await _loadSeedBundle(normalizedLanguageCode);
    final updatedJson = _preferences.getString(
      _updatedBundleKey(normalizedLanguageCode),
    );
    if (updatedJson != null) {
      try {
        final updatedResult = _parseLanguageBundle(
          updatedJson,
          normalizedLanguageCode,
        );
        if (!isNewerContentVersion(
          seedResult.bundle.version,
          updatedResult.bundle.version,
        )) {
          return updatedResult;
        }
      } on Object {
        // Bad updates must not block offline seed content.
      }
    }

    return seedResult;
  }

  Future<ContentBundleParseResult> _loadSeedBundle(
    String normalizedLanguageCode,
  ) async {
    final seedAssetPath =
        seedAssetPaths[normalizedLanguageCode] ??
        seedAssetPaths[defaultLanguageCode]!;
    final seedJson = await _assetBundle.loadString(seedAssetPath);

    return _parseLanguageBundle(seedJson, normalizedLanguageCode);
  }

  @override
  Future<void> saveUpdatedBundleJson(String languageCode, String json) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    _parseLanguageBundle(json, normalizedLanguageCode);
    await _preferences.setString(
      _updatedBundleKey(normalizedLanguageCode),
      json,
    );
  }

  @override
  Future<void> discardUpdatedBundle(String languageCode) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    await _preferences.remove(_updatedBundleKey(normalizedLanguageCode));
  }

  static String _updatedBundleKey(String languageCode) {
    return '$_updatedBundleKeyPrefix.$languageCode';
  }

  static ContentBundleParseResult _parseLanguageBundle(
    String json,
    String languageCode,
  ) {
    final result = ContentBundleParser.parseJson(json);
    if (result.bundle.language != languageCode) {
      throw ContentBundleParseException(
        'Bundle language ${result.bundle.language} does not match '
        '$languageCode.',
      );
    }

    return result;
  }
}

final class ContentManifest {
  const ContentManifest({
    required this.version,
    required this.schemaVersion,
    required this.language,
    required this.bundleUrl,
    required this.sha256,
    this.media = const {},
  });

  final String version;
  final int schemaVersion;
  final String language;
  final Uri bundleUrl;
  final String sha256;

  /// Maps a media source path (e.g. `media/wiki/x.png`) to its sha256 hash.
  /// Downloaded media is checked against it, and files that are byte-identical
  /// to a version already cached on disk are reused instead of re-downloaded.
  final Map<String, String> media;

  static ContentManifest fromJson(JsonMap json, String languageCode) {
    final version = json['version'];
    final schemaVersion = json['schemaVersion'];
    final language = json['language'] ?? languageCode;
    final bundleUrl = json['bundleUrl'];
    final sha256 = json['sha256'];

    if (version is! String || version.isEmpty) {
      throw const ContentBundleParseException(
        'Manifest version must be a non-empty string.',
      );
    }
    if (!isValidContentVersion(version)) {
      throw const ContentBundleParseException(
        'Manifest version must be dot-separated numbers, such as 2026.06.20.',
      );
    }
    if (schemaVersion is! int) {
      throw const ContentBundleParseException(
        'Manifest schemaVersion must be an integer.',
      );
    }
    if (language is! String || language.isEmpty) {
      throw const ContentBundleParseException(
        'Manifest language must be a non-empty string.',
      );
    }
    final bundleUri = bundleUrl is String ? Uri.tryParse(bundleUrl) : null;
    if (bundleUri == null ||
        !bundleUri.isAbsolute ||
        !_isAllowedBundleUri(bundleUri)) {
      throw const ContentBundleParseException(
        'Manifest bundleUrl must be an absolute https URI.',
      );
    }
    if (sha256 is! String || sha256.isEmpty) {
      throw const ContentBundleParseException(
        'Manifest sha256 must be a non-empty string.',
      );
    }

    final mediaField = json['media'];
    final media = <String, String>{};
    if (mediaField is Map) {
      for (final entry in mediaField.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is String) {
          media[key] = value.toLowerCase();
        }
      }
    }

    return ContentManifest(
      version: version,
      schemaVersion: schemaVersion,
      language: language.toLowerCase(),
      bundleUrl: bundleUri,
      sha256: sha256.toLowerCase(),
      media: media,
    );
  }

  /// https is required. Plain http is accepted only for a local server, so
  /// tests and local development keep working.
  static bool _isAllowedBundleUri(Uri uri) {
    if (uri.scheme == 'https') {
      return true;
    }

    return uri.scheme == 'http' &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1');
  }
}

abstract interface class RemoteContentManifestRepository {
  Future<ContentManifest?> fetchManifest(String languageCode);
}

abstract interface class ContentBundleDownloader {
  Future<String> downloadBundle(Uri bundleUrl);
}

abstract interface class BackgroundContentUpdater {
  /// Checks the remote manifest and installs a newer bundle or repairs the
  /// media of the current one. [onWorkStarted] runs once something is known
  /// to download, before the first download begins.
  Future<ContentBundleParseResult?> checkForUpdates(
    String languageCode, {
    void Function()? onWorkStarted,
    void Function(int current, int total)? onMediaProgress,
  });

  Future<ContentManifest?> fetchManifest(String languageCode);
}

final class GitHubPagesContentManifestRepository
    implements RemoteContentManifestRepository {
  const GitHubPagesContentManifestRepository({
    this.baseUri = const String.fromEnvironment(
      'SATO_WIKI_CONTENT_BASE_URL',
      defaultValue: 'https://dado-hash.github.io/Sato-Wiki/content',
    ),
    this.responseTimeout = const Duration(seconds: 10),
  });

  final String baseUri;

  /// Overall deadline for the manifest request and its body.
  final Duration responseTimeout;

  @override
  Future<ContentManifest?> fetchManifest(String languageCode) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    final uri = Uri.parse(
      '$baseUri/$normalizedLanguageCode/latest/manifest.json',
    );

    try {
      final json = await _readUri(uri);
      final decoded = jsonDecode(json);
      if (decoded is! JsonMap) {
        throw const ContentBundleParseException(
          'Manifest root must be an object.',
        );
      }

      return ContentManifest.fromJson(decoded, normalizedLanguageCode);
    } on Object {
      return null;
    }
  }

  Future<String> _readUri(Uri uri) {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);

    return readWithDeadline(
      client: client,
      deadline: responseTimeout,
      read: () async {
        final request = await client.getUrl(uri);
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          throw const ContentBundleParseException('Manifest fetch failed.');
        }

        return response.transform(utf8.decoder).join();
      },
    );
  }
}

final class HttpContentBundleDownloader implements ContentBundleDownloader {
  const HttpContentBundleDownloader({
    this.responseTimeout = const Duration(seconds: 30),
  });

  /// Overall deadline for the bundle request and its body.
  final Duration responseTimeout;

  @override
  Future<String> downloadBundle(Uri bundleUrl) {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    return readWithDeadline(
      client: client,
      deadline: responseTimeout,
      read: () async {
        final request = await client.getUrl(bundleUrl);
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          throw const ContentBundleParseException('Bundle download failed.');
        }

        return response.transform(utf8.decoder).join();
      },
    );
  }
}

final class VerifiedBackgroundContentUpdater
    implements BackgroundContentUpdater {
  const VerifiedBackgroundContentUpdater({
    required ContentBundleRepository localRepository,
    required RemoteContentManifestRepository manifestRepository,
    required ContentBundleDownloader downloader,
    ContentMediaStore? mediaStore,
  }) : _localRepository = localRepository,
       _manifestRepository = manifestRepository,
       _downloader = downloader,
       _mediaStore = mediaStore;

  final ContentBundleRepository _localRepository;
  final RemoteContentManifestRepository _manifestRepository;
  final ContentBundleDownloader _downloader;
  final ContentMediaStore? _mediaStore;

  @override
  Future<ContentBundleParseResult?> checkForUpdates(
    String languageCode, {
    void Function()? onWorkStarted,
    void Function(int current, int total)? onMediaProgress,
  }) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    final current = await _localRepository.load(normalizedLanguageCode);
    final manifest = await _manifestRepository.fetchManifest(
      normalizedLanguageCode,
    );

    if (manifest == null ||
        manifest.language != normalizedLanguageCode ||
        manifest.schemaVersion > ContentBundleMigrator.currentSchemaVersion) {
      return null;
    }

    final isNewerVersion = isNewerContentVersion(
      manifest.version,
      current.bundle.version,
    );
    final canRepairCurrentMedia =
        manifest.version == current.bundle.version &&
        _mediaStore != null &&
        !_mediaStore.hasBundleMedia(current.bundle) &&
        _mediaStore.canAttemptMediaRepair(
          language: current.bundle.language,
          version: current.bundle.version,
        );

    if (!isNewerVersion && !canRepairCurrentMedia) {
      return null;
    }

    if (canRepairCurrentMedia) {
      onWorkStarted?.call();
      final failedSources = await _mediaStore.prefetchBundleMedia(
        bundle: current.bundle,
        bundleUrl: manifest.bundleUrl,
        mediaHashes: manifest.media,
        onMediaProgress: onMediaProgress,
      );
      if (failedSources.isNotEmpty) {
        await _mediaStore.recordIncompleteMediaRepair(
          language: current.bundle.language,
          version: current.bundle.version,
        );
      }

      return _localRepository.load(normalizedLanguageCode);
    }

    onWorkStarted?.call();
    final json = await _downloader.downloadBundle(manifest.bundleUrl);
    final actualSha256 = sha256.convert(utf8.encode(json)).toString();
    if (actualSha256 != manifest.sha256) {
      throw const ContentBundleParseException('Bundle sha256 mismatch.');
    }

    final parsed = ContentBundleParser.parseJson(json);
    if (parsed.bundle.language != normalizedLanguageCode) {
      throw ContentBundleParseException(
        'Bundle language ${parsed.bundle.language} does not match '
        '$normalizedLanguageCode.',
      );
    }
    // Media failures do not block the verified text. Missing files are
    // retried by the repair path on a later launch.
    await _mediaStore?.prefetchBundleMedia(
      bundle: parsed.bundle,
      bundleUrl: manifest.bundleUrl,
      mediaHashes: manifest.media,
      onMediaProgress: onMediaProgress,
    );
    await _localRepository.saveUpdatedBundleJson(normalizedLanguageCode, json);

    return _localRepository.load(normalizedLanguageCode);
  }

  @override
  Future<ContentManifest?> fetchManifest(String languageCode) async {
    return _manifestRepository.fetchManifest(languageCode);
  }
}
