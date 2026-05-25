# Content Model

Questo documento descrive il contratto dati target tra repo contenuti, pipeline CI e app Flutter.

## Bundle

```json
{
  "version": "2026.05.25",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [],
  "news": [],
  "history": [],
  "bips": [],
  "changelogs": []
}
```

Ogni record deve includere:

- `id` stabile;
- `slug` leggibile;
- `language`;
- `title`;
- `summary`;
- `tags`;
- `sources`;
- `related`;
- `updatedAt`.

## WikiEntry

```json
{
  "id": "wiki.proof-of-work",
  "slug": "proof-of-work",
  "category": "protocol",
  "title": "Proof of Work",
  "description": "The consensus mechanism used to validate transactions...",
  "readingLevels": {
    "base": { "bodyMarkdown": "..." },
    "medium": { "bodyMarkdown": "..." },
    "advanced": { "bodyMarkdown": "..." }
  },
  "difficulty": "advanced",
  "readTimeMinutes": 15,
  "tags": ["Mining", "Consensus", "Cryptography"],
  "related": ["wiki.sha-256", "wiki.difficulty-adjustment"],
  "sources": []
}
```

## NewsArticle

```json
{
  "id": "news.taproot-retrospective",
  "slug": "taproot-retrospective",
  "title": "The Activation of Taproot: A Retrospective",
  "category": "protocol",
  "author": {
    "github": "author-handle",
    "displayName": "Andreas M.",
    "lightningAddress": "optional"
  },
  "publishedAt": "2023-11-14",
  "readTimeMinutes": 12,
  "coverImage": "optional",
  "bodyMarkdown": "...",
  "tags": ["Taproot", "Upgrades"],
  "related": ["code.bip.341"]
}
```

## HistoryEvent

```json
{
  "id": "history.bitcoin-pizza-day",
  "slug": "bitcoin-pizza-day",
  "date": "2010-05-22",
  "title": "Bitcoin Pizza Day",
  "category": "community",
  "summary": "Laszlo Hanyecz made the first documented commercial transaction...",
  "bodyMarkdown": "...",
  "sources": [],
  "related": ["wiki.transactions"]
}
```

Gli eventi sono append-only: correzioni ammesse solo per factual fix tracciati.

## Bip

```json
{
  "id": "code.bip.341",
  "number": 341,
  "title": "Taproot",
  "status": "active",
  "category": "consensus",
  "authors": ["Pieter Wuille", "Jonas Nick", "Anthony Towns"],
  "createdAt": "2020-01-19",
  "summaryMarkdown": "...",
  "impactMarkdown": "...",
  "officialUrl": "https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki",
  "related": ["wiki.taproot", "news.taproot-retrospective"],
  "statusHistory": []
}
```

Status ammessi:

- `draft`
- `proposed`
- `active`
- `final`
- `withdrawn`
- `rejected`

## ReleaseNote

```json
{
  "id": "release.bitcoin-core.27.0",
  "project": "bitcoin-core",
  "version": "27.0",
  "releasedAt": "2024-04-16",
  "importance": "major",
  "userImpactMarkdown": "...",
  "technicalChangesMarkdown": "...",
  "officialUrl": "..."
}
```
