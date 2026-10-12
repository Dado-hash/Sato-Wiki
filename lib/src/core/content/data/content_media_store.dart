import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/content_media.dart';
import '../domain/content_models.dart';
import '../domain/content_version.dart';
import 'content_bundle_errors.dart';
import 'content_http_deadline.dart';

abstract interface class ContentMediaDownloader {
  Future<List<int>> downloadMedia(Uri mediaUrl);
}

final class HttpContentMediaDownloader implements ContentMediaDownloader {
  const HttpContentMediaDownloader({
    this.responseTimeout = const Duration(seconds: 30),
  });

  /// Overall deadline for one media request and its body.
  final Duration responseTimeout;

  @override
  Future<List<int>> downloadMedia(Uri mediaUrl) {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);

    return readWithDeadline(
      client: client,
      deadline: responseTimeout,
      read: () async {
        final request = await client.getUrl(mediaUrl);
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          throw const ContentBundleParseException('Media download failed.');
        }

        final bytes = BytesBuilder(copy: false);
        await for (final chunk in response) {
          bytes.add(chunk);
        }

        return bytes.takeBytes();
      },
    );
  }
}

final class ContentMediaStore {
  ContentMediaStore({
    required Directory rootDirectory,
    ContentMediaDownloader downloader = const HttpContentMediaDownloader(),
    DateTime Function() clock = DateTime.now,
  }) : _rootDirectory = rootDirectory,
       _downloader = downloader,
       _clock = clock;

  static const mediaRepairCooldown = Duration(days: 1);

  final Directory _rootDirectory;
  final ContentMediaDownloader _downloader;
  final DateTime Function() _clock;

  static Future<ContentMediaStore> create({
    ContentMediaDownloader downloader = const HttpContentMediaDownloader(),
  }) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final rootDirectory = Directory('${supportDirectory.path}/content_media');

