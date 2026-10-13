// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'SatoWiki';

  @override
  String get wikiTab => 'Wiki';

  @override
  String get newsTab => 'News';

  @override
  String get historyTab => 'Storia';

  @override
  String get codeTab => 'Codice';

  @override
  String get searchTooltip => 'Cerca';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get languageSystemDefault => 'Predefinita di sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get categoryProtocol => 'Protocollo';

  @override
  String get categoryCryptography => 'Crittografia';

  @override
  String get categoryLightningNetwork => 'Lightning Network';

  @override
  String get categoryEconomics => 'Economia';

  @override
  String get categoryConsensus => 'Consenso';

  @override
  String get categoryAdoption => 'Adozione';

  @override
  String get categoryOrigin => 'Origine';

  @override
  String get categoryRegulation => 'Regolamentazione';

  @override
  String get categorySecurity => 'Sicurezza';

  @override
  String get all => 'Tutti';

  @override
  String shortMin(int minutes) {
    return '$minutes min';
  }

  @override
  String entryConceptualVisual(String title) {
    return 'Visuale concettuale: $title';
  }

  @override
  String get relatedConcepts => 'Concetti collegati';

  @override
  String get wikiEntryNotFound => 'Voce Wiki non trovata';

  @override
  String get readingLevelBase => 'Base';

  @override
  String get readingLevelMedium => 'Medio';

  @override
  String get readingLevelAdvanced => 'Avanzato';

  @override
  String get sourcesAndReferences => 'Fonti e riferimenti';

  @override
  String get newsTitle => 'News';

  @override
  String get newsSubtitle =>
      'Analisi Bitcoin di lungo formato dalla community.';

  @override
  String get articleNotFound => 'Articolo non trovato';

  @override
  String get close => 'Chiudi';

  @override
  String get market => 'Mercato';

  @override
  String get regulatory => 'Regolamentazione';

  @override
  String get culture => 'Cultura';

  @override
  String get development => 'Sviluppo';

  @override
  String get historyTitle => 'Storia';

  @override
  String get historySubtitle => 'Tappe e contesto dal tempo Bitcoin.';

  @override
  String get allEvents => 'Tutti gli eventi';

  @override
  String get community => 'Community';

  @override
  String get historyEventNotFound => 'Evento storico non trovato';

  @override
  String get recentBips => 'BIP recenti';

  @override
  String get allBipsTitle => 'Tutti i BIP';

  @override
  String get noBipsMatchFilter => 'Nessun BIP corrisponde al filtro.';

  @override
  String get noBipsAvailable => 'Nessun BIP disponibile per ora.';

  @override
  String get bipNumberDescending => 'BIP # più alto';

  @override
  String get bipNumberAscending => 'BIP # più basso';

  @override
  String get changelog => 'Changelog';

  @override
  String get noRecentReleases => 'Nessuna release recente.';

  @override
  String get bipNotFound => 'BIP non trovato';

  @override
  String get releaseNotFound => 'Release non trovata';

  @override
  String get openLinkFailed => 'Impossibile aprire il link.';

  @override
  String get statusActive => 'Attivo';

  @override
  String get statusFinal => 'Finale';

  @override
  String get statusDraft => 'Bozza';

  @override
  String get statusComplete => 'Completo';

  @override
  String get statusDeployed => 'Distribuito';

  @override
  String get statusClosed => 'Chiuso';

  @override
  String get statusProposed => 'Proposto';

  @override
  String get statusWithdrawn => 'Ritirato';

  @override
  String get statusRejected => 'Respinto';

  @override
  String get statusMajor => 'Major';

  @override
  String get statusMinor => 'Minor';

  @override
  String get statusPatch => 'Patch';

  @override
  String get authors => 'Autori';

  @override
  String get created => 'Creato';

  @override
  String get practicalImpact => 'Impatto pratico';

  @override
  String get statusHistory => 'Cronologia stato';

  @override
  String get userImpact => 'Impatto per l\'utente';

  @override
  String get technicalChanges => 'Modifiche tecniche';

  @override
  String get searchHint => 'Cerca conoscenza Bitcoin';

  @override
  String get noLocalResultFound => 'Nessun risultato locale.';

  @override
  String get routeNotFound => 'Route non trovata';

  @override
  String get contentUpdateTitle => 'Aggiornamento contenuti';

  @override
  String get contentUpdateAvailable =>
      'Nuovi contenuti pronti per il download.';

  @override
  String get contentUpdateChecking => 'Verifica aggiornamenti...';

  @override
  String get contentUpdateDownloadingBundle => 'Download contenuti...';

  @override
  String get contentUpdateDownloadingMedia => 'Download file media...';

  @override
  String contentUpdateDownloadingMediaFormatted(int current, int total) {
    return 'Download media ($current di $total)...';
  }

  @override
  String get contentUpdateInstalling => 'Installazione aggiornamento...';

  @override
  String get contentUpdateDone => 'Aggiornamento completato!';

  @override
  String get contentUpdateError =>
      'Aggiornamento fallito. I contenuti sono invariati.';

  @override
  String get todayTab => 'Oggi';

  @override
  String get todayHeadlineLead => 'Il libro arancione di';

  @override
  String get todayHeadlineAccent => 'Bitcoin';

  @override
  String get continueReading => 'Continua a leggere';

  @override
  String minutesLeft(int minutes) {
    return '$minutes min rimasti';
  }

  @override
  String readPercent(int percent) {
    return 'Letto al $percent%';
  }

  @override
  String get featured => 'In evidenza';

  @override
  String get allEntries => 'Tutte le voci';

  @override
  String get nextAnniversary => 'Prossima ricorrenza';

  @override
  String get onThisDayTitle => 'Accadde oggi';

  @override
  String inDays(int days) {
    return 'tra $days giorni';
  }

  @override
  String get tomorrow => 'domani';

  @override
  String get today => 'oggi';

  @override
  String get fromTheCode => 'Dal codice';

  @override
  String get seeAll => 'Vedi tutto';

  @override
  String get latestNews => 'Ultime news';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsTooltip => 'Impostazioni';

  @override
  String get back => 'Indietro';

  @override
  String entriesInCategories(int entries, int categories) {
    return '$entries voci in $categories categorie';
  }

  @override
  String entriesCount(int count) {
    return '$count voci';
  }

  @override
  String get searchWikiHint => 'Cerca nel wiki';

  @override
  String get readingLevelTitle => 'Livello di lettura';

  @override
  String get readingLevelAppliesToAll => 'Vale per tutte le voci';

  @override
  String get categories => 'Categorie';

  @override
  String get toExplore => 'Da esplorare';

  @override
  String eventsFromTo(int count, int from, int to) {
    return '$count eventi dal $from al $to';
  }

  @override
  String codeSummary(int bips, int releases) {
    return '$bips BIP e $releases release di Bitcoin Core';
  }

  @override
  String get bipStatusTitle => 'Stato dei BIP';

  @override
  String totalCount(int count) {
    return '$count totali';
  }

  @override
  String allCount(int count) {
    return 'Tutti i $count';
  }

  @override
  String get releases => 'Release';

  @override
  String get allReleasesTitle => 'Tutte le release';

  @override
  String get bipType => 'Tipo';

  @override
  String get inPlainWords => 'In parole semplici';

  @override
  String get readMoreInWiki => 'Approfondisci nel wiki';

  @override
  String get officialTextOnGitHub => 'Testo ufficiale su GitHub';

  @override
  String get officialReleaseNotes => 'Note di rilascio ufficiali';

  @override
  String get version => 'Versione';

  @override
  String get released => 'Rilasciata';

  @override
  String get textSize => 'Dimensione testo';

  @override
  String get saveBookmark => 'Salva nei segnalibri';

  @override
  String get removeBookmark => 'Rimuovi dai segnalibri';

  @override
  String get bookmarks => 'Segnalibri';

  @override
  String get noBookmarks => 'Ancora nessun elemento salvato.';

  @override
  String get noBookmarksHint =>
      'Tocca il segnalibro su una voce per ritrovarla qui.';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get recentSearches => 'Ricerche recenti';

  @override
  String get suggestedSearches => 'Suggerimenti';

  @override
  String get clearRecentSearches => 'Cancella';

  @override
  String noResultsFor(String query) {
    return 'Nessun risultato per \"$query\".';
  }

  @override
  String get settingsReading => 'Lettura';

  @override
  String get defaultLevel => 'Livello predefinito';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get settingsContent => 'Contenuti';

  @override
  String get contentVersion => 'Versione dei contenuti';

  @override
  String get upToDate => 'Aggiornato';

  @override
  String get updating => 'Aggiornamento';

  @override
  String get checkForUpdates => 'Controlla aggiornamenti';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String get openSourceLicenses => 'Licenze open source';

  @override
  String get categoryApplications => 'Applicazioni';

  @override
  String get categoryPeerServices => 'Servizi peer';

  @override
  String get categoryInformational => 'Informativo';

  @override
  String get categoryProcess => 'Processo';

  @override
  String get categoryApiRpc => 'API/RPC';

  @override
  String get categorySpecification => 'Specifica';

  @override
  String get categorySoftware => 'Software';

  @override
  String get categoryHardware => 'Hardware';

  @override
  String get categoryPrivacySecurity => 'Privacy e sicurezza';

  @override
  String get subcategoryNodes => 'Nodi';

  @override
  String get subcategorySoftwareWallets => 'Software wallet';

  @override
  String get subcategoryLightning => 'Lightning';

  @override
  String get subcategoryServers => 'Server e infrastruttura';

  @override
  String get subcategoryNodeSystems => 'Sistemi per nodo domestico';

  @override
  String get subcategoryMiningSoftware => 'Software di mining';

  @override
  String get subcategoryDeveloperTools =>
      'Librerie e strumenti per sviluppatori';

  @override
  String get subcategoryHardwareWallets => 'Hardware wallet';

  @override
  String get subcategorySeedBackups => 'Backup del seed';

  @override
  String get subcategoryMiningHardware => 'Hardware di mining';

  @override
  String get subcategoryNodeHardware => 'Hardware per nodi';

  @override
  String get wikiTreeCategoryMyths => 'Miti';

  @override
  String wikiTreeSubcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sottocategorie',
      one: '1 sottocategoria',
    );
    return '$_temp0';
  }

  @override
  String get wikiTreeGlossary => 'Glossario';

  @override
  String wikiTreeGlossaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count termini',
      one: '1 termine',
    );
    return 'Definizioni brevi · $_temp0';
  }

  @override
  String get wikiTreeOtherEntries => 'Altre voci';

  @override
  String wikiTreeGuideMinutes(int minutes) {
    return 'Guida · $minutes min';
  }

  @override
  String wikiTreeProductsCount(int count) {
    return 'Prodotti · $count';
  }

  @override
  String get wikiTreeStatusActive => 'Attivo';

  @override
  String get wikiTreeStatusDiscontinued => 'Dismesso';

  @override
  String get wikiTreeOpenSource => 'Open source';

  @override
  String get wikiTreeSourceNotOpen => 'Codice non aperto';

  @override
  String get wikiTreeYes => 'Sì';

  @override
  String get wikiTreeNo => 'No';

  @override
  String get wikiTreeLicense => 'Licenza';

  @override
  String get wikiTreeMaker => 'Produttore';

  @override
  String get wikiTreePlatforms => 'Piattaforme';

  @override
  String wikiTreeCheckedOn(String date) {
    return 'Verificato il $date';
  }

  @override
  String get wikiTreeWebsite => 'Sito web';

  @override
  String get wikiTreeSourceCode => 'Codice sorgente';

  @override
  String get wikiTreeProductNotice =>
      'SatoWiki non vende e non raccomanda prodotti e non usa link di affiliazione.';

  @override
  String get wikiTreeStatus => 'Stato';

  @override
  String get wikiTreeProductNotFound => 'Prodotto non trovato';

  @override
  String get learnStartHere => 'Inizia qui';

  @override
  String get learnQuote => 'Citazione';

  @override
  String get learnSource => 'Fonte';

  @override
  String learnStepsRead(int read, int total) {
    return '$read di $total letti';
  }

  @override
  String learnNextStep(String title) {
    return 'Prossima: $title';
  }

  @override
  String get learnAllStepsRead => 'Hai letto tutti i passi';

  @override
  String get learnStepRead => 'Letto';

  @override
  String learnStepNumber(int number) {
    return 'Passo $number';
  }

  @override
  String get learnPathNotFound => 'Percorso non trovato';

  @override
  String get learnGlossaryTitle => 'Glossario';

  @override
  String get learnGlossaryFilterHint => 'Filtra i termini';

  @override
  String learnGlossaryNoMatch(String query) {
    return 'Nessun termine corrisponde a \"$query\".';
  }

  @override
  String get learnGlossaryEmpty => 'Nessun termine nel glossario.';

  @override
  String get learnAlsoCalled => 'Detto anche';

  @override
  String get learnGlossaryNotFound => 'Termine non trovato';

  @override
  String get toolsSectionTools => 'Strumenti';

  @override
  String get toolsSectionLearn => 'Impara facendo';

  @override
  String get toolsSectionNetwork => 'Rete';

  @override
  String get toolsTileHashName => 'Hash';

  @override
  String get toolsTileHashCaption => 'SHA-256 · HASH160';

  @override
  String get toolsTileAddressName => 'Indirizzo';

  @override
  String get toolsTileAddressCaption => 'Tipo e checksum';

  @override
  String get toolsTileTransactionName => 'Transazione';

  @override
  String get toolsTileTransactionCaption => 'Decoder esadecimale';

  @override
  String get toolsTileTargetName => 'Target';

  @override
  String get toolsTileTargetCaption => 'Bits e difficoltà';

  @override
  String get toolsTileUnitsName => 'Unità';

  @override
  String get toolsTileUnitsCaption => 'sat · BTC · vB';

  @override
  String get toolsTileTablesName => 'Tabelle';

  @override
  String get toolsTileTablesCaption => 'Opcode, campi, messaggi';

  @override
  String get toolsLabName => 'Laboratorio blockchain';

  @override
  String get toolsLabCaption =>
      'Sei passi: hash, blocco, catena, rete, transazioni, coinbase.';

  @override
  String get toolsScriptName => 'Script passo per passo';

  @override
  String get toolsScriptCaption => 'Guarda lo stack dopo ogni opcode.';

  @override
  String get toolsExplorerName => 'Explorer';

  @override
  String get toolsExplorerCaption =>
      'Usa la rete. Spento per impostazione predefinita.';

  @override
  String get toolsCopy => 'Copia';

  @override
  String get toolsCopied => 'Copiato';

  @override
  String get toolsReadMore => 'Approfondisci nella wiki';

  @override
  String get toolsHashTitle => 'Hash';

  @override
  String get toolsHashModeText => 'Testo';

  @override
  String get toolsHashModeHex => 'Hex';

  @override
  String get toolsHashTextHint => 'Scrivi un testo';

  @override
  String get toolsHashHexHint => 'Incolla byte in esadecimale';

  @override
  String get toolsHashSha256 => 'SHA-256';

  @override
  String get toolsHashDoubleSha256 => 'Doppio SHA-256';

  @override
  String get toolsHashHash160 => 'HASH160';

  @override
  String get toolsHashInvalidHex =>
      'Non è esadecimale valido. Usa coppie di cifre 0-9 e a-f, senza spazi.';

  @override
  String get toolsHashEmptyHex =>
      'Inserisci byte in esadecimale per vedere i loro hash.';

  @override
  String get toolsHashNote =>
      'SHA-256 è la funzione hash su cui si basano il proof of work e la maggior parte degli identificativi Bitcoin. Il doppio SHA-256 la applica due volte, come fanno gli header dei blocchi e i txid. HASH160 è RIPEMD-160 di SHA-256 e produce i valori di 20 byte dentro gli indirizzi.';

  @override
  String get toolsAddressTitle => 'Indirizzo';

  @override
  String get toolsAddressHint => 'Incolla un indirizzo';

  @override
  String get toolsAddressChecksumValid => 'Checksum valido';

  @override
  String get toolsAddressChecksumInvalid => 'Checksum non valido';

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
  String get toolsAddressKindUnknownWitness => 'Programma witness sconosciuto';

  @override
  String get toolsAddressKindInvalid => 'Non è un indirizzo valido';

  @override
  String get toolsAddressDescP2pkh =>
      'Paga all\'hash di una chiave pubblica. È il formato classico, usato dal 2009.';

  @override
  String get toolsAddressDescP2sh =>
      'Paga all\'hash di uno script, quindi le condizioni di spesa restano nascoste fino all\'uso.';

  @override
  String get toolsAddressDescP2wpkh =>
      'Paga all\'hash di una chiave pubblica, nel formato SegWit versione 0.';

  @override
  String get toolsAddressDescP2wsh =>
      'Paga all\'hash di uno script, nel formato SegWit versione 0.';

  @override
  String get toolsAddressDescP2tr =>
      'Paga a una chiave di output taproot, nel formato SegWit versione 1.';

  @override
  String get toolsAddressDescUnknownWitness =>
      'Un indirizzo SegWit con una versione o una lunghezza che l\'app non analizza nel dettaglio.';

  @override
  String get toolsAddressErrorEmpty => 'Incolla un indirizzo per controllarlo.';

  @override
  String get toolsAddressErrorBadCharacter =>
      'Un carattere non è ammesso in questa codifica.';

  @override
  String get toolsAddressErrorBadChecksum =>
      'Il checksum non corrisponde. Il testo è stato cambiato o ha un errore di battitura.';

  @override
  String get toolsAddressErrorBadLength =>
      'La lunghezza non è corretta per questo tipo di indirizzo.';

  @override
  String get toolsAddressErrorUnknownVersion =>
      'La versione o la versione witness non è una di quelle che l\'app conosce.';

  @override
  String get toolsAddressErrorMixedCase =>
      'Maiuscole e minuscole sono mescolate. Bech32 usa un solo tipo di lettere.';

  @override
  String get toolsAddressErrorWrongVariant =>
      'Il tipo di checksum non corrisponde alla versione witness.';

  @override
  String get toolsAddressErrorMissingSeparator =>
      'Una stringa Bech32 richiede il separatore 1.';

  @override
  String get toolsAddressErrorEmptyHrp =>
      'Il prefisso di rete prima dell\'1 è vuoto.';

  @override
  String get toolsAddressErrorUnknownHrp =>
      'Il prefisso non è bc, tb o bcrt, quindi non è un indirizzo Bitcoin.';

  @override
  String get toolsAddressErrorEmptyData =>
      'Un indirizzo SegWit non ha dati witness.';

  @override
  String get toolsAddressErrorInvalidPadding =>
      'I dati witness hanno un padding non valido.';

  @override
  String get toolsAddressSecretWifTitle => 'Sembra una chiave privata';

  @override
  String get toolsAddressSecretExtendedTitle => 'Sembra una chiave estesa';

  @override
  String get toolsAddressSecretBody =>
      'Non incollare mai una chiave privata o una chiave estesa in un\'app o in un sito. Il campo è stato svuotato e non è stato analizzato.';

  @override
  String get toolsAddressBuiltTitle => 'Come è fatto';

  @override
  String get toolsPartPrefix => 'Prefisso di rete';

  @override
  String get toolsPartSeparator => 'Separatore';

  @override
  String get toolsPartWitnessVersion => 'Versione witness';

  @override
  String get toolsPartProgram => 'Programma (hash)';

  @override
  String get toolsPartChecksum => 'Checksum, ultimi 6 caratteri';

  @override
  String get toolsPartVersionByte => 'Byte di versione';

  @override
  String get toolsPartPayloadHash => 'Hash del payload';

  @override
  String get toolsPartBase58Checksum => 'Checksum, ultimi 4 byte';

  @override
  String get toolsAddressBase58Note =>
      'I caratteri Base58 non corrispondono ai byte, quindi la stringa è mostrata senza colori. Le sue parti sono elencate sotto.';

  @override
  String get toolsTxTitle => 'Transazione';

  @override
  String get toolsTxSummary => 'Riepilogo';

  @override
  String get toolsTxHint => 'Incolla una transazione grezza in esadecimale';

  @override
  String get toolsTxEmpty =>
      'Incolla una transazione grezza per decodificarla.';

  @override
  String get toolsTxLoadExample => 'Carica esempio';

  @override
  String get toolsTxExampleNote =>
      'Esempio: la transazione coinbase del genesis, dal blocco 0.';

  @override
  String get toolsTxTapHint =>
      'Tocca un campo con la freccia per leggere la sua voce wiki.';

  @override
  String get toolsTxTxid => 'txid';

  @override
  String get toolsTxWtxid => 'wtxid';

  @override
  String get toolsTxType => 'Tipo';

  @override
  String get toolsTxTypeCoinbase => 'Coinbase';

  @override
  String get toolsTxTypeRegular => 'Normale';

  @override
  String get toolsTxFormat => 'Formato';

  @override
  String get toolsTxFormatSegwit => 'SegWit';

  @override
  String get toolsTxFormatLegacy => 'Legacy';

  @override
  String get toolsTxSize => 'Dimensione';

  @override
  String get toolsTxWeight => 'Peso';

  @override
  String get toolsTxVsize => 'Dimensione virtuale';

  @override
  String toolsTxBytes(int count) {
    return '$count byte';
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
  String get toolsTxFieldsTitle => 'Campi';

  @override
  String get toolsTxHexTitle => 'Hex serializzato';

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
    return 'Input $index, elemento witness $item';
  }

  @override
  String get toolsTxCoinbaseTag => 'coinbase';

  @override
  String toolsTxValueBoth(String btc, String sat) {
    return '$btc BTC · $sat sat';
  }

  @override
  String toolsTxHiddenFields(int count) {
    return 'Altri $count campi non sono mostrati.';
  }

  @override
  String get toolsTxErrorNotHex =>
      'L\'input è vuoto, ha un numero dispari di cifre o non è esadecimale.';

  @override
  String get toolsTxErrorTruncated =>
      'I dati finiscono prima che un campo sia completo. La transazione potrebbe essere troncata.';

  @override
  String get toolsTxErrorTrailing =>
      'Ci sono byte dopo l\'ultimo campo. Controlla che la transazione sia completa e non abbia dati in più.';

  @override
  String get toolsTxErrorTooLarge =>
      'La transazione supera 400000 byte, il limite di questo strumento.';

  @override
  String get toolsTxErrorInvalid =>
      'Un valore è fuori dai limiti di una transazione, oppure il flag segwit non è riconosciuto.';

  @override
  String get toolsFieldVersion => 'Versione';

  @override
  String get toolsFieldMarker => 'Marker';

  @override
  String get toolsFieldFlag => 'Flag';

  @override
  String get toolsFieldInputCount => 'Numero di input';

  @override
  String get toolsFieldPreviousTxid => 'Txid precedente';

  @override
  String get toolsFieldPreviousIndex => 'Indice dell\'output precedente';

  @override
  String get toolsFieldScriptSigLength => 'Lunghezza di scriptSig';

  @override
  String get toolsFieldScriptSig => 'scriptSig';

  @override
  String get toolsFieldSequence => 'Sequence';

  @override
  String get toolsFieldOutputCount => 'Numero di output';

  @override
  String get toolsFieldValue => 'Valore';

  @override
  String get toolsFieldScriptPubKeyLength => 'Lunghezza di scriptPubKey';

  @override
  String get toolsFieldScriptPubKey => 'scriptPubKey';

  @override
  String get toolsFieldWitnessItemCount => 'Numero di elementi witness';

  @override
  String get toolsFieldWitnessItemLength => 'Lunghezza elemento witness';

  @override
  String get toolsFieldWitnessItem => 'Elemento witness';

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
  String get toolsScriptWitnessUnknown => 'Programma witness sconosciuto';

  @override
  String get toolsScriptBareMultisig => 'Multisig nudo';

  @override
  String get toolsScriptOpReturn => 'Dati OP_RETURN';

  @override
  String get toolsScriptNonStandard => 'Non standard';

  @override
  String get toolsTargetTitle => 'Target';

  @override
  String get toolsTargetHint =>
      'Bits, 8 cifre esadecimali, per esempio 1d00ffff';

  @override
  String get toolsTargetInvalid =>
      'Inserisci esattamente 8 cifre esadecimali, con il prefisso 0x facoltativo.';

  @override
  String get toolsTargetTargetLabel => 'Target';

  @override
  String get toolsTargetDifficulty => 'Difficoltà';

  @override
  String get toolsTargetExpected => 'Hash attesi per blocco';

  @override
  String toolsTargetScientific(String mantissa, int exponent) {
    return 'Circa $mantissa × 10^$exponent';
  }

  @override
  String get toolsTargetNote =>
      'Il target è il numero che l\'hash di un blocco deve restare sotto. La difficoltà lo confronta con il target massimo, 1d00ffff. Gli hash attesi sono il numero medio di tentativi necessari per trovare un blocco valido.';

  @override
  String get toolsUnitsTitle => 'Unità';

  @override
  String get toolsUnitsBtcSatTitle => 'BTC e satoshi';

  @override
  String get toolsUnitsBtcLabel => 'BTC';

  @override
  String get toolsUnitsSatLabel => 'Satoshi';

  @override
  String get toolsUnitsDecimalsError =>
      'Gli importi bitcoin hanno al massimo 8 decimali.';

  @override
  String get toolsUnitsInvalidAmount =>
      'Inserisci un importo decimale, per esempio 0,001.';

  @override
  String get toolsUnitsInvalidWhole =>
      'Inserisci un numero intero, zero o più.';

  @override
  String get toolsUnitsWeightTitle => 'Weight unit in byte virtuali';

  @override
  String get toolsUnitsWeightLabel => 'Weight unit (WU)';

  @override
  String toolsUnitsVbytesResult(int vbytes) {
    return '$vbytes vB';
  }

  @override
  String get toolsUnitsRateFromFeeTitle => 'Fee rate dalla fee';

  @override
  String get toolsUnitsFeeLabel => 'Fee (satoshi)';

  @override
  String get toolsUnitsVsizeLabel => 'Dimensione virtuale (vB)';

  @override
  String toolsUnitsRateResult(String rate) {
    return '$rate sat/vB';
  }

  @override
  String get toolsUnitsFeeFromRateTitle => 'Fee dalla fee rate';

  @override
  String get toolsUnitsRateLabel => 'Fee rate (sat/vB)';

  @override
  String toolsUnitsFeeResult(int sat) {
    return '$sat sat';
  }

  @override
  String get toolsUnitsRateInvalid =>
      'Inserisci una fee rate di zero o più, per esempio 2,5.';

  @override
  String get toolsUnitsVsizePositive =>
      'La dimensione virtuale deve essere maggiore di zero.';

  @override
  String get toolsUnitsResult => 'Risultato';

  @override
  String get toolsUnitsNote =>
      'Solo unità, nessun prezzo né valuta. Gli importi usano aritmetica intera, quindi non c\'è arrotondamento.';

  @override
  String get toolsReferencesTitle => 'Tabelle di riferimento';

  @override
  String get toolsReferencesEmpty => 'Nessuna tabella di riferimento per ora.';

  @override
  String toolsRowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count righe',
      one: '1 riga',
    );
    return '$_temp0';
  }

  @override
  String get toolsReferenceFilterHint => 'Filtra le righe';

  @override
  String get toolsReferenceNoMatch => 'Nessuna riga corrisponde al filtro.';
}
