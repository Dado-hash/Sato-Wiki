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
  String get languageSelectorTooltip => 'Language';

  @override
  String get searchTooltip => 'Search';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystemDefault => 'System Default';

  @override
  String get languageEnglish => 'English';

  @override
  String get orangeBookTitle => 'The Orange Book';

  @override
  String get wikiOverviewSubtitle =>
      'A technical encyclopedia for Bitcoin readers.';

  @override
  String get knowledgeBase => 'Knowledge Base';

  @override
  String get categoryProtocol => 'Protocol';

  @override
  String get categoryProtocolDescription =>
      'Core consensus rules, node architecture, and network topography.';

  @override
  String get categoryCryptography => 'Cryptography';

  @override
  String get categoryCryptographyDescription =>
      'Elliptic curve mathematics, hash functions, and signature schemes.';

  @override
  String get categoryLightningNetwork => 'Lightning Network';

  @override
  String get categoryLightningNetworkDescription =>
      'Layer 2 scaling, payment channels, and routing mechanisms.';

  @override
  String get categoryEconomics => 'Economics';

  @override
  String get categoryEconomicsDescription =>
      'Game theory, incentives, difficulty adjustment, and supply issuance.';

  @override
  String get categoryBips => 'BIPs';

  @override
  String get categoryConsensus => 'Consensus';

  @override
  String get categorySecp256k1 => 'Secp256k1';

  @override
  String get categorySha256 => 'SHA-256';

  @override
  String get categoryBolts => 'BOLTs';

  @override
  String get categoryChannels => 'Channels';

  @override
  String get categoryHalving => 'Halving';

  @override
  String get categoryDifficulty => 'Difficulty';

  @override
  String wikiEntriesInCategory(String category) {
    return 'Wiki entries in $category.';
  }

  @override
  String get wikiEntriesInThisCategory => 'Wiki entries in this category.';

  @override
  String get all => 'All';

  @override
  String get coreConcept => 'Core Concept';

  @override
  String minRead(int minutes) {
    return '$minutes min read';
  }

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
  String get readingLevelMedium => 'Medio';

  @override
  String get readingLevelAdvanced => 'Avanzato';

  @override
  String get sourcesAndReferences => 'Sources & References';

  @override
  String get newsTitle => 'News';

  @override
  String get newsSubtitle => 'Long-form Bitcoin analysis from the community.';

  @override
  String get editorial => 'Editorial';

  @override
  String get latestAnalysis => 'Latest analysis';

  @override
  String get articleNotFound => 'Article not found';

  @override
  String get lightningTip => 'Lightning Tip';

  @override
  String get lightningTipDescription =>
      'Mock only. Payment wiring waits for privacy and UX definition.';

  @override
  String get lightningTipMockTitle => 'Lightning Tip mock';

  @override
  String get noLightningAddress => 'No Lightning address configured.';

  @override
  String get close => 'Close';

  @override
  String get sendTip => 'Send Tip';

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
  String get timelineMetadata => 'Timeline';

  @override
  String get onThisDay => 'On this day';

  @override
  String get noEventToday => 'No event today';

  @override
  String get noEventTodayDescription =>
      'Historic events connected to the current date will be surfaced here.';

  @override
  String get allEvents => 'All Events';

  @override
  String get community => 'Community';

  @override
  String get historyEventNotFound => 'History event not found';

  @override
  String get codeDashboardTitle => 'Code Dashboard';

  @override
  String get codeDashboardSubtitle =>
      'Track Bitcoin Improvement Proposals (BIPs) and recent core changes.';

  @override
  String get filter => 'Filter';

  @override
  String get recentBips => 'Recent BIPs';

  @override
  String get noBipsMatchFilter => 'No BIPs match this filter.';

  @override
  String get bipTracker => 'BIP Tracker';

  @override
  String get activeUpper => 'ACTIVE';

  @override
  String get draftUpper => 'DRAFT';

  @override
  String get rejectedUpper => 'REJECTED';

  @override
  String get changelog => 'Changelog';

  @override
  String get noRecentReleases => 'No recent releases.';

  @override
  String get bipNotFound => 'BIP not found';

  @override
  String get releaseNotFound => 'Release not found';

  @override
  String get statusActive => 'Active';

  @override
  String get statusFinal => 'Final';

  @override
  String get statusDraft => 'Draft';

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
  String get authors => 'Authors';

  @override
  String get created => 'Created';

  @override
  String get layer => 'Layer';

  @override
  String get plainEnglishSummary => 'Plain English Summary';

  @override
  String get practicalImpact => 'Practical Impact';

  @override
  String get statusHistory => 'Status History';

  @override
  String get viewOfficialTextOnGitHub => 'View Official Text on GitHub';

  @override
  String get userImpact => 'User Impact';

  @override
  String get technicalChanges => 'Technical Changes';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchSubtitle => 'Find local content by title, tag and summary.';

  @override
  String get searchHint => 'Search Bitcoin knowledge';

  @override
  String get noLocalResultFound => 'No local result found.';

  @override
  String get trySearchExamples => 'Try: Proof of Work, Taproot, Pizza Day';

  @override
  String get routeNotFound => 'Route not found';

  @override
  String get wikiCategoryTitle => 'Wiki category';

  @override
  String get wikiEntryTitle => 'Wiki entry';

  @override
  String get newsArticleTitle => 'News article';

  @override
  String get historyEventTitle => 'History event';

  @override
  String get bipDetailTitle => 'BIP detail';

  @override
  String get changelogTitle => 'Changelog';
}
