# SatoWiki — Design Brief
### Documento per il Designer UI/UX

**Versione:** 0.1
**Data:** Maggio 2026
**Progetto:** SatoWiki — The Orange Book of Bitcoin

---

## 1. Il Progetto in una Riga

SatoWiki è un'app mobile open source che raccoglie tutto ciò che c'è da sapere su Bitcoin: un'enciclopedia, un archivio storico, un magazine di notizie e un tracker tecnico — tutto in un'unica app, pensata per durare nel tempo.

---

## 2. Identità del Brand

**Nome:** SatoWiki
**Tagline:** *The Orange Book of Bitcoin*

Il nome unisce Satoshi (il creatore di Bitcoin) e Wiki (conoscenza collettiva, aperta, viva). L'identità visiva deve evocare:

- **Autorevolezza** — questa è la fonte di riferimento, non un blog
- **Apertura** — i contenuti sono di tutti, costruiti dalla community
- **Modernità** — non il solito design cripto "laser eyes e lambo", ma qualcosa di serio, adulto, duraturo
- **Bitcoin** — l'arancione è la firma cromatica, usato con equilibrio e intenzione

Il tono visivo deve ricordare più una rivista tecnica di qualità o un'app di approfondimento giornalistico che un'app crypto speculativa.

---

## 3. Estetica e Stile

### Design System
**Material Design 3 (Material You)** — Google's latest design language. Si adatta dinamicamente al tema del device, supporta dark/light mode nativa, ed è il sistema più maturo per Flutter (lo stack dell'app).

### Palette Cromatica

| Ruolo | Colore | Note |
|---|---|---|
| Primary | #F7931A | Bitcoin Orange — usato per CTA, accenti, highlight |
| Primary Container | #FFF0D9 | Versione chiara dell'arancione per sfondi sezione |
| Surface (Light) | #FAFAFA | Quasi bianco, non bianco puro — più caldo |
| Surface (Dark) | #121212 | Dark mode principale — profondo, non nero assoluto |
| On Surface | #1C1C1E | Testo principale in light mode |
| On Surface Dark | #E5E5EA | Testo principale in dark mode |
| Secondary | #1A1A2E | Blu notte — per header, nav, elementi strutturali |
| Success / Active | #34C759 | Verde per stati attivi (BIP Active, ecc.) |
| Warning / Proposed | #FF9500 | Arancio ambra per stati intermedi |
| Error / Withdrawn | #FF3B30 | Rosso per stati negativi |

**Dark mode come default:** la community Bitcoin è abituata agli schermi scuri. La dark mode deve essere impeccabile. La light mode è secondaria ma deve essere altrettanto curata.

### Tipografia
- **Display / Titoli:** Inter o DM Sans — geometrico, moderno, leggibile
- **Body / Contenuto:** Inter o Lora — ottima leggibilità su schermi a qualsiasi dimensione
- **Monospace / Codice:** JetBrains Mono — per blocchi di codice, hash, indirizzi, script
- **Gerarchia:** 5 livelli di testo (Display, Headline, Title, Body, Label) seguendo le specifiche M3

### Iconografia
- Material Symbols (Outlined variant) come set base
- Icone personalizzate per le 4 sezioni principali (da progettare)
- L'icona dell'app: proposta aperta — potrebbe essere un libro arancione stilizzato, una "S" che ricorda il simbolo Bitcoin, o il simbolo ₿ integrato in una forma wiki

---

## 4. Struttura dell'App — Schermate Chiave da Progettare

### Navigazione Principale
Bottom Navigation Bar con 4 tab principali:

| Tab | Icona suggerita | Label |
|---|---|---|
| Enciclopedia | book_open | Wiki |
| News | newspaper | News |
| Storia | timeline / history | Storia |
| Codice | code / terminal | Codice |

La bottom bar deve essere minimal, con solo l'icona attiva evidenziata in Bitcoin Orange. Nessun label visibile di default (solo icone) oppure label sotto — da testare entrambe.

