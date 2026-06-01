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
  String get languageSelectorTooltip => 'Lingua';

  @override
  String get searchTooltip => 'Cerca';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get languageSystemDefault => 'Predefinita di sistema';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get orangeBookTitle => 'The Orange Book';

  @override
  String get wikiOverviewSubtitle =>
      'Un\'enciclopedia tecnica per lettori Bitcoin.';

  @override
  String get knowledgeBase => 'Base di conoscenza';

  @override
  String get categoryProtocol => 'Protocollo';

  @override
  String get categoryProtocolDescription =>
      'Regole di consenso, architettura dei nodi e topologia della rete.';

  @override
  String get categoryCryptography => 'Crittografia';

  @override
  String get categoryCryptographyDescription =>
      'Curve ellittiche, funzioni hash e schemi di firma.';

  @override
  String get categoryLightningNetwork => 'Lightning Network';

  @override
  String get categoryLightningNetworkDescription =>
      'Scalabilità layer 2, canali di pagamento e routing.';

  @override
  String get categoryEconomics => 'Economia';

  @override
  String get categoryEconomicsDescription =>
      'Teoria dei giochi, incentivi, difficoltà e politica monetaria.';

  @override
  String get categoryBips => 'BIP';

  @override
  String get categoryConsensus => 'Consenso';

  @override
  String get categorySecp256k1 => 'Secp256k1';

  @override
  String get categorySha256 => 'SHA-256';

  @override
  String get categoryBolts => 'BOLT';

  @override
  String get categoryChannels => 'Canali';

  @override
  String get categoryHalving => 'Halving';

  @override
  String get categoryDifficulty => 'Difficoltà';

  @override
  String wikiEntriesInCategory(String category) {
    return 'Voci Wiki in $category.';
  }

  @override
  String get wikiEntriesInThisCategory => 'Voci Wiki in questa categoria.';

  @override
  String get all => 'Tutti';

  @override
  String get coreConcept => 'Concetto chiave';

  @override
  String minRead(int minutes) {
    return '$minutes min di lettura';
  }

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
  String get editorial => 'Editoriale';

  @override
  String get latestAnalysis => 'Ultime analisi';

  @override
  String get articleNotFound => 'Articolo non trovato';

  @override
  String get lightningTip => 'Mancia Lightning';

  @override
  String get lightningTipDescription =>
      'Solo mock. Il collegamento ai pagamenti aspetta la definizione privacy e UX.';

  @override
  String get lightningTipMockTitle => 'Mock mancia Lightning';

  @override
  String get noLightningAddress => 'Nessun indirizzo Lightning configurato.';

  @override
  String get close => 'Chiudi';

  @override
  String get sendTip => 'Invia mancia';

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
  String get timelineMetadata => 'Timeline';

  @override
  String get onThisDay => 'In questo giorno';

  @override
  String get noEventToday => 'Nessun evento oggi';

  @override
  String get noEventTodayDescription =>
      'Qui appariranno eventi storici collegati alla data corrente.';

  @override
  String get allEvents => 'Tutti gli eventi';

  @override
  String get community => 'Community';

  @override
  String get historyEventNotFound => 'Evento storico non trovato';

  @override
  String get codeDashboardTitle => 'Dashboard Codice';

  @override
  String get codeDashboardSubtitle =>
      'Segui Bitcoin Improvement Proposal (BIP) e modifiche recenti del core.';

  @override
  String get filter => 'Filtro';

  @override
  String get recentBips => 'BIP recenti';

  @override
  String get allBipsTitle => 'Tutti i BIP';

  @override
  String get allBipsSubtitle =>
      'Sfoglia i Bitcoin Improvement Proposal per stato e numero.';

  @override
  String get noBipsMatchFilter => 'Nessun BIP corrisponde al filtro.';

  @override
  String get bipNumberDescending => 'BIP # più alto';

  @override
  String get bipNumberAscending => 'BIP # più basso';

  @override
  String get bipTracker => 'Tracker BIP';

  @override
  String get deployedUpper => 'DISTRIBUITO';

  @override
  String get activeUpper => 'ATTIVO';

  @override
  String get draftUpper => 'BOZZA';

  @override
  String get closedUpper => 'CHIUSO';

  @override
  String get rejectedUpper => 'RESPINTO';

  @override
  String get changelog => 'Changelog';

  @override
  String get noRecentReleases => 'Nessuna release recente.';

  @override
  String get bipNotFound => 'BIP non trovato';

  @override
  String get releaseNotFound => 'Release non trovata';

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
  String get authors => 'Autori';

  @override
  String get created => 'Creato';

  @override
  String get layer => 'Layer';

  @override
  String get plainEnglishSummary => 'Riassunto semplice';

  @override
  String get practicalImpact => 'Impatto pratico';

  @override
  String get statusHistory => 'Cronologia stato';

  @override
  String get viewOfficialTextOnGitHub => 'Vedi testo ufficiale su GitHub';

  @override
  String get userImpact => 'Impatto per l\'utente';

  @override
  String get technicalChanges => 'Modifiche tecniche';

  @override
  String get searchTitle => 'Cerca';

  @override
  String get searchSubtitle =>
      'Trova contenuti locali per titolo, tag e sommario.';

  @override
  String get searchHint => 'Cerca conoscenza Bitcoin';

  @override
  String get noLocalResultFound => 'Nessun risultato locale.';

  @override
  String get trySearchExamples => 'Prova: Proof of Work, Taproot, Pizza Day';

  @override
  String get routeNotFound => 'Route non trovata';

  @override
  String get wikiCategoryTitle => 'Categoria Wiki';

  @override
  String get wikiEntryTitle => 'Voce Wiki';

  @override
  String get newsArticleTitle => 'Articolo news';

  @override
  String get historyEventTitle => 'Evento storico';

  @override
  String get bipDetailTitle => 'Dettaglio BIP';

  @override
  String get changelogTitle => 'Changelog';

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
}
