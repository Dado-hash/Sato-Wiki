import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_media.dart';

/// Directories under assets/content/media that pubspec.yaml declares.
/// Flutter does not bundle subdirectories, so each one must be listed.
Set<String> _declaredMediaDirectories() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final directories = <String>{};
  for (final line in pubspec.split('\n')) {
    final entry = line.trim();
    if (!entry.startsWith('- assets/content/media/') || !entry.endsWith('/')) {
      continue;
    }
    directories.add(entry.substring('- '.length));
  }

  return directories;
}

String _directoryOf(String assetPath) {
  return '${assetPath.substring(0, assetPath.lastIndexOf('/'))}/';
}

void main() {
  const seedPaths = [
    'assets/content/seed_bundle_en.json',
    'assets/content/seed_bundle_it.json',
  ];

  test('every media file referenced by a seed bundle is declared', () {
    final declared = _declaredMediaDirectories();
    final problems = <String>[];

    for (final path in seedPaths) {
      final bundle = ContentBundleParser.parseJson(
        File(path).readAsStringSync(),
      ).bundle;
      for (final reference in ContentMedia.referencesFromBundle(bundle)) {
        final assetPath = 'assets/content/${reference.source}';
        if (!declared.contains(_directoryOf(assetPath))) {
          problems.add(
            '$path: ${reference.source} is not in a declared directory',
          );
        }
        if (!File(assetPath).existsSync()) {
          problems.add('$path: ${reference.source} does not exist');
        }
      }
    }

    expect(problems, isEmpty);
  });

  test('every media file on disk is in a declared directory', () {
    final declared = _declaredMediaDirectories();
    final problems = <String>[];

    for (final entity in Directory(
      'assets/content/media',
    ).listSync(recursive: true)) {
      if (entity is! File) {
        continue;
      }
      final assetPath = entity.path;
      if (!declared.contains(_directoryOf(assetPath))) {
        problems.add('$assetPath is not in a declared directory');
      }
    }

    expect(problems, isEmpty);
  });
}
