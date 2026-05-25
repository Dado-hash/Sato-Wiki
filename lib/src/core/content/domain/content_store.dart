import '../../../features/code/domain/repositories/code_repository.dart';
import '../../../features/history/domain/repositories/history_repository.dart';
import '../../../features/news/domain/repositories/news_repository.dart';
import '../../../features/wiki/domain/repositories/wiki_repository.dart';
import 'content_models.dart';

final class ContentStore
    implements
        WikiRepository,
        NewsRepository,
        HistoryRepository,
        CodeRepository {
  const ContentStore(this.bundle);

  final ContentBundle bundle;

  @override
  Future<WikiEntry?> findEntryById(String id) async {
    return bundle.wiki.where((entry) => entry.id == id).firstOrNull;
  }

  Future<WikiEntry?> findEntryBySlug(String slug) async {
    return bundle.wiki.where((entry) => entry.slug == slug).firstOrNull;
  }

  @override
  Future<List<WikiEntry>> listEntries() async => bundle.wiki;

  @override
  Future<List<WikiEntry>> listEntriesByCategory(String category) async {
    return bundle.wiki
        .where((entry) => entry.category == category)
        .toList(growable: false);
  }

  @override
  Future<NewsArticle?> findArticleById(String id) async {
    return bundle.news.where((article) => article.id == id).firstOrNull;
  }

  Future<NewsArticle?> findArticleBySlug(String slug) async {
    return bundle.news.where((article) => article.slug == slug).firstOrNull;
  }

  @override
  Future<List<NewsArticle>> listArticles() async {
    final articles = [...bundle.news]
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return articles;
  }

  @override
  Future<List<NewsArticle>> listArticlesByCategory(String category) async {
    return bundle.news
        .where((article) => article.category == category)
        .toList(growable: false);
  }

  @override
  Future<HistoryEvent?> findEventById(String id) async {
    return bundle.history.where((event) => event.id == id).firstOrNull;
  }

  Future<HistoryEvent?> findEventBySlug(String slug) async {
    return bundle.history.where((event) => event.slug == slug).firstOrNull;
  }

  @override
  Future<List<HistoryEvent>> listEvents() async {
    final events = [...bundle.history]
      ..sort((a, b) => a.date.compareTo(b.date));

    return events;
  }

  @override
  Future<List<HistoryEvent>> listEventsByCategory(String category) async {
    return bundle.history
        .where((event) => event.category == category)
        .toList(growable: false);
  }

  @override
  Future<List<HistoryEvent>> listEventsOnMonthDay(int month, int day) async {
    return bundle.history
        .where((event) => event.date.month == month && event.date.day == day)
        .toList(growable: false);
  }

  @override
  Future<Bip?> findBipByNumber(int number) async {
    return bundle.bips.where((bip) => bip.number == number).firstOrNull;
  }

  @override
  Future<List<Bip>> listBips() async {
    final bips = [...bundle.bips]..sort((a, b) => a.number.compareTo(b.number));

    return bips;
  }

  @override
  Future<List<Bip>> listBipsByStatus(BipStatus status) async {
    return bundle.bips
        .where((bip) => bip.status == status)
        .toList(growable: false);
  }

  @override
  Future<ReleaseNote?> findReleaseNoteById(String id) async {
    return bundle.changelogs.where((release) => release.id == id).firstOrNull;
  }

  Future<ReleaseNote?> findReleaseNoteByProjectVersion(
    String project,
    String version,
  ) async {
    return bundle.changelogs
        .where(
          (release) => release.project == project && release.version == version,
        )
        .firstOrNull;
  }

  @override
  Future<List<ReleaseNote>> listReleaseNotes() async {
    final releases = [...bundle.changelogs]
      ..sort((a, b) => b.releasedAt.compareTo(a.releasedAt));

    return releases;
  }

  @override
  Future<List<ReleaseNote>> listReleaseNotesByProject(String project) async {
    return bundle.changelogs
        .where((release) => release.project == project)
        .toList(growable: false);
  }
}
