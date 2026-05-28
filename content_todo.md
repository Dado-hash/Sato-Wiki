# Content Todo

Elenco dei contenuti da creare per SatoWiki.

## Wiki (Completato)

Tutte le voci delle sezioni Protocol, Cryptography, Lightning Network ed Economics
sono state create con template `content/templates/wiki_entry.md`, in inglese e
italiano, con i tre livelli di lettura `base`, `medium` e `advanced`.

### Protocol (`protocol`)

- [x] Proof of Work - `wiki.proof-of-work`
- [x] Bitcoin transactions - `wiki.transactions`
- [x] UTXO model - `wiki.utxo-model`
- [x] Blocks - `wiki.blocks`
- [x] Blockchain - `wiki.blockchain`
- [x] Full nodes - `wiki.full-nodes`
- [x] Consensus rules - `wiki.consensus-rules`
- [x] Mempool - `wiki.mempool`
- [x] Mining - `wiki.mining`
- [x] Block propagation - `wiki.block-propagation`
- [x] Peer-to-peer network - `wiki.peer-to-peer-network`
- [x] Bitcoin Script - `wiki.bitcoin-script`
- [x] Segregated Witness - `wiki.segregated-witness`
- [x] Taproot - `wiki.taproot`
- [x] Forks and soft forks - `wiki.forks-and-soft-forks`
- [x] Transaction fees - `wiki.transaction-fees`

### Cryptography (`cryptography`)

- [x] Hash functions - `wiki.hash-functions`
- [x] SHA-256 - `wiki.sha-256`
- [x] Merkle trees - `wiki.merkle-trees`
- [x] Private keys - `wiki.private-keys`
- [x] Public keys - `wiki.public-keys`
- [x] Digital signatures - `wiki.digital-signatures`
- [x] ECDSA - `wiki.ecdsa`
- [x] Schnorr signatures - `wiki.schnorr-signatures`
- [x] secp256k1 - `wiki.secp256k1`
- [x] Bitcoin addresses - `wiki.bitcoin-addresses`
- [x] Wallet seeds - `wiki.wallet-seeds`
- [x] Hierarchical deterministic wallets - `wiki.hd-wallets`
- [x] Multisig - `wiki.multisig`
- [x] Timelocks - `wiki.timelocks`
- [x] Hashlocks - `wiki.hashlocks`

### Lightning Network (`lightning network`)

- [x] Lightning Network overview - `wiki.lightning-network`
- [x] Payment channels - `wiki.payment-channels`
- [x] Channel funding transactions - `wiki.channel-funding-transactions`
- [x] Commitment transactions - `wiki.commitment-transactions`
- [x] HTLCs - `wiki.htlcs`
- [x] Onion routing - `wiki.onion-routing`
- [x] Lightning invoices - `wiki.lightning-invoices`
- [x] Channel liquidity - `wiki.channel-liquidity`
- [x] Routing fees - `wiki.routing-fees`
- [x] Watchtowers - `wiki.watchtowers`
- [x] BOLT specifications - `wiki.bolt-specifications`
- [x] Splicing - `wiki.splicing`
- [x] Anchor outputs - `wiki.anchor-outputs`
- [x] Multipath payments - `wiki.multipath-payments`
- [x] Lightning Service Providers - `wiki.lightning-service-providers`

### Economics (`economics`)

- [x] Fixed supply - `wiki.fixed-supply`
- [x] 21 million cap - `wiki.twenty-one-million-cap`
- [x] Issuance schedule - `wiki.issuance-schedule`
- [x] Halving - `wiki.halving`
- [x] Difficulty adjustment - `wiki.difficulty-adjustment`
- [x] Miner incentives - `wiki.miner-incentives`
- [x] Fee market - `wiki.fee-market`
- [x] Block subsidy - `wiki.block-subsidy`
- [x] Game theory - `wiki.game-theory`
- [x] Scarcity - `wiki.scarcity`
- [x] Store of value - `wiki.store-of-value`
- [x] Sound money - `wiki.sound-money`
- [x] Network effects - `wiki.network-effects`
- [x] Mining energy economics - `wiki.mining-energy-economics`
- [x] Volatility - `wiki.volatility`

