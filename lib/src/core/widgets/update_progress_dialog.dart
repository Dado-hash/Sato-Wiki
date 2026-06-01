import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../content/application/app_content_controller.dart';

class UpdateProgressDialog extends StatefulWidget {
  const UpdateProgressDialog({required this.contentController, super.key});

  final AppContentController contentController;

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  @override
  void initState() {
    super.initState();
    widget.contentController.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    widget.contentController.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (!mounted) return;

    final progress = widget.contentController.updateProgress;
    switch (progress.state) {
      case UpdateState.idle:
        Navigator.of(context).pop();
      case UpdateState.error:
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.of(context).pop();
        });
      case UpdateState.done:
      case UpdateState.checking:
      case UpdateState.downloadingBundle:
      case UpdateState.downloadingMedia:
      case UpdateState.installing:
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = widget.contentController.updateProgress;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusText = switch (progress.state) {
      UpdateState.checking => l10n.contentUpdateChecking,
      UpdateState.downloadingBundle => l10n.contentUpdateDownloadingBundle,
      UpdateState.downloadingMedia =>
        progress.mediaFilesTotal > 0
            ? l10n.contentUpdateDownloadingMediaFormatted(
                progress.mediaFilesDownloaded,
                progress.mediaFilesTotal,
              )
            : l10n.contentUpdateDownloadingMedia,
      UpdateState.installing => l10n.contentUpdateInstalling,
      UpdateState.done => l10n.contentUpdateDone,
      UpdateState.error => l10n.contentUpdateError,
      UpdateState.idle => '',
    };

    final isDeterminate =
        progress.state == UpdateState.downloadingMedia ||
        progress.state == UpdateState.installing ||
        progress.state == UpdateState.done;

    final canPop =
        progress.state == UpdateState.done ||
        progress.state == UpdateState.error;

    return PopScope(
      canPop: canPop,
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
              if (progress.state == UpdateState.done)
                const Icon(Icons.check_circle, color: Colors.green, size: 48)
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: progress.state == UpdateState.error
                        ? colorScheme.errorContainer
                        : colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      progress.state == UpdateState.error
                          ? Icons.error_outline
                          : Icons.download_outlined,
                      color: progress.state == UpdateState.error
                          ? colorScheme.error
                          : colorScheme.primary,
                      size: 28,
                    ),
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
        actions: progress.state == UpdateState.done
            ? [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
              ]
            : null,
      ),
    );
  }
}
