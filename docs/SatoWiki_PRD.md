# SatoWiki — Product Requirements Document

**Versione:** 0.1 (Draft)
**Data:** Maggio 2026
**Autore:** Dave (Maintainer)
**Stato:** In revisione

---

## 1. Visione del Prodotto

SatoWiki è un'applicazione mobile open source che funge da enciclopedia, archivio storico, aggregatore di notizie e tracker tecnico dell'ecosistema Bitcoin. L'obiettivo è creare la risorsa di riferimento più completa, accessibile e aggiornata per chiunque voglia capire, seguire ed approfondire Bitcoin — dal curioso alle prime armi allo sviluppatore esperto.

Il contenuto è interamente gestito dalla community tramite pull request su GitHub, con un processo di revisione ed approvazione controllato dai maintainer del progetto. Sia il codice sorgente che i contenuti sono rilasciati sotto licenza open source.

---

## 2. Obiettivi

- Creare un punto di riferimento unico e autorevole sull'ecosistema Bitcoin, accessibile da mobile in qualsiasi momento
- Abbattere la barriera tra contenuti tecnici e divulgativi tramite un sistema di livelli di lettura
- Costruire una community di contributori che mantengano e arricchiscano i contenuti nel tempo
- Sostenere il progetto tramite donazioni Lightning, sponsorship e, in futuro, modelli aggiuntivi

---

## 3. Utenti Target

### Profilo Primario — Il Bitcoiner (intermedio)
Conosce Bitcoin, usa wallet e magari Lightning. Vuole restare aggiornato sulle novità del protocollo, capire cosa cambia con i nuovi update, leggere analisi e notizie scritte da chi conosce il settore.

### Profilo Secondario — Lo Sviluppatore / Tecnico
Conosce il codice, segue le discussioni su Delving Bitcoin e la mailing list. Vuole un tracker strutturato dei BIP, i changelog di Bitcoin Core, LND, CLN riscritti in modo comprensibile, e un riferimento tecnico sempre aggiornato.

### Profilo Terziario — Il Curioso / Newbie
Ha sentito parlare di Bitcoin e vuole capire di cosa si tratta senza annegare in tecnicismi. Grazie al sistema dei livelli di lettura, può accedere agli stessi contenuti in modo semplificato senza un'app separata.

---

## 4. Le Quattro Sezioni

### 4.1 📖 Enciclopedia

Raccolta strutturata di voci su tutto l'ecosistema Bitcoin: concetti fondamentali, protocollo, crittografia, layer 2, wallet, Lightning Network, DeFi su Bitcoin, economics, terminologia, figure storiche, organizzazioni e molto altro.

**Caratteristiche principali:**
- Voci organizzate per categorie e tag
- Sistema di livelli di lettura (vedi sezione 5)
- Ogni voce collegata ad altre voci correlate (link interni)
- Ogni voce collegata a fonti esterne, paper, BIP di riferimento
- Contenuto gestito tramite file Markdown su repository GitHub
- Ricerca full-text nell'enciclopedia

**Governance del contenuto:**
- Ogni voce è un file Markdown con un template standard obbligatorio
- Le modifiche avvengono tramite Pull Request sulla repo dei contenuti
- I maintainer autorizzati effettuano la review e il merge
- Versioning completo tramite git history

---

### 4.2 📰 News

Sezione di notizie e approfondimenti sull'ecosistema Bitcoin, scritti dalla community e pubblicati tramite Pull Request. Non si tratta di breaking news ma di analisi, approfondimenti ed editoriali di qualità.

**Caratteristiche principali:**
- Articoli con autore, data e tag tematici
- Categorie: Protocollo / Mercato / Regulatory / Cultura / Sviluppo
- Feed cronologico con filtri per categoria e tag
- Ogni articolo può linkare voci dell'Enciclopedia e eventi della Storia
- Possibilità di Lightning tip direttamente all'autore dell'articolo

**Governance del contenuto:**
- Ogni articolo è un file Markdown con template standard
- Pubblicazione tramite PR con review dei maintainer
- Gli autori devono avere un profilo GitHub verificato

---

### 4.3 📅 Storia di Bitcoin

Timeline interattiva e cronologica di tutto ciò che è accaduto nell'ecosistema Bitcoin, dall'origine a oggi. La sezione cresce nel tempo, append-only: gli eventi vengono aggiunti ma mai riscritti (salvo correzioni fattuali).

**Caratteristiche principali:**
- Timeline verticale navigabile con zoom su anno / mese
- Ogni evento ha: data precisa, titolo, descrizione breve, categoria, link a voci enciclopediche e articoli correlati
- Categorie evento: Protocollo / Mercato / Cultura / Regulatory / Tecnologia / Figure storiche
- Filtri per categoria e range temporale
- "On this day" — widget che mostra gli eventi storici avvenuti nella data corrente
- Collegamento incrociato con le voci dell'Enciclopedia

**Governance del contenuto:**
- Ogni evento è un entry in un file YAML/JSON strutturato, aggiornato via PR
- Processo di verifica delle fonti obbligatorio per ogni nuovo evento

---

### 4.4 💻 Codice

Sezione dedicata al monitoraggio tecnico dell'ecosistema di sviluppo Bitcoin: BIP, release dei principali client e implementazioni, aggiornamenti di protocollo.