---

### 4.1 Home / Splash

Non c'è una vera home separata: l'app apre direttamente sull'ultima sezione visitata. Al primo avvio, si apre sull'Enciclopedia.

**Splash screen:** logo SatoWiki su sfondo scuro, animazione leggera (fade in), nessun loading bar.

---

### 4.2 Enciclopedia — Schermate

**A) Lista categorie / esplora**
- Grid o lista di categorie (Protocollo, Lightning, Crittografia, Economics, ecc.)
- Barra di ricerca sempre visibile in cima
- Voci in evidenza (es. "Voce della settimana")

**B) Lista voci per categoria**
- Lista card con titolo voce, breve descrizione (una riga), indicatore di complessità
- Filtro rapido

**C) Voce enciclopedica — SCHERMATA CHIAVE**
Questa è la schermata più importante del prodotto. Deve:

- Mostrare il titolo della voce con gerarchia tipografica chiara
- Avere in posizione prominente (ma non ingombrante) il **selettore dei 3 livelli di lettura**: tre pill/chip orizzontali — `Base` `Medio` `Avanzato` — con il livello attivo evidenziato in arancione
- Il contenuto della voce cambia dinamicamente al tap sul livello senza ricaricare la pagina (transizione animata)
- Tag tematici cliccabili
- Sezione "Voci correlate" in fondo
- Sezione "Fonti e riferimenti" collassabile

**Dettaglio selettore livelli:**
I tre pill devono essere chiari, accessibili, e non sovrastare il titolo. Possono essere posizionati subito sotto il titolo oppure in una sticky bar che appare durante lo scroll. Da testare entrambe le soluzioni.

---

### 4.3 News — Schermate

**A) Feed notizie**
- Lista di card articolo con: immagine di copertina (opzionale), titolo, autore, data, categoria tag, tempo di lettura stimato
- Filtri per categoria in cima (chip scrollabili orizzontalmente)
- Pull-to-refresh

**B) Articolo**
- Layout da reader: tipografia larga, spaziatura generosa, nessuna distrazione
- Header con immagine copertina (se presente)
- Autore con avatar GitHub, data, tempo di lettura
- Pulsante Lightning Tip per l'autore (visibile ma non invadente)
- Link a voci enciclopediche inline nel testo (chip colorati)

---

### 4.4 Storia — Schermate

**A) Timeline principale — SCHERMATA CHIAVE**
- Visualizzazione verticale con indicatori temporali (anno, mese)
- Ogni evento è una card sulla timeline con: data, titolo, categoria (colore diverso per categoria), descrizione breve
- Filtri per categoria (chip orizzontali) e range temporale (slider o selezione anno)
- Widget "On this day" in cima: eventi storici avvenuti oggi negli anni passati

**B) Dettaglio evento**
- Data completa, titolo, categoria
- Descrizione completa dell'evento
- Link a voci correlate nell'Enciclopedia
- Link ad articoli News correlati (se presenti)
- Fonti

---

### 4.5 Codice — Schermate

**A) Dashboard Codice**
- Due sezioni visibili: BIP Tracker e Changelog
- Card riassuntive per ciascuna (ultimi aggiornamenti, BIP recentemente cambiati di stato)

**B) BIP Tracker — Lista**
- Lista BIP con: numero, titolo, stato (badge colorato), categoria
- Filtri per stato e categoria
- Ricerca per numero o parola chiave

**C) BIP — Dettaglio**
- Header: numero BIP, titolo, stato (badge prominente), autore/i, data
- **Sommario in linguaggio naturale** (questo è il valore aggiunto rispetto al testo originale)
- Sezione "Impatto pratico" — cosa cambia per l'utente / per gli sviluppatori
- Link a testo ufficiale e discussione
- Storia degli stati (quando è passato da Draft a Proposed, ecc.)

**D) Changelog — Lista release**
- Lista per progetto (Bitcoin Core / LND / CLN / ...)
- Switch per selezionare il progetto
- Ogni release: versione, data, riassunto in una riga, indicatore di rilevanza (major/minor/patch)