---

## History (`history`)

Eventi storici di Bitcoin, ordinati cronologicamente per data. Ogni evento usa
il modello `HistoryEvent`:

```json
{
  "id": "history.{slug}",
  "slug": "{slug}",
  "date": "YYYY-MM-DD",
  "title": "...",
  "category": "...",
  "summary": "Una frase",
  "bodyMarkdown": "...",
  "sources": [],
  "related": []
}
```

Categorie usate: `origin`, `community`, `protocol`, `market`, `security`,
`regulation`, `adoption`.

Ogni evento va creato come file Markdown in `content/{lang}/history/{slug}.md`
con frontmatter YAML, e registrato in `seed_bundle_{lang}.json`. Immagini in
`assets/content/media/wiki/history-{slug}/`.

### Fase 1 — Origins & Whitepaper (2008–2009)

- [x] Bitcoin Whitepaper published - `history.bitcoin-whitepaper`
  `2008-10-31` | `origin`
  Satoshi Nakamoto pubblica il whitepaper "Bitcoin: A Peer-to-Peer Electronic
  Cash System" su mailing list cypherpunk.

- [x] Genesis Block mined - `history.genesis-block`
  `2009-01-03` | `origin`
  Il blocco 0 della blockchain Bitcoin viene minato da Satoshi, contenente il
  messaggio "The Times 03/Jan/2009 Chancellor on brink of second bailout for
  banks."

- [x] First Bitcoin transaction - `history.first-bitcoin-transaction`
  `2009-01-12` | `origin`
  Satoshi invia 10 BTC a Hal Finney, prima transazione Bitcoin della storia.

- [x] Bitcoin v0.1 released - `history.bitcoin-v01`
  `2009-01-09` | `origin`
  Satoshi rilascia Bitcoin v0.1 su SourceForge, codice C++ open source.

### Fase 2 — Early Adoption (2010–2011)

- [ ] Bitcoin Pizza Day - `history.bitcoin-pizza-day`
  `2010-05-22` | `community`
  Laszlo Hanyecz paga 10.000 BTC per due pizze, prima transazione commerciale
  documentata. (già presente in seed bundle)

- [ ] Mt. Gox launched - `history.mtgox-launch`
  `2010-07-17` | `market`
  Jed McCaleb lancia Mt. Gox, il primo grande exchange Bitcoin.

- [ ] Bitcoin reaches $1 parity - `history.bitcoin-one-dollar`
  `2011-02-09` | `market`
  Bitcoin raggiunge la parità con il dollaro USA per la prima volta.

- [ ] Silk Road launch - `history.silk-road-launch`
  `2011-02` | `community`
  Viene lanciato Silk Road, mercato darknet che adotta Bitcoin come valuta.

### Fase 3 — Growth & Turmoil (2012–2014)

- [ ] First halving - `history.first-halving`
  `2012-11-28` | `protocol`
  Primo halving Bitcoin: il block subsidy passa da 50 a 25 BTC. Altezza blocco
  210.000.

- [ ] Cyprus banking crisis - `history.cyprus-crisis`
  `2013-03` | `market`
  La crisi bancaria cipriota spinge l'adozione di Bitcoin come alternativa al
  sistema bancario tradizionale.

- [ ] First $1,000 milestone - `history.bitcoin-one-thousand`
  `2013-11-29` | `market`
  Bitcoin supera $1.000 per la prima volta.

- [ ] Mt. Gox collapse - `history.mtgox-collapse`
  `2014-02` | `security`
  Mt. Gox, il più grande exchange Bitcoin, dichiara bancarotta dopo la perdita
  di 850.000 BTC.

### Fase 4 — Maturation (2015–2017)

- [ ] SegWit proposal - `history.segwit-proposal`
  `2015-12` | `protocol`
  Pieter Wuille propone Segregated Witness (BIP 141, 143, 144) per risolvere
  malleabilità e scalabilità.

- [ ] Second halving - `history.second-halving`
  `2016-07-09` | `protocol`
  Secondo halving: il block subsidy passa da 25 a 12,5 BTC. Altezza blocco
  420.000.

