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
}
