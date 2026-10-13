import 'dart:convert';

import '../domain/content_models.dart';
import '../reading_level.dart';
import 'content_bundle_errors.dart';
import 'content_bundle_migrator.dart';

final class ContentBundleParseResult {
  const ContentBundleParseResult({
    required this.bundle,
    required this.warnings,
  });

  final ContentBundle bundle;
  final List<ContentBundleWarning> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
}

abstract final class ContentBundleParser {
  static ContentBundleParseResult parseJson(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw ContentBundleParseException('Invalid JSON: ${error.message}');
    }

    if (decoded is! JsonMap) {
      throw const ContentBundleParseException('Bundle root must be an object.');
    }

    final migration = ContentBundleMigrator.migrate(decoded);
    final data = migration.data;
    final warnings = [...migration.warnings];
    final language = _string(data, 'language', 'bundle', fallback: 'en');

    return ContentBundleParseResult(
      warnings: warnings,
      bundle: ContentBundle(
        schemaVersion: _int(data, 'schemaVersion', 'bundle'),
        version: _string(data, 'version', 'bundle'),
        language: language,
        generatedAt: _dateTime(data, 'generatedAt', 'bundle'),
        wiki: _records(
          data,
          'wiki',
          warnings,
          (record, path) => _wiki(record, path, language),
        ),
        news: _records(
          data,
          'news',
          warnings,
          (record, path) => _news(record, path, language),
        ),
        history: _records(
          data,
          'history',
          warnings,
          (record, path) => _history(record, path, language),
        ),
        bips: _records(
          data,
          'bips',
          warnings,
          (record, path) => _bip(record, path, language),
        ),
        changelogs: _records(
          data,
          'changelogs',
          warnings,
          (record, path) => _release(record, path, language),
        ),
        glossary: _optionalRecords(
          data,
          'glossary',
          warnings,
          (record, path) => _glossaryTerm(record, path, language),
        ),
        references: _optionalRecords(
          data,
          'references',
          warnings,
          (record, path) => _referenceTable(record, path, language),
        ),
        quotes: _optionalRecords(
          data,
          'quotes',
          warnings,
          (record, path) => _quote(record, path, language),
        ),
        paths: _optionalRecords(
          data,
          'paths',
          warnings,
          (record, path) => _learningPath(record, path, language),
        ),
        products: _optionalRecords(
          data,
          'products',
          warnings,
          (record, path) => _product(record, path, language),
        ),
        library: _optionalRecords(
          data,
          'library',
          warnings,
          (record, path) => _libraryWork(record, path, language),
        ),
      ),
    );
  }

  static LibraryWork _libraryWork(
    JsonMap data,
    String path,
    String bundleLanguage,
  ) {
    return LibraryWork(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      title: _string(data, 'title', path),
      author: _string(data, 'author', path),
      year: _int(data, 'year', path),
      summary: _string(data, 'summary', path),
      introduction: _string(data, 'introduction', path),
      originalLanguage: _string(data, 'originalLanguage', path),
      kind: _string(data, 'kind', path),
      topics: _stringList(data, 'topics', path),
      url: _uri(data, 'url', path),
      archiveUrl: _optionalUri(data, 'archiveUrl', path),
      licenseNote: _string(data, 'licenseNote', path),
      sources: _sources(data, '$path.sources'),
      related: _related(data, '$path.related'),
      updatedAt: _dateTime(data, 'updatedAt', path),
      reviewedAt: _reviewedAt(data, path),
    );
  }

  static Product _product(JsonMap data, String path, String bundleLanguage) {
    final status = ProductStatus.fromJson(_string(data, 'status', path));
    if (status == null) {
      throw ContentBundleParseException('$path.status is not supported.');
    }

    return Product(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      name: _string(data, 'name', path),
      summary: _string(data, 'summary', path),
      bodyMarkdown: _string(data, 'bodyMarkdown', path),
      category: _string(data, 'category', path),
      subcategory: _string(data, 'subcategory', path),
      maker: _string(data, 'maker', path),
      website: _uri(data, 'website', path),
      sourceUrl: _optionalUri(data, 'sourceUrl', path),
      openSource: _bool(data, 'openSource', path),
      license: _optionalString(data, 'license'),
      platforms: _stringList(data, 'platforms', path),
      status: status,
      reviewedAt: _requiredReviewedAt(data, path),
      sources: _sources(data, '$path.sources'),
      related: _related(data, '$path.related'),
      updatedAt: _dateTime(data, 'updatedAt', path),
    );
  }

  static LearningPath _learningPath(
    JsonMap data,
    String path,
    String bundleLanguage,
  ) {
    return LearningPath(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      title: _string(data, 'title', path),
      description: _string(data, 'description', path),
      estimatedMinutes: _int(data, 'estimatedMinutes', path),
      steps: _learningPathSteps(data, '$path.steps'),
      updatedAt: _dateTime(data, 'updatedAt', path),
    );
  }

  static List<LearningPathStep> _learningPathSteps(JsonMap data, String path) {
    final list = _objectList(data, 'steps', path);
    if (list.isEmpty) {
      throw ContentBundleParseException('$path must be a non-empty list.');
    }

    return List.unmodifiable(
      list.map(
        (step) => LearningPathStep(
          id: _string(step, 'id', '$path[]'),
          note: _string(step, 'note', '$path[]'),
        ),
      ),
    );
  }

  static Quote _quote(JsonMap data, String path, String bundleLanguage) {
    return Quote(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      text: _string(data, 'text', path),
      originalText: _optionalString(data, 'originalText'),
      author: _string(data, 'author', path),
      date: _dateTime(data, 'date', path),
      sourceTitle: _string(data, 'sourceTitle', path),
      sourceUrl: _uri(data, 'sourceUrl', path),
      topics: _stringList(data, 'topics', path),
      related: _related(data, '$path.related'),
      updatedAt: _dateTime(data, 'updatedAt', path),
    );
  }

  static ReferenceTable _referenceTable(
    JsonMap data,
    String path,
    String bundleLanguage,
  ) {
    return ReferenceTable(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      title: _string(data, 'title', path),
      description: _string(data, 'description', path),
      columns: _referenceColumns(data, '$path.columns'),
      rows: _referenceRows(data, '$path.rows'),
      sources: _sources(data, '$path.sources'),
      related: _related(data, '$path.related'),
      updatedAt: _dateTime(data, 'updatedAt', path),
      reviewedAt: _reviewedAt(data, path),
    );
  }

  static List<ReferenceColumn> _referenceColumns(JsonMap data, String path) {
    final list = _objectList(data, 'columns', path);
    if (list.isEmpty) {
      throw ContentBundleParseException('$path must be a non-empty list.');
    }

    return List.unmodifiable(
      list.map(
        (column) => ReferenceColumn(
          key: _string(column, 'key', '$path[]'),
          label: _string(column, 'label', '$path[]'),
        ),
      ),
    );
  }

  static List<ReferenceRow> _referenceRows(JsonMap data, String path) {
    final list = _objectList(data, 'rows', path);

    return List.unmodifiable(
      list.map((row) {
        final cellsValue = row['cells'];
        if (cellsValue is! JsonMap) {
          throw ContentBundleParseException('$path[].cells must be an object.');
        }
        final cells = <String, String>{};
        for (final entry in cellsValue.entries) {
          final text = entry.value;
          if (text is! String) {
            throw ContentBundleParseException(
              '$path[].cells.${entry.key} must be a string.',
            );
          }
          cells[entry.key] = text;
        }

        return ReferenceRow(
          cells: Map.unmodifiable(cells),
          link: _optionalString(row, 'link'),
        );
      }),
    );
  }

  static GlossaryTerm _glossaryTerm(
    JsonMap data,
    String path,
    String bundleLanguage,
  ) {
    return GlossaryTerm(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      term: _string(data, 'term', path),
      definition: _string(data, 'definition', path),
      aliases: _stringList(data, 'aliases', path),
      related: _related(data, '$path.related'),
      updatedAt: _dateTime(data, 'updatedAt', path),
      reviewedAt: _reviewedAt(data, path),
    );
  }

  static WikiEntry _wiki(JsonMap data, String path, String bundleLanguage) {
    final levels = _readingLevels(data, '$path.readingLevels');

    return WikiEntry(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      category: _string(data, 'category', path),
      subcategory: _optionalSubcategory(data, '$path.subcategory'),
      title: _string(data, 'title', path),
      description: _string(data, 'description', path),
      coverImage: _optionalRelativeUri(data, 'coverImage', path),
      readingLevels: levels,
      difficulty: _readingLevel(data, 'difficulty', path),
      readTimeMinutes: _int(data, 'readTimeMinutes', path),
      tags: _stringList(data, 'tags', path),
      sources: _sources(data, '$path.sources'),
      related: _related(data, '$path.related'),
      updatedAt: _dateTime(data, 'updatedAt', path),
      reviewedAt: _reviewedAt(data, path),
    );
  }

  static NewsArticle _news(JsonMap data, String path, String bundleLanguage) {
    return NewsArticle(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      title: _string(data, 'title', path),
      summary: _string(data, 'summary', path),
      category: _string(data, 'category', path),
      author: _contributor(_map(data, 'author', path), '$path.author'),
      publishedAt: _dateTime(data, 'publishedAt', path),
      readTimeMinutes: _int(data, 'readTimeMinutes', path),
      coverImage: _optionalUri(data, 'coverImage', path),
      bodyMarkdown: _string(data, 'bodyMarkdown', path),
      tags: _stringList(data, 'tags', path),
      sources: _sources(data, '$path.sources'),
      related: _related(data, '$path.related'),
      updatedAt: _dateTime(data, 'updatedAt', path),
      reviewedAt: _reviewedAt(data, path),
    );
  }

  static HistoryEvent _history(
    JsonMap data,
    String path,
    String bundleLanguage,
  ) {
    return HistoryEvent(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      date: _dateTime(data, 'date', path),
      title: _string(data, 'title', path),
      category: _string(data, 'category', path),
      summary: _string(data, 'summary', path),
      bodyMarkdown: _string(data, 'bodyMarkdown', path),
      tags: _stringList(data, 'tags', path),
      sources: _sources(data, '$path.sources'),
      related: _related(data, '$path.related'),
      updatedAt: _dateTime(data, 'updatedAt', path),
      reviewedAt: _reviewedAt(data, path),
    );
  }

  static Bip _bip(JsonMap data, String path, String bundleLanguage) {
    final status = BipStatus.fromJson(_string(data, 'status', path));
    if (status == null) {
      throw ContentBundleParseException('$path.status is not supported.');
    }

    return Bip(
      id: _string(data, 'id', path),
      number: _int(data, 'number', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      title: _string(data, 'title', path),
      summary: _string(data, 'summary', path),
      status: status,
      category: _string(data, 'category', path),
      authors: _stringList(data, 'authors', path),
      createdAt: _dateTime(data, 'createdAt', path),
      summaryMarkdown: _string(data, 'summaryMarkdown', path),
      impactMarkdown: _string(data, 'impactMarkdown', path),
      officialUrl: _uri(data, 'officialUrl', path),
      tags: _stringList(data, 'tags', path),
      sources: _sources(data, '$path.sources'),
      related: _related(data, '$path.related'),
      statusHistory: _statusHistory(data, '$path.statusHistory'),
      updatedAt: _dateTime(data, 'updatedAt', path),
      reviewedAt: _reviewedAt(data, path),
    );
  }

  static ReleaseNote _release(
    JsonMap data,
    String path,
    String bundleLanguage,
  ) {
    final importance = ReleaseImportance.fromJson(
      _string(data, 'importance', path),
    );
    if (importance == null) {
      throw ContentBundleParseException('$path.importance is not supported.');
    }

    return ReleaseNote(
      id: _string(data, 'id', path),
      slug: _string(data, 'slug', path),
      language: _string(data, 'language', path, fallback: bundleLanguage),
      project: _string(data, 'project', path),
      version: _string(data, 'version', path),
      title: _string(data, 'title', path),
      summary: _string(data, 'summary', path),
      releasedAt: _dateTime(data, 'releasedAt', path),
      importance: importance,
      userImpactMarkdown: _string(data, 'userImpactMarkdown', path),
      technicalChangesMarkdown: _string(data, 'technicalChangesMarkdown', path),
      officialUrl: _uri(data, 'officialUrl', path),
      tags: _stringList(data, 'tags', path),
      sources: _sources(data, '$path.sources'),
      related: _related(data, '$path.related'),
      updatedAt: _dateTime(data, 'updatedAt', path),
      reviewedAt: _reviewedAt(data, path),
    );
  }

  static Map<ReadingLevel, ReadingLevelContent> _readingLevels(
    JsonMap data,
    String path,
  ) {
    final value = data['readingLevels'];
    if (value is! JsonMap) {
      throw ContentBundleParseException('$path must be an object.');
    }

    final levels = <ReadingLevel, ReadingLevelContent>{};
    for (final level in ReadingLevel.values) {
      final levelMap = value[level.storageValue];
      if (levelMap is! JsonMap) {
        throw ContentBundleParseException(
          '$path.${level.storageValue} missing.',
        );
      }
      levels[level] = ReadingLevelContent(
        bodyMarkdown: _string(
          levelMap,
          'bodyMarkdown',
          '$path.${level.storageValue}',
        ),
      );
    }

    return levels;
  }

  static List<T> _records<T>(
    JsonMap data,
    String key,
    List<ContentBundleWarning> warnings,
    T Function(JsonMap record, String path) build,
  ) {
    final value = data[key];
    if (value == null) {
      warnings.add(
        ContentBundleWarning(
          path: key,
          message: 'Missing collection. Using empty list.',
        ),
      );
      return const [];
    }
    if (value is! List<Object?>) {
      warnings.add(
        ContentBundleWarning(path: key, message: 'Collection is not a list.'),
      );
      return const [];
    }

    final records = <T>[];
    for (var index = 0; index < value.length; index++) {
      final path = '$key[$index]';
      final item = value[index];
      if (item is! JsonMap) {
        warnings.add(
          ContentBundleWarning(path: path, message: 'Record is not an object.'),
        );
        continue;
      }

      try {
        records.add(build(item, path));
      } on ContentBundleParseException catch (error) {
        warnings.add(ContentBundleWarning(path: path, message: error.message));
      }
    }

    return List.unmodifiable(records);
  }

  /// Like [_records] for collections added after schema version 1: a missing
  /// key gives an empty list without a warning, so older bundles stay clean.
  static List<T> _optionalRecords<T>(
    JsonMap data,
    String key,
    List<ContentBundleWarning> warnings,
    T Function(JsonMap record, String path) build,
  ) {
    if (!data.containsKey(key) || data[key] == null) {
      return const [];
    }

    return _records(data, key, warnings, build);
  }

  static Contributor _contributor(JsonMap data, String path) {
    return Contributor(
      displayName: _string(data, 'displayName', path),
      github: _optionalString(data, 'github'),
      lightningAddress: _optionalString(data, 'lightningAddress'),
    );
  }

  static List<SourceReference> _sources(JsonMap data, String path) {
    final list = _objectList(data, 'sources', path);

    return List.unmodifiable(
      list.map((source) {
        final sourcePath = '$path[]';

        return SourceReference(
          title: _string(source, 'title', sourcePath),
          url: _uri(source, 'url', sourcePath),
          author: _optionalString(source, 'author'),
          publishedAt: _optionalDateTime(source, 'publishedAt', sourcePath),
        );
      }),
    );
  }

  static List<RelatedContentLink> _related(JsonMap data, String path) {
    final value = data['related'];
    if (value == null) {
      return const [];
    }
    if (value is! List<Object?>) {
      throw ContentBundleParseException('$path must be a list.');
    }

    return List.unmodifiable(
      value.map((item) {
        if (item is String) {
          return RelatedContentLink(id: item);
        }
        if (item is JsonMap) {
          return RelatedContentLink(
            id: _string(item, 'id', '$path[]'),
            title: _optionalString(item, 'title'),
          );
        }
        throw ContentBundleParseException(
          '$path[] must be a string or object.',
        );
      }),
    );
  }

  static List<BipStatusChange> _statusHistory(JsonMap data, String path) {
    final list = _objectList(data, 'statusHistory', path);

    return List.unmodifiable(
      list.map((item) {
        final status = BipStatus.fromJson(_string(item, 'status', '$path[]'));
        if (status == null) {
          throw ContentBundleParseException('$path[].status is unsupported.');
        }

        return BipStatusChange(
          date: _dateTime(item, 'date', '$path[]'),
          status: status,
          note: _string(item, 'note', '$path[]'),
        );
      }),
    );
  }

  static List<JsonMap> _objectList(JsonMap data, String key, String path) {
    final value = data[key];
    if (value == null) {
      return const [];
    }
    if (value is! List<Object?>) {
      throw ContentBundleParseException('$path must be a list.');
    }

    return List.unmodifiable(
      value.map((item) {
        if (item is JsonMap) {
          return item;
        }
        throw ContentBundleParseException('$path[] must be an object.');
      }),
    );
  }

  static JsonMap _map(JsonMap data, String key, String path) {
    final value = data[key];
    if (value is JsonMap) {
      return value;
    }
    throw ContentBundleParseException('$path.$key must be an object.');
  }

  static String _string(
    JsonMap data,
    String key,
    String path, {
    String? fallback,
  }) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    if (fallback != null) {
      return fallback;
    }
    throw ContentBundleParseException('$path.$key must be a non-empty string.');
  }

  static String? _optionalString(JsonMap data, String key) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }

  static int _int(JsonMap data, String key, String path) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    throw ContentBundleParseException('$path.$key must be an integer.');
  }

  static DateTime _dateTime(JsonMap data, String key, String path) {
    final value = _string(data, key, path);
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw ContentBundleParseException('$path.$key must be an ISO date.');
    }

    return parsed;
  }

  /// Optional `reviewedAt` on every record. Missing or null gives null; any
  /// other value must be an ISO 8601 date or date-time.
  static DateTime? _reviewedAt(JsonMap data, String path) {
    final value = data['reviewedAt'];
    if (value == null) {
      return null;
    }
    final parsed = value is String ? DateTime.tryParse(value) : null;
    if (parsed == null) {
      throw ContentBundleParseException(
        '$path.reviewedAt must be an ISO date.',
      );
    }

    return parsed;
  }

  /// `reviewedAt` for records that must carry one (products).
  static DateTime _requiredReviewedAt(JsonMap data, String path) {
    final value = _reviewedAt(data, path);
    if (value == null) {
      throw ContentBundleParseException('$path.reviewedAt is required.');
    }

    return value;
  }

  static bool _bool(JsonMap data, String key, String path) {
    final value = data[key];
    if (value is bool) {
      return value;
    }
    throw ContentBundleParseException('$path.$key must be a boolean.');
  }

  /// Optional wiki `subcategory`. Missing, null or blank gives null; any
  /// non-string value is an error.
  static String? _optionalSubcategory(JsonMap data, String path) {
    final value = data['subcategory'];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw ContentBundleParseException('$path must be a string.');
    }
    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  static DateTime? _optionalDateTime(JsonMap data, String key, String path) {
    final value = _optionalString(data, key);
    if (value == null) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw ContentBundleParseException('$path.$key must be an ISO date.');
    }

    return parsed;
  }

  static Uri _uri(JsonMap data, String key, String path) {
    final value = _string(data, key, path);
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      throw ContentBundleParseException('$path.$key must be an absolute URI.');
    }

    return uri;
  }

  static Uri? _optionalUri(JsonMap data, String key, String path) {
    final value = _optionalString(data, key);
    if (value == null) {
      return null;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      throw ContentBundleParseException('$path.$key must be an absolute URI.');
    }

    return uri;
  }

  static Uri? _optionalRelativeUri(JsonMap data, String key, String path) {
    final value = _optionalString(data, key);
    if (value == null) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null) {
      throw ContentBundleParseException('$path.$key must be a URI.');
    }

    return uri;
  }

  static List<String> _stringList(JsonMap data, String key, String path) {
    final value = data[key];
    if (value == null) {
      return const [];
    }
    if (value is! List<Object?> || value.any((item) => item is! String)) {
      throw ContentBundleParseException('$path.$key must be a string list.');
    }

    return List.unmodifiable(value.cast<String>());
  }

  static ReadingLevel _readingLevel(JsonMap data, String key, String path) {
    final value = _string(data, key, path);
    final level = ReadingLevel.fromStorageValue(value);
    if (level == null) {
      throw ContentBundleParseException('$path.$key is unsupported.');
    }

    return level;
  }
}
