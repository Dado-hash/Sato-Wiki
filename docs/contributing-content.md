# Contributing Content

Content starts from Markdown/YAML templates in `content/templates/`.

Flow:

1. Create or edit content in the content repo.
2. Generate JSON bundle.
3. Validate JSON with:

```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart assets/content/seed_bundle.json
```

4. Open PR with generated bundle and source Markdown.

PR checks must run:

```bash
/Users/davide/development/flutter/bin/dart run tool/validate_content.dart
/Users/davide/development/flutter/bin/dart run tool/generate_bundle.dart
```

Publishing target: static JSON bundle on CDN plus immutable versioned path:

```text
content/{version}/bundle.json
content/latest/manifest.json
```
