# Plan: Content Update Popup

## Modifica 1: `lib/src/core/content/data/content_media_store.dart`

Aggiungere parametro `onMediaProgress` a `prefetchBundleMedia`:

```dart
Future<void> prefetchBundleMedia({
  required ContentBundle bundle,
  required Uri bundleUrl,
  void Function(int current, int total)? onMediaProgress,
}) async {
```

Chiamare `onMediaProgress` nel loop di download media (dopo `for (final source in sources)`):

```dart
var mediaIndex = 0;
for (final source in sources) {
  onMediaProgress?.call(mediaIndex, sources.length);
  // ... existing download code ...
  mediaIndex++;
}
```

---

## Modifica 2: `lib/src/core/content/data/content_bundle_repository.dart`

Aggiungere parametro `onMediaProgress` a `VerifiedBackgroundContentUpdater.checkForUpdates`:

```dart
Future<ContentBundleParseResult?> checkForUpdates(
  String languageCode, {
  void Function(int current, int total)? onMediaProgress,
}) async {
```

Passarlo a `_mediaStore.prefetchBundleMedia`:

```dart
await _mediaStore?.prefetchBundleMedia(
  bundle: parsed.bundle,
  bundleUrl: manifest.bundleUrl,
  onMediaProgress: onMediaProgress,
);
```

E anche per il repair path:
```dart
await _mediaStore.prefetchBundleMedia(
  bundle: current.bundle,
  bundleUrl: manifest.bundleUrl,
  onMediaProgress: onMediaProgress,
);
```

---

## Modifica 3: `lib/src/core/content/application/app_content_controller.dart`

Aggiungere dopo gli import:

```dart
final class UpdateProgress {
  const UpdateProgress({
    required this.state,
    required this.progress,
    required this.description,
    this.mediaFilesDownloaded = 0,
    this.mediaFilesTotal = 0,
  });

  final UpdateState state;
  final double progress;
  final String description;
  final int mediaFilesDownloaded;
  final int mediaFilesTotal;
}

enum UpdateState { idle, checking, downloadingBundle, downloadingMedia, installing, done, error }
```

In `AppContentController` aggiungere campo:
```dart
UpdateProgress get updateProgress => _updateProgress;
UpdateProgress _updateProgress = const UpdateProgress(
  state: UpdateState.idle,
  progress: 0,
  description: '',
);
```

Modificare `checkForUpdates()`:

```dart
Future<void> checkForUpdates() async {
  final updater = _updater;
  if (updater == null) return;

  _updateProgress = const UpdateProgress(
    state: UpdateState.checking,
    progress: 0.05,
    description: 'checking',
  );
  notifyListeners();

  try {
    final current = await _repository.load(_languageCode);
    final manifest = await updater.fetchManifest(_languageCode);
    if (manifest == null) return;

    final isNewer = _isNewerVersion(manifest.version, current.bundle.version);
    if (!isNewer) return;

    _updateProgress = const UpdateProgress(
      state: UpdateState.downloadingBundle,
      progress: 0.1,
      description: 'downloadingBundle',
    );
    notifyListeners();

    final result = await updater.downloadAndVerify(
      manifest,
      _languageCode,
      onMediaProgress: (current, total) {
        final mediaProgress = total > 0 ? current / total : 0.0;
        _updateProgress = UpdateProgress(
          state: UpdateState.downloadingMedia,
          progress: 0.1 + 0.8 * mediaProgress,
          description: 'downloadingMedia',
          mediaFilesDownloaded: current,
          mediaFilesTotal: total,
        );
        notifyListeners();
      },
    );
    if (result == null) return;

    _updateProgress = const UpdateProgress(
      state: UpdateState.installing,
      progress: 0.95,
      description: 'installing',
    );
    notifyListeners();

    _content = _contentFromResult(result, _mediaStore);
    _updateProgress = const UpdateProgress(
      state: UpdateState.done,
      progress: 1.0,
      description: 'done',
    );
    notifyListeners();
  } on Object {
    _updateProgress = const UpdateProgress(
      state: UpdateState.error,
      progress: 0,
      description: 'error',
    );
    notifyListeners();
  }
}
```

Aggiungere metodo helper per version comparison (copiato da `VerifiedBackgroundContentUpdater`).

---

## Modifica 4: Nuovo file `lib/src/core/widgets/update_progress_dialog.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';
import '../content/application/app_content_controller.dart';

class UpdateProgressDialog extends StatefulWidget {
  const UpdateProgressDialog({
    required this.contentController,
    super.key,
  });

  final AppContentController contentController;

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  late AppContentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.contentController;
    _controller.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (!mounted) return;
    final progress = _controller.updateProgress;
    if (progress.state == UpdateState.done ||
        progress.state == UpdateState.error) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = _controller.updateProgress;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusText = switch (progress.state) {
      UpdateState.checking => l10n.contentUpdateChecking,
      UpdateState.downloadingBundle => l10n.contentUpdateDownloadingBundle,
      UpdateState.downloadingMedia => progress.mediaFilesTotal > 0
          ? l10n.contentUpdateDownloadingMediaFormatted(
              progress.mediaFilesDownloaded,
              progress.mediaFilesTotal,
            )
          : l10n.contentUpdateDownloadingMedia,
      UpdateState.installing => l10n.contentUpdateInstalling,
      UpdateState.done => l10n.contentUpdateDone,
      UpdateState.error => l10n.contentUpdateError,
      _ => '',
    };

