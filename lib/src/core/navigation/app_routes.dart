import 'sato_wiki_tab.dart';

abstract final class AppRoutes {
  static const root = '/';
  static const search = '/search';
  static const settings = '/settings';
  static const bookmarks = '/bookmarks';
  static const codeChangelogs = '/code/changelogs';

  static String get today => SatoWikiTab.today.routePath;
  static String get wiki => SatoWikiTab.wiki.routePath;
  static String get news => SatoWikiTab.news.routePath;
  static String get history => SatoWikiTab.history.routePath;
  static String get code => SatoWikiTab.code.routePath;

  static const wikiCategoryPattern = '/wiki/categories/:categoryId';
  static const wikiEntryPattern = '/wiki/entries/:entryId';
  static const newsArticlePattern = '/news/articles/:articleId';
  static const historyEventPattern = '/history/events/:eventId';
  static const codeBips = '/code/bips';
  static const codeBipPattern = '/code/bips/:bipNumber';
  static const codeChangelogPattern = '/code/changelogs/:project/:version';

  // Wiki subcategories, products, glossary, paths and library.
  static const wikiSubcategoryPattern = '/wiki/subcategories/:subcategoryId';
  static const productPattern = '/products/:slug';
  static const glossary = '/glossary';
  static const glossaryTermPattern = '/glossary/:slug';
  static const learningPathPattern = '/paths/:slug';
  static const library = '/library';
  static const libraryWorkPattern = '/library/:slug';

  // Tools, reference tables, demos and explorer, all under the Code tab.
  static const toolHash = '/code/tools/hash';
  static const toolAddress = '/code/tools/address';
  static const toolTransaction = '/code/tools/transaction';
  static const toolTarget = '/code/tools/target';
  static const toolUnits = '/code/tools/units';
  static const toolDice = '/code/tools/dice';
  static const references = '/code/references';
  static const referencePattern = '/code/references/:slug';
  static const lab = '/code/lab';
  static const labStepPattern = '/code/lab/:step';
  static const scriptStepper = '/code/script';
  static const explorer = '/code/explorer';
  static const explorerSetup = '/code/explorer/setup';
  static const explorerBlockPattern = '/code/explorer/block/:hash';
  static const explorerTransactionPattern = '/code/explorer/tx/:txid';
  static const explorerAddressPattern = '/code/explorer/address/:address';

  static String wikiSubcategory(String subcategoryId) =>
      '/wiki/subcategories/$subcategoryId';

  static String product(String slug) => '/products/$slug';

  static String glossaryTerm(String slug) => '/glossary/$slug';

  static String learningPath(String slug) => '/paths/$slug';

  static String libraryWork(String slug) => '/library/$slug';

  static String reference(String slug) => '/code/references/$slug';

  /// Lab step from 1 to 7. Step 2 is "Mine a block".
  static String labStep(int step) => '/code/lab/$step';

  static String explorerBlock(String hash) => '/code/explorer/block/$hash';

  static String explorerTransaction(String txid) => '/code/explorer/tx/$txid';

  static String explorerAddress(String address) =>
      '/code/explorer/address/$address';

  static String wikiCategory(String categoryId) =>
      '/wiki/categories/$categoryId';

  static String wikiEntry(String entryId) => '/wiki/entries/$entryId';

  static String newsArticle(String articleId) => '/news/articles/$articleId';

  static String historyEvent(String eventId) => '/history/events/$eventId';

  static String codeBip(int bipNumber) => '/code/bips/$bipNumber';

  static String codeChangelog(String project, String version) =>
      '/code/changelogs/$project/$version';
}
