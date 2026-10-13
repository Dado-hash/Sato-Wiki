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

  /// No description provided for @categorySoftware.
  ///
  /// In en, this message translates to:
  /// **'Software'**
  String get categorySoftware;

  /// No description provided for @categoryHardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get categoryHardware;

  /// No description provided for @categoryPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy and security'**
  String get categoryPrivacySecurity;

  /// No description provided for @subcategoryNodes.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get subcategoryNodes;

  /// No description provided for @subcategorySoftwareWallets.
  ///
  /// In en, this message translates to:
  /// **'Software wallets'**
  String get subcategorySoftwareWallets;

  /// No description provided for @subcategoryLightning.
  ///
  /// In en, this message translates to:
  /// **'Lightning'**
  String get subcategoryLightning;

  /// No description provided for @subcategoryServers.
  ///
  /// In en, this message translates to:
  /// **'Servers and infrastructure'**
  String get subcategoryServers;

  /// No description provided for @subcategoryNodeSystems.
  ///
  /// In en, this message translates to:
  /// **'Home node systems'**
  String get subcategoryNodeSystems;

  /// No description provided for @subcategoryMiningSoftware.
  ///
  /// In en, this message translates to:
  /// **'Mining software'**
  String get subcategoryMiningSoftware;

  /// No description provided for @subcategoryDeveloperTools.
  ///
  /// In en, this message translates to:
  /// **'Libraries and developer tools'**
  String get subcategoryDeveloperTools;

  /// No description provided for @subcategoryHardwareWallets.
  ///
  /// In en, this message translates to:
  /// **'Hardware wallets'**
  String get subcategoryHardwareWallets;

  /// No description provided for @subcategorySeedBackups.
  ///
  /// In en, this message translates to:
  /// **'Seed backups'**
  String get subcategorySeedBackups;

  /// No description provided for @subcategoryMiningHardware.
  ///
  /// In en, this message translates to:
  /// **'Mining hardware'**
  String get subcategoryMiningHardware;

  /// No description provided for @subcategoryNodeHardware.
  ///
  /// In en, this message translates to:
  /// **'Node hardware'**
  String get subcategoryNodeHardware;

  /// No description provided for @wikiTreeCategoryMyths.
  ///
  /// In en, this message translates to:
  /// **'Myths'**
  String get wikiTreeCategoryMyths;

  /// No description provided for @wikiTreeSubcategoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 subcategory} other{{count} subcategories}}'**
  String wikiTreeSubcategoriesCount(int count);

  /// No description provided for @wikiTreeGlossary.
  ///
  /// In en, this message translates to:
  /// **'Glossary'**
  String get wikiTreeGlossary;

  /// No description provided for @wikiTreeGlossaryCount.
  ///
  /// In en, this message translates to:
  /// **'Short definitions · {count, plural, =1{1 term} other{{count} terms}}'**
  String wikiTreeGlossaryCount(int count);

  /// No description provided for @wikiTreeOtherEntries.
  ///
  /// In en, this message translates to:
  /// **'Other entries'**
  String get wikiTreeOtherEntries;

  /// No description provided for @wikiTreeGuideMinutes.
  ///
  /// In en, this message translates to:
  /// **'Guide · {minutes} min'**
  String wikiTreeGuideMinutes(int minutes);

  /// No description provided for @wikiTreeProductsCount.
  ///
  /// In en, this message translates to:
  /// **'Products · {count}'**
  String wikiTreeProductsCount(int count);

  /// No description provided for @wikiTreeStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get wikiTreeStatusActive;

  /// No description provided for @wikiTreeStatusDiscontinued.
  ///
  /// In en, this message translates to:
  /// **'Discontinued'**
  String get wikiTreeStatusDiscontinued;

  /// No description provided for @wikiTreeOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get wikiTreeOpenSource;

  /// No description provided for @wikiTreeSourceNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Source not open'**
  String get wikiTreeSourceNotOpen;

  /// No description provided for @wikiTreeYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get wikiTreeYes;

  /// No description provided for @wikiTreeNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get wikiTreeNo;

  /// No description provided for @wikiTreeLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get wikiTreeLicense;

  /// No description provided for @wikiTreeMaker.
  ///
  /// In en, this message translates to:
  /// **'Maker'**
  String get wikiTreeMaker;

  /// No description provided for @wikiTreePlatforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get wikiTreePlatforms;

  /// No description provided for @wikiTreeCheckedOn.
  ///
  /// In en, this message translates to:
  /// **'Checked on {date}'**
  String wikiTreeCheckedOn(String date);

  /// No description provided for @wikiTreeWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get wikiTreeWebsite;

  /// No description provided for @wikiTreeSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get wikiTreeSourceCode;

  /// No description provided for @wikiTreeProductNotice.
  ///
  /// In en, this message translates to:
  /// **'SatoWiki does not sell or recommend products and has no affiliate links.'**
  String get wikiTreeProductNotice;

  /// No description provided for @wikiTreeStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get wikiTreeStatus;

  /// No description provided for @wikiTreeProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get wikiTreeProductNotFound;

  /// No description provided for @learnStartHere.
  ///
  /// In en, this message translates to:
  /// **'Start here'**
  String get learnStartHere;

  /// No description provided for @learnQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get learnQuote;

  /// No description provided for @learnSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get learnSource;

  /// No description provided for @learnStepsRead.
  ///
  /// In en, this message translates to:
  /// **'{read} of {total} read'**
  String learnStepsRead(int read, int total);

  /// No description provided for @learnNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next: {title}'**
  String learnNextStep(String title);

  /// No description provided for @learnAllStepsRead.
  ///
  /// In en, this message translates to:
  /// **'All steps read'**
  String get learnAllStepsRead;

  /// No description provided for @learnStepRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get learnStepRead;

  /// No description provided for @learnStepNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String learnStepNumber(int number);

  /// No description provided for @learnPathNotFound.
  ///
  /// In en, this message translates to:
  /// **'Path not found'**
  String get learnPathNotFound;

  /// No description provided for @learnGlossaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Glossary'**
  String get learnGlossaryTitle;

  /// No description provided for @learnGlossaryFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter terms'**
  String get learnGlossaryFilterHint;

  /// No description provided for @learnGlossaryNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No terms match \"{query}\".'**
  String learnGlossaryNoMatch(String query);

  /// No description provided for @learnGlossaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No glossary terms yet.'**
  String get learnGlossaryEmpty;

  /// No description provided for @learnAlsoCalled.
  ///
  /// In en, this message translates to:
  /// **'Also called'**
  String get learnAlsoCalled;

  /// No description provided for @learnGlossaryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Term not found'**
  String get learnGlossaryNotFound;

  /// No description provided for @toolsSectionTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsSectionTools;

  /// No description provided for @toolsSectionLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn by doing'**
  String get toolsSectionLearn;

  /// No description provided for @toolsSectionNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get toolsSectionNetwork;

  /// No description provided for @toolsTileHashName.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get toolsTileHashName;

  /// No description provided for @toolsTileHashCaption.
  ///
  /// In en, this message translates to:
  /// **'SHA-256 · HASH160'**
  String get toolsTileHashCaption;

  /// No description provided for @toolsTileAddressName.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get toolsTileAddressName;

  /// No description provided for @toolsTileAddressCaption.
  ///
  /// In en, this message translates to:
  /// **'Type and checksum'**
  String get toolsTileAddressCaption;

  /// No description provided for @toolsTileTransactionName.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get toolsTileTransactionName;

  /// No description provided for @toolsTileTransactionCaption.
  ///
  /// In en, this message translates to:
  /// **'Raw hex decoder'**
  String get toolsTileTransactionCaption;

  /// No description provided for @toolsTileTargetName.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get toolsTileTargetName;

  /// No description provided for @toolsTileTargetCaption.
  ///
  /// In en, this message translates to:
  /// **'Bits and difficulty'**
  String get toolsTileTargetCaption;

  /// No description provided for @toolsTileUnitsName.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get toolsTileUnitsName;

  /// No description provided for @toolsTileUnitsCaption.
  ///
  /// In en, this message translates to:
  /// **'sat · BTC · vB'**
  String get toolsTileUnitsCaption;

  /// No description provided for @toolsTileTablesName.
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get toolsTileTablesName;

  /// No description provided for @toolsTileTablesCaption.
  ///
  /// In en, this message translates to:
  /// **'Opcodes, fields, messages'**
  String get toolsTileTablesCaption;

  /// No description provided for @toolsLabName.
  ///
  /// In en, this message translates to:
  /// **'Blockchain lab'**
  String get toolsLabName;

  /// No description provided for @toolsLabCaption.
  ///
  /// In en, this message translates to:
  /// **'Six steps: hash, block, chain, network, transactions, coinbase.'**
  String get toolsLabCaption;

  /// No description provided for @toolsScriptName.
  ///
  /// In en, this message translates to:
  /// **'Script step by step'**
  String get toolsScriptName;

  /// No description provided for @toolsScriptCaption.
  ///
  /// In en, this message translates to:
  /// **'See the stack after each opcode.'**
  String get toolsScriptCaption;

  /// No description provided for @toolsExplorerName.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get toolsExplorerName;

  /// No description provided for @toolsExplorerCaption.
  ///
  /// In en, this message translates to:
  /// **'Uses the network. Off by default.'**
  String get toolsExplorerCaption;

  /// No description provided for @toolsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get toolsCopy;

  /// No description provided for @toolsCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get toolsCopied;

  /// No description provided for @toolsReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more in the wiki'**
  String get toolsReadMore;

  /// No description provided for @toolsHashTitle.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get toolsHashTitle;

  /// No description provided for @toolsHashModeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get toolsHashModeText;

  /// No description provided for @toolsHashModeHex.
  ///
  /// In en, this message translates to:
  /// **'Hex'**
  String get toolsHashModeHex;

  /// No description provided for @toolsHashTextHint.
  ///
  /// In en, this message translates to:
  /// **'Type any text'**
  String get toolsHashTextHint;

  /// No description provided for @toolsHashHexHint.
  ///
  /// In en, this message translates to:
  /// **'Paste bytes in hex'**
  String get toolsHashHexHint;

  /// No description provided for @toolsHashSha256.
  ///
  /// In en, this message translates to:
  /// **'SHA-256'**
  String get toolsHashSha256;

  /// No description provided for @toolsHashDoubleSha256.
  ///
  /// In en, this message translates to:
  /// **'Double SHA-256'**
  String get toolsHashDoubleSha256;

  /// No description provided for @toolsHashHash160.
  ///
  /// In en, this message translates to:
  /// **'HASH160'**
  String get toolsHashHash160;

  /// No description provided for @toolsHashInvalidHex.
  ///
  /// In en, this message translates to:
  /// **'Not valid hex. Use pairs of digits 0-9 and a-f, with no spaces.'**
  String get toolsHashInvalidHex;

  /// No description provided for @toolsHashEmptyHex.
  ///
  /// In en, this message translates to:
  /// **'Enter hex bytes to see their hashes.'**
  String get toolsHashEmptyHex;

  /// No description provided for @toolsHashNote.
  ///
  /// In en, this message translates to:
  /// **'SHA-256 is the hash that proof of work and most Bitcoin identifiers rely on. Double SHA-256 applies it twice, as block headers and transaction ids do. HASH160 is RIPEMD-160 of SHA-256 and gives the 20-byte values inside addresses.'**
  String get toolsHashNote;

  /// No description provided for @toolsAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get toolsAddressTitle;

  /// No description provided for @toolsAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Paste an address'**
  String get toolsAddressHint;

  /// No description provided for @toolsAddressChecksumValid.
  ///
  /// In en, this message translates to:
  /// **'Checksum valid'**
  String get toolsAddressChecksumValid;

  /// No description provided for @toolsAddressChecksumInvalid.
  ///
  /// In en, this message translates to:
  /// **'Checksum not valid'**
  String get toolsAddressChecksumInvalid;

  /// No description provided for @toolsAddressNetworkMainnet.
  ///
  /// In en, this message translates to:
  /// **'Mainnet'**
  String get toolsAddressNetworkMainnet;

  /// No description provided for @toolsAddressNetworkTestnet.
  ///
  /// In en, this message translates to:
  /// **'Testnet'**
  String get toolsAddressNetworkTestnet;

  /// No description provided for @toolsAddressNetworkRegtest.
  ///
  /// In en, this message translates to:
  /// **'Regtest'**
  String get toolsAddressNetworkRegtest;

  /// No description provided for @toolsAddressKindP2pkh.
  ///
  /// In en, this message translates to:
  /// **'P2PKH'**
  String get toolsAddressKindP2pkh;

  /// No description provided for @toolsAddressKindP2sh.
  ///
  /// In en, this message translates to:
  /// **'P2SH'**
  String get toolsAddressKindP2sh;

  /// No description provided for @toolsAddressKindP2wpkh.
  ///
  /// In en, this message translates to:
  /// **'P2WPKH'**
  String get toolsAddressKindP2wpkh;

  /// No description provided for @toolsAddressKindP2wsh.
  ///
  /// In en, this message translates to:
  /// **'P2WSH'**
  String get toolsAddressKindP2wsh;

  /// No description provided for @toolsAddressKindP2tr.
  ///
  /// In en, this message translates to:
  /// **'P2TR (Taproot)'**
  String get toolsAddressKindP2tr;

  /// No description provided for @toolsAddressKindUnknownWitness.
  ///
  /// In en, this message translates to:
  /// **'Unknown witness program'**
  String get toolsAddressKindUnknownWitness;

  /// No description provided for @toolsAddressKindInvalid.
  ///
  /// In en, this message translates to:
  /// **'Not a valid address'**
  String get toolsAddressKindInvalid;

  /// No description provided for @toolsAddressDescP2pkh.
  ///
  /// In en, this message translates to:
  /// **'Pays to the hash of a public key. This is the classic format, used since 2009.'**
  String get toolsAddressDescP2pkh;

  /// No description provided for @toolsAddressDescP2sh.
  ///
  /// In en, this message translates to:
  /// **'Pays to the hash of a script, so the spending conditions stay hidden until they are used.'**
  String get toolsAddressDescP2sh;

  /// No description provided for @toolsAddressDescP2wpkh.
  ///
  /// In en, this message translates to:
  /// **'Pays to the hash of a public key, in the SegWit version 0 format.'**
  String get toolsAddressDescP2wpkh;

  /// No description provided for @toolsAddressDescP2wsh.
  ///
  /// In en, this message translates to:
  /// **'Pays to the hash of a script, in the SegWit version 0 format.'**
  String get toolsAddressDescP2wsh;

  /// No description provided for @toolsAddressDescP2tr.
  ///
  /// In en, this message translates to:
  /// **'Pays to a taproot output key, in the SegWit version 1 format.'**
  String get toolsAddressDescP2tr;

  /// No description provided for @toolsAddressDescUnknownWitness.
  ///
  /// In en, this message translates to:
  /// **'A SegWit address with a witness version or length that this app does not analyse in detail.'**
  String get toolsAddressDescUnknownWitness;

  /// No description provided for @toolsAddressErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Paste an address to check it.'**
  String get toolsAddressErrorEmpty;

  /// No description provided for @toolsAddressErrorBadCharacter.
  ///
  /// In en, this message translates to:
  /// **'A character is not allowed in this encoding.'**
  String get toolsAddressErrorBadCharacter;

  /// No description provided for @toolsAddressErrorBadChecksum.
  ///
  /// In en, this message translates to:
  /// **'The checksum does not match. The text was changed or mistyped.'**
  String get toolsAddressErrorBadChecksum;

  /// No description provided for @toolsAddressErrorBadLength.
  ///
  /// In en, this message translates to:
  /// **'The length is wrong for this type of address.'**
  String get toolsAddressErrorBadLength;

  /// No description provided for @toolsAddressErrorUnknownVersion.
  ///
  /// In en, this message translates to:
  /// **'The version or witness version is not one this app knows.'**
  String get toolsAddressErrorUnknownVersion;

  /// No description provided for @toolsAddressErrorMixedCase.
  ///
  /// In en, this message translates to:
  /// **'Upper and lower case are mixed. Bech32 uses one case only.'**
  String get toolsAddressErrorMixedCase;

  /// No description provided for @toolsAddressErrorWrongVariant.
  ///
  /// In en, this message translates to:
  /// **'The checksum type does not match the witness version.'**
  String get toolsAddressErrorWrongVariant;

  /// No description provided for @toolsAddressErrorMissingSeparator.
  ///
  /// In en, this message translates to:
  /// **'A Bech32 string needs the 1 separator.'**
  String get toolsAddressErrorMissingSeparator;

  /// No description provided for @toolsAddressErrorEmptyHrp.
  ///
  /// In en, this message translates to:
  /// **'The network prefix before the 1 is empty.'**
  String get toolsAddressErrorEmptyHrp;

  /// No description provided for @toolsAddressErrorUnknownHrp.
  ///
  /// In en, this message translates to:
  /// **'The prefix is not bc, tb or bcrt, so this is not a Bitcoin address.'**
  String get toolsAddressErrorUnknownHrp;

  /// No description provided for @toolsAddressErrorEmptyData.
  ///
  /// In en, this message translates to:
  /// **'A SegWit address has no witness data.'**
  String get toolsAddressErrorEmptyData;

  /// No description provided for @toolsAddressErrorInvalidPadding.
  ///
  /// In en, this message translates to:
  /// **'The witness data has invalid padding.'**
  String get toolsAddressErrorInvalidPadding;

  /// No description provided for @toolsAddressSecretWifTitle.
  ///
  /// In en, this message translates to:
  /// **'This looks like a private key'**
  String get toolsAddressSecretWifTitle;

  /// No description provided for @toolsAddressSecretExtendedTitle.
  ///
  /// In en, this message translates to:
  /// **'This looks like an extended key'**
  String get toolsAddressSecretExtendedTitle;

  /// No description provided for @toolsAddressSecretBody.
  ///
  /// In en, this message translates to:
  /// **'Never paste a private key or an extended key into any app or website. The field was cleared and nothing was analysed.'**
  String get toolsAddressSecretBody;

  /// No description provided for @toolsAddressBuiltTitle.
  ///
  /// In en, this message translates to:
  /// **'How it is built'**
  String get toolsAddressBuiltTitle;

  /// No description provided for @toolsPartPrefix.
  ///
  /// In en, this message translates to:
  /// **'Network prefix'**
  String get toolsPartPrefix;

  /// No description provided for @toolsPartSeparator.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get toolsPartSeparator;

  /// No description provided for @toolsPartWitnessVersion.
  ///
  /// In en, this message translates to:
  /// **'Witness version'**
  String get toolsPartWitnessVersion;

  /// No description provided for @toolsPartProgram.
  ///
  /// In en, this message translates to:
  /// **'Program (hash)'**
  String get toolsPartProgram;

  /// No description provided for @toolsPartChecksum.
  ///
  /// In en, this message translates to:
  /// **'Checksum, last 6 characters'**
  String get toolsPartChecksum;

  /// No description provided for @toolsPartVersionByte.
  ///
  /// In en, this message translates to:
  /// **'Version byte'**
  String get toolsPartVersionByte;

  /// No description provided for @toolsPartPayloadHash.
  ///
  /// In en, this message translates to:
  /// **'Payload hash'**
  String get toolsPartPayloadHash;

  /// No description provided for @toolsPartBase58Checksum.
  ///
  /// In en, this message translates to:
  /// **'Checksum, last 4 bytes'**
  String get toolsPartBase58Checksum;

  /// No description provided for @toolsAddressBase58Note.
  ///
  /// In en, this message translates to:
  /// **'Base58 characters do not line up with bytes, so the string is shown without colours. Its parts are listed below.'**
  String get toolsAddressBase58Note;

  /// No description provided for @toolsTxTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get toolsTxTitle;

  /// No description provided for @toolsTxSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get toolsTxSummary;

  /// No description provided for @toolsTxHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a raw transaction in hex'**
  String get toolsTxHint;

  /// No description provided for @toolsTxEmpty.
  ///
  /// In en, this message translates to:
  /// **'Paste a raw transaction to decode it.'**
  String get toolsTxEmpty;

  /// No description provided for @toolsTxLoadExample.
  ///
  /// In en, this message translates to:
  /// **'Load example'**
  String get toolsTxLoadExample;

  /// No description provided for @toolsTxExampleNote.
  ///
  /// In en, this message translates to:
  /// **'Example: the genesis coinbase transaction, from block 0.'**
  String get toolsTxExampleNote;

  /// No description provided for @toolsTxTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a field with an arrow to read its wiki entry.'**
  String get toolsTxTapHint;

  /// No description provided for @toolsTxTxid.
  ///
  /// In en, this message translates to:
  /// **'txid'**
  String get toolsTxTxid;

  /// No description provided for @toolsTxWtxid.
  ///
  /// In en, this message translates to:
  /// **'wtxid'**
  String get toolsTxWtxid;

  /// No description provided for @toolsTxType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get toolsTxType;

  /// No description provided for @toolsTxTypeCoinbase.
  ///
  /// In en, this message translates to:
  /// **'Coinbase'**
  String get toolsTxTypeCoinbase;

  /// No description provided for @toolsTxTypeRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get toolsTxTypeRegular;

  /// No description provided for @toolsTxFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get toolsTxFormat;

  /// No description provided for @toolsTxFormatSegwit.
  ///
  /// In en, this message translates to:
  /// **'SegWit'**
  String get toolsTxFormatSegwit;

  /// No description provided for @toolsTxFormatLegacy.
  ///
  /// In en, this message translates to:
  /// **'Legacy'**
  String get toolsTxFormatLegacy;

  /// No description provided for @toolsTxSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get toolsTxSize;

  /// No description provided for @toolsTxWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get toolsTxWeight;

  /// No description provided for @toolsTxVsize.
  ///
  /// In en, this message translates to:
  /// **'Virtual size'**
  String get toolsTxVsize;

  /// No description provided for @toolsTxBytes.
  ///
  /// In en, this message translates to:
  /// **'{count} bytes'**
  String toolsTxBytes(int count);

  /// No description provided for @toolsTxWeightUnits.
  ///
  /// In en, this message translates to:
  /// **'{count} WU'**
  String toolsTxWeightUnits(int count);

  /// No description provided for @toolsTxVbytes.
  ///
  /// In en, this message translates to:
  /// **'{count} vB'**
  String toolsTxVbytes(int count);

  /// No description provided for @toolsTxFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get toolsTxFieldsTitle;

  /// No description provided for @toolsTxHexTitle.
  ///
  /// In en, this message translates to:
  /// **'Serialized hex'**
  String get toolsTxHexTitle;

  /// No description provided for @toolsTxInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Input {index}'**
  String toolsTxInputLabel(int index);

  /// No description provided for @toolsTxOutputLabel.
  ///
  /// In en, this message translates to:
  /// **'Output {index}'**
  String toolsTxOutputLabel(int index);

  /// No description provided for @toolsTxWitnessLabel.
  ///
  /// In en, this message translates to:
  /// **'Input {index}, witness item {item}'**
  String toolsTxWitnessLabel(int index, int item);

  /// No description provided for @toolsTxCoinbaseTag.
  ///
  /// In en, this message translates to:
  /// **'coinbase'**
  String get toolsTxCoinbaseTag;

  /// No description provided for @toolsTxValueBoth.
  ///
  /// In en, this message translates to:
  /// **'{btc} BTC · {sat} sat'**
  String toolsTxValueBoth(String btc, String sat);

  /// No description provided for @toolsTxHiddenFields.
  ///
  /// In en, this message translates to:
  /// **'{count} more fields are not shown.'**
  String toolsTxHiddenFields(int count);

  /// No description provided for @toolsTxErrorNotHex.
  ///
  /// In en, this message translates to:
  /// **'The input is empty, has an odd number of digits, or is not hexadecimal.'**
  String get toolsTxErrorNotHex;

  /// No description provided for @toolsTxErrorTruncated.
  ///
  /// In en, this message translates to:
  /// **'The data ends before a field is complete. The transaction may be cut short.'**
  String get toolsTxErrorTruncated;

  /// No description provided for @toolsTxErrorTrailing.
  ///
  /// In en, this message translates to:
  /// **'There are bytes after the last field. Check that the transaction is complete and has nothing extra.'**
  String get toolsTxErrorTrailing;

  /// No description provided for @toolsTxErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The transaction is larger than 400000 bytes, the limit of this tool.'**
  String get toolsTxErrorTooLarge;

  /// No description provided for @toolsTxErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'A value is outside what a transaction can hold, or the segwit flag is unknown.'**
  String get toolsTxErrorInvalid;

  /// No description provided for @toolsFieldVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get toolsFieldVersion;

  /// No description provided for @toolsFieldMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get toolsFieldMarker;

  /// No description provided for @toolsFieldFlag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get toolsFieldFlag;

  /// No description provided for @toolsFieldInputCount.
  ///
  /// In en, this message translates to:
  /// **'Input count'**
  String get toolsFieldInputCount;

  /// No description provided for @toolsFieldPreviousTxid.
  ///
  /// In en, this message translates to:
  /// **'Previous txid'**
  String get toolsFieldPreviousTxid;

  /// No description provided for @toolsFieldPreviousIndex.
  ///
  /// In en, this message translates to:
  /// **'Previous output index'**
  String get toolsFieldPreviousIndex;

  /// No description provided for @toolsFieldScriptSigLength.
  ///
  /// In en, this message translates to:
  /// **'scriptSig length'**
  String get toolsFieldScriptSigLength;

  /// No description provided for @toolsFieldScriptSig.
  ///
  /// In en, this message translates to:
  /// **'scriptSig'**
  String get toolsFieldScriptSig;

  /// No description provided for @toolsFieldSequence.
  ///
  /// In en, this message translates to:
  /// **'Sequence'**
  String get toolsFieldSequence;

  /// No description provided for @toolsFieldOutputCount.
  ///
  /// In en, this message translates to:
  /// **'Output count'**
  String get toolsFieldOutputCount;

  /// No description provided for @toolsFieldValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get toolsFieldValue;

  /// No description provided for @toolsFieldScriptPubKeyLength.
  ///
  /// In en, this message translates to:
  /// **'scriptPubKey length'**
  String get toolsFieldScriptPubKeyLength;

  /// No description provided for @toolsFieldScriptPubKey.
  ///
  /// In en, this message translates to:
  /// **'scriptPubKey'**
  String get toolsFieldScriptPubKey;

  /// No description provided for @toolsFieldWitnessItemCount.
  ///
  /// In en, this message translates to:
  /// **'Witness item count'**
  String get toolsFieldWitnessItemCount;

  /// No description provided for @toolsFieldWitnessItemLength.
  ///
  /// In en, this message translates to:
  /// **'Witness item length'**
  String get toolsFieldWitnessItemLength;

  /// No description provided for @toolsFieldWitnessItem.
  ///
  /// In en, this message translates to:
  /// **'Witness item'**
  String get toolsFieldWitnessItem;

  /// No description provided for @toolsFieldLockTime.
  ///
  /// In en, this message translates to:
  /// **'Lock time'**
  String get toolsFieldLockTime;

  /// No description provided for @toolsScriptP2pk.
  ///
  /// In en, this message translates to:
  /// **'P2PK'**
  String get toolsScriptP2pk;

  /// No description provided for @toolsScriptP2pkh.
  ///
  /// In en, this message translates to:
  /// **'P2PKH'**
  String get toolsScriptP2pkh;

  /// No description provided for @toolsScriptP2sh.
  ///
  /// In en, this message translates to:
  /// **'P2SH'**
  String get toolsScriptP2sh;

  /// No description provided for @toolsScriptP2wpkh.
  ///
  /// In en, this message translates to:
  /// **'P2WPKH'**
  String get toolsScriptP2wpkh;

  /// No description provided for @toolsScriptP2wsh.
  ///
  /// In en, this message translates to:
  /// **'P2WSH'**
  String get toolsScriptP2wsh;

  /// No description provided for @toolsScriptP2tr.
  ///
  /// In en, this message translates to:
  /// **'P2TR'**
  String get toolsScriptP2tr;

  /// No description provided for @toolsScriptWitnessUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown witness program'**
  String get toolsScriptWitnessUnknown;

  /// No description provided for @toolsScriptBareMultisig.
  ///
  /// In en, this message translates to:
  /// **'Bare multisig'**
  String get toolsScriptBareMultisig;

  /// No description provided for @toolsScriptOpReturn.
  ///
  /// In en, this message translates to:
  /// **'OP_RETURN data'**
  String get toolsScriptOpReturn;

  /// No description provided for @toolsScriptNonStandard.
  ///
  /// In en, this message translates to:
  /// **'Non-standard'**
  String get toolsScriptNonStandard;

  /// No description provided for @toolsTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get toolsTargetTitle;

  /// No description provided for @toolsTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Bits, 8 hex digits, for example 1d00ffff'**
  String get toolsTargetHint;

  /// No description provided for @toolsTargetInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter exactly 8 hex digits, with an optional 0x prefix.'**
  String get toolsTargetInvalid;

  /// No description provided for @toolsTargetTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get toolsTargetTargetLabel;

  /// No description provided for @toolsTargetDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get toolsTargetDifficulty;

  /// No description provided for @toolsTargetExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected hashes per block'**
  String get toolsTargetExpected;

  /// No description provided for @toolsTargetScientific.
  ///
  /// In en, this message translates to:
  /// **'About {mantissa} × 10^{exponent}'**
  String toolsTargetScientific(String mantissa, int exponent);

  /// No description provided for @toolsTargetNote.
  ///
  /// In en, this message translates to:
  /// **'The target is the number a block hash must stay below. Difficulty compares it with the maximum target, 1d00ffff. Expected hashes is the average number of attempts needed to find a valid block.'**
  String get toolsTargetNote;

  /// No description provided for @toolsUnitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get toolsUnitsTitle;

  /// No description provided for @toolsUnitsBtcSatTitle.
  ///
  /// In en, this message translates to:
  /// **'BTC and satoshi'**
  String get toolsUnitsBtcSatTitle;

  /// No description provided for @toolsUnitsBtcLabel.
  ///
  /// In en, this message translates to:
  /// **'BTC'**
  String get toolsUnitsBtcLabel;

  /// No description provided for @toolsUnitsSatLabel.
  ///
  /// In en, this message translates to:
  /// **'Satoshi'**
  String get toolsUnitsSatLabel;

  /// No description provided for @toolsUnitsDecimalsError.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin amounts have at most 8 decimals.'**
  String get toolsUnitsDecimalsError;

  /// No description provided for @toolsUnitsInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a decimal amount, for example 0.001.'**
  String get toolsUnitsInvalidAmount;

  /// No description provided for @toolsUnitsInvalidWhole.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number, zero or more.'**
  String get toolsUnitsInvalidWhole;

  /// No description provided for @toolsUnitsWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight units to virtual bytes'**
  String get toolsUnitsWeightTitle;

  /// No description provided for @toolsUnitsWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight units (WU)'**
  String get toolsUnitsWeightLabel;

  /// No description provided for @toolsUnitsVbytesResult.
  ///
  /// In en, this message translates to:
  /// **'{vbytes} vB'**
  String toolsUnitsVbytesResult(int vbytes);

  /// No description provided for @toolsUnitsRateFromFeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Fee rate from fee'**
  String get toolsUnitsRateFromFeeTitle;

  /// No description provided for @toolsUnitsFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee (satoshi)'**
  String get toolsUnitsFeeLabel;

  /// No description provided for @toolsUnitsVsizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Virtual size (vB)'**
  String get toolsUnitsVsizeLabel;

  /// No description provided for @toolsUnitsRateResult.
  ///
  /// In en, this message translates to:
  /// **'{rate} sat/vB'**
  String toolsUnitsRateResult(String rate);

  /// No description provided for @toolsUnitsFeeFromRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Fee from fee rate'**
  String get toolsUnitsFeeFromRateTitle;

  /// No description provided for @toolsUnitsRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee rate (sat/vB)'**
  String get toolsUnitsRateLabel;

  /// No description provided for @toolsUnitsFeeResult.
  ///
  /// In en, this message translates to:
  /// **'{sat} sat'**
  String toolsUnitsFeeResult(int sat);

  /// No description provided for @toolsUnitsRateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a fee rate of zero or more, for example 2.5.'**
  String get toolsUnitsRateInvalid;

  /// No description provided for @toolsUnitsVsizePositive.
  ///
  /// In en, this message translates to:
  /// **'Virtual size must be more than zero.'**
  String get toolsUnitsVsizePositive;

  /// No description provided for @toolsUnitsResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get toolsUnitsResult;

  /// No description provided for @toolsUnitsNote.
  ///
  /// In en, this message translates to:
  /// **'Only units, no prices or fiat. Bitcoin amounts use integer math, so nothing is rounded.'**
  String get toolsUnitsNote;

  /// No description provided for @toolsReferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reference tables'**
  String get toolsReferencesTitle;

  /// No description provided for @toolsReferencesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reference tables yet.'**
  String get toolsReferencesEmpty;

  /// No description provided for @toolsRowCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row} other{{count} rows}}'**
  String toolsRowCount(int count);

  /// No description provided for @toolsReferenceFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter rows'**
  String get toolsReferenceFilterHint;

  /// No description provided for @toolsReferenceNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No rows match this filter.'**
  String get toolsReferenceNoMatch;
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
