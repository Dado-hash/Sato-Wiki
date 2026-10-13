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
  String get categoryPrivacySecurity => 'Privacy and security';

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

  @override
  String get wikiTreeCategoryMyths => 'Myths';

  @override
  String wikiTreeSubcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategories',
      one: '1 subcategory',
    );
    return '$_temp0';
  }

  @override
  String get wikiTreeGlossary => 'Glossary';

  @override
  String wikiTreeGlossaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terms',
      one: '1 term',
    );
    return 'Short definitions · $_temp0';
  }

  @override
  String get wikiTreeOtherEntries => 'Other entries';

  @override
  String wikiTreeGuideMinutes(int minutes) {
    return 'Guide · $minutes min';
  }

  @override
  String wikiTreeProductsCount(int count) {
    return 'Products · $count';
  }

  @override
  String get wikiTreeStatusActive => 'Active';

  @override
  String get wikiTreeStatusDiscontinued => 'Discontinued';

  @override
  String get wikiTreeOpenSource => 'Open source';

  @override
  String get wikiTreeSourceNotOpen => 'Source not open';

  @override
  String get wikiTreeYes => 'Yes';

  @override
  String get wikiTreeNo => 'No';

  @override
  String get wikiTreeLicense => 'License';

  @override
  String get wikiTreeMaker => 'Maker';

  @override
  String get wikiTreePlatforms => 'Platforms';

  @override
  String wikiTreeCheckedOn(String date) {
    return 'Checked on $date';
  }

  @override
  String get wikiTreeWebsite => 'Website';

  @override
  String get wikiTreeSourceCode => 'Source code';

  @override
  String get wikiTreeProductNotice =>
      'SatoWiki does not sell or recommend products and has no affiliate links.';

  @override
  String get wikiTreeStatus => 'Status';

  @override
  String get wikiTreeProductNotFound => 'Product not found';

  @override
  String get learnStartHere => 'Start here';

  @override
  String get learnQuote => 'Quote';

  @override
  String get learnSource => 'Source';

  @override
  String learnStepsRead(int read, int total) {
    return '$read of $total read';
  }

  @override
  String learnNextStep(String title) {
    return 'Next: $title';
  }

  @override
  String get learnAllStepsRead => 'All steps read';

  @override
  String get learnStepRead => 'Read';

  @override
  String learnStepNumber(int number) {
    return 'Step $number';
  }

  @override
  String get learnPathNotFound => 'Path not found';

  @override
  String get learnGlossaryTitle => 'Glossary';

  @override
  String get learnGlossaryFilterHint => 'Filter terms';

  @override
  String learnGlossaryNoMatch(String query) {
    return 'No terms match \"$query\".';
  }

  @override
  String get learnGlossaryEmpty => 'No glossary terms yet.';

  @override
  String get learnAlsoCalled => 'Also called';

  @override
  String get learnGlossaryNotFound => 'Term not found';

  @override
  String get toolsSectionTools => 'Tools';

  @override
  String get toolsSectionLearn => 'Learn by doing';

  @override
  String get toolsSectionNetwork => 'Network';

  @override
  String get toolsTileHashName => 'Hash';

  @override
  String get toolsTileHashCaption => 'SHA-256 · HASH160';

  @override
  String get toolsTileAddressName => 'Address';

  @override
  String get toolsTileAddressCaption => 'Type and checksum';

  @override
  String get toolsTileTransactionName => 'Transaction';

  @override
  String get toolsTileTransactionCaption => 'Raw hex decoder';

  @override
  String get toolsTileTargetName => 'Target';

  @override
  String get toolsTileTargetCaption => 'Bits and difficulty';

  @override
  String get toolsTileUnitsName => 'Units';

  @override
  String get toolsTileUnitsCaption => 'sat · BTC · vB';

  @override
  String get toolsTileTablesName => 'Tables';

  @override
  String get toolsTileTablesCaption => 'Opcodes, fields, messages';

  @override
  String get toolsLabName => 'Blockchain lab';

  @override
  String get toolsLabCaption =>
      'Six steps: hash, block, chain, network, transactions, coinbase.';

  @override
  String get toolsScriptName => 'Script step by step';

  @override
  String get toolsScriptCaption => 'See the stack after each opcode.';

  @override
  String get toolsExplorerName => 'Explorer';

  @override
  String get toolsExplorerCaption => 'Uses the network. Off by default.';

  @override
  String get toolsCopy => 'Copy';

  @override
  String get toolsCopied => 'Copied';

  @override
  String get toolsReadMore => 'Read more in the wiki';

  @override
  String get toolsHashTitle => 'Hash';

  @override
  String get toolsHashModeText => 'Text';

  @override
  String get toolsHashModeHex => 'Hex';

  @override
  String get toolsHashTextHint => 'Type any text';

  @override
  String get toolsHashHexHint => 'Paste bytes in hex';

  @override
  String get toolsHashSha256 => 'SHA-256';

  @override
  String get toolsHashDoubleSha256 => 'Double SHA-256';

  @override
  String get toolsHashHash160 => 'HASH160';

  @override
  String get toolsHashInvalidHex =>
      'Not valid hex. Use pairs of digits 0-9 and a-f, with no spaces.';

  @override
  String get toolsHashEmptyHex => 'Enter hex bytes to see their hashes.';

  @override
  String get toolsHashNote =>
      'SHA-256 is the hash that proof of work and most Bitcoin identifiers rely on. Double SHA-256 applies it twice, as block headers and transaction ids do. HASH160 is RIPEMD-160 of SHA-256 and gives the 20-byte values inside addresses.';

  @override
  String get toolsAddressTitle => 'Address';

  @override
  String get toolsAddressHint => 'Paste an address';

  @override
  String get toolsAddressChecksumValid => 'Checksum valid';

  @override
  String get toolsAddressChecksumInvalid => 'Checksum not valid';

  @override
  String get toolsAddressNetworkMainnet => 'Mainnet';

  @override
  String get toolsAddressNetworkTestnet => 'Testnet';

  @override
  String get toolsAddressNetworkRegtest => 'Regtest';

  @override
  String get toolsAddressKindP2pkh => 'P2PKH';

  @override
  String get toolsAddressKindP2sh => 'P2SH';

  @override
  String get toolsAddressKindP2wpkh => 'P2WPKH';

  @override
  String get toolsAddressKindP2wsh => 'P2WSH';

  @override
  String get toolsAddressKindP2tr => 'P2TR (Taproot)';

  @override
  String get toolsAddressKindUnknownWitness => 'Unknown witness program';

  @override
  String get toolsAddressKindInvalid => 'Not a valid address';

  @override
  String get toolsAddressDescP2pkh =>
      'Pays to the hash of a public key. This is the classic format, used since 2009.';

  @override
  String get toolsAddressDescP2sh =>
      'Pays to the hash of a script, so the spending conditions stay hidden until they are used.';

  @override
  String get toolsAddressDescP2wpkh =>
      'Pays to the hash of a public key, in the SegWit version 0 format.';

  @override
  String get toolsAddressDescP2wsh =>
      'Pays to the hash of a script, in the SegWit version 0 format.';

  @override
  String get toolsAddressDescP2tr =>
      'Pays to a taproot output key, in the SegWit version 1 format.';

  @override
  String get toolsAddressDescUnknownWitness =>
      'A SegWit address with a witness version or length that this app does not analyse in detail.';

  @override
  String get toolsAddressErrorEmpty => 'Paste an address to check it.';

  @override
  String get toolsAddressErrorBadCharacter =>
      'A character is not allowed in this encoding.';

  @override
  String get toolsAddressErrorBadChecksum =>
      'The checksum does not match. The text was changed or mistyped.';

  @override
  String get toolsAddressErrorBadLength =>
      'The length is wrong for this type of address.';

  @override
  String get toolsAddressErrorUnknownVersion =>
      'The version or witness version is not one this app knows.';

  @override
  String get toolsAddressErrorMixedCase =>
      'Upper and lower case are mixed. Bech32 uses one case only.';

  @override
  String get toolsAddressErrorWrongVariant =>
      'The checksum type does not match the witness version.';

  @override
  String get toolsAddressErrorMissingSeparator =>
      'A Bech32 string needs the 1 separator.';

  @override
  String get toolsAddressErrorEmptyHrp =>
      'The network prefix before the 1 is empty.';

  @override
  String get toolsAddressErrorUnknownHrp =>
      'The prefix is not bc, tb or bcrt, so this is not a Bitcoin address.';

  @override
  String get toolsAddressErrorEmptyData =>
      'A SegWit address has no witness data.';

  @override
  String get toolsAddressErrorInvalidPadding =>
      'The witness data has invalid padding.';

  @override
  String get toolsAddressSecretWifTitle => 'This looks like a private key';

  @override
  String get toolsAddressSecretExtendedTitle =>
      'This looks like an extended key';

  @override
  String get toolsAddressSecretBody =>
      'Never paste a private key or an extended key into any app or website. The field was cleared and nothing was analysed.';

  @override
  String get toolsAddressBuiltTitle => 'How it is built';

  @override
  String get toolsPartPrefix => 'Network prefix';

  @override
  String get toolsPartSeparator => 'Separator';

  @override
  String get toolsPartWitnessVersion => 'Witness version';

  @override
  String get toolsPartProgram => 'Program (hash)';

  @override
  String get toolsPartChecksum => 'Checksum, last 6 characters';

  @override
  String get toolsPartVersionByte => 'Version byte';

  @override
  String get toolsPartPayloadHash => 'Payload hash';

  @override
  String get toolsPartBase58Checksum => 'Checksum, last 4 bytes';

  @override
  String get toolsAddressBase58Note =>
      'Base58 characters do not line up with bytes, so the string is shown without colours. Its parts are listed below.';

  @override
  String get toolsTxTitle => 'Transaction';

  @override
  String get toolsTxSummary => 'Summary';

  @override
  String get toolsTxHint => 'Paste a raw transaction in hex';

  @override
  String get toolsTxEmpty => 'Paste a raw transaction to decode it.';

  @override
  String get toolsTxLoadExample => 'Load example';

  @override
  String get toolsTxExampleNote =>
      'Example: the genesis coinbase transaction, from block 0.';

  @override
  String get toolsTxTapHint =>
      'Tap a field with an arrow to read its wiki entry.';

  @override
  String get toolsTxTxid => 'txid';

  @override
  String get toolsTxWtxid => 'wtxid';

  @override
  String get toolsTxType => 'Type';

  @override
  String get toolsTxTypeCoinbase => 'Coinbase';

  @override
  String get toolsTxTypeRegular => 'Regular';

  @override
  String get toolsTxFormat => 'Format';

  @override
  String get toolsTxFormatSegwit => 'SegWit';

  @override
  String get toolsTxFormatLegacy => 'Legacy';

  @override
  String get toolsTxSize => 'Size';

  @override
  String get toolsTxWeight => 'Weight';

  @override
  String get toolsTxVsize => 'Virtual size';

  @override
  String toolsTxBytes(int count) {
    return '$count bytes';
  }

  @override
  String toolsTxWeightUnits(int count) {
    return '$count WU';
  }

  @override
  String toolsTxVbytes(int count) {
    return '$count vB';
  }

  @override
  String get toolsTxFieldsTitle => 'Fields';

  @override
  String get toolsTxHexTitle => 'Serialized hex';

  @override
  String toolsTxInputLabel(int index) {
    return 'Input $index';
  }

  @override
  String toolsTxOutputLabel(int index) {
    return 'Output $index';
  }

  @override
  String toolsTxWitnessLabel(int index, int item) {
    return 'Input $index, witness item $item';
  }

  @override
  String get toolsTxCoinbaseTag => 'coinbase';

  @override
  String toolsTxValueBoth(String btc, String sat) {
    return '$btc BTC · $sat sat';
  }

  @override
  String toolsTxHiddenFields(int count) {
    return '$count more fields are not shown.';
  }

  @override
  String get toolsTxErrorNotHex =>
      'The input is empty, has an odd number of digits, or is not hexadecimal.';

  @override
  String get toolsTxErrorTruncated =>
      'The data ends before a field is complete. The transaction may be cut short.';

  @override
  String get toolsTxErrorTrailing =>
      'There are bytes after the last field. Check that the transaction is complete and has nothing extra.';

  @override
  String get toolsTxErrorTooLarge =>
      'The transaction is larger than 400000 bytes, the limit of this tool.';

  @override
  String get toolsTxErrorInvalid =>
      'A value is outside what a transaction can hold, or the segwit flag is unknown.';

  @override
  String get toolsFieldVersion => 'Version';

  @override
  String get toolsFieldMarker => 'Marker';

  @override
  String get toolsFieldFlag => 'Flag';

  @override
  String get toolsFieldInputCount => 'Input count';

  @override
  String get toolsFieldPreviousTxid => 'Previous txid';

  @override
  String get toolsFieldPreviousIndex => 'Previous output index';

  @override
  String get toolsFieldScriptSigLength => 'scriptSig length';

  @override
  String get toolsFieldScriptSig => 'scriptSig';

  @override
  String get toolsFieldSequence => 'Sequence';

  @override
  String get toolsFieldOutputCount => 'Output count';

  @override
  String get toolsFieldValue => 'Value';

  @override
  String get toolsFieldScriptPubKeyLength => 'scriptPubKey length';

  @override
  String get toolsFieldScriptPubKey => 'scriptPubKey';

  @override
  String get toolsFieldWitnessItemCount => 'Witness item count';

  @override
  String get toolsFieldWitnessItemLength => 'Witness item length';

  @override
  String get toolsFieldWitnessItem => 'Witness item';

  @override
  String get toolsFieldLockTime => 'Lock time';

  @override
  String get toolsScriptP2pk => 'P2PK';

  @override
  String get toolsScriptP2pkh => 'P2PKH';

  @override
  String get toolsScriptP2sh => 'P2SH';

  @override
  String get toolsScriptP2wpkh => 'P2WPKH';

  @override
  String get toolsScriptP2wsh => 'P2WSH';

  @override
  String get toolsScriptP2tr => 'P2TR';

  @override
  String get toolsScriptWitnessUnknown => 'Unknown witness program';

  @override
  String get toolsScriptBareMultisig => 'Bare multisig';

  @override
  String get toolsScriptOpReturn => 'OP_RETURN data';

  @override
  String get toolsScriptNonStandard => 'Non-standard';

  @override
  String get toolsTargetTitle => 'Target';

  @override
  String get toolsTargetHint => 'Bits, 8 hex digits, for example 1d00ffff';

  @override
  String get toolsTargetInvalid =>
      'Enter exactly 8 hex digits, with an optional 0x prefix.';

  @override
  String get toolsTargetTargetLabel => 'Target';

  @override
  String get toolsTargetDifficulty => 'Difficulty';

  @override
  String get toolsTargetExpected => 'Expected hashes per block';

  @override
  String toolsTargetScientific(String mantissa, int exponent) {
    return 'About $mantissa × 10^$exponent';
  }

  @override
  String get toolsTargetNote =>
      'The target is the number a block hash must stay below. Difficulty compares it with the maximum target, 1d00ffff. Expected hashes is the average number of attempts needed to find a valid block.';

  @override
  String get toolsUnitsTitle => 'Units';

  @override
  String get toolsUnitsBtcSatTitle => 'BTC and satoshi';

  @override
  String get toolsUnitsBtcLabel => 'BTC';

  @override
  String get toolsUnitsSatLabel => 'Satoshi';

  @override
  String get toolsUnitsDecimalsError =>
      'Bitcoin amounts have at most 8 decimals.';

  @override
  String get toolsUnitsInvalidAmount =>
      'Enter a decimal amount, for example 0.001.';

  @override
  String get toolsUnitsInvalidWhole => 'Enter a whole number, zero or more.';

  @override
  String get toolsUnitsWeightTitle => 'Weight units to virtual bytes';

  @override
  String get toolsUnitsWeightLabel => 'Weight units (WU)';

  @override
  String toolsUnitsVbytesResult(int vbytes) {
    return '$vbytes vB';
  }

  @override
  String get toolsUnitsRateFromFeeTitle => 'Fee rate from fee';

  @override
  String get toolsUnitsFeeLabel => 'Fee (satoshi)';

  @override
  String get toolsUnitsVsizeLabel => 'Virtual size (vB)';

  @override
  String toolsUnitsRateResult(String rate) {
    return '$rate sat/vB';
  }

  @override
  String get toolsUnitsFeeFromRateTitle => 'Fee from fee rate';

  @override
  String get toolsUnitsRateLabel => 'Fee rate (sat/vB)';

  @override
  String toolsUnitsFeeResult(int sat) {
    return '$sat sat';
  }

  @override
  String get toolsUnitsRateInvalid =>
      'Enter a fee rate of zero or more, for example 2.5.';

  @override
  String get toolsUnitsVsizePositive => 'Virtual size must be more than zero.';

  @override
  String get toolsUnitsResult => 'Result';

  @override
  String get toolsUnitsNote =>
      'Only units, no prices or fiat. Bitcoin amounts use integer math, so nothing is rounded.';

  @override
  String get toolsReferencesTitle => 'Reference tables';

  @override
  String get toolsReferencesEmpty => 'No reference tables yet.';

  @override
  String toolsRowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows',
      one: '1 row',
    );
    return '$_temp0';
  }

  @override
  String get toolsReferenceFilterHint => 'Filter rows';

  @override
  String get toolsReferenceNoMatch => 'No rows match this filter.';
}