    final isDeterminate = progress.state == UpdateState.downloadingMedia ||
        progress.state == UpdateState.installing ||
        progress.state == UpdateState.done;

    return PopScope(
      canPop: progress.state == UpdateState.done ||
          progress.state == UpdateState.error,
      child: AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  progress.state == UpdateState.done
                      ? Icons.check_circle
                      : progress.state == UpdateState.error
                          ? Icons.error_outline
                          : Icons.download_outlined,
                  color: progress.state == UpdateState.done
                      ? Colors.green
                      : progress.state == UpdateState.error
                          ? colorScheme.error
                          : colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.contentUpdateTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.contentUpdateAvailable,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (isDeterminate)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.progress,
                    minHeight: 6,
                  ),
                )
              else
                const LinearProgressIndicator(minHeight: 6),
              const SizedBox(height: 12),
              Text(
                statusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Modifica 5: `lib/src/app.dart`

Aggiungere import del dialog e tracking dello stato:

```dart
import 'core/content/application/app_content_controller.dart';
import 'core/widgets/update_progress_dialog.dart';
```

In `_SatoWikiAppState`:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  widget.settingsController.addListener(_handleAppStateChanged);
  widget.contentController.addListener(_handleAppStateChanged);
  widget.contentController.addListener(_handleUpdateProgress);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    widget.contentController.checkForUpdates();
  });
}

@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  widget.settingsController.removeListener(_handleAppStateChanged);
  widget.contentController.removeListener(_handleAppStateChanged);
  widget.contentController.removeListener(_handleUpdateProgress);
  super.dispose();
}

void _handleUpdateProgress() {
  final progress = widget.contentController.updateProgress;
  switch (progress.state) {
    case UpdateState.checking:
    case UpdateState.downloadingBundle:
    case UpdateState.downloadingMedia:
    case UpdateState.installing:
      _maybeShowUpdateDialog();
    case UpdateState.done:
    case UpdateState.error:
    case _:
      break;
  }
}

void _maybeShowUpdateDialog() {
  if (!mounted) return;
  final route = ModalRoute.of(context);
  if (route == null || !route.isCurrent) return;
  // Check if dialog is already showing
  final overlay = Overlay.of(context);
  if (overlay.widget.debugIsVisible == null) return;
  
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => UpdateProgressDialog(
      contentController: widget.contentController,
    ),
  );
}
```

---

## Modifica 6: ARB files

### `lib/l10n/app_en.arb` — aggiungere:

```
"contentUpdateTitle": "Content Update",
"contentUpdateAvailable": "New content is ready to download.",
"contentUpdateChecking": "Checking for updates...",
"contentUpdateDownloadingBundle": "Downloading content...",
"contentUpdateDownloadingMedia": "Downloading media files...",
"contentUpdateDownloadingMediaFormatted": "Downloading media ({current} of {total})...",
"@contentUpdateDownloadingMediaFormatted": {
  "placeholders": {
    "current": {"type": "int"},
    "total": {"type": "int"}
  }
},
"contentUpdateInstalling": "Installing update...",
"contentUpdateDone": "Update complete!",
"contentUpdateError": "Update failed. Content is unchanged."
```

### `lib/l10n/app_it.arb` — aggiungere:

```
"contentUpdateTitle": "Aggiornamento contenuti",
"contentUpdateAvailable": "Nuovi contenuti pronti per il download.",
"contentUpdateChecking": "Verifica aggiornamenti...",
"contentUpdateDownloadingBundle": "Download contenuti...",
"contentUpdateDownloadingMedia": "Download file media...",
"contentUpdateDownloadingMediaFormatted": "Download media ({current} di {total})...",
"@contentUpdateDownloadingMediaFormatted": {
  "placeholders": {
    "current": {"type": "int"},
    "total": {"type": "int"}
  }
},
"contentUpdateInstalling": "Installazione aggiornamento...",
"contentUpdateDone": "Aggiornamento completato!",
"contentUpdateError": "Aggiornamento fallito. I contenuti sono invariati."
```

---

## Ordine di esecuzione

1. `content_media_store.dart` — aggiungere callback
2. `content_bundle_repository.dart` — agganciare callback
3. `app_content_controller.dart` — aggiungere UpdateProgress + modificare checkForUpdates
4. `update_progress_dialog.dart` — nuovo file widget
5. `app_en.arb` + `app_it.arb` — nuove chiavi
6. Rigenerare localizzazioni con `flutter gen-l10n`
7. `app.dart` — collegare dialog
8. Verificare con `flutter test` e `flutter analyze`

---

## Nota su Downloader byte-level progress

Per il bundle JSON, il download è `Future<String>` quindi non c'è progresso byte-by-byte senza riscrivere `HttpContentBundleDownloader`. Per v1 usiamo progresso per-fase:
- checking: ~5%
- downloadingBundle: ~15%
- downloadingMedia: 15% → 95%
- installing: ~100%

Se in futuro serve byte-level progress, modificare `ContentBundleDownloader` con un `Stream<int>` per i byte ricevuti.