    return ContentMediaStore(
      rootDirectory: rootDirectory,
      downloader: downloader,
    );
  }

  ContentMediaResolver resolverFor({
    required String language,
    required String version,
  }) {
    if (!isValidContentVersion(version)) {
      return ContentMediaResolver.empty;
    }

    return ContentMediaResolver(
      resolve: (source) {
        if (ContentMedia.validateSource(source) != null) {
          return null;
        }

        final file = _fileFor(
          language: language,
          version: version,
          source: source,
        );

        return file.existsSync() ? file.uri : null;
      },
    );
  }

  bool hasBundleMedia(ContentBundle bundle) {
    if (!isValidContentVersion(bundle.version)) {
      return false;
    }

    final references = ContentMedia.referencesFromBundle(bundle);
    final errors = ContentMedia.validateReferences(references);
    if (errors.isNotEmpty) {
      return false;
    }

    final sources = references.map((reference) => reference.source).toSet();
    for (final source in sources) {
      final file = _fileFor(
        language: bundle.language,
        version: bundle.version,
        source: source,
      );
      if (!file.existsSync()) {
        return false;
      }
    }

    return true;
  }

  /// Copies the seed media of [bundle] from the app assets into its version
  /// directory. A missing asset is skipped: the repair path fetches it later.
  Future<void> installBundleMediaFromAssets({
    required ContentBundle bundle,
    AssetBundle? assetBundle,
    String assetRoot = 'assets/content',
  }) async {
    final references = ContentMedia.referencesFromBundle(bundle);
    final errors = ContentMedia.validateReferences(references);
    if (errors.isNotEmpty) {
      throw ContentBundleParseException(_errorMessage(errors));
    }
    if (references.isEmpty) {
      return;
    }

    final effectiveAssetBundle = assetBundle ?? rootBundle;
    final sources = references
        .map((reference) => reference.source)
        .toSet()
        .toList(growable: false);

    for (final source in sources) {
      final targetFile = _fileFor(
        language: bundle.language,
        version: bundle.version,
        source: source,
      );
      if (targetFile.existsSync()) {
        continue;
      }

      final ByteData assetData;
      try {
        assetData = await effectiveAssetBundle.load('$assetRoot/$source');
      } on FlutterError catch (error) {
        if (kDebugMode) {
          debugPrint('Seed media asset missing: $assetRoot/$source ($error)');
        }
        continue;
      }

      await targetFile.parent.create(recursive: true);
      await targetFile.writeAsBytes(
        assetData.buffer.asUint8List(
          assetData.offsetInBytes,
          assetData.lengthInBytes,
        ),
        flush: true,
      );
    }
  }

  /// Downloads media referenced by [bundle] into its version directory.
  ///
  /// A file that fails to download or does not match its hash is left out and
  /// its source is returned; the other files are still installed. Once the
  /// version directory is in place, other versions of the same language are
  /// deleted.
  ///
  /// [mediaHashes] (source path -> sha256, from the remote manifest) lets
  /// files that are byte-identical to a version already cached on disk be
  /// reused instead of re-downloaded, since a content version bump does not
  /// imply every referenced image actually changed.
  Future<List<String>> prefetchBundleMedia({
    required ContentBundle bundle,
    required Uri bundleUrl,
    Map<String, String> mediaHashes = const {},
    void Function(int current, int total)? onMediaProgress,
  }) async {
    final references = ContentMedia.referencesFromBundle(bundle);
    final errors = ContentMedia.validateReferences(references);
    if (errors.isNotEmpty) {
      throw ContentBundleParseException(_errorMessage(errors));
    }
    if (references.isEmpty) {
      await _pruneOtherVersions(
        language: bundle.language,
        keepVersion: bundle.version,
      );

      return const [];
    }

    final sources = references
        .map((reference) => reference.source)
        .toSet()
        .toList(growable: false);
    final versionDirectory = _versionDirectory(
      language: bundle.language,
      version: bundle.version,
    );
    final temporaryDirectory = Directory('${versionDirectory.path}.tmp');

    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
    await temporaryDirectory.create(recursive: true);

    final failedSources = <String>[];
    try {
      for (var i = 0; i < sources.length; i++) {
        final source = sources[i];
        onMediaProgress?.call(i, sources.length);
        try {
          await _fetchMediaInto(
            temporaryDirectory: temporaryDirectory,
            versionDirectory: versionDirectory,
            language: bundle.language,
            source: source,
            bundleUrl: bundleUrl,
            expectedHash: mediaHashes[source],
          );
        } on Object catch (error) {
          failedSources.add(source);
          if (kDebugMode) {
            debugPrint('Content media failed: $source ($error)');
          }
        }
      }

      if (versionDirectory.existsSync()) {
        await versionDirectory.delete(recursive: true);
      }
      await temporaryDirectory.rename(versionDirectory.path);
    } on Object {
      if (temporaryDirectory.existsSync()) {
        await temporaryDirectory.delete(recursive: true);
      }
      rethrow;
    }

    // Runs after the downloads, so files can still be reused from old versions.
    await _pruneOtherVersions(
      language: bundle.language,
      keepVersion: bundle.version,
    );

    return List.unmodifiable(failedSources);
  }

  Future<void> _fetchMediaInto({
    required Directory temporaryDirectory,
    required Directory versionDirectory,
    required String language,
    required String source,
    required Uri bundleUrl,
    String? expectedHash,
  }) async {
    final targetFile = File('${temporaryDirectory.path}/$source');
    await targetFile.parent.create(recursive: true);

    // A repair keeps the files this version already has and fetches only
    // the missing ones.
    final installedFile = File('${versionDirectory.path}/$source');
    if (installedFile.existsSync()) {
      final installedBytes = await installedFile.readAsBytes();
      if (expectedHash == null ||
          sha256.convert(installedBytes).toString() == expectedHash) {
        await targetFile.writeAsBytes(installedBytes, flush: true);
        return;
      }
    }

    if (expectedHash != null) {
      final cachedBytes = _findCachedMediaMatching(
        language: language,
        source: source,
        expectedHash: expectedHash,
      );
      if (cachedBytes != null) {
        await targetFile.writeAsBytes(cachedBytes, flush: true);
        return;
      }
    }

    final mediaUrl = bundleUrl.resolve(source);
    final bytes = await _downloader.downloadMedia(mediaUrl);
    if (expectedHash != null &&
        sha256.convert(bytes).toString() != expectedHash) {
      throw ContentBundleParseException('Media sha256 mismatch for $source.');
    }
    await targetFile.writeAsBytes(bytes, flush: true);
  }

  /// Scans previously cached content versions for [language] and returns
  /// the bytes of [source] if a copy on disk already matches [expectedHash].
  List<int>? _findCachedMediaMatching({
    required String language,
    required String source,
    required String expectedHash,
  }) {
    final languageDirectory = Directory('${_rootDirectory.path}/$language');
    if (!languageDirectory.existsSync()) {
      return null;
    }

    for (final entity in languageDirectory.listSync()) {
      if (entity is! Directory || entity.path.endsWith('.tmp')) {
        continue;
      }
      final file = File('${entity.path}/$source');
      if (!file.existsSync()) {
        continue;
      }
      final bytes = file.readAsBytesSync();
      if (sha256.convert(bytes).toString() == expectedHash) {
        return bytes;
      }
    }

    return null;
  }

  /// Whether a media repair for [version] may run now.
  ///
  /// After a repair that still left files missing, the next attempt waits for
  /// [mediaRepairCooldown], so a file that is gone from the server does not
  /// trigger a repair on every launch.
  bool canAttemptMediaRepair({
    required String language,
    required String version,
  }) {
    final marker = _repairMarker(language);
    if (!marker.existsSync()) {
      return true;
    }

    try {
      final lines = marker.readAsLinesSync();
      if (lines.length < 2 || lines[0] != version) {
        return true;
      }
      final lastAttempt = DateTime.tryParse(lines[1]);

      return lastAttempt == null ||
          _clock().difference(lastAttempt) >= mediaRepairCooldown;
    } on FileSystemException {
      return true;
    }
  }

  /// Records a repair of [version] that left files missing.
  Future<void> recordIncompleteMediaRepair({
    required String language,
    required String version,
  }) async {
    final marker = _repairMarker(language);
    await marker.parent.create(recursive: true);
    await marker.writeAsString(
      '$version\n${_clock().toUtc().toIso8601String()}\n',
      flush: true,
    );
  }

  File _repairMarker(String language) {
    return File('${_rootDirectory.path}/$language/.media-repair');
  }

  /// Deletes every version directory of [language] except [keepVersion], and
  /// any leftover `.tmp` directory.
  Future<void> _pruneOtherVersions({
    required String language,
    required String keepVersion,
  }) async {
    final languageDirectory = Directory('${_rootDirectory.path}/$language');
    if (!languageDirectory.existsSync()) {
      return;
    }

    final keepPath = _versionDirectory(
      language: language,
      version: keepVersion,
    ).path;
    for (final entity in languageDirectory.listSync()) {
      if (entity is! Directory || entity.path == keepPath) {
        continue;
      }
      try {
        await entity.delete(recursive: true);
      } on Object catch (error) {
        if (kDebugMode) {
          debugPrint(
            'Could not delete old content media: ${entity.path} ($error)',
          );
        }
      }
    }
  }

  File _fileFor({
    required String language,
    required String version,
    required String source,
  }) {
    return File(
      '${_versionDirectory(language: language, version: version).path}/$source',
    );
  }

  Directory _versionDirectory({
    required String language,
    required String version,
  }) {
    if (!isValidContentVersion(version)) {
      throw ContentBundleParseException('Invalid content version: $version.');
    }

    return Directory('${_rootDirectory.path}/$language/$version');
  }

  String _errorMessage(List<ContentMediaValidationError> errors) {
    return errors
        .map((error) => '${error.source}: ${error.message}')
        .join('\n');
  }
}
