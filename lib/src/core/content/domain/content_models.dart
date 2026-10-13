import '../reading_level.dart';

typedef JsonMap = Map<String, Object?>;

final class ContentBundle {
  const ContentBundle({
    required this.schemaVersion,
    required this.version,
    required this.language,
    required this.generatedAt,
    required this.wiki,
    required this.news,
    required this.history,
    required this.bips,
    required this.changelogs,
    this.glossary = const [],
    this.references = const [],
    this.quotes = const [],
    this.paths = const [],
    this.products = const [],
  });

  final int schemaVersion;
  final String version;
  final String language;
  final DateTime generatedAt;
  final List<WikiEntry> wiki;
  final List<NewsArticle> news;
  final List<HistoryEvent> history;
  final List<Bip> bips;
  final List<ReleaseNote> changelogs;

  /// Optional collections added after schema version 1. A bundle without
  /// these keys parses with empty lists.
  final List<GlossaryTerm> glossary;
  final List<ReferenceTable> references;
  final List<Quote> quotes;
  final List<LearningPath> paths;
  final List<Product> products;
}

final class SourceReference {
  const SourceReference({
    required this.title,
    required this.url,
    this.author,
    this.publishedAt,
  });

  final String title;
  final Uri url;
  final String? author;
  final DateTime? publishedAt;
}

final class RelatedContentLink {
  const RelatedContentLink({required this.id, this.title});

  final String id;
  final String? title;
}

final class Contributor {
  const Contributor({
    required this.displayName,
    this.github,
    this.lightningAddress,
  });

  final String displayName;
  final String? github;
  final String? lightningAddress;
}

final class ReadingLevelContent {
  const ReadingLevelContent({required this.bodyMarkdown});

  final String bodyMarkdown;
}

final class WikiEntry {
  const WikiEntry({
    required this.id,
    required this.slug,
    required this.language,
    required this.category,
    required this.title,
    required this.description,
    this.coverImage,
    required this.readingLevels,
    required this.difficulty,
    required this.readTimeMinutes,
    required this.tags,
    required this.sources,
    required this.related,
    required this.updatedAt,
    this.subcategory,
    this.reviewedAt,
  });

  final String id;
  final String slug;
  final String language;
  final String category;
  final String? subcategory;
  final String title;
  final String description;
  final Uri? coverImage;
  final Map<ReadingLevel, ReadingLevelContent> readingLevels;
  final ReadingLevel difficulty;
  final int readTimeMinutes;
  final List<String> tags;
  final List<SourceReference> sources;
  final List<RelatedContentLink> related;
  final DateTime updatedAt;
  final DateTime? reviewedAt;

  ReadingLevelContent contentFor(ReadingLevel level) {
    return readingLevels[level] ?? readingLevels[ReadingLevel.base]!;
  }
}

final class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.slug,
    required this.language,
    required this.title,
    required this.summary,
    required this.category,
    required this.author,
    required this.publishedAt,
    required this.readTimeMinutes,
    required this.bodyMarkdown,
    required this.tags,
    required this.sources,
    required this.related,
    required this.updatedAt,
    this.coverImage,
    this.reviewedAt,
  });

  final String id;
  final String slug;
  final String language;
  final String title;
  final String summary;
  final String category;
  final Contributor author;
  final DateTime publishedAt;
  final int readTimeMinutes;
  final Uri? coverImage;
  final String bodyMarkdown;
  final List<String> tags;
  final List<SourceReference> sources;
  final List<RelatedContentLink> related;
  final DateTime updatedAt;
  final DateTime? reviewedAt;
}

final class HistoryEvent {
  const HistoryEvent({
    required this.id,
    required this.slug,
    required this.language,
    required this.date,
    required this.title,
    required this.category,
    required this.summary,
    required this.bodyMarkdown,
    required this.tags,
    required this.sources,
    required this.related,
    required this.updatedAt,
    this.reviewedAt,
  });

  final String id;
  final String slug;
  final String language;
  final DateTime date;
  final String title;
  final String category;
  final String summary;
  final String bodyMarkdown;
  final List<String> tags;
  final List<SourceReference> sources;
  final List<RelatedContentLink> related;
  final DateTime updatedAt;
  final DateTime? reviewedAt;
}

enum BipStatus {
  draft,
  complete,
  deployed,
  closed;

  static BipStatus? fromJson(String value) {
    return switch (value.trim().toLowerCase().replaceAll(' ', '-')) {
      'draft' || 'proposed' || 'bip-number-allocated' => BipStatus.draft,
      'complete' || 'final' => BipStatus.complete,
      'deployed' || 'active' => BipStatus.deployed,
      'closed' || 'withdrawn' || 'rejected' => BipStatus.closed,
      _ => null,
    };
  }

  String get storageValue {
    return switch (this) {
      BipStatus.draft => 'draft',
      BipStatus.complete => 'complete',
      BipStatus.deployed => 'deployed',
      BipStatus.closed => 'closed',
    };
  }
}

final class BipStatusChange {
  const BipStatusChange({
    required this.date,
    required this.status,
    required this.note,
  });

  final DateTime date;
  final BipStatus status;
  final String note;
}

final class Bip {
  const Bip({
    required this.id,
    required this.number,
    required this.language,
    required this.title,
    required this.summary,
    required this.status,
    required this.category,
    required this.authors,
    required this.createdAt,
    required this.summaryMarkdown,
    required this.impactMarkdown,
    required this.officialUrl,
    required this.tags,
    required this.sources,
    required this.related,
    required this.statusHistory,
    required this.updatedAt,
    this.reviewedAt,
  });

