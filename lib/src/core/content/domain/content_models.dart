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
  });

  final String id;
  final String slug;
  final String language;
  final String category;
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
}

enum BipStatus {
  draft,
  proposed,
  active,
  finalStatus,
  withdrawn,
  rejected;

  static BipStatus? fromJson(String value) {
    return switch (value) {
      'draft' => BipStatus.draft,
      'proposed' => BipStatus.proposed,
      'active' => BipStatus.active,
      'final' => BipStatus.finalStatus,
      'withdrawn' => BipStatus.withdrawn,
      'rejected' => BipStatus.rejected,
      _ => null,
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
}
