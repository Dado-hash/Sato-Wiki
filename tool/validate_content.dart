import 'dart:io';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';

void main(List<String> args) {
  final path = args.isEmpty ? 'assets/content/seed_bundle.json' : args.single;
  final file = File(path);

  if (!file.existsSync()) {
    stderr.writeln('Missing content bundle: $path');
    exitCode = 1;
    return;
  }

  final result = ContentBundleParser.parseJson(file.readAsStringSync());
  for (final warning in result.warnings) {
    stderr.writeln('warning ${warning.path}: ${warning.message}');
  }

  stdout.writeln(
    'valid ${result.bundle.version} '
    'wiki=${result.bundle.wiki.length} '
    'news=${result.bundle.news.length} '
    'history=${result.bundle.history.length} '
    'bips=${result.bundle.bips.length} '
    'changelogs=${result.bundle.changelogs.length}',
  );
}
