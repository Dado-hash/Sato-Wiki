import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final lang = args.isNotEmpty ? args[0] : 'en';
  final seedPath = 'assets/content/seed_bundle_$lang.json';
  final wikiDir = Directory('content/$lang/wiki');

  if (!wikiDir.existsSync()) {
    stderr.writeln('Directory not found: $wikiDir');
    exitCode = 1;
    return;
  }

  final existingSeed = File(seedPath).readAsStringSync();
  final existingData = jsonDecode(existingSeed) as Map<String, Object?>;

  final mdFiles =
      wikiDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final idToTitle = <String, String>{};
  for (final file in mdFiles) {
    final meta = parseFrontmatterOnly(file);
    if (meta != null) {
      final id = meta['id'] as String?;
      final title = meta['title'] as String?;
      if (id != null && title != null) {
        idToTitle[id] = title;
      }
    }
  }

  final wikiEntries = <Map<String, Object?>>[];
  for (final file in mdFiles) {
    try {
      final entry = parseWikiMarkdown(file, lang, idToTitle);
      wikiEntries.add(entry);
      stdout.writeln('  ${entry['id']} ← ${file.path}');
    } catch (e) {
      stderr.writeln('ERROR ${file.path}: $e');
      exitCode = 1;
      return;
    }
  }

  existingData['wiki'] = wikiEntries;
  existingData['version'] = '2026.05.27';
  existingData['generatedAt'] = '2026-05-27T00:00:00Z';

  final json = const JsonEncoder.withIndent('  ').convert(existingData);
  File(seedPath).writeAsStringSync('$json\n');
  stdout.writeln('\n✓ Wrote $seedPath (${wikiEntries.length} wiki entries)');
}

Map<String, Object?>? parseFrontmatterOnly(File file) {
  final text = file.readAsStringSync();
  final fmMatch = RegExp('^---\n(.*?)\n---', dotAll: true).firstMatch(text);
  if (fmMatch == null) return null;
  return _parseFrontmatter(fmMatch.group(1)!);
}

Map<String, Object?> parseWikiMarkdown(
  File file,
  String lang,
  Map<String, String> idToTitle,
) {
  final text = file.readAsStringSync();

  final fmMatch = RegExp('^---\n(.*?)\n---', dotAll: true).firstMatch(text);
  if (fmMatch == null) {
    throw FormatException('Missing frontmatter (---)');
  }

  final frontmatter = fmMatch.group(1)!;
  final bodyStart = fmMatch.end;
  final bodyRaw = text.substring(bodyStart).trim();
  final meta = _parseFrontmatter(frontmatter);

  final slug = meta['slug'] as String;

  return {
    'id': meta['id'] as String,
    'slug': slug,
    'language': meta['language'] as String? ?? lang,
    'category': meta['category'] as String,
    'title': meta['title'] as String,
    'description': meta['description'] as String,
    'coverImage':
        meta['coverImage'] as String? ?? 'media/wiki/$slug/$slug-hero.svg',
    'readingLevels': {
      'base': {'bodyMarkdown': _extractSection(bodyRaw, 'base')},
      'medium': {'bodyMarkdown': _extractSection(bodyRaw, 'medium')},
      'advanced': {'bodyMarkdown': _extractSection(bodyRaw, 'advanced')},
    },
    'difficulty': meta['difficulty'] as String? ?? 'advanced',
    'readTimeMinutes': meta['readTimeMinutes'] as int? ?? 8,
    'tags': _strList(meta['tags']),
    'sources': _srcList(meta['sources']),
    'related': _relList(meta['related'], idToTitle),
    'updatedAt': meta['updatedAt'] as String? ?? '2026-05-27T00:00:00Z',
  };
}

String _extractSection(String body, String level) {
  final re = RegExp(
    '^##[ \t]+$level[ \t]*\n(.*?)(?=\n##[ \t])',
    dotAll: true,
    multiLine: true,
  );
  final m = re.firstMatch(body);
  if (m != null) return m.group(1)!.trim();

  final reLast = RegExp(
    '^##[ \t]+$level[ \t]*\n(.*)',
    dotAll: true,
    multiLine: true,
  );
  final mLast = reLast.firstMatch(body);
  return mLast == null ? '' : mLast.group(1)!.trim();
}

