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
      'Seven steps: hash, block, chain, network, transactions, coinbase, a real header.';

  @override
  String get toolsScriptName => 'Script step by step';

  @override
  String get toolsScriptCaption => 'See the stack after each opcode.';

  @override
  String get toolsExplorerName => 'Explorer';

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

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryEmpty => 'No works in the library yet.';

  @override
  String get libraryNoMatch => 'No works match this filter.';

  @override
  String get libraryAuthorLabel => 'Author';

  @override
  String get libraryTopicLabel => 'Topic';

  @override
  String get libraryYearLabel => 'Year';

  @override
  String get libraryKindLabel => 'Type';

  @override
  String get libraryOriginalLanguageLabel => 'Original language';

  @override
  String get libraryLicenseLabel => 'License';

  @override
  String get libraryKindPaper => 'Paper';

  @override
  String get libraryKindEssay => 'Essay';

  @override
  String get libraryKindPost => 'Post';

  @override
  String get libraryKindEmail => 'Email';

  @override
  String get libraryKindBook => 'Book';

  @override
  String get libraryKindManifesto => 'Manifesto';

  @override
  String get libraryNotFound => 'Work not found';

  @override
  String get libraryReadOriginal => 'Read the original';

  @override
  String get libraryArchivedCopy => 'Archived copy';

  @override
  String get libraryIntroduction => 'Our introduction';

  @override
  String get libraryNotice =>
      'SatoWiki does not host the full text. The original opens in your browser.';

  @override
  String get librarySearchTypeGlossary => 'Glossary';

  @override
  String get librarySearchTypeProduct => 'Product';

  @override
  String get librarySearchTypeReference => 'Reference';

  @override
  String get librarySearchTypeLibrary => 'Library';

  @override
  String get connectTryIt => 'Try it';

  @override
  String get connectQuotesTitle => 'In their words';

  @override
  String get connectLibraryTitle => 'Library';

  @override
  String connectLibraryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count works',
      one: '1 work',
    );
    return '$_temp0';
  }

  @override
  String get connectHashTitle => 'Hash tool';

  @override
  String get connectHashCaption => 'Compute SHA-256 and HASH160 of any text';

  @override
  String get connectAddressTitle => 'Address tool';

  @override
  String get connectAddressCaption =>
      'Check the type and checksum of an address';

  @override
  String get connectTransactionTitle => 'Transaction tool';

  @override
  String get connectTransactionCaption =>
      'Decode a raw transaction field by field';

  @override
  String get connectTargetTitle => 'Target tool';

  @override
  String get connectTargetCaption => 'Convert bits, target and difficulty';

  @override
  String get connectUnitsTitle => 'Units tool';

  @override
  String get connectUnitsCaption => 'Convert sat, BTC and vB';

  @override
  String get connectScriptTitle => 'Script step by step';

  @override
  String get connectScriptCaption => 'See the stack after each opcode';

  @override
  String get connectLabTitle => 'Blockchain lab';

  @override
  String get connectLabCaption =>
      'Build and break a small blockchain, step by step';

  @override
  String connectLabStepTitle(int step) {
    return 'Blockchain lab, step $step';
  }

  @override
  String get connectLabStep1Caption => 'Type text and watch its hash change';

  @override
  String get connectLabStep2Caption =>
      'Mine a block: find a nonce that makes it valid';

  @override
  String get connectLabStep3Caption =>
      'Change one block and see the next ones break';

  @override
  String get connectLabStep6Caption =>
      'Inspect the coinbase transaction that pays the miner';

  @override
  String get connectLabStep7Caption =>
      'Read the 80-byte header that every block contains';

  @override
  String get explorerTitle => 'Explorer';

  @override
  String get explorerStateOn => 'On';

  @override
  String get explorerStateOff => 'Off';

  @override
  String explorerStateOnServer(String host) {
    return 'On · $host';
  }

  @override
  String get explorerSetupTitle => 'Before you turn it on';

  @override
  String get explorerSetupIntro =>
      'The explorer asks a server on the internet for data. The rest of the app works without a network.';

  @override
  String get explorerSetupWhatServerSees =>
      'Every search is sent to the server shown below. The server operator can see your IP address and what you search.';

  @override
  String get explorerSetupOwnAddresses =>
      'If you look up your own addresses, the server can link them to your IP address.';

  @override
  String get explorerSetupNothingSent =>
      'Nothing is sent until you press Search. Searches are not saved on this device. The explorer does not use Tor or any proxy.';

  @override
  String get explorerServerLabel => 'Server';

  @override
  String get explorerServerField => 'Server address';

  @override
  String get explorerServerHelp =>
      'Use https. Plain http works only for localhost, .onion and .local addresses.';

  @override
  String get explorerServerInvalid =>
      'This address is not allowed. Use https, or http only for localhost, .onion or .local. It was not saved.';

  @override
  String get explorerTurnOn => 'Turn on the explorer';

  @override
  String get explorerTurnOff => 'Turn off the explorer';

  @override
  String get explorerTurnOffNote => 'You can turn it on again from Settings.';

  @override
  String get explorerSaveServer => 'Save server';

  @override
  String get explorerServerSaved => 'Server saved.';

  @override
  String get explorerOffTitle => 'The explorer is off';

  @override
  String get explorerOffBody =>
      'Nothing is sent to any server while it is off.';

  @override
  String get explorerSearchHint => 'Height, block hash, txid or address';

  @override
  String get explorerSearchButton => 'Search';

  @override
  String get explorerSearchNote =>
      'One search sends one request per step. Searches are not saved.';

  @override
  String explorerServerInUse(String server) {
    return 'Server: $server';
  }

  @override
  String get explorerSecretWifTitle => 'This looks like a private key';

  @override
  String get explorerSecretExtendedTitle => 'This looks like an extended key';

  @override
  String get explorerSecretBody =>
      'Nothing was sent. The field was cleared. Never paste a private key into any app or website.';

  @override
  String get explorerInvalidInput =>
      'Enter a block height, a 64-character hash or txid, or an address.';

  @override
  String get explorerLookingUp => 'Looking up…';

  @override
  String get explorerNotFound =>
      'The server does not know this block, transaction or address.';

  @override
  String get explorerNetworkError =>
      'The server could not be reached. Check the connection and try again.';

  @override
  String get explorerBadResponse =>
      'The server sent an answer the explorer cannot read.';

  @override
  String explorerRateLimited(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Try again in $seconds seconds.',
      one: 'Try again in 1 second.',
    );
    return 'Too many requests. The server asked to slow down. $_temp0';
  }

  @override
  String get explorerNoAutoRetry => 'The explorer does not retry on its own.';

  @override
  String get explorerRetry => 'Try again';

  @override
  String get explorerBlockTitle => 'Block';

  @override
  String get explorerTransactionTitle => 'Transaction';

  @override
  String get explorerAddressTitle => 'Address';

  @override
  String get explorerHeight => 'Height';

  @override
  String get explorerHash => 'Hash';

  @override
  String get explorerTxid => 'Txid';

  @override
  String get explorerTime => 'Time';

  @override
  String get explorerTransactionCount => 'Transactions';

  @override
  String get explorerSize => 'Size';

  @override
  String get explorerWeight => 'Weight';

  @override
  String get explorerMerkleRoot => 'Merkle root';

  @override
  String get explorerPreviousBlock => 'Previous block';

  @override
  String get explorerNonce => 'Nonce';

  @override
  String get explorerBits => 'Bits';

  @override
  String get explorerDifficulty => 'Difficulty';

  @override
  String get explorerVersion => 'Version';

  @override
  String get explorerStatus => 'Status';

  @override
  String get explorerConfirmed => 'Confirmed';

  @override
  String get explorerUnconfirmed => 'Unconfirmed';

  @override
  String get explorerBlockOfTransaction => 'Block';

  @override
  String get explorerFee => 'Fee';

  @override
  String get explorerFeeRate => 'Fee rate';

  @override
  String explorerFeeRateValue(String rate) {
    return '$rate sat/vB';
  }

  @override
  String get explorerInputs => 'Inputs';

  @override
  String get explorerOutputs => 'Outputs';

  @override
  String explorerInputNumber(int index) {
    return 'Input $index';
  }

  @override
  String explorerOutputNumber(int index) {
    return 'Output $index';
  }

  @override
  String get explorerCoinbase => 'Coinbase, no previous output';

  @override
  String explorerAmount(String btc, String sat) {
    return '$btc BTC · $sat sat';
  }

  @override
  String get explorerScriptType => 'Script type';

  @override
  String get explorerBlockUnknown => 'Not yet in a block';

  @override
  String get explorerAddressReceived => 'Received';

  @override
  String get explorerAddressSpent => 'Spent';

  @override
  String get explorerAddressBalance => 'Balance';

  @override
  String get explorerAddressMempool => 'Mempool';

  @override
  String get explorerAddressTransactions => 'Latest transactions';

  @override
  String get explorerAddressFirstPage =>
      'Only the first page from the server is shown.';

  @override
  String get explorerNoTransactions =>
      'No transactions found for this address.';

  @override
  String get explorerLoading => 'Loading…';

  @override
  String get labTitle => 'Blockchain lab';

  @override
  String get labIntro =>
      'A small blockchain you can change and repair, one idea at a time. The blocks here are a teaching model, not the real protocol.';

  @override
  String get labIndexSteps => 'Steps';

  @override
  String labStepCounter(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get labStepOptional => 'Optional';

  @override
  String get labStepTitle1 => 'Hash';

  @override
  String get labStepDesc1 => 'Type text and watch its fingerprint change.';

  @override
  String get labStepTitle2 => 'Mine a block';

  @override
  String get labStepDesc2 =>
      'Change the data, then search for a nonce that makes the hash start with zeros.';

  @override
  String get labStepTitle3 => 'Chain';

  @override
  String get labStepDesc3 =>
      'Change one block and see every block after it break.';

  @override
  String get labStepTitle4 => 'Network';

  @override
  String get labStepDesc4 =>
      'Several copies of the chain. A node keeps only a valid one.';

  @override
  String get labStepTitle5 => 'Transactions';

  @override
  String get labStepDesc5 => 'Turn transfers into the data of a block.';

  @override
  String get labStepTitle6 => 'Coinbase';

  @override
  String get labStepDesc6 => 'The first transaction of a block pays the miner.';

  @override
  String get labStepTitle7 => 'A real header';

  @override
  String get labStepDesc7 =>
      'Decode the 80 bytes of the genesis block and hash them.';

  @override
  String get labDifference => 'In Bitcoin it is different';

  @override
  String get labDiff1 =>
      'A real block hash is SHA-256 applied twice to an 80-byte header, not to a line of text.';

  @override
  String get labDiff2 =>
      'The header is 80 bytes, the hash is double SHA-256, and the rule is a numeric target, not a count of zeros.';

  @override
  String get labDiff3 =>
      'Real nodes follow the chain with the most accumulated work, not a rule that counts zeros. Each block is checked against the target in its header.';

  @override
  String get labDiff4 =>
      'Real nodes also check every transaction and signature, and relay blocks to peers. This lab checks only the blocks, on this device.';

  @override
  String get labDiff5 =>
      'Real transactions spend earlier outputs, and each input carries a signature. Here a transfer is only a line of text.';

  @override
  String get labDiff6 =>
      'The subsidy halves every 210,000 blocks, about every four years, and coinbase outputs cannot be spent for 100 blocks.';

  @override
  String get labDiff7 =>
      'This is the real header format. The target comes from bits, and the hash is double SHA-256 of these 80 bytes.';

  @override
  String get labPreviousStep => 'Previous step';

  @override
  String get labNextStep => 'Next step';

  @override
  String get labValid => 'Valid';

  @override
  String get labNotValid => 'Not valid';

  @override
  String labBlockNumber(int number) {
    return 'Block $number';
  }

  @override
  String get labHashHint => 'Type any text';

  @override
  String get labHashIntro =>
      'Type in the box. Every key press gives a new fingerprint of the text.';

  @override
  String get labHashLabel => 'SHA-256 of the text';

  @override
  String get labHashNote =>
      'Change one letter, one capital or one space and the hash changes completely. The same text always gives the same hash.';

  @override
  String get labMineIntro =>
      'Change the data, then search for a nonce that makes the hash start with zeros. Editing the data makes the block not valid again.';

  @override
  String get labBlockData => 'Data';

  @override
  String get labBlockPrevious => 'Previous hash';

  @override
  String get labBlockNonce => 'Nonce';

  @override
  String get labBlockHash => 'Hash';

  @override
  String labMineRule(int zeros) {
    return 'Rule: the hash starts with $zeros zeros';
  }

  @override
  String get labMineButton => 'Mine';

  @override
  String get labMineCancel => 'Cancel';

  @override
  String get labMineRunning => 'Mining. Cancel stops the search.';

  @override
  String get labMineAttempts => 'Attempts';

  @override
  String get labMineSpeed => 'Speed';

  @override
  String labMineSpeedValue(String rate) {
    return '$rate hash/s';
  }

  @override
  String labMineFound(int attempts) {
    return 'Nonce found after $attempts attempts.';
  }

  @override
  String get labMineStopped => 'Search stopped. The nonce is unchanged.';

  @override
  String get labMineGaveUp =>
      'No nonce found in this run. Change the data or try again.';

  @override
  String get labChainIntro =>
      'Three blocks, each linked to the hash of the one before. Change the data of a block and see what happens to the blocks after it.';

  @override
  String get labChainRemine => 'Mine again';

  @override
  String get labChainWhy =>
      'Block 3 stores the old hash of block 2. Fixing the chain means mining block 2 again, and then every block after it.';

  @override
  String get labNetworkIntro =>
      'Three nodes, each with its own copy of the chain. A node keeps a copy only when every block in it is valid.';

  @override
  String labNetworkNode(String name) {
    return 'Node $name';
  }

  @override
  String get labNetworkKeeps => 'Keeps this copy';

  @override
  String get labNetworkRejects => 'Rejects this copy';

  @override
  String get labNetworkTamper => 'Change data on node B';

  @override
  String get labNetworkRestore => 'Restore node B';

  @override
  String get labTxIntro =>
      'Each line is one transfer. The block data is the list of lines, and the block hash depends on every character.';

  @override
  String get labTxFrom => 'From';

  @override
  String get labTxTo => 'To';

  @override
  String get labTxAmount => 'Amount';

  @override
  String get labTxAdd => 'Add transfer';

  @override
  String get labTxRemove => 'Remove transfer';

  @override
  String get labTxAmountError => 'Enter a whole number, zero or more.';

  @override
  String get labTxNameError => 'Names cannot be empty.';

  @override
  String get labTxEmpty => 'No transfers yet. Add one to build the block.';

  @override
  String get labTxData => 'Block data';

  @override
  String get labTxBlockHash => 'Block hash';

  @override
  String get labCoinbaseIntro =>
      'The first line of every block is the coinbase: new units paid to the miner, with no sender. Change the miner name and mine again.';

  @override
  String get labCoinbaseMiner => 'Miner name';

  @override
  String labCoinbaseReward(String amount) {
    return 'Reward: $amount units';
  }

  @override
  String get labHeaderIntro =>
      'This is the genesis block of Bitcoin, mined in January 2009. Its header is 80 bytes, and each field below is read from them.';

  @override
  String get labHeaderVersion => 'Version';

  @override
  String get labHeaderMerkle => 'Merkle root';

  @override
  String get labHeaderTime => 'Time';

  @override
  String get labHeaderBits => 'Bits';

  @override
  String get labHeaderFields => 'Decoded fields';

  @override
  String get labHeaderBytes => '80 bytes, serialized';

  @override
  String get labHeaderDoubleHash => 'Double SHA-256';

  @override
  String get labHeaderTarget => 'Target';

  @override
  String get labHeaderBelowTarget => 'Hash below target';

  @override
  String get labScriptTitle => 'Script step by step';

  @override
  String get labScriptIntro =>
      'Run a script one opcode at a time. The stack shows what each opcode leaves behind.';

  @override
  String get labScriptSimulated =>
      'Signature checks are simulated in this teaching interpreter. A signature counts as valid only when the example lists it as valid. No real keys or signatures are checked. This is not consensus code.';

  @override
  String get labScriptExampleLabel => 'Example';

  @override
  String get labScriptCustomChip => 'Your script';

  @override
  String get labScriptCustomHint =>
      'Type ASM, for example 2 3 OP_ADD 5 OP_EQUAL';

  @override
  String get labScriptCustomNote =>
      'A typed script has no transaction and no simulated signatures, so signature and timelock opcodes cannot pass.';

  @override
  String get labScriptSourceLabel => 'Script';

  @override
  String get labScriptStep => 'Step';

  @override
  String get labScriptRunToEnd => 'Run to end';

  @override
  String get labScriptReset => 'Reset';

  @override
  String get labScriptNotStarted => 'Not started';

  @override
  String labScriptRunCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opcodes run',
      one: '1 opcode run',
    );
    return '$_temp0';
  }

  @override
  String get labScriptRemaining => 'Remaining script';

  @override
  String get labScriptNextLabel => 'Next';

  @override
  String get labScriptNothingLeft => 'Nothing left to run.';

  @override
  String get labScriptStack => 'Stack';

  @override
  String get labScriptAltStack => 'Alt stack';

  @override
  String get labScriptTopLabel => 'Top';

  @override
  String get labScriptEmptyStack => 'The stack is empty.';

  @override
  String get labScriptEmptyItem => 'empty';

  @override
  String get labScriptResult => 'Result';

  @override
  String get labScriptSucceeds => 'Script succeeds';

  @override
  String labScriptFails(String reason) {
    return 'Script fails: $reason';
  }

  @override
  String labScriptParseError(int index, String reason) {
    return 'Token $index cannot be read: $reason';
  }

  @override
  String get labScriptFalseTop => 'the top item is false or the stack is empty';

  @override
  String get labScriptParseUnknown =>
      'not an opcode, number, hex or quoted text';

  @override
  String get labScriptParseInvalidHex => 'not valid hex';

  @override
  String get labScriptParseInvalidNumber => 'not a valid number';

  @override
  String get labScriptParseUnterminated =>
      'the quoted text has no closing quote';

  @override
  String get labScriptParseTruncated =>
      'a push runs past the end of the script';

  @override
  String get labScriptNoteSignature =>
      'This signature was checked against the simulated set.';

  @override
  String get labScriptNoteTimelockOk => 'The timelock is satisfied.';

  @override
  String get labScriptNoteTimelockNo => 'The timelock is not satisfied.';

  @override
  String get labScriptNoteTimelockOff =>
      'The relative timelock is disabled, so this opcode does nothing.';

  @override
  String get labScriptNoteContext =>
      'This opcode needs a transaction, and this demo has none.';

  @override
  String get labScriptErrStackUnderflow =>
      'an opcode needed more items than the stack has';

  @override
  String get labScriptErrAltStackUnderflow =>
      'FROMALTSTACK ran with an empty alt stack';

  @override
  String get labScriptErrVerifyFailed => 'a VERIFY opcode found a false value';

  @override
  String get labScriptErrEqualVerifyFailed =>
      'EQUALVERIFY found two different items';

  @override
  String get labScriptErrNumEqualVerifyFailed =>
      'NUMEQUALVERIFY found two different numbers';

  @override
  String get labScriptErrOpReturn =>
      'OP_RETURN marks the output as unspendable';

  @override
  String get labScriptErrDisabledOpcode => 'a disabled opcode is in the script';

  @override
  String get labScriptErrUnsupportedOpcode =>
      'this opcode is not implemented here';

  @override
  String get labScriptErrUnbalancedConditional =>
      'IF, ELSE and ENDIF do not match';

  @override
  String get labScriptErrNumberOverflow => 'a number is longer than 4 bytes';

  @override
  String get labScriptErrNonMinimalNumber =>
      'a number is not minimally encoded';

  @override
  String get labScriptErrPushTooLarge => 'a push is longer than 520 bytes';

  @override
  String get labScriptErrStackTooLarge =>
      'the stacks hold more than 1000 items';

  @override
  String get labScriptErrOpCountExceeded => 'more than 201 opcodes ran';

  @override
  String get labScriptErrBadPickIndex =>
      'PICK or ROLL asked for a depth the stack does not have';

  @override
  String get labScriptErrKeyCountOutOfRange =>
      'CHECKMULTISIG asked for fewer than 0 or more than 20 keys';

  @override
  String get labScriptErrSigCountOutOfRange =>
      'CHECKMULTISIG asked for more signatures than keys';

  @override
  String get labScriptErrNegativeLockTime => 'a timelock operand is negative';

  @override
  String get labScriptErrLockTimeNotReached =>
      'the transaction lock time is too early';

  @override
  String get labScriptErrLockTimeTypeMismatch =>
      'the timelock counts blocks but the transaction counts time, or the reverse';

  @override
  String get labScriptErrInputSequenceFinal =>
      'the input sequence is final, so the lock time cannot be used';

  @override
  String get labScriptErrInputSequenceDisabled =>
      'the input sequence disables relative timelocks';

  @override
  String get labScriptErrTxVersionTooLow =>
      'relative timelocks need transaction version 2 or higher';

  @override
  String get labScriptErrMissingContext =>
      'a timelock opcode needs a transaction, and none is set';

  @override
  String get labScriptErrScriptTooLarge =>
      'the script is longer than 10,000 bytes';

  @override
  String get labScriptExArithmeticName => 'Arithmetic';

  @override
  String get labScriptExArithmeticDesc =>
      'Adds two numbers and checks the sum.';

  @override
  String get labScriptExP2pkhName => 'Pay to public key hash';

  @override
  String get labScriptExP2pkhDesc =>
      'The classic lock: a public key, a signature and a hash check.';

  @override
  String get labScriptExMultisigName => 'Multisig 2 of 3';

  @override
  String get labScriptExMultisigDesc =>
      'Two of the three simulated signatures are needed.';

  @override
  String get labScriptExHashlockName => 'Hashlock';

  @override
  String get labScriptExHashlockDesc =>
      'The secret is the text whose SHA-256 is locked.';

  @override
  String get labScriptExCltvName => 'Absolute timelock';

  @override
  String get labScriptExCltvDesc =>
      'CHECKLOCKTIMEVERIFY: the spend waits for a block height.';

  @override
  String get labScriptExCsvName => 'Relative timelock';

  @override
  String get labScriptExCsvDesc =>
      'CHECKSEQUENCEVERIFY: the input must be old enough.';

  @override
  String get labScriptExHtlcName => 'HTLC, claimed';

  @override
  String get labScriptExHtlcDesc =>
      'The receiver reveals the secret before the timeout.';

  @override
  String get labScriptExHtlcRefundName => 'HTLC, refund';

  @override
  String get labScriptExHtlcRefundDesc =>
      'After the timeout the sender takes the funds back.';
}
