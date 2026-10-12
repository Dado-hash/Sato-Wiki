import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../content/application/app_content_controller.dart';
import '../theme/app_tokens.dart';
import '../theme/sato_colors.dart';
import 'sato_progress_bar.dart';

/// Non-blocking strip that reports a content update. It only paints its own
/// box, so taps outside it reach the app underneath.
class UpdateProgressBanner extends StatefulWidget {
  const UpdateProgressBanner({required this.contentController, super.key});

  final AppContentController contentController;

  @override
  State<UpdateProgressBanner> createState() => _UpdateProgressBannerState();
}

class _UpdateProgressBannerState extends State<UpdateProgressBanner> {
  static const _doneDuration = Duration(milliseconds: 2500);
  static const _errorDuration = Duration(milliseconds: 4000);

  late UpdateProgress _progress;
  Timer? _hideTimer;

  /// Set by the close button. Cleared when a new download starts.
  bool _dismissed = false;

  /// Set when the done or error message has been shown for its full time.
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _progress = widget.contentController.updateProgress;
    _scheduleExpiry(_progress.state);
    widget.contentController.addListener(_handleProgressChanged);
  }

  @override
  void didUpdateWidget(UpdateProgressBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentController != widget.contentController) {
      oldWidget.contentController.removeListener(_handleProgressChanged);
      widget.contentController.addListener(_handleProgressChanged);
      _handleProgressChanged();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.contentController.removeListener(_handleProgressChanged);
    super.dispose();
  }

  void _handleProgressChanged() {
    if (!mounted) return;

    final next = widget.contentController.updateProgress;
    final previousState = _progress.state;
    if (next.state != previousState) {
      _hideTimer?.cancel();
      _expired = false;
      if (_isWorking(next.state) && !_isWorking(previousState)) {
        _dismissed = false;
      }
      _scheduleExpiry(next.state);
    }

    setState(() => _progress = next);
  }

  void _scheduleExpiry(UpdateState state) {
    final duration = switch (state) {
      UpdateState.done => _doneDuration,
      UpdateState.error => _errorDuration,
      UpdateState.idle ||
      UpdateState.checking ||
      UpdateState.downloadingBundle ||
      UpdateState.downloadingMedia ||
      UpdateState.installing => null,
    };
    if (duration == null) return;

    _hideTimer = Timer(duration, () {
      if (mounted) setState(() => _expired = true);
    });
  }

  void _dismiss() {
    setState(() => _dismissed = true);
  }

  static bool _isWorking(UpdateState state) {
    return state == UpdateState.downloadingBundle ||
        state == UpdateState.downloadingMedia ||
        state == UpdateState.installing;
  }

  bool get _isVisible {
    if (_dismissed || _expired) return false;

    return _isWorking(_progress.state) ||
        _progress.state == UpdateState.done ||
        _progress.state == UpdateState.error;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 220),
      reverseDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 150),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _isVisible
          ? _UpdateBanner(
              key: const ValueKey('update-banner'),
              progress: _progress,
              onClose: _dismiss,
            )
          : const SizedBox.shrink(key: ValueKey('update-banner-hidden')),
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner({
    required this.progress,
    required this.onClose,
    super.key,
  });

  final UpdateProgress progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sato = context.sato;
    final state = progress.state;
    final isDone = state == UpdateState.done;
    final isError = state == UpdateState.error;

    final statusText = switch (state) {
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
      UpdateState.idle || UpdateState.checking => '',
    };

    final IconData icon;
    final Color iconColor;
    if (isDone) {
      icon = Icons.check_rounded;
      iconColor = sato.statusDeployed;
    } else if (isError) {
      icon = Icons.error_outline_rounded;
      iconColor = colorScheme.error;
    } else {
      icon = Icons.download_rounded;
      iconColor = colorScheme.primary;
    }

    final Widget? bar = switch (state) {
      UpdateState.downloadingBundle => ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: const LinearProgressIndicator(minHeight: 4),
      ),
      UpdateState.downloadingMedia ||
      UpdateState.installing => SatoProgressBar(value: progress.progress),
      UpdateState.idle ||
      UpdateState.checking ||
      UpdateState.done ||
      UpdateState.error => null,
    };

    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.contentUpdateTitle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.5 : 0.14,
              ),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: colorScheme.surfaceContainerHigh,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
            side: BorderSide(color: sato.borderStrong),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sato.accentTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (bar != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        bar,
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.close,
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: 44,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
