// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SatoWiki';

  @override
  String get wikiTab => 'Wiki';

  @override
  String get newsTab => 'News';

  @override
  String get historyTab => 'History';

  @override
  String get codeTab => 'Code';

  @override
  String get searchTooltip => 'Search';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystemDefault => 'System Default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get categoryProtocol => 'Protocol';

  @override
  String get categoryCryptography => 'Cryptography';

  @override
  String get categoryLightningNetwork => 'Lightning Network';

  @override
  String get categoryEconomics => 'Economics';

  @override
  String get categoryConsensus => 'Consensus';

  @override
  String get categoryAdoption => 'Adoption';

  @override
  String get categoryOrigin => 'Origin';

  @override
  String get categoryRegulation => 'Regulation';

  @override
  String get categorySecurity => 'Security';

  @override
  String get all => 'All';

  @override
  String shortMin(int minutes) {
    return '$minutes min';
  }

  @override
  String entryConceptualVisual(String title) {
    return '$title conceptual visual';
  }

  @override
  String get relatedConcepts => 'Related Concepts';

  @override
  String get wikiEntryNotFound => 'Wiki entry not found';

  @override
  String get readingLevelBase => 'Base';

  @override
  String get readingLevelMedium => 'Medium';

  @override
  String get readingLevelAdvanced => 'Advanced';

  @override
  String get sourcesAndReferences => 'Sources & References';

  @override
  String get newsTitle => 'News';

  @override
  String get newsSubtitle => 'Long-form Bitcoin analysis from the community.';

  @override
  String get articleNotFound => 'Article not found';

  @override
  String get close => 'Close';

  @override
  String get market => 'Market';

  @override
  String get regulatory => 'Regulatory';

  @override
  String get culture => 'Culture';

  @override
  String get development => 'Development';

  @override
  String get historyTitle => 'History';

  @override
  String get historySubtitle => 'Milestones and context from Bitcoin time.';

  @override
  String get allEvents => 'All Events';

  @override
  String get community => 'Community';

  @override
  String get historyEventNotFound => 'History event not found';

  @override
  String get recentBips => 'Recent BIPs';

  @override
  String get allBipsTitle => 'All BIPs';

  @override
  String get noBipsMatchFilter => 'No BIPs match this filter.';

  @override
  String get noBipsAvailable => 'No BIPs available yet.';

  @override
  String get bipNumberDescending => 'Highest BIP #';

  @override
  String get bipNumberAscending => 'Lowest BIP #';

  @override
  String get changelog => 'Changelog';

  @override
  String get noRecentReleases => 'No recent releases.';

  @override
  String get bipNotFound => 'BIP not found';

  @override
  String get releaseNotFound => 'Release not found';

  @override
  String get openLinkFailed => 'Could not open the link.';

  @override
  String get statusActive => 'Active';

  @override
  String get statusFinal => 'Final';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusComplete => 'Complete';

  @override
  String get statusDeployed => 'Deployed';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusProposed => 'Proposed';

  @override
  String get statusWithdrawn => 'Withdrawn';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusMajor => 'Major';

  @override
  String get statusMinor => 'Minor';

  @override
  String get statusPatch => 'Patch';

  @override
  String get authors => 'Authors';

  @override
  String get created => 'Created';

  @override
  String get practicalImpact => 'Practical Impact';

  @override
  String get statusHistory => 'Status History';

  @override
  String get userImpact => 'User Impact';

  @override
  String get technicalChanges => 'Technical Changes';

  @override
  String get searchHint => 'Search Bitcoin knowledge';

  @override
  String get noLocalResultFound => 'No local result found.';

  @override
  String get routeNotFound => 'Route not found';

  @override
  String get contentUpdateTitle => 'Content Update';

  @override
  String get contentUpdateAvailable => 'New content is ready to download.';

  @override
  String get contentUpdateChecking => 'Checking for updates...';

  @override
  String get contentUpdateDownloadingBundle => 'Downloading content...';

  @override
  String get contentUpdateDownloadingMedia => 'Downloading media files...';

  @override
  String contentUpdateDownloadingMediaFormatted(int current, int total) {
    return 'Downloading media ($current of $total)...';
  }

  @override
  String get contentUpdateInstalling => 'Installing update...';

  @override
  String get contentUpdateDone => 'Update complete!';

  @override
  String get contentUpdateError => 'Update failed. Content is unchanged.';

  @override
  String get todayTab => 'Today';

  @override
  String get todayHeadlineLead => 'The orange book of';

  @override
  String get todayHeadlineAccent => 'Bitcoin';

  @override
  String get continueReading => 'Continue reading';

  @override
  String minutesLeft(int minutes) {
    return '$minutes min left';
  }

  @override
  String readPercent(int percent) {
    return '$percent% read';
  }

  @override
  String get featured => 'Featured';

  @override
  String get allEntries => 'All entries';

  @override
  String get nextAnniversary => 'Next anniversary';

  @override
  String get onThisDayTitle => 'On this day';

  @override
  String inDays(int days) {
    return 'in $days days';
  }

  @override
  String get tomorrow => 'tomorrow';

  @override
  String get today => 'today';

  @override
  String get fromTheCode => 'From the code';

  @override
  String get seeAll => 'See all';

  @override
  String get latestNews => 'Latest news';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get back => 'Back';

  @override
  String entriesInCategories(int entries, int categories) {
    return '$entries entries in $categories categories';
  }

  @override
  String entriesCount(int count) {
    return '$count entries';
  }

  @override
  String get searchWikiHint => 'Search the wiki';

  @override
  String get readingLevelTitle => 'Reading level';

  @override
  String get readingLevelAppliesToAll => 'Applies to every entry';

  @override
  String get categories => 'Categories';

  @override
  String get toExplore => 'To explore';

  @override
  String eventsFromTo(int count, int from, int to) {
    return '$count events from $from to $to';
  }

  @override
  String codeSummary(int bips, int releases) {
    return '$bips BIPs and $releases Bitcoin Core releases';
  }

  @override
  String get bipStatusTitle => 'BIP status';

  @override
  String totalCount(int count) {
    return '$count total';
  }

  @override
  String allCount(int count) {
    return 'All $count';
  }

  @override
  String get releases => 'Releases';

  @override
  String get allReleasesTitle => 'All releases';

  @override
  String get bipType => 'Type';

  @override
  String get inPlainWords => 'In plain words';

  @override
  String get readMoreInWiki => 'Read more in the wiki';

  @override
  String get officialTextOnGitHub => 'Official text on GitHub';

  @override
  String get officialReleaseNotes => 'Official release notes';

  @override
  String get version => 'Version';

  @override
  String get released => 'Released';

  @override
  String get textSize => 'Text size';

  @override
  String get saveBookmark => 'Save to bookmarks';

  @override
  String get removeBookmark => 'Remove from bookmarks';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get noBookmarks => 'Nothing saved yet.';

  @override
  String get noBookmarksHint => 'Tap the bookmark on an entry to find it here.';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get suggestedSearches => 'Suggestions';

  @override
  String get clearRecentSearches => 'Clear';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\".';
  }

  @override
  String get settingsReading => 'Reading';

  @override
  String get defaultLevel => 'Default level';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsContent => 'Content';

  @override
  String get contentVersion => 'Content version';

  @override
  String get upToDate => 'Up to date';

  @override
  String get updating => 'Updating';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get settingsAbout => 'About';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get categoryApplications => 'Applications';

  @override
  String get categoryPeerServices => 'Peer services';

  @override
  String get categoryInformational => 'Informational';

  @override
  String get categoryProcess => 'Process';

  @override
  String get categoryApiRpc => 'API/RPC';

  @override
  String get categorySpecification => 'Specification';

  @override
  String get categorySoftware => 'Software';

  @override
  String get categoryHardware => 'Hardware';

  @override
  String get subcategoryNodes => 'Nodes';

  @override
  String get subcategorySoftwareWallets => 'Software wallets';

  @override
  String get subcategoryLightning => 'Lightning';

  @override
  String get subcategoryServers => 'Servers and infrastructure';

  @override
  String get subcategoryNodeSystems => 'Home node systems';

  @override
  String get subcategoryMiningSoftware => 'Mining software';

  @override
  String get subcategoryDeveloperTools => 'Libraries and developer tools';

  @override
  String get subcategoryHardwareWallets => 'Hardware wallets';

  @override
  String get subcategorySeedBackups => 'Seed backups';

  @override
  String get subcategoryMiningHardware => 'Mining hardware';

  @override
  String get subcategoryNodeHardware => 'Node hardware';
}
