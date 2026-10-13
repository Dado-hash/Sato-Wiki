import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/lab_blockchain.dart';
import 'tool_widgets.dart';

/// Most tries one mining run makes. A run that reaches it stops with a message.
const int labMaxMiningAttempts = 5000000;

/// Tries between two UI updates. Small enough that the screen keeps responding.
const int labMiningBatchSize = 2000;

/// Progress of one mining run: tries so far and how fast they came.
final class LabMiningProgress {
  /// Creates a progress value.
  const LabMiningProgress({required this.attempts, required this.elapsed});

  /// Nonces tried so far, counting from 0.
  final int attempts;

  /// Time since the run started.
  final Duration elapsed;

  /// Hashes per second, or 0 before any time has passed.
  double get hashesPerSecond {
    final micros = elapsed.inMicroseconds;

    return micros == 0 ? 0 : attempts * Duration.microsecondsPerSecond / micros;
  }
}

/// Searches for a nonce in small batches, yielding to the event loop between
/// them so the screen stays responsive.
///
/// Returns the block with the first nonce that meets [leadingZeros], or null
/// when [isCancelled] turns true or [labMaxMiningAttempts] tries pass.
Future<LabBlock?> mineLabBlockInBatches(
  LabBlock block, {
  required int leadingZeros,
  required bool Function() isCancelled,
  required void Function(LabMiningProgress progress) onProgress,
}) async {
  final watch = Stopwatch()..start();
  var nonce = 0;
  while (nonce < labMaxMiningAttempts) {
    if (isCancelled()) {
      return null;
    }
    final chunk = mineLabBlockChunk(
      block,
      leadingZeros: leadingZeros,
      startNonce: nonce,
      attempts: labMiningBatchSize,
    );
    final found = chunk.nonce;
    if (found != null) {
      onProgress(
        LabMiningProgress(attempts: found + 1, elapsed: watch.elapsed),
      );

      return block.copyWith(nonce: found);
    }
    nonce = chunk.nextNonce;
    onProgress(LabMiningProgress(attempts: nonce, elapsed: watch.elapsed));
    await Future<void>.delayed(Duration.zero);
  }

  return null;
}

/// Lets a screen run one mining job at a time and report its progress.
///
/// The job receives a cancel check and a progress callback. Cancelling is
/// cooperative: the job stops at its next batch.
mixin LabMiningMixin<T extends StatefulWidget> on State<T> {
  bool _mining = false;
  bool _cancelRequested = false;
  LabMiningProgress? _progress;

  /// Whether a job is running.
  bool get isMining => _mining;

  /// Progress of the latest run, or null before the first batch.
  LabMiningProgress? get miningProgress => _progress;

  /// Runs [job] unless a run is already going.
  Future<void> runMining(
    Future<void> Function(
      bool Function() isCancelled,
      void Function(LabMiningProgress progress) onProgress,
    )
    job,
  ) async {
    if (_mining) {
      return;
    }
    setState(() {
      _mining = true;
      _cancelRequested = false;
      _progress = null;
    });
    try {
      await job(() => _cancelRequested || !mounted, (progress) {
        if (mounted) {
          setState(() => _progress = progress);
        }
      });
    } finally {
      if (mounted) {
        setState(() => _mining = false);
      }
    }
  }

  /// Asks the running job to stop at its next batch.
  void cancelMining() {
    if (_mining) {
      setState(() => _cancelRequested = true);
    }
  }
}

/// Mine and Cancel buttons, with the live tries and speed of a run.
class LabMineControls extends StatelessWidget {
  const LabMineControls({
    required this.mineLabel,
    required this.mining,
    required this.progress,
    required this.onMine,
    required this.onCancel,
    super.key,
  });

  /// Text of the button that starts a run, such as "Mine".
  final String mineLabel;
  final bool mining;
  final LabMiningProgress? progress;

  /// Null disables the button.
  final VoidCallback? onMine;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final current = progress;
    final locale = toolLocale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mining)
          OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            child: Text(l10n.labMineCancel),
          )
        else
          FilledButton(
            onPressed: onMine,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            child: Text(mineLabel),
          ),
        if (mining) ...[
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(l10n.labMineRunning, style: textTheme.bodySmall),
          ),
        ],
        if (current != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ToolKeyValue(
            label: l10n.labMineAttempts,
            value: labNumber(locale, current.attempts),
            monospace: true,
          ),
          ToolKeyValue(
            label: l10n.labMineSpeed,
            value: l10n.labMineSpeedValue(
              labNumber(locale, current.hashesPerSecond.round()),
            ),
            monospace: true,
          ),
        ],
      ],
    );
  }
}

/// Whole number with the digit grouping of [locale].
String labNumber(String locale, num value) {
  return NumberFormat.decimalPattern(locale).format(value);
}
