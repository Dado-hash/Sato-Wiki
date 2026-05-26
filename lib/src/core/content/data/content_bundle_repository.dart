import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_locale.dart';
import '../domain/content_models.dart';
import 'content_bundle_errors.dart';
import 'content_bundle_migrator.dart';
import 'content_bundle_parser.dart';
import 'content_media_store.dart';

abstract interface class ContentBundleRepository {
  Future<ContentBundleParseResult> load(String languageCode);

  Future<void> saveUpdatedBundleJson(String languageCode, String json);
}

final class LocalFirstContentBundleRepository
    implements ContentBundleRepository {
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
    final updatedJson = _preferences.getString(
      _updatedBundleKey(normalizedLanguageCode),
    );
    if (updatedJson != null) {
      try {
        return _parseLanguageBundle(updatedJson, normalizedLanguageCode);
      } on Object {
        // Bad updates must not block offline seed content.
      }
    }

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
  });

  final String version;
  final int schemaVersion;
  final String language;
  final Uri bundleUrl;
  final String sha256;

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
    if (bundleUrl is! String || Uri.tryParse(bundleUrl)?.isAbsolute != true) {
      throw const ContentBundleParseException(
        'Manifest bundleUrl must be an absolute URI.',
      );
    }
    if (sha256 is! String || sha256.isEmpty) {
      throw const ContentBundleParseException(
        'Manifest sha256 must be a non-empty string.',
      );
    }

    return ContentManifest(
      version: version,
      schemaVersion: schemaVersion,
      language: language.toLowerCase(),
      bundleUrl: Uri.parse(bundleUrl),
      sha256: sha256.toLowerCase(),
    );
  }
}

abstract interface class RemoteContentManifestRepository {
  Future<ContentManifest?> fetchManifest(String languageCode);
}

abstract interface class ContentBundleDownloader {
  Future<String> downloadBundle(Uri bundleUrl);
}

abstract interface class BackgroundContentUpdater {
  Future<ContentBundleParseResult?> checkForUpdates(String languageCode);
}

final class GitHubPagesContentManifestRepository
    implements RemoteContentManifestRepository {
  const GitHubPagesContentManifestRepository({
    this.baseUri = const String.fromEnvironment(
      'SATO_WIKI_CONTENT_BASE_URL',
      defaultValue: 'https://dado-hash.github.io/Sato-Wiki/content',
    ),
  });

  final String baseUri;

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

  Future<String> _readUri(Uri uri) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw const ContentBundleParseException('Manifest fetch failed.');
      }

      return await response.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }
}

final class HttpContentBundleDownloader implements ContentBundleDownloader {
  const HttpContentBundleDownloader();

  @override
  Future<String> downloadBundle(Uri bundleUrl) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(bundleUrl);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw const ContentBundleParseException('Bundle download failed.');
      }

      return await response.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
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
  Future<ContentBundleParseResult?> checkForUpdates(String languageCode) async {
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

    final isNewerVersion = _isNewerVersion(
      manifest.version,
      current.bundle.version,
    );
    final canRepairCurrentMedia =
        manifest.version == current.bundle.version &&
        _mediaStore != null &&
        !_mediaStore.hasBundleMedia(current.bundle);

    if (!isNewerVersion && !canRepairCurrentMedia) {
      return null;
    }

    if (canRepairCurrentMedia) {
      await _mediaStore.prefetchBundleMedia(
        bundle: current.bundle,
        bundleUrl: manifest.bundleUrl,
      );

      return _localRepository.load(normalizedLanguageCode);
    }

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
    await _mediaStore?.prefetchBundleMedia(
      bundle: parsed.bundle,
      bundleUrl: manifest.bundleUrl,
    );
    await _localRepository.saveUpdatedBundleJson(normalizedLanguageCode, json);

    return _localRepository.load(normalizedLanguageCode);
  }

  bool _isNewerVersion(String candidate, String current) {
    final candidateParts = _versionParts(candidate);
    final currentParts = _versionParts(current);
    if (candidateParts != null && currentParts != null) {
      final length = candidateParts.length > currentParts.length
          ? candidateParts.length
          : currentParts.length;
      for (var i = 0; i < length; i++) {
        final candidateValue = i < candidateParts.length
            ? candidateParts[i]
            : 0;
        final currentValue = i < currentParts.length ? currentParts[i] : 0;
        if (candidateValue != currentValue) {
          return candidateValue > currentValue;
        }
      }

      return false;
    }

    return candidate.compareTo(current) > 0;
  }

  List<int>? _versionParts(String version) {
    final parts = version.split('.');
    final values = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null) {
        return null;
      }
      values.add(value);
    }

    return values;
  }
}