  final String id;
  final int number;
  final String language;
  final String title;
  final String summary;
  final BipStatus status;
  final String category;
  final List<String> authors;
  final DateTime createdAt;
  final String summaryMarkdown;
  final String impactMarkdown;
  final Uri officialUrl;
  final List<String> tags;
  final List<SourceReference> sources;
  final List<RelatedContentLink> related;
  final List<BipStatusChange> statusHistory;
  final DateTime updatedAt;
  final DateTime? reviewedAt;
}

enum ReleaseImportance {
  patch,
  minor,
  major;

  static ReleaseImportance? fromJson(String value) {
    return switch (value) {
      'patch' => ReleaseImportance.patch,
      'minor' => ReleaseImportance.minor,
      'major' => ReleaseImportance.major,
      _ => null,
    };
  }
}

final class GlossaryTerm {
  const GlossaryTerm({
    required this.id,
    required this.slug,
    required this.language,
    required this.term,
    required this.definition,
    required this.related,
    required this.updatedAt,
    this.aliases = const [],
    this.reviewedAt,
  });

  final String id;
  final String slug;
  final String language;
  final String term;
  final String definition;
  final List<String> aliases;
  final List<RelatedContentLink> related;
  final DateTime updatedAt;
  final DateTime? reviewedAt;
}

enum ProductStatus {
  active,
  discontinued;

  static ProductStatus? fromJson(String value) {
    return switch (value) {
      'active' => ProductStatus.active,
      'discontinued' => ProductStatus.discontinued,
      _ => null,
    };
  }
}

final class Product {
  const Product({
    required this.id,
    required this.slug,
    required this.language,
    required this.name,
    required this.summary,
    required this.bodyMarkdown,
    required this.category,
    required this.subcategory,
    required this.maker,
    required this.website,
    required this.openSource,
    required this.status,
    required this.reviewedAt,
    required this.sources,
    required this.related,
    required this.updatedAt,
    this.sourceUrl,
    this.license,
    this.platforms = const [],
  });

  final String id;
  final String slug;
  final String language;
  final String name;
  final String summary;
  final String bodyMarkdown;
  final String category;
  final String subcategory;
  final String maker;
  final Uri website;
  final Uri? sourceUrl;
  final bool openSource;
  final String? license;
  final List<String> platforms;
  final ProductStatus status;
  final DateTime reviewedAt;
  final List<SourceReference> sources;
  final List<RelatedContentLink> related;
  final DateTime updatedAt;
}

final class LearningPathStep {
  const LearningPathStep({required this.id, required this.note});

  /// Content id of the record this step points to.
  final String id;
  final String note;
}

final class LearningPath {
  const LearningPath({
    required this.id,
    required this.slug,
    required this.language,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.steps,
    required this.updatedAt,
  });

  final String id;
  final String slug;
  final String language;
  final String title;
  final String description;
  final int estimatedMinutes;
  final List<LearningPathStep> steps;
  final DateTime updatedAt;
}

final class Quote {
  const Quote({
    required this.id,
    required this.slug,
    required this.language,
    required this.text,
    required this.author,
    required this.date,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.related,
    required this.updatedAt,
    this.originalText,
    this.topics = const [],
  });

  final String id;
  final String slug;
  final String language;
  final String text;

  /// English original, present only in non-English bundles.
  final String? originalText;
  final String author;
  final DateTime date;
  final String sourceTitle;
  final Uri sourceUrl;
  final List<String> topics;
  final List<RelatedContentLink> related;
  final DateTime updatedAt;
}

final class ReferenceColumn {
  const ReferenceColumn({required this.key, required this.label});

  final String key;
  final String label;
}

final class ReferenceRow {
  const ReferenceRow({required this.cells, this.link});

  /// Text per column key.
  final Map<String, String> cells;

  /// Optional content id this row points to.
  final String? link;
}

final class ReferenceTable {
  const ReferenceTable({
    required this.id,
    required this.slug,
    required this.language,
    required this.title,
    required this.description,
    required this.columns,
    required this.rows,
    required this.sources,
    required this.related,
    required this.updatedAt,
    this.reviewedAt,
  });

  final String id;
  final String slug;
  final String language;
  final String title;
  final String description;
  final List<ReferenceColumn> columns;
  final List<ReferenceRow> rows;
  final List<SourceReference> sources;
  final List<RelatedContentLink> related;
  final DateTime updatedAt;
  final DateTime? reviewedAt;
}

final class ReleaseNote {
  const ReleaseNote({
    required this.id,
    required this.slug,
    required this.language,
    required this.project,
    required this.version,
    required this.title,
    required this.summary,
    required this.releasedAt,
    required this.importance,
    required this.userImpactMarkdown,
    required this.technicalChangesMarkdown,
    required this.officialUrl,
    required this.tags,
    required this.sources,
    required this.related,
    required this.updatedAt,
    this.reviewedAt,
  });

  final String id;
  final String slug;
  final String language;
  final String project;
  final String version;
  final String title;
  final String summary;
  final DateTime releasedAt;
  final ReleaseImportance importance;
  final String userImpactMarkdown;
  final String technicalChangesMarkdown;
  final Uri officialUrl;
  final List<String> tags;
  final List<SourceReference> sources;
  final List<RelatedContentLink> related;
  final DateTime updatedAt;
  final DateTime? reviewedAt;
}