- [ ] Bitcoin Cash fork - `history.bitcoin-cash-fork`
  `2017-08-01` | `protocol`
  Bitcoin subisce un hard fork che crea Bitcoin Cash, con block size aumentato
  a 8 MB.

- [ ] SegWit activation - `history.segwit-activation`
  `2017-08-23` | `protocol`
  SegWit si attiva sulla mainnet di Bitcoin dopo UASF, risolvendo transaction
  malleability e aprendo la strada a Lightning Network.

- [ ] Lightning Network whitepaper - `history.lightning-whitepaper`
  `2017-08` | `protocol`
  Poon e Dryja pubblicano "The Bitcoin Lightning Network" paper.

- [ ] $20,000 ATH - `history.bitcoin-twenty-thousand`
  `2017-12-17` | `market`
  Bitcoin raggiunge $19.783, il massimo storico del ciclo 2017.

- [ ] CME Bitcoin futures - `history.cme-bitcoin-futures`
  `2017-12-18` | `market`
  CME Group lancia i futures su Bitcoin, primo derivato regolamentato
  importante.

### Fase 5 — Institutional (2018–2021)

- [ ] Lightning Network mainnet - `history.lightning-mainnet`
  `2018-03` | `protocol`
  Lightning Network entra in produzione su mainnet con la prima implementazione
  stabile (LND 0.4).

- [ ] Third halving - `history.third-halving`
  `2020-05-11` | `protocol`
  Terzo halving: il block subsidy passa da 12,5 a 6,25 BTC. Altezza blocco
  630.000.

- [ ] MicroStrategy Bitcoin treasury - `history.microstrategy-treasury`
  `2020-08-11` | `adoption`
  MicroStrategy annuncia l'acquisto di $250M in BTC come riserva di tesoreria,
  primo di una serie di acquisti aziendali.

- [ ] El Salvador legal tender - `history.el-salvador-law`
  `2021-06-09` | `adoption`
  El Salvador diventa il primo paese ad adottare Bitcoin come moneta a corso
  legale.

- [ ] Taproot activation - `history.taproot-activation`
  `2021-11-14` | `protocol`
  Taproot (BIP 340-342) si attiva su mainnet, migliorando privacy ed
  efficienza degli script.

- [ ] All-time high $69,000 - `history.bitcoin-ath-2021`
  `2021-11-10` | `market`
  Bitcoin raggiunge il massimo storico di ~$69.000.

### Fase 6 — New Frontiers (2022–2026)

- [ ] Ordinals launch - `history.ordinals-launch`
  `2023-01-21` | `community`
  Casey Rodarmor lancia il protocollo Ordinals, permettendo inscription di
  dati sulla blockchain Bitcoin.

- [ ] Bitcoin ETFs approved - `history.bitcoin-etf-approval`
  `2024-01-10` | `regulation`
  La SEC approva 11 spot Bitcoin ETF, segnando un punto di svolta per
  l'adozione istituzionale.

- [ ] Fourth halving - `history.fourth-halving`
  `2024-04-20` | `protocol`
  Quarto halving: il block subsidy passa da 6,25 a 3,125 BTC. Altezza blocco
  840.000.

- [ ] Runes protocol launch - `history.runes-launch`
  `2024-04` | `protocol`
  Casey Rodarmor lancia Runes, protocollo di token fungibile su Bitcoin
  basato su UTXO.

- [ ] Bitcoin $100,000 milestone - `history.bitcoin-one-hundred-thousand`
  `2024-12-05` | `market`
  Bitcoin supera $100.000 per la prima volta, trainato dall'afflusso degli
  ETF.

---

## Template per file evento

```markdown
---
id: history.{slug}
slug: {slug}
language: en
date: YYYY-MM-DD
title: Titolo Evento
category: {category}
summary: Una frase di riepilogo.
coverImage: media/wiki/history-{slug}/history-{slug}-hero.svg
sources:
  - title: Fonte
    url: https://...
related:
  - wiki.{related-concept}
updatedAt: 2026-05-28T00:00:00Z
---

Testo completo dell'evento con contesto storico, impatto e significato.
Supporta immagini Markdown inline.
```

---
