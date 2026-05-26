import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';

void main(List<String> args) {
  final options = _GenerateBundleOptions.parse(args);
  final source = options.source;
  final pagesRoot = options.pagesRoot;
  final outputRoot = '$pagesRoot/content';
  final baseUrl = options.baseUrl;
  final sourceJson = File(source).readAsStringSync();
  final decoded = jsonDecode(sourceJson);
  if (decoded is! Map<String, Object?>) {
    stderr.writeln('Bundle root must be an object.');
    exitCode = 1;
    return;
  }
  final data = Map<String, Object?>.from(decoded);
  final stamp = options.stamp ? _buildStamp(DateTime.now().toUtc()) : null;
  if (stamp != null) {
    data['version'] = stamp.version;
    data['generatedAt'] = stamp.generatedAt;
  }
  final json = const JsonEncoder.withIndent('  ').convert(data);

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
  if (stamp != null) {
    stdout.writeln('stamped version=${stamp.version}');
  }
}

final class _GenerateBundleOptions {
  const _GenerateBundleOptions({
    required this.source,
    required this.pagesRoot,
    required this.baseUrl,
    required this.stamp,
  });

  final String source;
  final String pagesRoot;
  final String baseUrl;
  final bool stamp;

  static _GenerateBundleOptions parse(List<String> args) {
    var stamp = false;
    final positional = <String>[];
    for (final arg in args) {
      if (arg == '--stamp') {
        stamp = true;
      } else {
        positional.add(arg);
      }
    }

    return _GenerateBundleOptions(
      source: positional.isEmpty
          ? 'assets/content/seed_bundle_en.json'
          : positional.first,
      pagesRoot: positional.length < 2 ? 'build/pages' : positional[1],
      baseUrl: positional.length < 3
          ? 'https://dado-hash.github.io/Sato-Wiki/content'
          : positional[2],
      stamp: stamp,
    );
  }
}

final class _BundleStamp {
  const _BundleStamp({required this.version, required this.generatedAt});

  final String version;
  final String generatedAt;
}

_BundleStamp _buildStamp(DateTime now) {
  final version =
      '${now.year.toString().padLeft(4, '0')}.'
      '${now.month.toString().padLeft(2, '0')}.'
      '${now.day.toString().padLeft(2, '0')}.'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';

  return _BundleStamp(version: version, generatedAt: now.toIso8601String());
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