Map<String, Object?> _parseFrontmatter(String src) {
  final lines = src.split('\n');
  final result = <String, Object?>{};
  var i = 0;

  while (i < lines.length) {
    final line = lines[i];
    if (line.trim().isEmpty || line.trim().startsWith('#')) {
      i++;
      continue;
    }

    final colonIdx = line.indexOf(':');
    if (colonIdx == -1) {
      i++;
      continue;
    }

    final key = line.substring(0, colonIdx).trim();
    var valuePart = line.substring(colonIdx + 1).trim();

    if (valuePart.isEmpty) {
      i++;
      final items = <Object?>[];
      while (i < lines.length) {
        final subLine = lines[i];
        final subTrimmed = subLine.trimLeft();
        if (subTrimmed.isEmpty || !subTrimmed.startsWith('- ')) break;
        final rest = subTrimmed.substring(2).trim();
        final ci = rest.indexOf(':');
        if (ci != -1 &&
            ci < 30 &&
            !RegExp(r'^https?://').hasMatch(rest) &&
            !RegExp(r'^\d{4}').hasMatch(rest)) {
          final obj = <String, Object?>{};
          _addKv(
            obj,
            rest.substring(0, ci).trim(),
            rest.substring(ci + 1).trim(),
          );
          var j = i + 1;
          while (j < lines.length) {
            final next = lines[j];
            if (next.trimLeft().startsWith('- ')) break;
            if (next.trim().isEmpty) {
              j++;
              continue;
            }
            final nextIndent = next.length - next.trimLeft().length;
            if (nextIndent <= subLine.length - subTrimmed.length) break;
            final ci2 = next.trimLeft().indexOf(':');
            if (ci2 == -1) {
              j++;
              continue;
            }
            _addKv(
              obj,
              next.trimLeft().substring(0, ci2).trim(),
              next.trimLeft().substring(ci2 + 1).trim(),
            );
            j++;
          }
          items.add(obj);
          i = j;
        } else {
          items.add(_yamlScalar(rest));
          i++;
        }
      }
      result[key] = items;
    } else {
      result[key] = _yamlScalar(valuePart);
      i++;
    }
  }

  return result;
}

void _addKv(Map<String, Object?> obj, String k, String v) {
  if (_isUrl(v)) {
    obj[k] = v;
  } else if (v.isEmpty) {
    // skip
  } else {
    final parsed = _yamlScalar(v);
    obj[k] = parsed;
  }
}

bool _isUrl(String s) =>
    RegExp(r'^https?://').hasMatch(s) ||
    RegExp(r'^[a-zA-Z0-9._-]+@').hasMatch(s);

Object? _yamlScalar(String s) {
  if (s == 'true') return true;
  if (s == 'false') return false;
  if (s == 'null' || s == '~') return null;
  final i = int.tryParse(s);
  if (i != null) return i;
  return _dequote(s);
}

String _dequote(String s) {
  if ((s.startsWith('"') && s.endsWith('"')) ||
      (s.startsWith("'") && s.endsWith("'"))) {
    return s.substring(1, s.length - 1);
  }
  return s;
}

List<String> _strList(Object? v) {
  if (v is List<Object?>) return v.whereType<String>().toList();
  return [];
}

List<Map<String, Object?>> _srcList(Object? v) {
  if (v is! List<Object?>) return [];
  return v.map((e) {
    if (e is! Map<String, Object?>) return <String, Object?>{};
    final m = <String, Object?>{};
    for (final k in ['title', 'url', 'author', 'publishedAt']) {
      if (e[k] != null) {
        m[k] = e[k] is DateTime
            ? (e[k] as DateTime).toIso8601String().split('T')[0]
            : e[k];
      }
    }
    return m;
  }).toList();
}

List<Map<String, Object?>> _relList(Object? v, Map<String, String> idToTitle) {
  if (v is! List<Object?>) return [];
  return v.map((e) {
    final id = e is String
        ? e
        : e is Map<String, Object?>
        ? e['id'] as String?
        : null;
    if (id == null) return <String, Object?>{};
    final title = idToTitle[id];
    if (title != null) return <String, Object?>{'id': id, 'title': title};
    return <String, Object?>{'id': id};
  }).toList();
}