**Caratteristiche principali:**

**BIP Tracker:**
- Lista completa dei Bitcoin Improvement Proposals con stato aggiornato (Draft / Proposed / Active / Final / Withdrawn / Rejected)
- Per ogni BIP: numero, titolo, autore, stato, data, categoria (Consensus / Informational / Process / Standards Track)
- Sommario leggibile in linguaggio naturale (non solo il testo originale)
- Link alla discussione ufficiale e al testo completo
- Filtri per stato e categoria
- Notifiche push su cambio di stato dei BIP seguiti

**Changelog Leggibili:**
- Aggiornamenti di Bitcoin Core, LND (Lightning Network Daemon), Core Lightning, Eclair e altri client rilevanti
- Ogni release ha un changelog riscritto in linguaggio comprensibile (non solo git log)
- Evidenziazione delle modifiche con impatto per l'utente finale vs. modifiche interne
- Link al tag GitHub ufficiale e alle release notes originali

**Governance del contenuto:**
- I sommari dei BIP e i changelog riscritti vengono proposti via PR e revisionati dai maintainer tecnici

---

## 5. Sistema dei Livelli di Lettura

Ogni voce dell'Enciclopedia (e, dove applicabile, gli articoli della sezione News) supporta tre livelli di lettura, selezionabili tramite tre pulsanti nella parte superiore del contenuto.

| Livello | Label | Destinatario | Caratteristiche |
|---|---|---|---|
| 1 | 🟢 Base | Curioso / Newbie | Definizione in una riga, analogia semplice, zero tecnicismi |
| 2 | 🟡 Medio | Bitcoiner | Spiegazione in un paragrafo, contesto, esempi pratici |
| 3 | 🔴 Avanzato | Sviluppatore / Tecnico | Dettaglio completo, riferimenti tecnici, link a BIP e paper |

La selezione del livello è persistente tra le sessioni: l'app ricorda l'ultima preferenza dell'utente.

I contributtori che scrivono voci enciclopediche sono tenuti a produrre tutti e tre i livelli seguendo il template obbligatorio della repo.

---

## 6. Modello Open Source e Governance

### Codice
- Licenza: MIT (o GPL, da definire)
- Repository: GitHub (organizzazione dedicata SatoWiki)
- Contributi via PR con review dei maintainer

### Contenuti
- Licenza: Creative Commons CC BY-SA 4.0
- Repository separata per i contenuti (satowiki-content)
- PR → review → merge da parte dei maintainer autorizzati
- I maintainer di primo livello sono nominati dal founder (Dave)
- Template obbligatori per ogni tipo di contenuto (voce, articolo, evento, BIP summary)
- Linee guida editoriali pubblicate nella repo (CONTRIBUTING.md)

### Lingue
- Lingua principale: Inglese
- Italiano come seconda lingua prioritaria (per ora)
- Struttura multilingua nella repo per espansioni future

---

## 7. Stack Tecnologico (Indicativo)

| Componente | Tecnologia |
|---|---|
| App mobile | Flutter (iOS + Android) |
| Contenuti | Markdown/YAML su GitHub |
| Build & deploy contenuti | GitHub Actions → CDN (statico) |
| API contenuti | JSON statico generato da CI/CD |
| News feed | Markdown su GitHub, aggiornato via PR |
| Donazioni | BTCPay Server (Lightning + on-chain) |
| Notifiche push | Firebase Cloud Messaging o self-hosted |

---

## 8. Modello Economico

**Fase 1 (lancio):**
- Donazioni Lightning e on-chain tramite BTCPay Server
- Pulsante di donazione visibile nell'app e nella repo
- Lightning tip agli autori degli articoli News (opzionale)

**Fase 2 (crescita):**
- Sponsorship da aziende dell'ecosistema (exchange, wallet provider, nodi)
- Sponsorship chiaramente etichettato e mai invasivo

**Fase 3 (da esplorare):**
- Da definire in base alla trazione del progetto

L'app non mostra pubblicità. I contenuti non sono influenzati dagli sponsor.

---

## 9. Requisiti Non Funzionali

- **Offline-first:** le sezioni Enciclopedia e Storia devono essere accessibili senza connessione (contenuto pre-scaricato e aggiornato in background)
- **Performance:** navigazione fluida, caricamento voci < 500ms
- **Accessibilità:** supporto screen reader, dimensioni testo regolabili
- **Privacy:** nessun tracciamento utente, nessun analytics di terze parti invasivo
- **Internazionalizzazione:** architettura pronta per contenuti multilingua

---

## 10. Out of Scope (v1)

- Funzionalità social (commenti, upvote in-app)
- Wallet Bitcoin integrato
- Prezzi e dati di mercato in real-time
- Versione web (potenziale v2)
- App desktop

---

## 11. Metriche di Successo

- Numero di voci enciclopediche pubblicate
- Numero di contributor attivi sulla repo
- Numero di download e utenti attivi mensili
- Donazioni Lightning ricevute (indicatore di engagement della community)
- Star sulla repo GitHub

---

*Documento soggetto a revisione. Le sezioni architetturali e tecnologiche saranno dettagliate in documenti separati (Technical Spec, Content Guidelines, API Design).*
