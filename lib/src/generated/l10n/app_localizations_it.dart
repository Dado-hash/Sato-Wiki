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
      'Sette passi: hash, blocco, catena, rete, transazioni, coinbase, un header reale.';

  @override
  String get toolsScriptName => 'Script passo per passo';

  @override
  String get toolsScriptCaption => 'Guarda lo stack dopo ogni opcode.';

  @override
  String get toolsExplorerName => 'Explorer';

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

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryEmpty => 'Nessuna opera in biblioteca per ora.';

  @override
  String get libraryNoMatch => 'Nessuna opera corrisponde al filtro.';

  @override
  String get libraryAuthorLabel => 'Autore';

  @override
  String get libraryTopicLabel => 'Argomento';

  @override
  String get libraryYearLabel => 'Anno';

  @override
  String get libraryKindLabel => 'Tipo';

  @override
  String get libraryOriginalLanguageLabel => 'Lingua originale';

  @override
  String get libraryLicenseLabel => 'Licenza';

  @override
  String get libraryKindPaper => 'Paper';

  @override
  String get libraryKindEssay => 'Saggio';

  @override
  String get libraryKindPost => 'Post';

  @override
  String get libraryKindEmail => 'Email';

  @override
  String get libraryKindBook => 'Libro';

  @override
  String get libraryKindManifesto => 'Manifesto';

  @override
  String get libraryNotFound => 'Opera non trovata';

  @override
  String get libraryReadOriginal => 'Leggi l\'originale';

  @override
  String get libraryArchivedCopy => 'Copia archiviata';

  @override
  String get libraryIntroduction => 'La nostra introduzione';

  @override
  String get libraryNotice =>
      'SatoWiki non ospita il testo integrale. L\'originale si apre nel browser.';

  @override
  String get librarySearchTypeGlossary => 'Glossario';

  @override
  String get librarySearchTypeProduct => 'Prodotto';

  @override
  String get librarySearchTypeReference => 'Riferimento';

  @override
  String get librarySearchTypeLibrary => 'Biblioteca';

  @override
  String get connectTryIt => 'Prova';

  @override
  String get connectQuotesTitle => 'Con le loro parole';

  @override
  String get connectLibraryTitle => 'Biblioteca';

  @override
  String connectLibraryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opere',
      one: '1 opera',
    );
    return '$_temp0';
  }

  @override
  String get connectHashTitle => 'Strumento hash';

  @override
  String get connectHashCaption => 'Calcola SHA-256 e HASH160 di un testo';

  @override
  String get connectAddressTitle => 'Strumento indirizzo';

  @override
  String get connectAddressCaption =>
      'Verifica tipo e checksum di un indirizzo';

  @override
  String get connectTransactionTitle => 'Strumento transazione';

  @override
  String get connectTransactionCaption =>
      'Decodifica una transazione grezza campo per campo';

  @override
  String get connectTargetTitle => 'Strumento target';

  @override
  String get connectTargetCaption => 'Converti bit, target e difficoltà';

  @override
  String get connectUnitsTitle => 'Strumento unità';

  @override
  String get connectUnitsCaption => 'Converti sat, BTC e vB';

  @override
  String get connectScriptTitle => 'Script passo per passo';

  @override
  String get connectScriptCaption => 'Guarda lo stack dopo ogni opcode';

  @override
  String get connectLabTitle => 'Laboratorio blockchain';

  @override
  String get connectLabCaption =>
      'Costruisci e rompi una piccola blockchain, passo per passo';

  @override
  String connectLabStepTitle(int step) {
    return 'Laboratorio blockchain, passo $step';
  }

  @override
  String get connectLabStep1Caption =>
      'Scrivi un testo e guarda cambiare il suo hash';

  @override
  String get connectLabStep2Caption =>
      'Mina un blocco: trova un nonce che lo renda valido';

  @override
  String get connectLabStep3Caption =>
      'Cambia un blocco e guarda rompersi quelli successivi';

  @override
  String get connectLabStep6Caption =>
      'Esamina la transazione coinbase che paga il miner';

  @override
  String get connectLabStep7Caption =>
      'Leggi l\'header di 80 byte che ogni blocco contiene';

  @override
  String get explorerTitle => 'Explorer';

  @override
  String get explorerStateOn => 'Attivo';

  @override
  String get explorerStateOff => 'Spento';

  @override
  String explorerStateOnServer(String host) {
    return 'Attivo · $host';
  }

  @override
  String get explorerSetupTitle => 'Prima di attivare';

  @override
  String get explorerSetupIntro =>
      'L\'explorer chiede i dati a un server su internet. Il resto dell\'app funziona senza rete.';

  @override
  String get explorerSetupWhatServerSees =>
      'Ogni ricerca viene inviata al server qui sotto. Chi gestisce il server può vedere il tuo indirizzo IP e cosa cerchi.';

  @override
  String get explorerSetupOwnAddresses =>
      'Se cerchi i tuoi indirizzi, il server può collegarli al tuo indirizzo IP.';

  @override
  String get explorerSetupNothingSent =>
      'Quando la schermata dell\'explorer è aperta, chiede al server blocchi, commissioni e mempool ogni 60 secondi. Le ricerche partono solo quando premi Cerca e non vengono salvate sul dispositivo. L\'explorer non usa Tor né proxy.';

  @override
  String get explorerServerLabel => 'Server';

  @override
  String get explorerServerField => 'Indirizzo del server';

  @override
  String get explorerServerHelp =>
      'Usa https. Http semplice funziona solo per localhost e per indirizzi .onion e .local.';

  @override
  String get explorerServerInvalid =>
      'Questo indirizzo non è ammesso. Usa https, o http solo per localhost, .onion o .local. Non è stato salvato.';

  @override
  String get explorerTurnOn => 'Attiva l\'explorer';

  @override
  String get explorerTurnOff => 'Spegni l\'explorer';

  @override
  String get explorerTurnOffShort => 'Spegni';

  @override
  String get explorerTurnOffNote => 'Puoi riattivarlo dalle Impostazioni.';

  @override
  String get explorerSaveServer => 'Salva server';

  @override
  String get explorerServerSaved => 'Server salvato.';

  @override
  String get explorerOffTitle => 'L\'explorer è spento';

  @override
  String get explorerOffBody =>
      'Finché è spento non viene inviato nulla a nessun server.';

  @override
  String get explorerSearchHint => 'Altezza, hash del blocco, txid o indirizzo';

  @override
  String get explorerSearchButton => 'Cerca';

  @override
  String get explorerSecretWifTitle => 'Sembra una chiave privata';

  @override
  String get explorerSecretExtendedTitle => 'Sembra una chiave estesa';

  @override
  String get explorerSecretBody =>
      'Non è stato inviato nulla e il campo è stato svuotato. Non incollare mai una chiave privata in app o siti.';

  @override
  String get explorerInvalidInput =>
      'Inserisci un’altezza di blocco, un hash o un txid di 64 caratteri, oppure un indirizzo.';

  @override
  String get explorerLookingUp => 'Ricerca in corso…';

  @override
  String get explorerNotFound =>
      'Il server non conosce questo blocco, questa transazione o questo indirizzo.';

  @override
  String get explorerNetworkError =>
      'Non è stato possibile raggiungere il server. Controlla la connessione e riprova.';

  @override
  String get explorerBadResponse =>
      'Il server ha inviato una risposta che l\'explorer non sa leggere.';

  @override
  String explorerRateLimited(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Riprova tra $seconds secondi.',
      one: 'Riprova tra 1 secondo.',
    );
    return 'Troppe richieste. Il server ha chiesto di rallentare. $_temp0';
  }

  @override
  String get explorerNoAutoRetry => 'L\'explorer non riprova da solo.';

  @override
  String get explorerRetry => 'Riprova';

  @override
  String get explorerBlockTitle => 'Blocco';

  @override
  String get explorerTransactionTitle => 'Transazione';

  @override
  String get explorerAddressTitle => 'Indirizzo';

  @override
  String get explorerHeight => 'Altezza';

  @override
  String get explorerHash => 'Hash';

  @override
  String get explorerTxid => 'Txid';

  @override
  String get explorerTime => 'Ora';

  @override
  String get explorerTransactionCount => 'Transazioni';

  @override
  String get explorerSize => 'Dimensione';

  @override
  String get explorerWeight => 'Peso';

  @override
  String get explorerMerkleRoot => 'Merkle root';

  @override
  String get explorerPreviousBlock => 'Blocco precedente';

  @override
  String get explorerNonce => 'Nonce';

  @override
  String get explorerBits => 'Bits';

  @override
  String get explorerDifficulty => 'Difficoltà';

  @override
  String get explorerVersion => 'Versione';

  @override
  String get explorerStatus => 'Stato';

  @override
  String get explorerConfirmed => 'Confermata';

  @override
  String get explorerUnconfirmed => 'Non confermata';

  @override
  String get explorerBlockOfTransaction => 'Blocco';

  @override
  String get explorerFee => 'Fee';

  @override
  String get explorerFeeRate => 'Fee rate';

  @override
  String explorerFeeRateValue(String rate) {
    return '$rate sat/vB';
  }

  @override
  String get explorerInputs => 'Input';

  @override
  String get explorerOutputs => 'Output';

  @override
  String explorerInputNumber(int index) {
    return 'Input $index';
  }

  @override
  String explorerOutputNumber(int index) {
    return 'Output $index';
  }

  @override
  String get explorerCoinbase => 'Coinbase, nessun output precedente';

  @override
  String explorerAmount(String btc, String sat) {
    return '$btc BTC · $sat sat';
  }

  @override
  String get explorerScriptType => 'Tipo di script';

  @override
  String get explorerBlockUnknown => 'Non ancora in un blocco';

  @override
  String get explorerAddressReceived => 'Ricevuto';

  @override
  String get explorerAddressSpent => 'Speso';

  @override
  String get explorerAddressBalance => 'Saldo';

  @override
  String get explorerAddressMempool => 'Mempool';

  @override
  String get explorerAddressTransactions => 'Ultime transazioni';

  @override
  String get explorerAddressFirstPage =>
      'Viene mostrata solo la prima pagina del server.';

  @override
  String get explorerNoTransactions =>
      'Nessuna transazione trovata per questo indirizzo.';

  @override
  String get explorerLoading => 'Caricamento…';

  @override
  String explorerDashLive(String host) {
    return 'Live · $host';
  }

  @override
  String explorerDashLivePaused(String host) {
    return 'In pausa · $host';
  }

  @override
  String get explorerDashBlocks => 'Blocchi';

  @override
  String get explorerDashBlocksHint => 'In coda ← · → confermati';

  @override
  String get explorerDashNow => 'Ora';

  @override
  String get explorerDashNext => 'Prossimo';

  @override
  String get explorerDashQueued => 'In coda';

  @override
  String explorerDashMinutes(int minutes) {
    return '~$minutes min';
  }

  @override
  String explorerDashMoreBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count blocchi',
      one: '+1 blocco',
    );
    return '$_temp0';
  }

  @override
  String explorerDashBlockAgo(int minutes) {
    return '$minutes min fa';
  }

  @override
  String explorerDashMedianRate(String rate) {
    return '~$rate sat/vB';
  }

  @override
  String explorerDashRange(String min, String max) {
    return '$min–$max sat/vB';
  }

  @override
  String explorerDashBtc(String btc) {
    return '$btc BTC';
  }

  @override
  String explorerDashTxCount(String count) {
    return '$count tx';
  }

  @override
  String explorerDashSizeMb(String size) {
    return '$size MB';
  }

  @override
  String explorerDashWeightMwu(String weight) {
    return '$weight MWU';
  }

  @override
  String get explorerDashFeesTitle => 'Commissioni consigliate';

  @override
  String get explorerDashFeeNoPriority => 'Senza fretta';

  @override
  String get explorerDashFeeLow => 'Bassa';

  @override
  String get explorerDashFeeMedium => 'Media';

  @override
  String get explorerDashFeeHigh => 'Alta';

  @override
  String get explorerDashFeeDay => '~1 giorno';

  @override
  String get explorerDashFeeHour => '~1 ora';

  @override
  String explorerDashTypicalTx(String sats) {
    return 'Tx tipica da 140 vB con priorità alta: ~$sats sat';
  }

  @override
  String get explorerDashMempoolTitle => 'Mempool';

  @override
  String explorerDashBandsLabel(String bands) {
    return 'Quota dei vbyte per commissione: $bands';
  }

  @override
  String explorerDashVsizeMb(String size) {
    return '$size vMB';
  }

  @override
  String get explorerDashTotalFees => 'Commissioni totali';

  @override
  String get explorerDashToClear => 'Da svuotare';

  @override
  String explorerDashBlocksToClear(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~$count blocchi',
      one: '~1 blocco',
    );
    return '$_temp0';
  }

  @override
  String get explorerDashEstimate => 'Stima';

  @override
  String get explorerDashEpoch => 'Epoca';

  @override
  String explorerDashEpochProgress(String done, String total) {
    return '$done blocchi su $total in questa epoca';
  }

  @override
  String get explorerDashRemaining => 'Mancano';

  @override
  String explorerDashRemainingDays(String blocks, String days) {
    return '$blocks · ~$days g';
  }

  @override
  String explorerDashRemainingHours(String blocks, String hours) {
    return '$blocks · ~$hours h';
  }

  @override
  String get explorerDashAverageBlock => 'Blocco medio';

  @override
  String get explorerDashLatestTxs => 'Ultime transazioni';

  @override
  String explorerDashTxVsize(String vsize) {
    return '$vsize vB';
  }

  @override
  String explorerDashFooterUpdated(String time, int interval) {
    return 'Aggiornato alle $time · ogni $interval s mentre la schermata è aperta';
  }

  @override
  String get explorerDashPaused => 'In pausa';

  @override
  String get explorerDashUpdateFailed =>
      'L\'ultimo aggiornamento non è riuscito. Restano i dati precedenti.';

  @override
  String get explorerDashPause => 'Metti in pausa';

  @override
  String get explorerDashResume => 'Riprendi';

  @override
  String get explorerDashFeesDerived => 'Stime dalla mempool';

  @override
  String explorerDashPrivacy(int count, String host) {
    return 'Ogni aggiornamento invia $count richieste a $host. Il server vede il tuo indirizzo IP. Le ricerche non vengono salvate.';
  }

  @override
  String get labTitle => 'Laboratorio blockchain';

  @override
  String get labIntro =>
      'Una piccola blockchain che puoi cambiare e riparare, un\'idea alla volta. I blocchi qui sono un modello didattico, non il protocollo reale.';

  @override
  String get labIndexSteps => 'Passi';

  @override
  String labStepCounter(int current, int total) {
    return 'Passo $current di $total';
  }

  @override
  String get labStepOptional => 'Facoltativo';

  @override
  String get labStepTitle1 => 'Hash';

  @override
  String get labStepDesc1 =>
      'Scrivi un testo e guarda cambiare la sua impronta.';

  @override
  String get labStepTitle2 => 'Mina un blocco';

  @override
  String get labStepDesc2 =>
      'Cambia i dati, poi cerca un nonce che faccia iniziare l\'hash con gli zeri.';

  @override
  String get labStepTitle3 => 'Catena';

  @override
  String get labStepDesc3 =>
      'Cambia un blocco e guarda spezzarsi tutti quelli dopo.';

  @override
  String get labStepTitle4 => 'Rete';

  @override
  String get labStepDesc4 =>
      'Più copie della catena. Un nodo tiene solo una copia valida.';

  @override
  String get labStepTitle5 => 'Transazioni';

  @override
  String get labStepDesc5 => 'Trasforma i trasferimenti nei dati di un blocco.';

  @override
  String get labStepTitle6 => 'Coinbase';

  @override
  String get labStepDesc6 => 'La prima transazione di un blocco paga il miner.';

  @override
  String get labStepTitle7 => 'Un header reale';

  @override
  String get labStepDesc7 =>
      'Decodifica gli 80 byte del blocco genesi e calcolane l\'hash.';

  @override
  String get labDifference => 'In Bitcoin è diverso';

  @override
  String get labDiff1 =>
      'Un vero hash di blocco è SHA-256 applicato due volte a un header di 80 byte, non a una riga di testo.';

  @override
  String get labDiff2 =>
      'L\'header è di 80 byte, l\'hash è un doppio SHA-256 e la regola è un target numerico, non un numero di zeri.';

  @override
  String get labDiff3 =>
      'I nodi reali seguono la catena con più lavoro accumulato, non una regola che conta gli zeri. Ogni blocco è verificato contro il target nel suo header.';

  @override
  String get labDiff4 =>
      'I nodi reali controllano anche ogni transazione e ogni firma, e inoltrano i blocchi ai peer. Questo laboratorio controlla solo i blocchi, su questo dispositivo.';

  @override
  String get labDiff5 =>
      'Le transazioni reali spendono output precedenti, e ogni input porta una firma. Qui un trasferimento è solo una riga di testo.';

  @override
  String get labDiff6 =>
      'Il sussidio si dimezza ogni 210.000 blocchi, circa ogni quattro anni, e gli output della coinbase non si possono spendere per 100 blocchi.';

  @override
  String get labDiff7 =>
      'Questo è il formato reale dell\'header. Il target deriva da bits, e l\'hash è un doppio SHA-256 di questi 80 byte.';

  @override
  String get labPreviousStep => 'Passo precedente';

  @override
  String get labNextStep => 'Passo successivo';

  @override
  String get labValid => 'Valido';

  @override
  String get labNotValid => 'Non valido';

  @override
  String labBlockNumber(int number) {
    return 'Blocco $number';
  }

  @override
  String get labHashHint => 'Scrivi un testo qualsiasi';

  @override
  String get labHashIntro =>
      'Scrivi nel campo. Ogni tasto produce una nuova impronta del testo.';

  @override
  String get labHashLabel => 'SHA-256 del testo';

  @override
  String get labHashNote =>
      'Cambia una lettera, una maiuscola o uno spazio e l\'hash cambia del tutto. Lo stesso testo dà sempre lo stesso hash.';

  @override
  String get labMineIntro =>
      'Cambia i dati, poi cerca un nonce che faccia iniziare l\'hash con degli zeri. Modificare i dati rende di nuovo il blocco non valido.';

  @override
  String get labBlockData => 'Dati';

  @override
  String get labBlockPrevious => 'Hash precedente';

  @override
  String get labBlockNonce => 'Nonce';

  @override
  String get labBlockHash => 'Hash';

  @override
  String labMineRule(int zeros) {
    return 'Regola: l\'hash inizia con $zeros zeri';
  }

  @override
  String get labMineButton => 'Mina';

  @override
  String get labMineCancel => 'Annulla';

  @override
  String get labMineRunning => 'Mining in corso. Annulla ferma la ricerca.';

  @override
  String get labMineAttempts => 'Tentativi';

  @override
  String get labMineSpeed => 'Velocità';

  @override
  String labMineSpeedValue(String rate) {
    return '$rate hash/s';
  }

  @override
  String labMineFound(int attempts) {
    return 'Nonce trovato dopo $attempts tentativi.';
  }

  @override
  String get labMineStopped => 'Ricerca fermata. Il nonce non cambia.';

  @override
  String get labMineGaveUp =>
      'Nessun nonce trovato in questa prova. Cambia i dati o riprova.';

  @override
  String get labChainIntro =>
      'Tre blocchi, ognuno collegato all\'hash del precedente. Cambia i dati di un blocco e guarda cosa succede a quelli dopo.';

  @override
  String get labChainRemine => 'Mina di nuovo';

  @override
  String get labChainWhy =>
      'Il blocco 3 contiene l\'hash vecchio del blocco 2. Per sistemare la catena bisogna minare di nuovo il 2 e tutti i successivi.';

  @override
  String get labNetworkIntro =>
      'Tre nodi, ognuno con la sua copia della catena. Un nodo tiene una copia solo se ogni suo blocco è valido.';

  @override
  String labNetworkNode(String name) {
    return 'Nodo $name';
  }

  @override
  String get labNetworkKeeps => 'Tiene questa copia';

  @override
  String get labNetworkRejects => 'Rifiuta questa copia';

  @override
  String get labNetworkTamper => 'Cambia i dati sul nodo B';

  @override
  String get labNetworkRestore => 'Ripristina il nodo B';

  @override
  String get labTxIntro =>
      'Ogni riga è un trasferimento. I dati del blocco sono l\'elenco delle righe, e l\'hash del blocco dipende da ogni carattere.';

  @override
  String get labTxFrom => 'Da';

  @override
  String get labTxTo => 'A';

  @override
  String get labTxAmount => 'Importo';

  @override
  String get labTxAdd => 'Aggiungi trasferimento';

  @override
  String get labTxRemove => 'Rimuovi trasferimento';

  @override
  String get labTxAmountError => 'Inserisci un numero intero, zero o più.';

  @override
  String get labTxNameError => 'I nomi non possono essere vuoti.';

  @override
  String get labTxEmpty =>
      'Nessun trasferimento. Aggiungine uno per costruire il blocco.';

  @override
  String get labTxData => 'Dati del blocco';

  @override
  String get labTxBlockHash => 'Hash del blocco';

  @override
  String get labCoinbaseIntro =>
      'La prima riga di ogni blocco è la coinbase: unità nuove pagate al miner, senza mittente. Cambia il nome del miner e mina di nuovo.';

  @override
  String get labCoinbaseMiner => 'Nome del miner';

  @override
  String labCoinbaseReward(String amount) {
    return 'Ricompensa: $amount unità';
  }

  @override
  String get labHeaderIntro =>
      'Questo è il blocco genesi di Bitcoin, minato nel gennaio 2009. Il suo header è di 80 byte, e ogni campo qui sotto si legge da questi byte.';

  @override
  String get labHeaderVersion => 'Versione';

  @override
  String get labHeaderMerkle => 'Radice di Merkle';

  @override
  String get labHeaderTime => 'Tempo';

  @override
  String get labHeaderBits => 'Bits';

  @override
  String get labHeaderFields => 'Campi decodificati';

  @override
  String get labHeaderBytes => '80 byte, serializzati';

  @override
  String get labHeaderDoubleHash => 'Doppio SHA-256';

  @override
  String get labHeaderTarget => 'Target';

  @override
  String get labHeaderBelowTarget => 'Hash sotto il target';

  @override
  String get labScriptTitle => 'Script passo per passo';

  @override
  String get labScriptIntro =>
      'Esegui uno script un opcode alla volta. Lo stack mostra cosa lascia ogni opcode.';

  @override
  String get labScriptSimulated =>
      'I controlli delle firme sono simulati in questo interprete didattico. Una firma è valida solo se l\'esempio la elenca come valida. Non si controllano chiavi o firme reali. Non è codice di consenso.';

  @override
  String get labScriptExampleLabel => 'Esempio';

  @override
  String get labScriptCustomChip => 'Il tuo script';

  @override
  String get labScriptCustomHint =>
      'Scrivi ASM, per esempio 2 3 OP_ADD 5 OP_EQUAL';

  @override
  String get labScriptCustomNote =>
      'Uno script scritto a mano non ha transazione né firme simulate: gli opcode di firma e di timelock non possono riuscire.';

  @override
  String get labScriptSourceLabel => 'Script';

  @override
  String get labScriptStep => 'Passo';

  @override
  String get labScriptRunToEnd => 'Esegui fino in fondo';

  @override
  String get labScriptReset => 'Azzera';

  @override
  String get labScriptNotStarted => 'Non avviato';

  @override
  String labScriptRunCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opcodi eseguiti',
      one: '1 opcode eseguito',
    );
    return '$_temp0';
  }

  @override
  String get labScriptRemaining => 'Script rimanente';

  @override
  String get labScriptNextLabel => 'Prossimo';

  @override
  String get labScriptNothingLeft => 'Non resta nulla da eseguire.';

  @override
  String get labScriptStack => 'Stack';

  @override
  String get labScriptAltStack => 'Alt stack';

  @override
  String get labScriptTopLabel => 'Cima';

  @override
  String get labScriptEmptyStack => 'Lo stack è vuoto.';

  @override
  String get labScriptEmptyItem => 'vuoto';

  @override
  String get labScriptResult => 'Esito';

  @override
  String get labScriptSucceeds => 'Lo script riesce';

  @override
  String labScriptFails(String reason) {
    return 'Lo script fallisce: $reason';
  }

  @override
  String labScriptParseError(int index, String reason) {
    return 'Il token $index non si legge: $reason';
  }

  @override
  String get labScriptFalseTop =>
      'l\'elemento in cima è falso o lo stack è vuoto';

  @override
  String get labScriptParseUnknown =>
      'non è un opcode, un numero, hex o testo tra apici';

  @override
  String get labScriptParseInvalidHex => 'non è hex valido';

  @override
  String get labScriptParseInvalidNumber => 'non è un numero valido';

  @override
  String get labScriptParseUnterminated => 'il testo tra apici non si chiude';

  @override
  String get labScriptParseTruncated => 'un push supera la fine dello script';

  @override
  String get labScriptNoteSignature =>
      'Questa firma è stata controllata sull\'insieme simulato.';

  @override
  String get labScriptNoteTimelockOk => 'Il timelock è soddisfatto.';

  @override
  String get labScriptNoteTimelockNo => 'Il timelock non è soddisfatto.';

  @override
  String get labScriptNoteTimelockOff =>
      'Il timelock relativo è disattivato, quindi questo opcode non fa nulla.';

  @override
  String get labScriptNoteContext =>
      'Questo opcode richiede una transazione, e questa demo non ne ha.';

  @override
  String get labScriptErrStackUnderflow =>
      'un opcode richiedeva più elementi di quanti ne ha lo stack';

  @override
  String get labScriptErrAltStackUnderflow =>
      'FROMALTSTACK è stato eseguito con l\'alt stack vuoto';

  @override
  String get labScriptErrVerifyFailed =>
      'un opcode VERIFY ha trovato un valore falso';

  @override
  String get labScriptErrEqualVerifyFailed =>
      'EQUALVERIFY ha trovato due elementi diversi';

  @override
  String get labScriptErrNumEqualVerifyFailed =>
      'NUMEQUALVERIFY ha trovato due numeri diversi';

  @override
  String get labScriptErrOpReturn => 'OP_RETURN rende l\'output non spendibile';

  @override
  String get labScriptErrDisabledOpcode =>
      'nello script c\'è un opcode disattivato';

  @override
  String get labScriptErrUnsupportedOpcode =>
      'questo opcode non è implementato qui';

  @override
  String get labScriptErrUnbalancedConditional =>
      'IF, ELSE e ENDIF non corrispondono';

  @override
  String get labScriptErrNumberOverflow => 'un numero è più lungo di 4 byte';

  @override
  String get labScriptErrNonMinimalNumber =>
      'un numero non è codificato in modo minimo';

  @override
  String get labScriptErrPushTooLarge => 'un push è più lungo di 520 byte';

  @override
  String get labScriptErrStackTooLarge =>
      'gli stack contengono più di 1000 elementi';

  @override
  String get labScriptErrOpCountExceeded =>
      'sono stati eseguiti più di 201 opcode';

  @override
  String get labScriptErrBadPickIndex =>
      'PICK o ROLL chiedono una profondità che lo stack non ha';

  @override
  String get labScriptErrKeyCountOutOfRange =>
      'CHECKMULTISIG chiede meno di 0 o più di 20 chiavi';

  @override
  String get labScriptErrSigCountOutOfRange =>
      'CHECKMULTISIG chiede più firme delle chiavi';

  @override
  String get labScriptErrNegativeLockTime =>
      'l\'operando di un timelock è negativo';

  @override
  String get labScriptErrLockTimeNotReached =>
      'il lock time della transazione è troppo presto';

  @override
  String get labScriptErrLockTimeTypeMismatch =>
      'il timelock conta blocchi ma la transazione conta tempo, o il contrario';

  @override
  String get labScriptErrInputSequenceFinal =>
      'la sequence dell\'input è finale, quindi il lock time non si può usare';

  @override
  String get labScriptErrInputSequenceDisabled =>
      'la sequence dell\'input disattiva i timelock relativi';

  @override
  String get labScriptErrTxVersionTooLow =>
      'i timelock relativi richiedono la versione di transazione 2 o superiore';

  @override
  String get labScriptErrMissingContext =>
      'un opcode di timelock richiede una transazione, e non ce n\'è una';

  @override
  String get labScriptErrScriptTooLarge =>
      'lo script è più lungo di 10.000 byte';

  @override
  String get labScriptExArithmeticName => 'Aritmetica';

  @override
  String get labScriptExArithmeticDesc =>
      'Somma due numeri e controlla il risultato.';

  @override
  String get labScriptExP2pkhName => 'Pagamento a hash di chiave pubblica';

  @override
  String get labScriptExP2pkhDesc =>
      'Il blocco classico: una chiave pubblica, una firma e il controllo di un hash.';

  @override
  String get labScriptExMultisigName => 'Multisig 2 di 3';

  @override
  String get labScriptExMultisigDesc => 'Servono due delle tre firme simulate.';

  @override
  String get labScriptExHashlockName => 'Hashlock';

  @override
  String get labScriptExHashlockDesc =>
      'Il segreto è il testo di cui è bloccato l\'SHA-256.';

  @override
  String get labScriptExCltvName => 'Timelock assoluto';

  @override
  String get labScriptExCltvDesc =>
      'CHECKLOCKTIMEVERIFY: la spesa attende un\'altezza di blocco.';

  @override
  String get labScriptExCsvName => 'Timelock relativo';

  @override
  String get labScriptExCsvDesc =>
      'CHECKSEQUENCEVERIFY: l\'input deve avere un\'età sufficiente.';

  @override
  String get labScriptExHtlcName => 'HTLC, reclamato';

  @override
  String get labScriptExHtlcDesc =>
      'Il ricevente rivela il segreto prima del timeout.';

  @override
  String get labScriptExHtlcRefundName => 'HTLC, rimborso';

  @override
  String get labScriptExHtlcRefundDesc =>
      'Dopo il timeout il mittente riprende i fondi.';

  @override
  String get toolsDiceTileName => 'Dadi → Seed';

  @override
  String get toolsDiceTileCaption =>
      'Tira dadi veri, ottieni una seed BIP39 offline';

  @override
  String get toolsDiceTitle => 'Dadi → Seed';

  @override
  String get toolsDiceEyebrow => 'STRUMENTO OFFLINE';

  @override
  String get toolsDiceIntro =>
      'Tira dei dadi veri, la fotocamera li legge sul telefono e SatoWiki trasforma i tiri in una seed BIP39. Niente rete, niente salvataggi: quando esci, tutto viene cancellato.';

  @override
  String get toolsDiceLengthLabel => 'Lunghezza della seed';

  @override
  String toolsDiceWords(int count) {
    return '$count parole';
  }

  @override
  String toolsDiceLengthSummary(int rolls, int bits, int throws) {
    return '$rolls tiri · $bits bit di entropia · ~$throws lanci da 5 dadi';
  }

  @override
  String get toolsDiceChecklistTitle => 'PRIMA DI INIZIARE';

  @override
  String get toolsDiceCheckAirplane => 'Attiva la modalità aereo';

  @override
  String get toolsDiceCheckAirplaneCaption =>
      'La sandbox funziona senza rete. Così nessun dato può uscire.';

  @override
  String get toolsDiceCheckAirplaneOffline =>
      'Nessuna rete rilevata. Sei pronto.';

  @override
  String get toolsDiceCheckAirplaneOpenSettings =>
      'Ancora online. Tocca per aprire le impostazioni della modalità aereo.';

  @override
  String get toolsDiceCheckAirplaneOpenSettingsHint =>
      'Apre le impostazioni di sistema';

  @override
  String get toolsDiceCheckAirplaneControlCenter =>
      'Ancora online. Attiva la modalità aereo dal Centro di Controllo.';

  @override
  String get toolsDiceCheckPrivate => 'Scegli un posto riservato';

  @override
  String get toolsDiceCheckPrivateCaption =>
      'Nessuno alle spalle, nessuna telecamera puntata sul foglio.';

  @override
  String get toolsDiceCheckPaper => 'Prepara carta e penna';

  @override
  String get toolsDiceCheckPaperCaption =>
      'Trascriverai le parole a mano. Non c\'è copia né screenshot.';

  @override
  String get toolsDiceCheckDice => 'Dadi ben visibili su fondo chiaro';

  @override
  String get toolsDiceCheckDiceCaption =>
      'Funziona meglio con dadi contrastati su un foglio bianco.';

  @override
  String get toolsDiceSandboxInfoTitle => 'Cosa succede nella sandbox';

  @override
  String get toolsDiceSandboxInfo1 =>
      'Screenshot e registrazione schermo bloccati';

  @override
  String get toolsDiceSandboxInfo2 =>
      'Le immagini restano in memoria, mai su disco';

  @override
  String get toolsDiceSandboxInfo3 =>
      'Uscendo o chiudendo l\'app, tiri e parole vengono cancellati';

  @override
  String get toolsDiceEnter => 'Entra nella sandbox';

  @override
  String get toolsDiceHowMath => 'Come funziona la matematica';

  @override
  String get toolsDiceSandboxActive => 'SANDBOX ATTIVA';

  @override
  String get toolsDiceOffline => 'OFFLINE';

  @override
  String get toolsDiceOnline => 'ONLINE';

  @override
  String get toolsDiceOnlineWarning =>
      'Sei online. Attiva la modalità aereo per la massima sicurezza.';

  @override
  String get toolsDiceExit => 'Esci e cancella';

  @override
  String get toolsDiceExitConfirmTitle => 'Cancellare la sessione?';

  @override
  String get toolsDiceExitConfirmBody =>
      'Tiri e parole verranno cancellati e non si possono recuperare.';

  @override
  String get toolsDiceExitConfirm => 'Cancella';

  @override
  String get toolsDiceCancel => 'Annulla';

  @override
  String get toolsDiceLive => 'LIVE · ON-DEVICE';

  @override
  String get toolsDiceHoldStill => 'Dadi fermi: cattura in corso…';

  @override
  String get toolsDiceAimCamera => 'Inquadra i dadi';

  @override
  String get toolsDiceCameraUnavailable =>
      'Il riconoscimento dei dadi non è disponibile su questo dispositivo. Inserisci i tiri con la tastiera.';

  @override
  String toolsDiceBitsOf(int max) {
    return '/ $max bit';
  }

  @override
  String get toolsDiceThrowLabel => 'LANCIO';

  @override
  String get toolsDiceRollsLabel => 'TIRI';

  @override
  String get toolsDiceBitsPerRoll => 'Ogni tiro vale ~2,58 bit';

  @override
  String toolsDiceCountOf(int count, int total) {
    return '$count / $total';
  }

  @override
  String get toolsDiceRecordedRolls => 'TIRI REGISTRATI';

  @override
  String get toolsDiceDistributionTitle => 'Distribuzione delle facce';

  @override
  String get toolsDiceDistributionOk => 'Distribuzione regolare';

  @override
  String get toolsDiceDistributionBiased =>
      'Distribuzione insolita: controlla i dadi e le letture';

  @override
  String get toolsDiceUndo => 'Annulla ultimo';

  @override
  String get toolsDiceKeypad => 'Tastiera';

  @override
  String get toolsDiceConfirmThrow => 'Conferma lancio';

  @override
  String toolsDiceCorrectTitle(int number) {
    return 'Controlla lancio $number';
  }

  @override
  String get toolsDiceCorrectBody =>
      'Confronta i valori con i dadi e tocca un dado per cambiarlo. Niente viene registrato finché non salvi. L\'ordine segue la posizione sul foglio, da sinistra a destra.';

  @override
  String toolsDiceNewValueFor(int number) {
    return 'NUOVO VALORE PER IL DADO $number';
  }

  @override
  String get toolsDiceCheckReading => 'verifica';

  @override
  String toolsDiceValue(int value) {
    return 'Valore $value';
  }

  @override
  String toolsDiceDie(int number, int value) {
    return 'Dado $number: valore $value';
  }

  @override
  String get toolsDiceSaveThrow => 'Salva lancio';

  @override
  String get toolsDiceManualTitle => 'Inserisci i tiri';

  @override
  String get toolsDiceClose => 'Chiudi';

  @override
  String get toolsDiceDone => 'COMPLETATA';

  @override
  String get toolsDiceResultTitle => 'La tua seed è pronta';

  @override
  String toolsDiceResultMeta(int words, int rolls, int bits, int checksum) {
    return '$words parole · $rolls tiri · $bits bit + $checksum checksum';
  }

  @override
  String get toolsDiceResultWarning =>
      'Scrivila a mano, ora. Quando esci dalla sandbox viene cancellata e non si può recuperare.';

  @override
  String get toolsDiceWordsLabel => 'PAROLE · INGLESE BIP39';

  @override
  String get toolsDiceHoldToReveal => 'Tieni premuto per rivelare';

  @override
  String get toolsDiceReleaseToHide => 'Rilascia per nascondere';

  @override
  String get toolsDiceRevealCaption =>
      'Niente copia, niente screenshot: le parole spariscono quando rilasci.';

  @override
  String toolsDiceBitsLabel(int bits, int groups) {
    return '$bits BIT IN $groups GRUPPI DA 11';
  }

  @override
  String toolsDiceLegendChecksum(int bits) {
    return 'checksum ($bits bit)';
  }

  @override
  String toolsDiceLegendEntropy(int bits) {
    return 'entropia ($bits bit)';
  }

  @override
  String get toolsDiceTapWordHint =>
      'Tocca una parola per vedere i suoi 11 bit.';

  @override
  String get toolsDiceMathTitle => 'Mostra la matematica';

  @override
  String toolsDiceMathStep1(int rolls) {
    return '$rolls tiri, in ordine';
  }

  @override
  String toolsDiceMathStep2(int bits) {
    return 'SHA-256 della stringa dei tiri = entropia ($bits bit)';
  }

  @override
  String toolsDiceMathStep3(int bits) {
    return 'SHA-256 dell\'entropia: i primi $bits bit sono il checksum';
  }

  @override
  String toolsDiceMathStep4(int total, int groups) {
    return '$total bit, divisi in $groups gruppi da 11';
  }

  @override
  String get toolsDiceMathStep5 =>
      'Ogni gruppo è un indice (0–2047) nella wordlist inglese';

  @override
  String get toolsDiceMathNote =>
      'Stesso metodo di SeedSigner e Coldcard: puoi verificare la seed inserendo gli stessi tiri su un dispositivo separato.';

  @override
  String get toolsDiceMathHidden =>
      'Tieni premuto il pulsante in basso per vedere i valori';

  @override
  String get toolsDiceWipeDone => 'Ho trascritto la seed, cancella';

  @override
  String get toolsDiceNewSession => 'Nuova sessione';

  @override
  String get toolsDiceWipedNotice => 'Sessione cancellata.';

  @override
  String get toolsDiceScreenshotTitle => 'Screenshot rilevato';

  @override
  String get toolsDiceScreenshotBody =>
      'La sessione è stata cancellata. Una seed finita in uno screenshot non è sicura: ricomincia.';

  @override
  String get toolsDiceVeil => 'Sandbox nascosta';
}
