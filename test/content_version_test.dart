import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_errors.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/content/domain/content_version.dart';

void main() {
  test('accepts only dot-separated numeric versions', () {
    expect(isValidContentVersion('2026.05.25'), isTrue);
    expect(isValidContentVersion('2026.06.20.071041'), isTrue);
    expect(isValidContentVersion('31'), isTrue);

    expect(isValidContentVersion(''), isFalse);
    expect(isValidContentVersion('2026.05.25-beta'), isFalse);
    expect(isValidContentVersion('../escape'), isFalse);
    expect(isValidContentVersion('2026.05.25\n'), isFalse);
    expect(isValidContentVersion('v2026'), isFalse);
    expect(isValidContentVersion('2026..05'), isFalse);
  });

  test('compares numeric versions part by part', () {
    expect(isNewerContentVersion('2026.06.01', '2026.05.26'), isTrue);
    expect(isNewerContentVersion('2026.05.26', '2026.06.01'), isFalse);
    expect(isNewerContentVersion('1.10', '1.9'), isTrue);
    expect(isNewerContentVersion('1.0', '1'), isFalse);
    expect(isNewerContentVersion('1', '1.0'), isFalse);
    expect(isNewerContentVersion('2026.05.25.1', '2026.05.25'), isTrue);
    expect(isNewerContentVersion('2026.05.25', '2026.05.25'), isFalse);
  });

  test('falls back to string comparison for non-numeric versions', () {
    expect(isNewerContentVersion('b', 'a'), isTrue);
    expect(isNewerContentVersion('a', 'b'), isFalse);
    expect(isNewerContentVersion('1.0-beta', '1.0'), isTrue);
  });

  group('ContentManifest.fromJson', () {
    Map<String, Object?> manifestJson({
      String version = '2026.05.26',
      Object? bundleUrl = 'https://example.com/content/en/bundle.json',
    }) {
      return {
        'version': version,
        'schemaVersion': 1,
        'language': 'en',
        'bundleUrl': bundleUrl,
        'sha256': 'ABCDEF',
      };
    }

    test('accepts a valid manifest and lowercases hashes', () {
      final manifest = ContentManifest.fromJson({
        ...manifestJson(),
        'media': {'media/wiki/a.png': 'ABC123'},
      }, 'en');

      expect(manifest.version, '2026.05.26');
      expect(manifest.sha256, 'abcdef');
      expect(manifest.media['media/wiki/a.png'], 'abc123');
    });

    test('rejects versions that are not dotted numbers', () {
      expect(
        () =>
            ContentManifest.fromJson(manifestJson(version: '../escape'), 'en'),
        throwsA(isA<ContentBundleParseException>()),
      );
    });

    test('requires https bundle URLs except for local hosts', () {
      for (final url in [
        'https://example.com/content/en/bundle.json',
        'http://localhost:8080/bundle.json',
        'http://127.0.0.1:8080/bundle.json',
      ]) {
        expect(
          ContentManifest.fromJson(
            manifestJson(bundleUrl: url),
            'en',
          ).bundleUrl,
          Uri.parse(url),
        );
      }

      for (final url in [
        'http://example.com/content/en/bundle.json',
        'ftp://example.com/bundle.json',
        'file:///tmp/bundle.json',
        'bundle.json',
      ]) {
        expect(
          () => ContentManifest.fromJson(manifestJson(bundleUrl: url), 'en'),
          throwsA(isA<ContentBundleParseException>()),
          reason: url,
        );
      }
    });
  });
}
