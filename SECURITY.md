# Security Policy

## Reporting a vulnerability

Please do not open a public issue for a security problem.

Report it privately with GitHub's [private vulnerability reporting](https://github.com/Dado-hash/Sato-Wiki/security/advisories/new). Include what you found, how to reproduce it and which version or commit you tested.

You will get an answer as soon as the maintainer can review the report. Please allow time for a fix before disclosing the issue publicly.

## What is in scope

SatoWiki holds no accounts, keys or funds, so the areas that matter are:

- **Content updates.** The app downloads a content bundle and its media from GitHub Pages, verifies a SHA-256 hash and validates the schema before installing. A way to make the app install content that fails those checks, or to write files outside its media directory, is a vulnerability.
- **Content rendering.** Markdown, links and images come from the bundle. A way to make bundled content run code, or open something other than the link shown to the reader, is a vulnerability.
- **The build and publishing pipeline.** The GitHub Actions workflows in `.github/workflows/`, including the automated content sync.

A factual error in an entry is not a security issue. Please open a content correction issue instead.

## Supported versions

Only the latest version on the `main` branch is supported.
