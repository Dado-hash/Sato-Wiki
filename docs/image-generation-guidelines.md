# Image Generation Guidelines

Guida per creare immagini, schemi e illustrazioni dei contenuti SatoWiki.

## Direzione Visiva

Le immagini devono sembrare parte di una rivista tecnica su Bitcoin, non di una
crypto app speculativa.

Obiettivo:

- autorevole, editoriale, compatto;
- dark-first, con alto contrasto ma senza effetto neon;
- tecnico e leggibile anche su schermi piccoli;
- coerente con Material 3 custom e con i componenti reader dell'app;
- adatto a un'enciclopedia: spiega, non vende.

Da evitare:

- monete 3D lucide, razzi, grafici "to the moon", fuoco, laser, neon viola;
- persone fotorealistiche, trading desk, stock photo generiche;
- troppi effetti glow, bokeh, sfondi blu/viola dominanti;
- testo lungo dentro l'immagine generata;
- loghi di exchange, wallet o aziende non necessari.

## Palette

Usare come riferimento la dark mode dell'app.

- Background principale: `#111418`, `#131313`, `#171B21`.
- Surface/card tecniche: `#1C1B1B`, `#20252D`, `#2A2A2A`.
- Testo/linee chiare: `#F4EAD8`, `#E5E2E1`, `#DBC2AE`.
- Accento Bitcoin: `#F7931A` o `#FFB874`, usato solo per percorsi, stati attivi
  e punti importanti.
- Success/validita: verde sobrio, circa `#22C55E`.
- Alternative branch o contrasto tecnico: violetto desaturato, circa `#7C5CFF`,
  solo come colore secondario.

L'immagine non deve diventare tutta arancione. L'arancione e un evidenziatore,
non lo sfondo.

## Stile

Preferire:

- diagrammi editoriali, isometrici molto leggeri o 2.5D sobrio;
- blocchi, nodi, connessioni, frecce, griglie leggere;
- texture minima tipo carta scura o superficie tecnica opaca;
- ombre morbide e controllate;
- bordo sottile e radius 8px, coerente con le card dell'app;
- dettagli tecnici come header, hash, Merkle root, target, nonce rappresentati
  visivamente, ma senza sovraccaricare.

Per immagini generate con AI:

- chiedere "no readable text" quando possibile;
- usare caption e alt text nel Markdown per spiegare il contenuto;
- se servono label precise, aggiungerle dopo in SVG/Figma/Canva, non affidarle
  al modello generativo;
- mantenere composizione pulita, con soggetto leggibile al centro.

## Formati E Dimensioni

Per schemi tecnici:

- preferire SVG quando possibile;
- se generati come raster, usare PNG o WebP;
- ratio consigliato: 16:9;
- dimensione sorgente consigliata: 1600x900 o 1920x1080;
- mantenere margine interno abbondante, almeno 8 percento per lato;
- verificare leggibilita a 360px di larghezza.

Per immagini inline:

- path sotto `media/`;
- alt text obbligatorio;
- caption breve nel title Markdown;
- niente URL esterni.

Esempio:

```md
![Mining loop diagram](media/wiki/proof-of-work/pow-mining-loop.webp "A miner changes the block candidate until its hash is below the target.")
```

## Naming

Usare nomi brevi e descrittivi.

```text
media/wiki/{slug}/{concept}.webp
media/wiki/{slug}/{concept}.svg
media/news/{slug}/{concept}.webp
media/history/{slug}/{concept}.webp
media/code/{slug}/{concept}.svg
```

Esempi:

```text
media/wiki/proof-of-work/pow-mining-loop.svg
media/wiki/proof-of-work/accumulated-work.svg
media/wiki/utxo-model/utxo-flow.svg
media/wiki/difficulty-adjustment/retarget-window.svg
```

## Prompt Base

Usare questo come scheletro:

```text
Dark editorial technical illustration for a Bitcoin encyclopedia mobile app.
Matte dark background, subtle thin-line grid, warm off-white details, restrained
Bitcoin orange accent, small green success accent only where meaningful.
Clean infographic composition, rounded technical panels, thin borders, precise
arrows, no neon, no glossy 3D coins, no trading visuals, no people, no brand
logos, no readable text. 16:9 aspect ratio, high contrast, mobile-readable.
```

## Proof Of Work: Immagini Da Generare

Queste sono le prime due immagini per `wiki.proof-of-work`.

### 1. Mining Loop

Path consigliato:

```text
media/wiki/proof-of-work/pow-mining-loop.webp
```

Alt text:

```text
Mining loop diagram
```

Caption:

```text
A miner changes the block candidate until its hash is below the target.
```

Descrizione:

Un diagramma tecnico dark che mostra il ciclo di ricerca della Proof of Work.
Da sinistra a destra: un blocco candidato astratto, un modulo/hash engine, una
soglia target, poi due esiti: retry e valid block. Il retry torna indietro con
una freccia sottile; l'esito valido prosegue con un piccolo accento verde.

Prompt:

```text
Dark editorial technical infographic for Bitcoin Proof of Work. Show a clean
mining loop: a block candidate panel on the left, a hashing engine in the
center, a target threshold gate on the right, and a retry arrow looping back to
the block candidate. Use matte charcoal surfaces, thin warm off-white outlines,
restrained Bitcoin orange arrows, and one small green success path for a valid
block. Abstract header fields and hash dots are allowed, but no readable text.
No people, no glossy coins, no neon, no exchange or trading imagery. 16:9,
mobile-readable, precise, calm technical magazine style.
```

Negative prompt:

```text
neon crypto, glowing coin, rocket, bull market chart, trader, photorealistic
person, exchange logo, excessive orange, purple gradient background, cluttered
text, illegible labels, sci-fi hologram
```

### 2. Accumulated Work

Path consigliato:

```text
media/wiki/proof-of-work/accumulated-work.webp
```

Alt text:

```text
Accumulated work diagram
```

Caption:

```text
Nodes choose the valid branch with the most accumulated proof of work, not simply the first block they heard about.
```

Descrizione:

Un diagramma con due rami di blockchain che partono da un antenato comune. Il
ramo principale ha piu lavoro accumulato ed e evidenziato con accento verde
molto sobrio; il ramo alternativo e valido ma secondario, in violetto/grigio. La
composizione deve comunicare "work accumulated over time" senza affidarsi a
testo interno.

Prompt:

```text
Dark editorial technical infographic for Bitcoin accumulated proof of work.
Show two competing blockchain branches sharing a common ancestor. The upper
branch has more accumulated work and is subtly highlighted with a green endpoint
and warm Bitcoin orange connection lines. The lower branch is valid but
secondary, with muted violet-gray blocks. Use matte charcoal background, thin
grid, rounded block panels, small hash-like dot patterns, and clean arrows. No
readable text inside the image. No glossy coins, no miners, no trading charts,
no neon. 16:9, high contrast, mobile-readable, precise technical magazine
style.
```

Negative prompt:

```text
long paragraph labels, realistic mining farm, stock photo, glowing blockchain
tunnel, blue-purple neon, floating coins, finance chart, chaotic network,
cyberpunk city, oversized Bitcoin logo
```

## Checklist Prima Di Usare Un'Immagine

- Il soggetto si capisce senza leggere testo dentro l'immagine?
- Funziona in dark mode e non sembra una pubblicita crypto?
- L'arancione evidenzia solo una parte importante?
- La composizione resta leggibile a 360px di larghezza?
- Il file e sotto `media/` e referenziato con alt text?
- La caption spiega il punto didattico in una frase?
- Le fonti o i concetti rappresentati sono coerenti con il contenuto?
