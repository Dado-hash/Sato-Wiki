import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';

void main(List<String> args) {
  final source = args.isEmpty
      ? 'assets/content/seed_bundle_en.json'
      : args.first;
  final outputRoot = args.length < 2 ? 'build/pages/content' : args[1];
  final baseUrl = args.length < 3
      ? 'https://dado-hash.github.io/Sato-Wiki/content'
      : args[2];
  final json = File(source).readAsStringSync();

  final result = ContentBundleParser.parseJson(json);
  final bundle = result.bundle;

  final formatted = const JsonEncoder.withIndent(
    '  ',
  ).convert(jsonDecode(json));
  final normalizedJson = '$formatted\n';
  final languageRoot = Directory('$outputRoot/${bundle.language}');
  final versionRoot = Directory('${languageRoot.path}/${bundle.version}')
    ..createSync(recursive: true);
  final latestRoot = Directory('${languageRoot.path}/latest')
    ..createSync(recursive: true);
  final bundleFile = File('${versionRoot.path}/bundle.json');
  bundleFile.writeAsStringSync(normalizedJson);

  final sha = sha256.convert(utf8.encode(normalizedJson)).toString();
  final bundleUrl = '$baseUrl/${bundle.language}/${bundle.version}/bundle.json';
  final manifest = <String, Object?>{
    'version': bundle.version,
    'schemaVersion': bundle.schemaVersion,
    'language': bundle.language,
    'bundleUrl': bundleUrl,
    'sha256': sha,
    'generatedAt': bundle.generatedAt.toUtc().toIso8601String(),
  };
  final manifestJson = const JsonEncoder.withIndent('  ').convert(manifest);
  File('${latestRoot.path}/manifest.json').writeAsStringSync('$manifestJson\n');

  stdout.writeln('generated ${bundleFile.path}');
  stdout.writeln('generated ${latestRoot.path}/manifest.json');
}
