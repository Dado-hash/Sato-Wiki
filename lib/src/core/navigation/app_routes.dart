import 'sato_wiki_tab.dart';

abstract final class AppRoutes {
  static const root = '/';
  static const search = '/search';

  static String get wiki => SatoWikiTab.wiki.routePath;
  static String get news => SatoWikiTab.news.routePath;
  static String get history => SatoWikiTab.history.routePath;
  static String get code => SatoWikiTab.code.routePath;

  static const wikiCategoryPattern = '/wiki/categories/:categoryId';
  static const wikiEntryPattern = '/wiki/entries/:entryId';
  static const newsArticlePattern = '/news/articles/:articleId';
  static const historyEventPattern = '/history/events/:eventId';
  static const codeBipPattern = '/code/bips/:bipNumber';
  static const codeChangelogPattern = '/code/changelogs/:project/:version';

  static String wikiCategory(String categoryId) =>
      '/wiki/categories/$categoryId';

  static String wikiEntry(String entryId) => '/wiki/entries/$entryId';

  static String newsArticle(String articleId) => '/news/articles/$articleId';

  static String historyEvent(String eventId) => '/history/events/$eventId';

  static String codeBip(int bipNumber) => '/code/bips/$bipNumber';

  static String codeChangelog(String project, String version) =>
      '/code/changelogs/$project/$version';
}