**E) Changelog — Dettaglio release**
- Versione e data
- Changelog riscritto in linguaggio comprensibile
- Distinzione visiva tra "Novità per l'utente" e "Modifiche tecniche interne"
- Link alle release notes originali su GitHub

---

## 5. Pattern e Componenti UI Specifici

### Livello di Lettura — Selector Component
Tre chip/pill in riga orizzontale. Design suggerito:
- Background inattivo: surface variant (grigio neutro)
- Background attivo: Bitcoin Orange (#F7931A) con testo bianco
- Forma: pill (bordi completamente arrotondati)
- Dimensione: compatta, non occupa più del 50% della larghezza schermo
- Animazione: fade + slide del contenuto al cambio livello

### Badge Stato BIP
Pill colorati con font monospace per il numero BIP:
- Draft → grigio
- Proposed → arancio ambra
- Active / Final → verde
- Withdrawn / Rejected → rosso

### Lightning Tip Button
Pulsante secondario (non primario) con icona Lightning ⚡ — discreto, non deve sembrare pubblicità. Posizionato in fondo all'articolo. Al tap: modal con QR code Lightning invoice e importo suggerito.

### Card Voce Enciclopedica
Bordo sottile, corner radius 12dp, nessuna ombra pesante. Titolo in bold, descrizione in body size, indicatore complessità come tre dot colorati (🟢🟡🔴) o un tag testuale.

---

## 6. Dark Mode

La dark mode è il tema principale. Linee guida:
- **Niente nero puro (#000000)** — usa #121212 come base surface
- **Elevazione tramite colore**, non ombre (seguire M3 dark elevation)
- L'arancione Bitcoin su dark deve avere un leggero twist di saturazione per restare vibrante senza affaticare la vista
- Card su dark: surface container a #1E1E1E o simile
- Testo principale: #E5E5EA (non bianco puro)

---

## 7. Animazioni e Motion

Minimal e significative:
- Transizione tra livelli di lettura: cross-fade del contenuto (200ms)
- Navigazione tra sezioni: slide orizzontale (M3 default)
- Timeline storia: scroll momentum naturale, nessuna animazione eccessiva
- Nessun loading spinner: skeleton screens dove possibile

---

## 8. Riferimenti Visivi e Mood

**App da studiare per l'ispirazione:**
- Wikipedia (struttura informativa, navigazione voce)
- Artifact (reader mode, tipografia editoriale)
- Linear (minimal, dark, profondo)
- Robinhood / Revolut (data visualization pulita)
- Bear app (tipografia e leggibilità su mobile)

**Mood generale:** serio, autorevole, moderno. Come *The Economist* se fosse un'app mobile in dark mode con un accent color arancione.

**Cosa evitare:**
- Gradienti pesanti e neon (troppo "crypto 2021")
- Immagini di Bitcoin fisici, laser eyes, simboli ₿ ovunque
- Layout affollati o dashboard troppo dense
- Font sans-serif troppo tondeggianti (troppo consumer/giocoso)

---

## 9. Deliverable Richiesti al Designer

1. **Moodboard** con palette, tipografia, riferimenti visivi
2. **Design System base** — componenti principali in Figma (colori, tipografia, bottoni, card, chip, badge)
3. **Wireframe** delle schermate chiave (bassa fedeltà)
4. **Mockup alta fedeltà** per:
   - Voce enciclopedica con selettore livelli (dark + light)
   - Timeline Storia
   - BIP Tracker lista + dettaglio
   - Feed News + Articolo
5. **Prototipo interattivo** Figma per il flusso principale (navigazione tra le 4 sezioni + apertura voce enciclopedica con cambio livello)
6. **Icone sezione** custom per i 4 tab della bottom navigation

---

*Per qualsiasi chiarimento sul prodotto, sulle funzionalità o sulle priorità di design, fare riferimento al PRD allegato (SatoWiki_PRD.md).*
