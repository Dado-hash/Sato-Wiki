import 'dart:convert';
import 'dart:io';

import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';

void main(List<String> args) {
  final source = args.isEmpty ? 'assets/content/seed_bundle.json' : args.first;
  final output = args.length < 2 ? 'build/content/bundle.json' : args[1];
  final json = File(source).readAsStringSync();

  ContentBundleParser.parseJson(json);

  final formatted = const JsonEncoder.withIndent(
    '  ',
  ).convert(jsonDecode(json));
  final outputFile = File(output)..createSync(recursive: true);
  outputFile.writeAsStringSync('$formatted\n');

  stdout.writeln('generated $output');
}
