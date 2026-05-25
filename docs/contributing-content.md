# Contributing Content

Content starts from Markdown/YAML templates in `content/templates/`.

Flow:

1. Create or edit content in the content repo.
2. Generate JSON bundle.
3. Validate JSON with:

```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle_en.json
```

4. Open PR with generated bundle and source Markdown.

PR checks must run:

```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart
```

Publishing target: static JSON bundle on CDN plus immutable versioned path:

```text
content/{language}/{version}/bundle.json
content/{language}/latest/manifest.json
```

Current GitHub Pages target:

```text
https://dado-hash.github.io/Sato-Wiki/content/en/latest/manifest.json
https://dado-hash.github.io/Sato-Wiki/content/en/{version}/bundle.json
```
