import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/content_media.dart';
import '../domain/content_models.dart';
import 'content_bundle_errors.dart';

abstract interface class ContentMediaDownloader {
  Future<List<int>> downloadMedia(Uri mediaUrl);
}

final class HttpContentMediaDownloader implements ContentMediaDownloader {
  const HttpContentMediaDownloader();

  @override
  Future<List<int>> downloadMedia(Uri mediaUrl) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(mediaUrl);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw const ContentBundleParseException('Media download failed.');
      }

      return await response.expand((chunk) => chunk).toList();
    } finally {
      client.close(force: true);
    }
  }
}

final class ContentMediaStore {
  ContentMediaStore({
    required Directory rootDirectory,
    ContentMediaDownloader downloader = const HttpContentMediaDownloader(),
  }) : _rootDirectory = rootDirectory,
       _downloader = downloader;

  final Directory _rootDirectory;
  final ContentMediaDownloader _downloader;

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
      } on FlutterError {
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

  Future<void> prefetchBundleMedia({
    required ContentBundle bundle,
    required Uri bundleUrl,
    void Function(int current, int total)? onMediaProgress,
  }) async {
    final references = ContentMedia.referencesFromBundle(bundle);
    final errors = ContentMedia.validateReferences(references);
    if (errors.isNotEmpty) {
      throw ContentBundleParseException(_errorMessage(errors));
    }
    if (references.isEmpty) {
      return;
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

    try {
      for (var i = 0; i < sources.length; i++) {
        final source = sources[i];
        onMediaProgress?.call(i, sources.length);
        final mediaUrl = bundleUrl.resolve(source);
        final bytes = await _downloader.downloadMedia(mediaUrl);
        final targetFile = File('${temporaryDirectory.path}/$source');
        await targetFile.parent.create(recursive: true);
        await targetFile.writeAsBytes(bytes, flush: true);
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
    return Directory('${_rootDirectory.path}/$language/$version');
  }

  String _errorMessage(List<ContentMediaValidationError> errors) {
    return errors
        .map((error) => '${error.source}: ${error.message}')
        .join('\n');
  }
}
