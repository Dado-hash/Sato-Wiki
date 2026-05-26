import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';

void main(List<String> args) {
  final source = args.isEmpty
      ? 'assets/content/seed_bundle_en.json'
      : args.first;
  final pagesRoot = args.length < 2 ? 'build/pages' : args[1];
  final outputRoot = '$pagesRoot/content';
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
  final sourceMediaRoot = Directory('${File(source).parent.path}/media');
  final outputMediaRoot = Directory('${versionRoot.path}/media');
  if (sourceMediaRoot.existsSync()) {
    if (outputMediaRoot.existsSync()) {
      outputMediaRoot.deleteSync(recursive: true);
    }
    _copyDirectory(sourceMediaRoot, outputMediaRoot);
  }

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
  _writeIndexHtml(
    pagesRoot: pagesRoot,
    language: bundle.language,
    version: bundle.version,
  );

  stdout.writeln('generated ${bundleFile.path}');
  if (sourceMediaRoot.existsSync()) {
    stdout.writeln('generated ${outputMediaRoot.path}');
  }
  stdout.writeln('generated ${latestRoot.path}/manifest.json');
  stdout.writeln('generated $pagesRoot/index.html');
}

void _copyDirectory(Directory source, Directory target) {
  target.createSync(recursive: true);
  for (final entity in source.listSync(recursive: true)) {
    final relativePath = entity.path.substring(source.path.length + 1);
    final targetPath = '${target.path}/$relativePath';
    if (entity is Directory) {
      Directory(targetPath).createSync(recursive: true);
    } else if (entity is File) {
      File(targetPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(entity.readAsBytesSync(), flush: true);
    }
  }
}

void _writeIndexHtml({
  required String pagesRoot,
  required String language,
  required String version,
}) {
  final manifestPath = 'content/$language/latest/manifest.json';
  final bundlePath = 'content/$language/$version/bundle.json';
  final html =
      '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>SatoWiki Content CDN</title>
  <style>
    :root {
      color-scheme: dark;
      --bg: #0f1114;
      --surface: #171a1f;
      --text: #f4ead8;
      --muted: #a7a29a;
      --orange: #f7931a;
      --border: #2f343c;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      background: var(--bg);
      color: var(--text);
      font: 16px/1.5 Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }
    main {
      width: min(720px, calc(100vw - 32px));
      padding: 32px;
      border: 1px solid var(--border);
      border-radius: 8px;
      background: var(--surface);
    }
    h1 {
      margin: 0 0 8px;
      font-size: clamp(2rem, 6vw, 4rem);
      line-height: 1;
    }
    p { color: var(--muted); }
    a {
      color: var(--orange);
      text-decoration-thickness: 1px;
      text-underline-offset: 4px;
    }
    code {
      font-family: "JetBrains Mono", ui-monospace, SFMono-Regular, Menlo, monospace;
      color: var(--text);
    }
    ul {
      padding-left: 20px;
      margin-bottom: 0;
    }
  </style>
</head>
<body>
  <main>
    <h1>SatoWiki</h1>
    <p>The Orange Book of Bitcoin content endpoint.</p>
    <p>Current published bundle: <code>$language/$version</code></p>
    <ul>
      <li><a href="$manifestPath">Latest manifest</a></li>
      <li><a href="$bundlePath">Versioned bundle</a></li>
    </ul>
  </main>
</body>
</html>
''';
  File('$pagesRoot/index.html')
    ..createSync(recursive: true)
    ..writeAsStringSync(html);
}
