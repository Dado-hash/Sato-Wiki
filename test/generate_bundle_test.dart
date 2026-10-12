import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/generate_bundle.dart';

void main() {
  late Directory tempDir;
  late String pagesRoot;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('generate_bundle_test');
    pagesRoot = '${tempDir.path}/pages';
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  String writeSource(String language, String version) {
    final file = File('${tempDir.path}/src/$language.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode({
          'schemaVersion': 1,
          'version': version,
          'language': language,
          'generatedAt': '2026-06-20T00:00:00Z',
          'wiki': <Object?>[],
          'news': <Object?>[],
          'history': <Object?>[],
          'bips': <Object?>[],
          'changelogs': <Object?>[],
        }),
      );

    return file.path;
  }

  test('running EN then IT leaves one index listing both languages', () {
    final en = writeSource('en', '2026.06.20.000001');
    final it = writeSource('it', '2026.06.20.000002');

    generateContentBundle(
      source: en,
      pagesRoot: pagesRoot,
      baseUrl: 'https://example.test/content',
    );
    generateContentBundle(
      source: it,
      pagesRoot: pagesRoot,
      baseUrl: 'https://example.test/content',
    );

    final index = File('$pagesRoot/index.html').readAsStringSync();
    expect(index, contains('<code>en/2026.06.20.000001</code>'));
    expect(index, contains('<code>it/2026.06.20.000002</code>'));
    expect(index, contains('content/en/latest/manifest.json'));
    expect(index, contains('content/it/2026.06.20.000002/bundle.json'));
    expect(
      File('$pagesRoot/content/en/2026.06.20.000001/bundle.json').existsSync(),
      isTrue,
    );
    expect(
      File('$pagesRoot/content/it/latest/manifest.json').existsSync(),
      isTrue,
    );
  });

  test('a single run indexes only its language', () {
    final en = writeSource('en', '2026.06.20.000001');

    final messages = generateContentBundle(
      source: en,
      pagesRoot: pagesRoot,
      baseUrl: 'https://example.test/content',
    );

    final index = File('$pagesRoot/index.html').readAsStringSync();
    expect(index, contains('<code>en/2026.06.20.000001</code>'));
    expect(index, isNot(contains('<code>it/')));
    expect(messages.last, 'generated $pagesRoot/index.html');
  });

  test('a non-object root is rejected', () {
    final file = File('${tempDir.path}/array.json')..writeAsStringSync('[]');

    expect(
      () => generateContentBundle(
        source: file.path,
        pagesRoot: pagesRoot,
        baseUrl: 'https://example.test/content',
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
