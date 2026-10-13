import 'dart:convert';
import 'dart:io';

import 'package:sato_wiki/src/core/content/data/content_bundle_errors.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_media.dart';
import 'package:sato_wiki/src/core/content/domain/content_models.dart';

const _defaultBundlePath = 'assets/content/seed_bundle_en.json';
const _recordCollections = ['wiki', 'news', 'history', 'bips', 'changelogs'];
const _bipStatusTags = {'Draft', 'Complete', 'Deployed', 'Closed'};
const _subcategoryCategories = {'software', 'hardware'};

// Texts written by tool/sync_code_content.dart when no editorial summary exists.
const _placeholderTexts = [
  'Draft generated from official',
  'Bozza generata dai metadati ufficiali',
  'Bozza generata dalle note ufficiali',
  'Impact to be verified during maintainer review.',
  'Impatto da verificare durante la review del maintainer.',
  'Technical changes to summarize during review.',
  'Modifiche tecniche da sintetizzare durante la review.',
];
final _placeholderPatterns = [
  RegExp(r'^Bitcoin Core \S+ release\.$'),
  RegExp(r'^Release Bitcoin Core \S+\.$'),
];

final class ContentValidationResult {
  const ContentValidationResult({
    required this.errors,
    required this.warnings,
    this.summary,
  });

  final List<String> errors;
  final List<String> warnings;

  /// Summary line for a bundle that parsed, null when it could not be read.
  final String? summary;

  bool failsWith({required bool strict}) {
    return errors.isNotEmpty || (strict && warnings.isNotEmpty);
  }
}

ContentValidationResult validateContentBundle(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return ContentValidationResult(
      errors: ['Missing content bundle: $path'],
      warnings: const [],
    );
  }

  final source = file.readAsStringSync();
  final ContentBundleParseResult parsed;
  try {
    parsed = ContentBundleParser.parseJson(source);
  } on ContentBundleParseException catch (error) {
    return ContentValidationResult(errors: [error.message], warnings: const []);
  }

  final errors = <String>[];
  final warnings = <String>[
    for (final warning in parsed.warnings)
      '${warning.path}: ${warning.message}',
  ];
  final data = jsonDecode(source) as Map<String, Object?>;
  _checkRecords(data, errors, warnings);
  _checkMedia(parsed.bundle, file.parent.path, errors);

  final bundle = parsed.bundle;
  final mediaCount = ContentMedia.referencesFromBundle(bundle)
      .map((reference) => reference.source)
      .where((source) => ContentMedia.validateSource(source) == null)
      .toSet()
      .length;

  return ContentValidationResult(
    errors: errors,
    warnings: warnings,
    summary:
        'valid ${bundle.version} '
        'language=${bundle.language} '
        'wiki=${bundle.wiki.length} '
        'news=${bundle.news.length} '
        'history=${bundle.history.length} '
        'bips=${bundle.bips.length} '
        'changelogs=${bundle.changelogs.length} '
        'media=$mediaCount',
  );
}

void _checkRecords(
  Map<String, Object?> data,
  List<String> errors,
  List<String> warnings,
) {
  final recordIds = <String>{
    for (final collection in _recordCollections)
      for (final record in _records(data, collection))
        if (record['id'] is String) record['id']! as String,
  };

  for (final collection in _recordCollections) {
    for (final record in _records(data, collection)) {
      final where = '$collection ${record['id']}';
      for (final target in _relatedIds(record)) {
        if (!recordIds.contains(target)) {
          errors.add('$where: related id $target matches no record.');
        }
      }
      if (!_isValidReviewedAt(record['reviewedAt'])) {
        errors.add('$where: reviewedAt must be an ISO date.');
      }
      if (collection == 'wiki') {
        _checkWikiSubcategory(record, where, errors, warnings);
      }
      if (_needsReview(record)) {
        warnings.add('$where: automation.needsReview is true.');
      }
      if (_containsPlaceholder(record)) {
        warnings.add('$where: text still contains a generated placeholder.');
      }
    }
  }

  for (final bip in _records(data, 'bips')) {
    final tags = [
      for (final tag in _stringList(bip['tags']))
        if (_bipStatusTags.contains(tag)) tag,
    ];
    if (tags.length > 1) {
      errors.add(
        'bips ${bip['id']}: more than one status tag (${tags.join(', ')}).',
      );
      continue;
    }
    final status = bip['status'] is String
        ? BipStatus.fromJson(bip['status']! as String)
        : null;
    if (tags.length == 1 && status != null) {
      final expected = status.name[0].toUpperCase() + status.name.substring(1);
      if (tags.single != expected) {
        errors.add(
          'bips ${bip['id']}: status tag ${tags.single} contradicts '
          'status ${bip['status']}.',
        );
      }
    }
  }
}

