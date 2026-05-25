import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SatoWiki'**
  String get appTitle;

  /// No description provided for @wikiTab.
  ///
  /// In en, this message translates to:
  /// **'Wiki'**
  String get wikiTab;

  /// No description provided for @newsTab.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsTab;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @codeTab.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeTab;

  /// No description provided for @languageSelectorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSelectorTooltip;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @orangeBookTitle.
  ///
  /// In en, this message translates to:
  /// **'The Orange Book'**
  String get orangeBookTitle;

  /// No description provided for @wikiOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A technical encyclopedia for Bitcoin readers.'**
  String get wikiOverviewSubtitle;

  /// No description provided for @knowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get knowledgeBase;

  /// No description provided for @categoryProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get categoryProtocol;

  /// No description provided for @categoryProtocolDescription.
  ///
  /// In en, this message translates to:
  /// **'Core consensus rules, node architecture, and network topography.'**
  String get categoryProtocolDescription;

  /// No description provided for @categoryCryptography.
  ///
  /// In en, this message translates to:
  /// **'Cryptography'**
  String get categoryCryptography;

  /// No description provided for @categoryCryptographyDescription.
  ///
  /// In en, this message translates to:
  /// **'Elliptic curve mathematics, hash functions, and signature schemes.'**
  String get categoryCryptographyDescription;

  /// No description provided for @categoryLightningNetwork.
  ///
  /// In en, this message translates to:
  /// **'Lightning Network'**
  String get categoryLightningNetwork;

  /// No description provided for @categoryLightningNetworkDescription.
  ///
  /// In en, this message translates to:
  /// **'Layer 2 scaling, payment channels, and routing mechanisms.'**
  String get categoryLightningNetworkDescription;

  /// No description provided for @categoryEconomics.
  ///
  /// In en, this message translates to:
  /// **'Economics'**
  String get categoryEconomics;

  /// No description provided for @categoryEconomicsDescription.
  ///
  /// In en, this message translates to:
  /// **'Game theory, incentives, difficulty adjustment, and supply issuance.'**
  String get categoryEconomicsDescription;

  /// No description provided for @categoryBips.
  ///
  /// In en, this message translates to:
  /// **'BIPs'**
  String get categoryBips;

  /// No description provided for @categoryConsensus.
  ///
  /// In en, this message translates to:
  /// **'Consensus'**
  String get categoryConsensus;

  /// No description provided for @categorySecp256k1.
  ///
  /// In en, this message translates to:
  /// **'Secp256k1'**
  String get categorySecp256k1;

  /// No description provided for @categorySha256.
  ///
  /// In en, this message translates to:
  /// **'SHA-256'**
  String get categorySha256;

  /// No description provided for @categoryBolts.
  ///
  /// In en, this message translates to:
  /// **'BOLTs'**
  String get categoryBolts;

  /// No description provided for @categoryChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get categoryChannels;

  /// No description provided for @categoryHalving.
  ///
  /// In en, this message translates to:
  /// **'Halving'**
  String get categoryHalving;

  /// No description provided for @categoryDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get categoryDifficulty;

  /// No description provided for @wikiEntriesInCategory.
  ///
  /// In en, this message translates to:
  /// **'Wiki entries in {category}.'**
  String wikiEntriesInCategory(String category);

  /// No description provided for @wikiEntriesInThisCategory.
  ///
  /// In en, this message translates to:
  /// **'Wiki entries in this category.'**
  String get wikiEntriesInThisCategory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @coreConcept.
  ///
  /// In en, this message translates to:
  /// **'Core Concept'**
  String get coreConcept;

  /// No description provided for @minRead.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String minRead(int minutes);

  /// No description provided for @shortMin.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String shortMin(int minutes);

  /// No description provided for @entryConceptualVisual.
  ///
  /// In en, this message translates to:
  /// **'{title} conceptual visual'**
  String entryConceptualVisual(String title);

  /// No description provided for @relatedConcepts.
  ///
  /// In en, this message translates to:
  /// **'Related Concepts'**
  String get relatedConcepts;

  /// No description provided for @wikiEntryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Wiki entry not found'**
  String get wikiEntryNotFound;

  /// No description provided for @readingLevelBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get readingLevelBase;

  /// No description provided for @readingLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medio'**
  String get readingLevelMedium;

  /// No description provided for @readingLevelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Avanzato'**
  String get readingLevelAdvanced;

  /// No description provided for @sourcesAndReferences.
  ///
  /// In en, this message translates to:
  /// **'Sources & References'**
  String get sourcesAndReferences;

  /// No description provided for @newsTitle.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsTitle;

  /// No description provided for @newsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Long-form Bitcoin analysis from the community.'**
  String get newsSubtitle;

  /// No description provided for @editorial.
  ///
  /// In en, this message translates to:
  /// **'Editorial'**
  String get editorial;

  /// No description provided for @latestAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Latest analysis'**
  String get latestAnalysis;

  /// No description provided for @articleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Article not found'**
  String get articleNotFound;

  /// No description provided for @lightningTip.
  ///
  /// In en, this message translates to:
  /// **'Lightning Tip'**
  String get lightningTip;

  /// No description provided for @lightningTipDescription.
  ///
  /// In en, this message translates to:
  /// **'Mock only. Payment wiring waits for privacy and UX definition.'**
  String get lightningTipDescription;

  /// No description provided for @lightningTipMockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lightning Tip mock'**
  String get lightningTipMockTitle;

  /// No description provided for @noLightningAddress.
  ///
  /// In en, this message translates to:
  /// **'No Lightning address configured.'**
  String get noLightningAddress;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @sendTip.
  ///
  /// In en, this message translates to:
  /// **'Send Tip'**
  String get sendTip;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @regulatory.
  ///
  /// In en, this message translates to:
  /// **'Regulatory'**
  String get regulatory;

  /// No description provided for @culture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get culture;

  /// No description provided for @development.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get development;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones and context from Bitcoin time.'**
  String get historySubtitle;

  /// No description provided for @timelineMetadata.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineMetadata;

  /// No description provided for @onThisDay.
  ///
  /// In en, this message translates to:
  /// **'On this day'**
  String get onThisDay;

  /// No description provided for @noEventToday.
  ///
  /// In en, this message translates to:
  /// **'No event today'**
  String get noEventToday;

  /// No description provided for @noEventTodayDescription.
  ///
  /// In en, this message translates to:
  /// **'Historic events connected to the current date will be surfaced here.'**
  String get noEventTodayDescription;

  /// No description provided for @allEvents.
  ///
  /// In en, this message translates to:
  /// **'All Events'**
  String get allEvents;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @historyEventNotFound.
  ///
  /// In en, this message translates to:
  /// **'History event not found'**
  String get historyEventNotFound;

  /// No description provided for @codeDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Code Dashboard'**
  String get codeDashboardTitle;

  /// No description provided for @codeDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track Bitcoin Improvement Proposals (BIPs) and recent core changes.'**
  String get codeDashboardSubtitle;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @recentBips.
  ///
  /// In en, this message translates to:
  /// **'Recent BIPs'**
  String get recentBips;

  /// No description provided for @allBipsTitle.
  ///
  /// In en, this message translates to:
  /// **'All BIPs'**
  String get allBipsTitle;

  /// No description provided for @allBipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Bitcoin Improvement Proposals by status and number.'**
  String get allBipsSubtitle;

  /// No description provided for @noBipsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No BIPs match this filter.'**
  String get noBipsMatchFilter;

  /// No description provided for @bipNumberDescending.
  ///
  /// In en, this message translates to:
  /// **'Highest BIP #'**
  String get bipNumberDescending;

  /// No description provided for @bipNumberAscending.
  ///
  /// In en, this message translates to:
  /// **'Lowest BIP #'**
  String get bipNumberAscending;

  /// No description provided for @bipTracker.
  ///
  /// In en, this message translates to:
  /// **'BIP Tracker'**
  String get bipTracker;

  /// No description provided for @activeUpper.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeUpper;

  /// No description provided for @draftUpper.
  ///
  /// In en, this message translates to:
  /// **'DRAFT'**
  String get draftUpper;

  /// No description provided for @rejectedUpper.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get rejectedUpper;

  /// No description provided for @changelog.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog;

  /// No description provided for @noRecentReleases.
  ///
  /// In en, this message translates to:
  /// **'No recent releases.'**
  String get noRecentReleases;

  /// No description provided for @bipNotFound.
  ///
  /// In en, this message translates to:
  /// **'BIP not found'**
  String get bipNotFound;

  /// No description provided for @releaseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Release not found'**
  String get releaseNotFound;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusFinal.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get statusFinal;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusProposed.
  ///
  /// In en, this message translates to:
  /// **'Proposed'**
  String get statusProposed;

  /// No description provided for @statusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get statusWithdrawn;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusMajor.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get statusMajor;

  /// No description provided for @statusMinor.
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get statusMinor;

  /// No description provided for @authors.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get authors;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @layer.
  ///
  /// In en, this message translates to:
  /// **'Layer'**
  String get layer;

  /// No description provided for @plainEnglishSummary.
  ///
  /// In en, this message translates to:
  /// **'Plain English Summary'**
  String get plainEnglishSummary;

  /// No description provided for @practicalImpact.
  ///
  /// In en, this message translates to:
  /// **'Practical Impact'**
  String get practicalImpact;

  /// No description provided for @statusHistory.
  ///
  /// In en, this message translates to:
  /// **'Status History'**
  String get statusHistory;

  /// No description provided for @viewOfficialTextOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'View Official Text on GitHub'**
  String get viewOfficialTextOnGitHub;

  /// No description provided for @userImpact.
  ///
  /// In en, this message translates to:
  /// **'User Impact'**
  String get userImpact;

  /// No description provided for @technicalChanges.
  ///
  /// In en, this message translates to:
  /// **'Technical Changes'**
  String get technicalChanges;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find local content by title, tag and summary.'**
  String get searchSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Bitcoin knowledge'**
  String get searchHint;

  /// No description provided for @noLocalResultFound.
  ///
  /// In en, this message translates to:
  /// **'No local result found.'**
  String get noLocalResultFound;

  /// No description provided for @trySearchExamples.
  ///
  /// In en, this message translates to:
  /// **'Try: Proof of Work, Taproot, Pizza Day'**
  String get trySearchExamples;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found'**
  String get routeNotFound;

  /// No description provided for @wikiCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Wiki category'**
  String get wikiCategoryTitle;

  /// No description provided for @wikiEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Wiki entry'**
  String get wikiEntryTitle;

  /// No description provided for @newsArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'News article'**
  String get newsArticleTitle;

  /// No description provided for @historyEventTitle.
  ///
  /// In en, this message translates to:
  /// **'History event'**
  String get historyEventTitle;

  /// No description provided for @bipDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'BIP detail'**
  String get bipDetailTitle;

  /// No description provided for @changelogTitle.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelogTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
