import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

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

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @categoryProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get categoryProtocol;

  /// No description provided for @categoryCryptography.
  ///
  /// In en, this message translates to:
  /// **'Cryptography'**
  String get categoryCryptography;

  /// No description provided for @categoryLightningNetwork.
  ///
  /// In en, this message translates to:
  /// **'Lightning Network'**
  String get categoryLightningNetwork;

  /// No description provided for @categoryEconomics.
  ///
  /// In en, this message translates to:
  /// **'Economics'**
  String get categoryEconomics;

  /// No description provided for @categoryConsensus.
  ///
  /// In en, this message translates to:
  /// **'Consensus'**
  String get categoryConsensus;

  /// No description provided for @categoryAdoption.
  ///
  /// In en, this message translates to:
  /// **'Adoption'**
  String get categoryAdoption;

  /// No description provided for @categoryOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get categoryOrigin;

  /// No description provided for @categoryRegulation.
  ///
  /// In en, this message translates to:
  /// **'Regulation'**
  String get categoryRegulation;

  /// No description provided for @categorySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get categorySecurity;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

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
  /// **'Medium'**
  String get readingLevelMedium;

  /// No description provided for @readingLevelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
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

  /// No description provided for @articleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Article not found'**
  String get articleNotFound;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

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

  /// No description provided for @noBipsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No BIPs match this filter.'**
  String get noBipsMatchFilter;

  /// No description provided for @noBipsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No BIPs available yet.'**
  String get noBipsAvailable;

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

  /// No description provided for @openLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get openLinkFailed;

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

  /// No description provided for @statusComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get statusComplete;

  /// No description provided for @statusDeployed.
  ///
  /// In en, this message translates to:
  /// **'Deployed'**
  String get statusDeployed;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

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

  /// No description provided for @statusPatch.
  ///
  /// In en, this message translates to:
  /// **'Patch'**
  String get statusPatch;

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

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found'**
  String get routeNotFound;

  /// No description provided for @contentUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Content Update'**
  String get contentUpdateTitle;

  /// No description provided for @contentUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'New content is ready to download.'**
  String get contentUpdateAvailable;

  /// No description provided for @contentUpdateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get contentUpdateChecking;

  /// No description provided for @contentUpdateDownloadingBundle.
  ///
  /// In en, this message translates to:
  /// **'Downloading content...'**
  String get contentUpdateDownloadingBundle;

  /// No description provided for @contentUpdateDownloadingMedia.
  ///
  /// In en, this message translates to:
  /// **'Downloading media files...'**
  String get contentUpdateDownloadingMedia;

  /// No description provided for @contentUpdateDownloadingMediaFormatted.
  ///
  /// In en, this message translates to:
  /// **'Downloading media ({current} of {total})...'**
  String contentUpdateDownloadingMediaFormatted(int current, int total);

  /// No description provided for @contentUpdateInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing update...'**
  String get contentUpdateInstalling;

  /// No description provided for @contentUpdateDone.
  ///
  /// In en, this message translates to:
  /// **'Update complete!'**
  String get contentUpdateDone;

  /// No description provided for @contentUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Update failed. Content is unchanged.'**
  String get contentUpdateError;

  /// No description provided for @todayTab.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTab;

  /// No description provided for @todayHeadlineLead.
  ///
  /// In en, this message translates to:
  /// **'The orange book of'**
  String get todayHeadlineLead;

  /// No description provided for @todayHeadlineAccent.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin'**
  String get todayHeadlineAccent;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReading;

  /// No description provided for @minutesLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String minutesLeft(int minutes);

  /// No description provided for @readPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% read'**
  String readPercent(int percent);

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @allEntries.
  ///
  /// In en, this message translates to:
  /// **'All entries'**
  String get allEntries;

  /// No description provided for @nextAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Next anniversary'**
  String get nextAnniversary;

  /// No description provided for @onThisDayTitle.
  ///
  /// In en, this message translates to:
  /// **'On this day'**
  String get onThisDayTitle;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'in {days} days'**
  String inDays(int days);

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get tomorrow;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @fromTheCode.
  ///
  /// In en, this message translates to:
  /// **'From the code'**
  String get fromTheCode;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest news'**
  String get latestNews;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @entriesInCategories.
  ///
  /// In en, this message translates to:
  /// **'{entries} entries in {categories} categories'**
  String entriesInCategories(int entries, int categories);

  /// No description provided for @entriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String entriesCount(int count);

  /// No description provided for @searchWikiHint.
  ///
  /// In en, this message translates to:
  /// **'Search the wiki'**
  String get searchWikiHint;

  /// No description provided for @readingLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading level'**
  String get readingLevelTitle;

  /// No description provided for @readingLevelAppliesToAll.
  ///
  /// In en, this message translates to:
  /// **'Applies to every entry'**
  String get readingLevelAppliesToAll;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @toExplore.
  ///
  /// In en, this message translates to:
  /// **'To explore'**
  String get toExplore;

  /// No description provided for @eventsFromTo.
  ///
  /// In en, this message translates to:
  /// **'{count} events from {from} to {to}'**
  String eventsFromTo(int count, int from, int to);

  /// No description provided for @codeSummary.
  ///
  /// In en, this message translates to:
  /// **'{bips} BIPs and {releases} Bitcoin Core releases'**
  String codeSummary(int bips, int releases);

  /// No description provided for @bipStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'BIP status'**
  String get bipStatusTitle;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalCount(int count);

  /// No description provided for @allCount.
  ///
  /// In en, this message translates to:
  /// **'All {count}'**
  String allCount(int count);

  /// No description provided for @releases.
  ///
  /// In en, this message translates to:
  /// **'Releases'**
  String get releases;

  /// No description provided for @allReleasesTitle.
  ///
  /// In en, this message translates to:
  /// **'All releases'**
  String get allReleasesTitle;

  /// No description provided for @bipType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get bipType;

  /// No description provided for @inPlainWords.
  ///
  /// In en, this message translates to:
  /// **'In plain words'**
  String get inPlainWords;

  /// No description provided for @readMoreInWiki.
  ///
  /// In en, this message translates to:
  /// **'Read more in the wiki'**
  String get readMoreInWiki;

  /// No description provided for @officialTextOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'Official text on GitHub'**
  String get officialTextOnGitHub;

  /// No description provided for @officialReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Official release notes'**
  String get officialReleaseNotes;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @released.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get released;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @saveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save to bookmarks'**
  String get saveBookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove from bookmarks'**
  String get removeBookmark;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet.'**
  String get noBookmarks;

  /// No description provided for @noBookmarksHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on an entry to find it here.'**
  String get noBookmarksHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @suggestedSearches.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestedSearches;

  /// No description provided for @clearRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearRecentSearches;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\".'**
  String noResultsFor(String query);

  /// No description provided for @settingsReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get settingsReading;

  /// No description provided for @defaultLevel.
  ///
  /// In en, this message translates to:
  /// **'Default level'**
  String get defaultLevel;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get settingsContent;

  /// No description provided for @contentVersion.
  ///
  /// In en, this message translates to:
  /// **'Content version'**
  String get contentVersion;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get upToDate;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get updating;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// No description provided for @categoryApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get categoryApplications;

  /// No description provided for @categoryPeerServices.
  ///
  /// In en, this message translates to:
  /// **'Peer services'**
  String get categoryPeerServices;

  /// No description provided for @categoryInformational.
  ///
  /// In en, this message translates to:
  /// **'Informational'**
  String get categoryInformational;

  /// No description provided for @categoryProcess.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get categoryProcess;

  /// No description provided for @categoryApiRpc.
  ///
  /// In en, this message translates to:
  /// **'API/RPC'**
  String get categoryApiRpc;

  /// No description provided for @categorySpecification.
  ///
  /// In en, this message translates to:
  /// **'Specification'**
  String get categorySpecification;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
