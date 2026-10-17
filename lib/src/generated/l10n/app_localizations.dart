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
  /// **'Seven steps: hash, block, chain, network, transactions, coinbase, a real header.'**
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

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No works in the library yet.'**
  String get libraryEmpty;

  /// No description provided for @libraryNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No works match this filter.'**
  String get libraryNoMatch;

  /// No description provided for @libraryAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get libraryAuthorLabel;

  /// No description provided for @libraryTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get libraryTopicLabel;

  /// No description provided for @libraryYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get libraryYearLabel;

  /// No description provided for @libraryKindLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get libraryKindLabel;

  /// No description provided for @libraryOriginalLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Original language'**
  String get libraryOriginalLanguageLabel;

  /// No description provided for @libraryLicenseLabel.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get libraryLicenseLabel;

  /// No description provided for @libraryKindPaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get libraryKindPaper;

  /// No description provided for @libraryKindEssay.
  ///
  /// In en, this message translates to:
  /// **'Essay'**
  String get libraryKindEssay;

  /// No description provided for @libraryKindPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get libraryKindPost;

  /// No description provided for @libraryKindEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get libraryKindEmail;

  /// No description provided for @libraryKindBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get libraryKindBook;

  /// No description provided for @libraryKindManifesto.
  ///
  /// In en, this message translates to:
  /// **'Manifesto'**
  String get libraryKindManifesto;

  /// No description provided for @libraryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Work not found'**
  String get libraryNotFound;

  /// No description provided for @libraryReadOriginal.
  ///
  /// In en, this message translates to:
  /// **'Read the original'**
  String get libraryReadOriginal;

  /// No description provided for @libraryArchivedCopy.
  ///
  /// In en, this message translates to:
  /// **'Archived copy'**
  String get libraryArchivedCopy;

  /// No description provided for @libraryIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Our introduction'**
  String get libraryIntroduction;

  /// No description provided for @libraryNotice.
  ///
  /// In en, this message translates to:
  /// **'SatoWiki does not host the full text. The original opens in your browser.'**
  String get libraryNotice;

  /// No description provided for @librarySearchTypeGlossary.
  ///
  /// In en, this message translates to:
  /// **'Glossary'**
  String get librarySearchTypeGlossary;

  /// No description provided for @librarySearchTypeProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get librarySearchTypeProduct;

  /// No description provided for @librarySearchTypeReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get librarySearchTypeReference;

  /// No description provided for @librarySearchTypeLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get librarySearchTypeLibrary;

  /// No description provided for @connectTryIt.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get connectTryIt;

  /// No description provided for @connectQuotesTitle.
  ///
  /// In en, this message translates to:
  /// **'In their words'**
  String get connectQuotesTitle;

  /// No description provided for @connectLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get connectLibraryTitle;

  /// No description provided for @connectLibraryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 work} other{{count} works}}'**
  String connectLibraryCount(int count);

  /// No description provided for @connectHashTitle.
  ///
  /// In en, this message translates to:
  /// **'Hash tool'**
  String get connectHashTitle;

  /// No description provided for @connectHashCaption.
  ///
  /// In en, this message translates to:
  /// **'Compute SHA-256 and HASH160 of any text'**
  String get connectHashCaption;

  /// No description provided for @connectAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Address tool'**
  String get connectAddressTitle;

  /// No description provided for @connectAddressCaption.
  ///
  /// In en, this message translates to:
  /// **'Check the type and checksum of an address'**
  String get connectAddressCaption;

  /// No description provided for @connectTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction tool'**
  String get connectTransactionTitle;

  /// No description provided for @connectTransactionCaption.
  ///
  /// In en, this message translates to:
  /// **'Decode a raw transaction field by field'**
  String get connectTransactionCaption;

  /// No description provided for @connectTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Target tool'**
  String get connectTargetTitle;

  /// No description provided for @connectTargetCaption.
  ///
  /// In en, this message translates to:
  /// **'Convert bits, target and difficulty'**
  String get connectTargetCaption;

  /// No description provided for @connectUnitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Units tool'**
  String get connectUnitsTitle;

  /// No description provided for @connectUnitsCaption.
  ///
  /// In en, this message translates to:
  /// **'Convert sat, BTC and vB'**
  String get connectUnitsCaption;

  /// No description provided for @connectScriptTitle.
  ///
  /// In en, this message translates to:
  /// **'Script step by step'**
  String get connectScriptTitle;

  /// No description provided for @connectScriptCaption.
  ///
  /// In en, this message translates to:
  /// **'See the stack after each opcode'**
  String get connectScriptCaption;

  /// No description provided for @connectLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Blockchain lab'**
  String get connectLabTitle;

  /// No description provided for @connectLabCaption.
  ///
  /// In en, this message translates to:
  /// **'Build and break a small blockchain, step by step'**
  String get connectLabCaption;

  /// No description provided for @connectLabStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Blockchain lab, step {step}'**
  String connectLabStepTitle(int step);

  /// No description provided for @connectLabStep1Caption.
  ///
  /// In en, this message translates to:
  /// **'Type text and watch its hash change'**
  String get connectLabStep1Caption;

  /// No description provided for @connectLabStep2Caption.
  ///
  /// In en, this message translates to:
  /// **'Mine a block: find a nonce that makes it valid'**
  String get connectLabStep2Caption;

  /// No description provided for @connectLabStep3Caption.
  ///
  /// In en, this message translates to:
  /// **'Change one block and see the next ones break'**
  String get connectLabStep3Caption;

  /// No description provided for @connectLabStep6Caption.
  ///
  /// In en, this message translates to:
  /// **'Inspect the coinbase transaction that pays the miner'**
  String get connectLabStep6Caption;

  /// No description provided for @connectLabStep7Caption.
  ///
  /// In en, this message translates to:
  /// **'Read the 80-byte header that every block contains'**
  String get connectLabStep7Caption;

  /// No description provided for @explorerTitle.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get explorerTitle;

  /// No description provided for @explorerStateOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get explorerStateOn;

  /// No description provided for @explorerStateOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get explorerStateOff;

  /// No description provided for @explorerStateOnServer.
  ///
  /// In en, this message translates to:
  /// **'On · {host}'**
  String explorerStateOnServer(String host);

  /// No description provided for @explorerSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you turn it on'**
  String get explorerSetupTitle;

  /// No description provided for @explorerSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'The explorer asks a server on the internet for data. The rest of the app works without a network.'**
  String get explorerSetupIntro;

  /// No description provided for @explorerSetupWhatServerSees.
  ///
  /// In en, this message translates to:
  /// **'Every search is sent to the server shown below. The server operator can see your IP address and what you search.'**
  String get explorerSetupWhatServerSees;

  /// No description provided for @explorerSetupOwnAddresses.
  ///
  /// In en, this message translates to:
  /// **'If you look up your own addresses, the server can link them to your IP address.'**
  String get explorerSetupOwnAddresses;

  /// No description provided for @explorerSetupNothingSent.
  ///
  /// In en, this message translates to:
  /// **'When the explorer screen is open, it asks the server for blocks, fees and the mempool every 60 seconds. Searches are sent only when you press Search and are not saved on this device. The explorer does not use Tor or any proxy.'**
  String get explorerSetupNothingSent;

  /// No description provided for @explorerServerLabel.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get explorerServerLabel;

  /// No description provided for @explorerServerField.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get explorerServerField;

  /// No description provided for @explorerServerHelp.
  ///
  /// In en, this message translates to:
  /// **'Use https. Plain http works only for localhost, .onion and .local addresses.'**
  String get explorerServerHelp;

  /// No description provided for @explorerServerInvalid.
  ///
  /// In en, this message translates to:
  /// **'This address is not allowed. Use https, or http only for localhost, .onion or .local. It was not saved.'**
  String get explorerServerInvalid;

  /// No description provided for @explorerTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on the explorer'**
  String get explorerTurnOn;

  /// No description provided for @explorerTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off the explorer'**
  String get explorerTurnOff;

  /// Short header action. The full label is the tooltip.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get explorerTurnOffShort;

  /// No description provided for @explorerTurnOffNote.
  ///
  /// In en, this message translates to:
  /// **'You can turn it on again from Settings.'**
  String get explorerTurnOffNote;

  /// No description provided for @explorerSaveServer.
  ///
  /// In en, this message translates to:
  /// **'Save server'**
  String get explorerSaveServer;

  /// No description provided for @explorerServerSaved.
  ///
  /// In en, this message translates to:
  /// **'Server saved.'**
  String get explorerServerSaved;

  /// No description provided for @explorerOffTitle.
  ///
  /// In en, this message translates to:
  /// **'The explorer is off'**
  String get explorerOffTitle;

  /// No description provided for @explorerOffBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sent to any server while it is off.'**
  String get explorerOffBody;

  /// No description provided for @explorerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Height, block hash, txid or address'**
  String get explorerSearchHint;

  /// No description provided for @explorerSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get explorerSearchButton;

  /// No description provided for @explorerSecretWifTitle.
  ///
  /// In en, this message translates to:
  /// **'This looks like a private key'**
  String get explorerSecretWifTitle;

  /// No description provided for @explorerSecretExtendedTitle.
  ///
  /// In en, this message translates to:
  /// **'This looks like an extended key'**
  String get explorerSecretExtendedTitle;

  /// No description provided for @explorerSecretBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing was sent. The field was cleared. Never paste a private key into any app or website.'**
  String get explorerSecretBody;

  /// No description provided for @explorerInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Enter a block height, a 64-character hash or txid, or an address.'**
  String get explorerInvalidInput;

  /// No description provided for @explorerLookingUp.
  ///
  /// In en, this message translates to:
  /// **'Looking up…'**
  String get explorerLookingUp;

  /// No description provided for @explorerNotFound.
  ///
  /// In en, this message translates to:
  /// **'The server does not know this block, transaction or address.'**
  String get explorerNotFound;

  /// No description provided for @explorerNetworkError.
  ///
  /// In en, this message translates to:
  /// **'The server could not be reached. Check the connection and try again.'**
  String get explorerNetworkError;

  /// No description provided for @explorerBadResponse.
  ///
  /// In en, this message translates to:
  /// **'The server sent an answer the explorer cannot read.'**
  String get explorerBadResponse;

  /// No description provided for @explorerRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. The server asked to slow down. {seconds, plural, =1{Try again in 1 second.} other{Try again in {seconds} seconds.}}'**
  String explorerRateLimited(int seconds);

  /// No description provided for @explorerNoAutoRetry.
  ///
  /// In en, this message translates to:
  /// **'The explorer does not retry on its own.'**
  String get explorerNoAutoRetry;

  /// No description provided for @explorerRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get explorerRetry;

  /// No description provided for @explorerBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get explorerBlockTitle;

  /// No description provided for @explorerTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get explorerTransactionTitle;

  /// No description provided for @explorerAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get explorerAddressTitle;

  /// No description provided for @explorerHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get explorerHeight;

  /// No description provided for @explorerHash.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get explorerHash;

  /// No description provided for @explorerTxid.
  ///
  /// In en, this message translates to:
  /// **'Txid'**
  String get explorerTxid;

  /// No description provided for @explorerTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get explorerTime;

  /// No description provided for @explorerTransactionCount.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get explorerTransactionCount;

  /// No description provided for @explorerSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get explorerSize;

  /// No description provided for @explorerWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get explorerWeight;

  /// No description provided for @explorerMerkleRoot.
  ///
  /// In en, this message translates to:
  /// **'Merkle root'**
  String get explorerMerkleRoot;

  /// No description provided for @explorerPreviousBlock.
  ///
  /// In en, this message translates to:
  /// **'Previous block'**
  String get explorerPreviousBlock;

  /// No description provided for @explorerNonce.
  ///
  /// In en, this message translates to:
  /// **'Nonce'**
  String get explorerNonce;

  /// No description provided for @explorerBits.
  ///
  /// In en, this message translates to:
  /// **'Bits'**
  String get explorerBits;

  /// No description provided for @explorerDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get explorerDifficulty;

  /// No description provided for @explorerVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get explorerVersion;

  /// No description provided for @explorerStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get explorerStatus;

  /// No description provided for @explorerConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get explorerConfirmed;

  /// No description provided for @explorerUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed'**
  String get explorerUnconfirmed;

  /// No description provided for @explorerBlockOfTransaction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get explorerBlockOfTransaction;

  /// No description provided for @explorerFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get explorerFee;

  /// No description provided for @explorerFeeRate.
  ///
  /// In en, this message translates to:
  /// **'Fee rate'**
  String get explorerFeeRate;

  /// No description provided for @explorerFeeRateValue.
  ///
  /// In en, this message translates to:
  /// **'{rate} sat/vB'**
  String explorerFeeRateValue(String rate);

  /// No description provided for @explorerInputs.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get explorerInputs;

  /// No description provided for @explorerOutputs.
  ///
  /// In en, this message translates to:
  /// **'Outputs'**
  String get explorerOutputs;

  /// No description provided for @explorerInputNumber.
  ///
  /// In en, this message translates to:
  /// **'Input {index}'**
  String explorerInputNumber(int index);

  /// No description provided for @explorerOutputNumber.
  ///
  /// In en, this message translates to:
  /// **'Output {index}'**
  String explorerOutputNumber(int index);

  /// No description provided for @explorerCoinbase.
  ///
  /// In en, this message translates to:
  /// **'Coinbase, no previous output'**
  String get explorerCoinbase;

  /// No description provided for @explorerAmount.
  ///
  /// In en, this message translates to:
  /// **'{btc} BTC · {sat} sat'**
  String explorerAmount(String btc, String sat);

  /// No description provided for @explorerScriptType.
  ///
  /// In en, this message translates to:
  /// **'Script type'**
  String get explorerScriptType;

  /// No description provided for @explorerBlockUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not yet in a block'**
  String get explorerBlockUnknown;

  /// No description provided for @explorerAddressReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get explorerAddressReceived;

  /// No description provided for @explorerAddressSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get explorerAddressSpent;

  /// No description provided for @explorerAddressBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get explorerAddressBalance;

  /// No description provided for @explorerAddressMempool.
  ///
  /// In en, this message translates to:
  /// **'Mempool'**
  String get explorerAddressMempool;

  /// No description provided for @explorerAddressTransactions.
  ///
  /// In en, this message translates to:
  /// **'Latest transactions'**
  String get explorerAddressTransactions;

  /// No description provided for @explorerAddressFirstPage.
  ///
  /// In en, this message translates to:
  /// **'Only the first page from the server is shown.'**
  String get explorerAddressFirstPage;

  /// No description provided for @explorerNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found for this address.'**
  String get explorerNoTransactions;

  /// No description provided for @explorerLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get explorerLoading;

  /// No description provided for @explorerDashLive.
  ///
  /// In en, this message translates to:
  /// **'Live · {host}'**
  String explorerDashLive(String host);

  /// No description provided for @explorerDashLivePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused · {host}'**
  String explorerDashLivePaused(String host);

  /// No description provided for @explorerDashBlocks.
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get explorerDashBlocks;

  /// No description provided for @explorerDashBlocksHint.
  ///
  /// In en, this message translates to:
  /// **'Queued ← · → confirmed'**
  String get explorerDashBlocksHint;

  /// No description provided for @explorerDashNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get explorerDashNow;

  /// No description provided for @explorerDashNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get explorerDashNext;

  /// No description provided for @explorerDashQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get explorerDashQueued;

  /// No description provided for @explorerDashMinutes.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String explorerDashMinutes(int minutes);

  /// No description provided for @explorerDashMoreBlocks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 block} other{+{count} blocks}}'**
  String explorerDashMoreBlocks(int count);

  /// No description provided for @explorerDashBlockAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min fa'**
  String explorerDashBlockAgo(int minutes);

  /// No description provided for @explorerDashMedianRate.
  ///
  /// In en, this message translates to:
  /// **'~{rate} sat/vB'**
  String explorerDashMedianRate(String rate);

  /// No description provided for @explorerDashRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} sat/vB'**
  String explorerDashRange(String min, String max);

  /// No description provided for @explorerDashBtc.
  ///
  /// In en, this message translates to:
  /// **'{btc} BTC'**
  String explorerDashBtc(String btc);

  /// No description provided for @explorerDashTxCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tx'**
  String explorerDashTxCount(String count);

  /// No description provided for @explorerDashSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String explorerDashSizeMb(String size);

  /// No description provided for @explorerDashWeightMwu.
  ///
  /// In en, this message translates to:
  /// **'{weight} MWU'**
  String explorerDashWeightMwu(String weight);

  /// No description provided for @explorerDashFeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended fees'**
  String get explorerDashFeesTitle;

  /// No description provided for @explorerDashFeeNoPriority.
  ///
  /// In en, this message translates to:
  /// **'No priority'**
  String get explorerDashFeeNoPriority;

  /// No description provided for @explorerDashFeeLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get explorerDashFeeLow;

  /// No description provided for @explorerDashFeeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get explorerDashFeeMedium;

  /// No description provided for @explorerDashFeeHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get explorerDashFeeHigh;

  /// No description provided for @explorerDashFeeDay.
  ///
  /// In en, this message translates to:
  /// **'~1 day'**
  String get explorerDashFeeDay;

  /// No description provided for @explorerDashFeeHour.
  ///
  /// In en, this message translates to:
  /// **'~1 hour'**
  String get explorerDashFeeHour;

  /// No description provided for @explorerDashTypicalTx.
  ///
  /// In en, this message translates to:
  /// **'Typical 140 vB transaction at high priority: ~{sats} sat'**
  String explorerDashTypicalTx(String sats);

  /// No description provided for @explorerDashMempoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Mempool'**
  String get explorerDashMempoolTitle;

  /// No description provided for @explorerDashBandsLabel.
  ///
  /// In en, this message translates to:
  /// **'Share of vbytes by fee rate: {bands}'**
  String explorerDashBandsLabel(String bands);

  /// No description provided for @explorerDashVsizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} vMB'**
  String explorerDashVsizeMb(String size);

  /// No description provided for @explorerDashTotalFees.
  ///
  /// In en, this message translates to:
  /// **'Total fees'**
  String get explorerDashTotalFees;

  /// No description provided for @explorerDashToClear.
  ///
  /// In en, this message translates to:
  /// **'To clear'**
  String get explorerDashToClear;

  /// No description provided for @explorerDashBlocksToClear.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{~1 block} other{~{count} blocks}}'**
  String explorerDashBlocksToClear(int count);

  /// No description provided for @explorerDashEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get explorerDashEstimate;

  /// No description provided for @explorerDashEpoch.
  ///
  /// In en, this message translates to:
  /// **'Epoch'**
  String get explorerDashEpoch;

  /// No description provided for @explorerDashEpochProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} blocks in this epoch'**
  String explorerDashEpochProgress(String done, String total);

  /// No description provided for @explorerDashRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get explorerDashRemaining;

  /// No description provided for @explorerDashRemainingDays.
  ///
  /// In en, this message translates to:
  /// **'{blocks} · ~{days} d'**
  String explorerDashRemainingDays(String blocks, String days);

  /// No description provided for @explorerDashRemainingHours.
  ///
  /// In en, this message translates to:
  /// **'{blocks} · ~{hours} h'**
  String explorerDashRemainingHours(String blocks, String hours);

  /// No description provided for @explorerDashAverageBlock.
  ///
  /// In en, this message translates to:
  /// **'Average block'**
  String get explorerDashAverageBlock;

  /// No description provided for @explorerDashLatestTxs.
  ///
  /// In en, this message translates to:
  /// **'Latest transactions'**
  String get explorerDashLatestTxs;

  /// No description provided for @explorerDashTxVsize.
  ///
  /// In en, this message translates to:
  /// **'{vsize} vB'**
  String explorerDashTxVsize(String vsize);

  /// No description provided for @explorerDashFooterUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated at {time} · every {interval} s while open'**
  String explorerDashFooterUpdated(String time, int interval);

  /// No description provided for @explorerDashPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get explorerDashPaused;

  /// No description provided for @explorerDashUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'The last update failed. The data shown is from before.'**
  String get explorerDashUpdateFailed;

  /// No description provided for @explorerDashPause.
  ///
  /// In en, this message translates to:
  /// **'Pause updates'**
  String get explorerDashPause;

  /// No description provided for @explorerDashResume.
  ///
  /// In en, this message translates to:
  /// **'Resume updates'**
  String get explorerDashResume;

  /// No description provided for @explorerDashPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Each refresh sends 4 requests to {host}. The server sees your IP address. Searches are not saved.'**
  String explorerDashPrivacy(String host);

  /// No description provided for @labTitle.
  ///
  /// In en, this message translates to:
  /// **'Blockchain lab'**
  String get labTitle;

  /// No description provided for @labIntro.
  ///
  /// In en, this message translates to:
  /// **'A small blockchain you can change and repair, one idea at a time. The blocks here are a teaching model, not the real protocol.'**
  String get labIntro;

  /// No description provided for @labIndexSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get labIndexSteps;

  /// No description provided for @labStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String labStepCounter(int current, int total);

  /// No description provided for @labStepOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get labStepOptional;

  /// No description provided for @labStepTitle1.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get labStepTitle1;

  /// No description provided for @labStepDesc1.
  ///
  /// In en, this message translates to:
  /// **'Type text and watch its fingerprint change.'**
  String get labStepDesc1;

  /// No description provided for @labStepTitle2.
  ///
  /// In en, this message translates to:
  /// **'Mine a block'**
  String get labStepTitle2;

  /// No description provided for @labStepDesc2.
  ///
  /// In en, this message translates to:
  /// **'Change the data, then search for a nonce that makes the hash start with zeros.'**
  String get labStepDesc2;

  /// No description provided for @labStepTitle3.
  ///
  /// In en, this message translates to:
  /// **'Chain'**
  String get labStepTitle3;

  /// No description provided for @labStepDesc3.
  ///
  /// In en, this message translates to:
  /// **'Change one block and see every block after it break.'**
  String get labStepDesc3;

  /// No description provided for @labStepTitle4.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get labStepTitle4;

  /// No description provided for @labStepDesc4.
  ///
  /// In en, this message translates to:
  /// **'Several copies of the chain. A node keeps only a valid one.'**
  String get labStepDesc4;

  /// No description provided for @labStepTitle5.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get labStepTitle5;

  /// No description provided for @labStepDesc5.
  ///
  /// In en, this message translates to:
  /// **'Turn transfers into the data of a block.'**
  String get labStepDesc5;

  /// No description provided for @labStepTitle6.
  ///
  /// In en, this message translates to:
  /// **'Coinbase'**
  String get labStepTitle6;

  /// No description provided for @labStepDesc6.
  ///
  /// In en, this message translates to:
  /// **'The first transaction of a block pays the miner.'**
  String get labStepDesc6;

  /// No description provided for @labStepTitle7.
  ///
  /// In en, this message translates to:
  /// **'A real header'**
  String get labStepTitle7;

  /// No description provided for @labStepDesc7.
  ///
  /// In en, this message translates to:
  /// **'Decode the 80 bytes of the genesis block and hash them.'**
  String get labStepDesc7;

  /// No description provided for @labDifference.
  ///
  /// In en, this message translates to:
  /// **'In Bitcoin it is different'**
  String get labDifference;

  /// No description provided for @labDiff1.
  ///
  /// In en, this message translates to:
  /// **'A real block hash is SHA-256 applied twice to an 80-byte header, not to a line of text.'**
  String get labDiff1;

  /// No description provided for @labDiff2.
  ///
  /// In en, this message translates to:
  /// **'The header is 80 bytes, the hash is double SHA-256, and the rule is a numeric target, not a count of zeros.'**
  String get labDiff2;

  /// No description provided for @labDiff3.
  ///
  /// In en, this message translates to:
  /// **'Real nodes follow the chain with the most accumulated work, not a rule that counts zeros. Each block is checked against the target in its header.'**
  String get labDiff3;

  /// No description provided for @labDiff4.
  ///
  /// In en, this message translates to:
  /// **'Real nodes also check every transaction and signature, and relay blocks to peers. This lab checks only the blocks, on this device.'**
  String get labDiff4;

  /// No description provided for @labDiff5.
  ///
  /// In en, this message translates to:
  /// **'Real transactions spend earlier outputs, and each input carries a signature. Here a transfer is only a line of text.'**
  String get labDiff5;

  /// No description provided for @labDiff6.
  ///
  /// In en, this message translates to:
  /// **'The subsidy halves every 210,000 blocks, about every four years, and coinbase outputs cannot be spent for 100 blocks.'**
  String get labDiff6;

  /// No description provided for @labDiff7.
  ///
  /// In en, this message translates to:
  /// **'This is the real header format. The target comes from bits, and the hash is double SHA-256 of these 80 bytes.'**
  String get labDiff7;

  /// No description provided for @labPreviousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get labPreviousStep;

  /// No description provided for @labNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get labNextStep;

  /// No description provided for @labValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get labValid;

  /// No description provided for @labNotValid.
  ///
  /// In en, this message translates to:
  /// **'Not valid'**
  String get labNotValid;

  /// No description provided for @labBlockNumber.
  ///
  /// In en, this message translates to:
  /// **'Block {number}'**
  String labBlockNumber(int number);

  /// No description provided for @labHashHint.
  ///
  /// In en, this message translates to:
  /// **'Type any text'**
  String get labHashHint;

  /// No description provided for @labHashIntro.
  ///
  /// In en, this message translates to:
  /// **'Type in the box. Every key press gives a new fingerprint of the text.'**
  String get labHashIntro;

  /// No description provided for @labHashLabel.
  ///
  /// In en, this message translates to:
  /// **'SHA-256 of the text'**
  String get labHashLabel;

  /// No description provided for @labHashNote.
  ///
  /// In en, this message translates to:
  /// **'Change one letter, one capital or one space and the hash changes completely. The same text always gives the same hash.'**
  String get labHashNote;

  /// No description provided for @labMineIntro.
  ///
  /// In en, this message translates to:
  /// **'Change the data, then search for a nonce that makes the hash start with zeros. Editing the data makes the block not valid again.'**
  String get labMineIntro;

  /// No description provided for @labBlockData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get labBlockData;

  /// No description provided for @labBlockPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous hash'**
  String get labBlockPrevious;

  /// No description provided for @labBlockNonce.
  ///
  /// In en, this message translates to:
  /// **'Nonce'**
  String get labBlockNonce;

  /// No description provided for @labBlockHash.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get labBlockHash;

  /// No description provided for @labMineRule.
  ///
  /// In en, this message translates to:
  /// **'Rule: the hash starts with {zeros} zeros'**
  String labMineRule(int zeros);

  /// No description provided for @labMineButton.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get labMineButton;

  /// No description provided for @labMineCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get labMineCancel;

  /// No description provided for @labMineRunning.
  ///
  /// In en, this message translates to:
  /// **'Mining. Cancel stops the search.'**
  String get labMineRunning;

  /// No description provided for @labMineAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get labMineAttempts;

  /// No description provided for @labMineSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get labMineSpeed;

  /// No description provided for @labMineSpeedValue.
  ///
  /// In en, this message translates to:
  /// **'{rate} hash/s'**
  String labMineSpeedValue(String rate);

  /// No description provided for @labMineFound.
  ///
  /// In en, this message translates to:
  /// **'Nonce found after {attempts} attempts.'**
  String labMineFound(int attempts);

  /// No description provided for @labMineStopped.
  ///
  /// In en, this message translates to:
  /// **'Search stopped. The nonce is unchanged.'**
  String get labMineStopped;

  /// No description provided for @labMineGaveUp.
  ///
  /// In en, this message translates to:
  /// **'No nonce found in this run. Change the data or try again.'**
  String get labMineGaveUp;

  /// No description provided for @labChainIntro.
  ///
  /// In en, this message translates to:
  /// **'Three blocks, each linked to the hash of the one before. Change the data of a block and see what happens to the blocks after it.'**
  String get labChainIntro;

  /// No description provided for @labChainRemine.
  ///
  /// In en, this message translates to:
  /// **'Mine again'**
  String get labChainRemine;

  /// No description provided for @labChainWhy.
  ///
  /// In en, this message translates to:
  /// **'Block 3 stores the old hash of block 2. Fixing the chain means mining block 2 again, and then every block after it.'**
  String get labChainWhy;

  /// No description provided for @labNetworkIntro.
  ///
  /// In en, this message translates to:
  /// **'Three nodes, each with its own copy of the chain. A node keeps a copy only when every block in it is valid.'**
  String get labNetworkIntro;

  /// No description provided for @labNetworkNode.
  ///
  /// In en, this message translates to:
  /// **'Node {name}'**
  String labNetworkNode(String name);

  /// No description provided for @labNetworkKeeps.
  ///
  /// In en, this message translates to:
  /// **'Keeps this copy'**
  String get labNetworkKeeps;

  /// No description provided for @labNetworkRejects.
  ///
  /// In en, this message translates to:
  /// **'Rejects this copy'**
  String get labNetworkRejects;

  /// No description provided for @labNetworkTamper.
  ///
  /// In en, this message translates to:
  /// **'Change data on node B'**
  String get labNetworkTamper;

  /// No description provided for @labNetworkRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore node B'**
  String get labNetworkRestore;

  /// No description provided for @labTxIntro.
  ///
  /// In en, this message translates to:
  /// **'Each line is one transfer. The block data is the list of lines, and the block hash depends on every character.'**
  String get labTxIntro;

  /// No description provided for @labTxFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get labTxFrom;

  /// No description provided for @labTxTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get labTxTo;

  /// No description provided for @labTxAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get labTxAmount;

  /// No description provided for @labTxAdd.
  ///
  /// In en, this message translates to:
  /// **'Add transfer'**
  String get labTxAdd;

  /// No description provided for @labTxRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove transfer'**
  String get labTxRemove;

  /// No description provided for @labTxAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number, zero or more.'**
  String get labTxAmountError;

  /// No description provided for @labTxNameError.
  ///
  /// In en, this message translates to:
  /// **'Names cannot be empty.'**
  String get labTxNameError;

  /// No description provided for @labTxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transfers yet. Add one to build the block.'**
  String get labTxEmpty;

  /// No description provided for @labTxData.
  ///
  /// In en, this message translates to:
  /// **'Block data'**
  String get labTxData;

  /// No description provided for @labTxBlockHash.
  ///
  /// In en, this message translates to:
  /// **'Block hash'**
  String get labTxBlockHash;

  /// No description provided for @labCoinbaseIntro.
  ///
  /// In en, this message translates to:
  /// **'The first line of every block is the coinbase: new units paid to the miner, with no sender. Change the miner name and mine again.'**
  String get labCoinbaseIntro;

  /// No description provided for @labCoinbaseMiner.
  ///
  /// In en, this message translates to:
  /// **'Miner name'**
  String get labCoinbaseMiner;

  /// No description provided for @labCoinbaseReward.
  ///
  /// In en, this message translates to:
  /// **'Reward: {amount} units'**
  String labCoinbaseReward(String amount);

  /// No description provided for @labHeaderIntro.
  ///
  /// In en, this message translates to:
  /// **'This is the genesis block of Bitcoin, mined in January 2009. Its header is 80 bytes, and each field below is read from them.'**
  String get labHeaderIntro;

  /// No description provided for @labHeaderVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get labHeaderVersion;

  /// No description provided for @labHeaderMerkle.
  ///
  /// In en, this message translates to:
  /// **'Merkle root'**
  String get labHeaderMerkle;

  /// No description provided for @labHeaderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get labHeaderTime;

  /// No description provided for @labHeaderBits.
  ///
  /// In en, this message translates to:
  /// **'Bits'**
  String get labHeaderBits;

  /// No description provided for @labHeaderFields.
  ///
  /// In en, this message translates to:
  /// **'Decoded fields'**
  String get labHeaderFields;

  /// No description provided for @labHeaderBytes.
  ///
  /// In en, this message translates to:
  /// **'80 bytes, serialized'**
  String get labHeaderBytes;

  /// No description provided for @labHeaderDoubleHash.
  ///
  /// In en, this message translates to:
  /// **'Double SHA-256'**
  String get labHeaderDoubleHash;

  /// No description provided for @labHeaderTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get labHeaderTarget;

  /// No description provided for @labHeaderBelowTarget.
  ///
  /// In en, this message translates to:
  /// **'Hash below target'**
  String get labHeaderBelowTarget;

  /// No description provided for @labScriptTitle.
  ///
  /// In en, this message translates to:
  /// **'Script step by step'**
  String get labScriptTitle;

  /// No description provided for @labScriptIntro.
  ///
  /// In en, this message translates to:
  /// **'Run a script one opcode at a time. The stack shows what each opcode leaves behind.'**
  String get labScriptIntro;

  /// No description provided for @labScriptSimulated.
  ///
  /// In en, this message translates to:
  /// **'Signature checks are simulated in this teaching interpreter. A signature counts as valid only when the example lists it as valid. No real keys or signatures are checked. This is not consensus code.'**
  String get labScriptSimulated;

  /// No description provided for @labScriptExampleLabel.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get labScriptExampleLabel;

  /// No description provided for @labScriptCustomChip.
  ///
  /// In en, this message translates to:
  /// **'Your script'**
  String get labScriptCustomChip;

  /// No description provided for @labScriptCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Type ASM, for example 2 3 OP_ADD 5 OP_EQUAL'**
  String get labScriptCustomHint;

  /// No description provided for @labScriptCustomNote.
  ///
  /// In en, this message translates to:
  /// **'A typed script has no transaction and no simulated signatures, so signature and timelock opcodes cannot pass.'**
  String get labScriptCustomNote;

  /// No description provided for @labScriptSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get labScriptSourceLabel;

  /// No description provided for @labScriptStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get labScriptStep;

  /// No description provided for @labScriptRunToEnd.
  ///
  /// In en, this message translates to:
  /// **'Run to end'**
  String get labScriptRunToEnd;

  /// No description provided for @labScriptReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get labScriptReset;

  /// No description provided for @labScriptNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get labScriptNotStarted;

  /// No description provided for @labScriptRunCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 opcode run} other{{count} opcodes run}}'**
  String labScriptRunCount(int count);

  /// No description provided for @labScriptRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining script'**
  String get labScriptRemaining;

  /// No description provided for @labScriptNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get labScriptNextLabel;

  /// No description provided for @labScriptNothingLeft.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to run.'**
  String get labScriptNothingLeft;

  /// No description provided for @labScriptStack.
  ///
  /// In en, this message translates to:
  /// **'Stack'**
  String get labScriptStack;

  /// No description provided for @labScriptAltStack.
  ///
  /// In en, this message translates to:
  /// **'Alt stack'**
  String get labScriptAltStack;

  /// No description provided for @labScriptTopLabel.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get labScriptTopLabel;

  /// No description provided for @labScriptEmptyStack.
  ///
  /// In en, this message translates to:
  /// **'The stack is empty.'**
  String get labScriptEmptyStack;

  /// No description provided for @labScriptEmptyItem.
  ///
  /// In en, this message translates to:
  /// **'empty'**
  String get labScriptEmptyItem;

  /// No description provided for @labScriptResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get labScriptResult;

  /// No description provided for @labScriptSucceeds.
  ///
  /// In en, this message translates to:
  /// **'Script succeeds'**
  String get labScriptSucceeds;

  /// No description provided for @labScriptFails.
  ///
  /// In en, this message translates to:
  /// **'Script fails: {reason}'**
  String labScriptFails(String reason);

  /// No description provided for @labScriptParseError.
  ///
  /// In en, this message translates to:
  /// **'Token {index} cannot be read: {reason}'**
  String labScriptParseError(int index, String reason);

  /// No description provided for @labScriptFalseTop.
  ///
  /// In en, this message translates to:
  /// **'the top item is false or the stack is empty'**
  String get labScriptFalseTop;

  /// No description provided for @labScriptParseUnknown.
  ///
  /// In en, this message translates to:
  /// **'not an opcode, number, hex or quoted text'**
  String get labScriptParseUnknown;

  /// No description provided for @labScriptParseInvalidHex.
  ///
  /// In en, this message translates to:
  /// **'not valid hex'**
  String get labScriptParseInvalidHex;

  /// No description provided for @labScriptParseInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'not a valid number'**
  String get labScriptParseInvalidNumber;

  /// No description provided for @labScriptParseUnterminated.
  ///
  /// In en, this message translates to:
  /// **'the quoted text has no closing quote'**
  String get labScriptParseUnterminated;

  /// No description provided for @labScriptParseTruncated.
  ///
  /// In en, this message translates to:
  /// **'a push runs past the end of the script'**
  String get labScriptParseTruncated;

  /// No description provided for @labScriptNoteSignature.
  ///
  /// In en, this message translates to:
  /// **'This signature was checked against the simulated set.'**
  String get labScriptNoteSignature;

  /// No description provided for @labScriptNoteTimelockOk.
  ///
  /// In en, this message translates to:
  /// **'The timelock is satisfied.'**
  String get labScriptNoteTimelockOk;

  /// No description provided for @labScriptNoteTimelockNo.
  ///
  /// In en, this message translates to:
  /// **'The timelock is not satisfied.'**
  String get labScriptNoteTimelockNo;

  /// No description provided for @labScriptNoteTimelockOff.
  ///
  /// In en, this message translates to:
  /// **'The relative timelock is disabled, so this opcode does nothing.'**
  String get labScriptNoteTimelockOff;

  /// No description provided for @labScriptNoteContext.
  ///
  /// In en, this message translates to:
  /// **'This opcode needs a transaction, and this demo has none.'**
  String get labScriptNoteContext;

  /// No description provided for @labScriptErrStackUnderflow.
  ///
  /// In en, this message translates to:
  /// **'an opcode needed more items than the stack has'**
  String get labScriptErrStackUnderflow;

  /// No description provided for @labScriptErrAltStackUnderflow.
  ///
  /// In en, this message translates to:
  /// **'FROMALTSTACK ran with an empty alt stack'**
  String get labScriptErrAltStackUnderflow;

  /// No description provided for @labScriptErrVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'a VERIFY opcode found a false value'**
  String get labScriptErrVerifyFailed;

  /// No description provided for @labScriptErrEqualVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'EQUALVERIFY found two different items'**
  String get labScriptErrEqualVerifyFailed;

  /// No description provided for @labScriptErrNumEqualVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'NUMEQUALVERIFY found two different numbers'**
  String get labScriptErrNumEqualVerifyFailed;

  /// No description provided for @labScriptErrOpReturn.
  ///
  /// In en, this message translates to:
  /// **'OP_RETURN marks the output as unspendable'**
  String get labScriptErrOpReturn;

  /// No description provided for @labScriptErrDisabledOpcode.
  ///
  /// In en, this message translates to:
  /// **'a disabled opcode is in the script'**
  String get labScriptErrDisabledOpcode;

  /// No description provided for @labScriptErrUnsupportedOpcode.
  ///
  /// In en, this message translates to:
  /// **'this opcode is not implemented here'**
  String get labScriptErrUnsupportedOpcode;

  /// No description provided for @labScriptErrUnbalancedConditional.
  ///
  /// In en, this message translates to:
  /// **'IF, ELSE and ENDIF do not match'**
  String get labScriptErrUnbalancedConditional;

  /// No description provided for @labScriptErrNumberOverflow.
  ///
  /// In en, this message translates to:
  /// **'a number is longer than 4 bytes'**
  String get labScriptErrNumberOverflow;

  /// No description provided for @labScriptErrNonMinimalNumber.
  ///
  /// In en, this message translates to:
  /// **'a number is not minimally encoded'**
  String get labScriptErrNonMinimalNumber;

  /// No description provided for @labScriptErrPushTooLarge.
  ///
  /// In en, this message translates to:
  /// **'a push is longer than 520 bytes'**
  String get labScriptErrPushTooLarge;

  /// No description provided for @labScriptErrStackTooLarge.
  ///
  /// In en, this message translates to:
  /// **'the stacks hold more than 1000 items'**
  String get labScriptErrStackTooLarge;

  /// No description provided for @labScriptErrOpCountExceeded.
  ///
  /// In en, this message translates to:
  /// **'more than 201 opcodes ran'**
  String get labScriptErrOpCountExceeded;

  /// No description provided for @labScriptErrBadPickIndex.
  ///
  /// In en, this message translates to:
  /// **'PICK or ROLL asked for a depth the stack does not have'**
  String get labScriptErrBadPickIndex;

  /// No description provided for @labScriptErrKeyCountOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'CHECKMULTISIG asked for fewer than 0 or more than 20 keys'**
  String get labScriptErrKeyCountOutOfRange;

  /// No description provided for @labScriptErrSigCountOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'CHECKMULTISIG asked for more signatures than keys'**
  String get labScriptErrSigCountOutOfRange;

  /// No description provided for @labScriptErrNegativeLockTime.
  ///
  /// In en, this message translates to:
  /// **'a timelock operand is negative'**
  String get labScriptErrNegativeLockTime;

  /// No description provided for @labScriptErrLockTimeNotReached.
  ///
  /// In en, this message translates to:
  /// **'the transaction lock time is too early'**
  String get labScriptErrLockTimeNotReached;

  /// No description provided for @labScriptErrLockTimeTypeMismatch.
  ///
  /// In en, this message translates to:
  /// **'the timelock counts blocks but the transaction counts time, or the reverse'**
  String get labScriptErrLockTimeTypeMismatch;

  /// No description provided for @labScriptErrInputSequenceFinal.
  ///
  /// In en, this message translates to:
  /// **'the input sequence is final, so the lock time cannot be used'**
  String get labScriptErrInputSequenceFinal;

  /// No description provided for @labScriptErrInputSequenceDisabled.
  ///
  /// In en, this message translates to:
  /// **'the input sequence disables relative timelocks'**
  String get labScriptErrInputSequenceDisabled;

  /// No description provided for @labScriptErrTxVersionTooLow.
  ///
  /// In en, this message translates to:
  /// **'relative timelocks need transaction version 2 or higher'**
  String get labScriptErrTxVersionTooLow;

  /// No description provided for @labScriptErrMissingContext.
  ///
  /// In en, this message translates to:
  /// **'a timelock opcode needs a transaction, and none is set'**
  String get labScriptErrMissingContext;

  /// No description provided for @labScriptErrScriptTooLarge.
  ///
  /// In en, this message translates to:
  /// **'the script is longer than 10,000 bytes'**
  String get labScriptErrScriptTooLarge;

  /// No description provided for @labScriptExArithmeticName.
  ///
  /// In en, this message translates to:
  /// **'Arithmetic'**
  String get labScriptExArithmeticName;

  /// No description provided for @labScriptExArithmeticDesc.
  ///
  /// In en, this message translates to:
  /// **'Adds two numbers and checks the sum.'**
  String get labScriptExArithmeticDesc;

  /// No description provided for @labScriptExP2pkhName.
  ///
  /// In en, this message translates to:
  /// **'Pay to public key hash'**
  String get labScriptExP2pkhName;

  /// No description provided for @labScriptExP2pkhDesc.
  ///
  /// In en, this message translates to:
  /// **'The classic lock: a public key, a signature and a hash check.'**
  String get labScriptExP2pkhDesc;

  /// No description provided for @labScriptExMultisigName.
  ///
  /// In en, this message translates to:
  /// **'Multisig 2 of 3'**
  String get labScriptExMultisigName;

  /// No description provided for @labScriptExMultisigDesc.
  ///
  /// In en, this message translates to:
  /// **'Two of the three simulated signatures are needed.'**
  String get labScriptExMultisigDesc;

  /// No description provided for @labScriptExHashlockName.
  ///
  /// In en, this message translates to:
  /// **'Hashlock'**
  String get labScriptExHashlockName;

  /// No description provided for @labScriptExHashlockDesc.
  ///
  /// In en, this message translates to:
  /// **'The secret is the text whose SHA-256 is locked.'**
  String get labScriptExHashlockDesc;

  /// No description provided for @labScriptExCltvName.
  ///
  /// In en, this message translates to:
  /// **'Absolute timelock'**
  String get labScriptExCltvName;

  /// No description provided for @labScriptExCltvDesc.
  ///
  /// In en, this message translates to:
  /// **'CHECKLOCKTIMEVERIFY: the spend waits for a block height.'**
  String get labScriptExCltvDesc;

  /// No description provided for @labScriptExCsvName.
  ///
  /// In en, this message translates to:
  /// **'Relative timelock'**
  String get labScriptExCsvName;

  /// No description provided for @labScriptExCsvDesc.
  ///
  /// In en, this message translates to:
  /// **'CHECKSEQUENCEVERIFY: the input must be old enough.'**
  String get labScriptExCsvDesc;

  /// No description provided for @labScriptExHtlcName.
  ///
  /// In en, this message translates to:
  /// **'HTLC, claimed'**
  String get labScriptExHtlcName;

  /// No description provided for @labScriptExHtlcDesc.
  ///
  /// In en, this message translates to:
  /// **'The receiver reveals the secret before the timeout.'**
  String get labScriptExHtlcDesc;

  /// No description provided for @labScriptExHtlcRefundName.
  ///
  /// In en, this message translates to:
  /// **'HTLC, refund'**
  String get labScriptExHtlcRefundName;

  /// No description provided for @labScriptExHtlcRefundDesc.
  ///
  /// In en, this message translates to:
  /// **'After the timeout the sender takes the funds back.'**
  String get labScriptExHtlcRefundDesc;
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