void _checkWikiSubcategory(
  Map<String, Object?> record,
  String where,
  List<String> errors,
  List<String> warnings,
) {
  final subcategory = record['subcategory'];
  if (subcategory != null && subcategory is! String) {
    errors.add('$where: subcategory must be a string.');
    return;
  }
  final category = record['category'];
  final needsSubcategory =
      category is String &&
      _subcategoryCategories.contains(category.trim().toLowerCase());
  if (needsSubcategory &&
      (subcategory is! String || subcategory.trim().isEmpty)) {
    warnings.add('$where: category $category has no subcategory.');
  }
}

bool _isValidReviewedAt(Object? value) {
  if (value == null) {
    return true;
  }

  return value is String && DateTime.tryParse(value) != null;
}

void _checkMedia(
  ContentBundle bundle,
  String contentRoot,
  List<String> errors,
) {
  final references = ContentMedia.referencesFromBundle(bundle);
  for (final error in ContentMedia.validateReferences(references)) {
    errors.add('media ${error.source}: ${error.message}');
  }
  final sources = references
      .map((reference) => reference.source)
      .where((source) => ContentMedia.validateSource(source) == null)
      .toSet();
  for (final source in sources) {
    if (!File('$contentRoot/$source').existsSync()) {
      errors.add('media $source: Referenced media file does not exist.');
    }
  }
}

List<Map<String, Object?>> _records(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! List<Object?>) {
    return const [];
  }

  return [
    for (final item in value)
      if (item is Map<String, Object?>) item,
  ];
}

List<String> _stringList(Object? value) {
  if (value is! List<Object?>) {
    return const [];
  }

  return [
    for (final item in value)
      if (item is String) item,
  ];
}

Iterable<String> _relatedIds(Map<String, Object?> record) sync* {
  final related = record['related'];
  if (related is! List<Object?>) {
    return;
  }
  for (final item in related) {
    if (item is String) {
      yield item;
    } else if (item is Map<String, Object?> && item['id'] is String) {
      yield item['id']! as String;
    }
  }
}

bool _needsReview(Map<String, Object?> record) {
  final automation = record['automation'];

  return automation is Map<String, Object?> &&
      automation['needsReview'] == true;
}

bool _containsPlaceholder(Object? value) {
  if (value is String) {
    return _placeholderTexts.any(value.contains) ||
        _placeholderPatterns.any((pattern) => pattern.hasMatch(value));
  }
  if (value is List<Object?>) {
    return value.any(_containsPlaceholder);
  }
  if (value is Map<String, Object?>) {
    return value.values.any(_containsPlaceholder);
  }

  return false;
}

void main(List<String> args) {
  final strict = args.contains('--strict');
  final positional = args.where((arg) => arg != '--strict').toList();
  if (positional.length > 1) {
    stderr.writeln('Usage: validate_content.dart [--strict] [bundle.json]');
    exitCode = 64;
    return;
  }

  final result = validateContentBundle(
    positional.isEmpty ? _defaultBundlePath : positional.single,
  );
  for (final error in result.errors) {
    stderr.writeln('error $error');
  }
  for (final warning in result.warnings) {
    stderr.writeln('warning $warning');
  }
  stderr.writeln(
    '${result.errors.length} error(s), '
    '${result.warnings.length} warning(s)'
    '${strict ? ' (--strict: warnings fail)' : ''}',
  );

  if (result.failsWith(strict: strict)) {
    exitCode = 1;
    return;
  }
  final summary = result.summary;
  if (summary != null) {
    stdout.writeln(summary);
  }
}
