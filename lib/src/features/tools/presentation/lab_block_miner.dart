import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/lab_blockchain.dart';
import 'lab_block_card.dart';
import 'lab_mining.dart';
import 'lab_steps.dart';
import 'tool_widgets.dart';

enum _LabMineOutcome { none, found, stopped, gaveUp }

/// One lab block with a nonce and a Mine button.
///
/// The validity is computed from the current data and nonce, so editing the
/// data makes the block not valid again. A run in progress is cancelled when
/// the data changes.
class LabBlockMiner extends StatefulWidget {
  const LabBlockMiner({
    required this.number,
    required this.data,
    required this.mineLabel,
    this.difficulty = labToyDifficulty,
    super.key,
  });

  /// Position of the block in the lab chain.
  final int number;

  /// Block content. Changing it changes the hash.
  final String data;

  /// Text of the button that starts a run.
  final String mineLabel;

  /// Leading zero characters the hash needs.
  final int difficulty;

  @override
  State<LabBlockMiner> createState() => _LabBlockMinerState();
}

class _LabBlockMinerState extends State<LabBlockMiner>
    with LabMiningMixin<LabBlockMiner> {
  int _nonce = 0;
  _LabMineOutcome _outcome = _LabMineOutcome.none;

  @override
  void didUpdateWidget(LabBlockMiner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      cancelMining();
      _outcome = _LabMineOutcome.none;
    }
  }

  Future<void> _mine() {
    return runMining((isCancelled, onProgress) async {
      final block = LabBlock(
        number: widget.number,
        nonce: 0,
        data: widget.data,
        previousHash: labGenesisPreviousHash,
      );
      final found = await mineLabBlockInBatches(
        block,
        leadingZeros: widget.difficulty,
        isCancelled: isCancelled,
        onProgress: onProgress,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        if (found != null) {
          _nonce = found.nonce;
          _outcome = _LabMineOutcome.found;
        } else {
          _outcome = isCancelled()
              ? _LabMineOutcome.stopped
              : _LabMineOutcome.gaveUp;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final block = LabBlock(
      number: widget.number,
      nonce: _nonce,
      data: widget.data,
      previousHash: labGenesisPreviousHash,
    );
    final progress = miningProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabBlockCard(
          title: l10n.labBlockNumber(widget.number),
          valid: block.isMined(widget.difficulty),
          children: [
            ToolKeyValue(label: l10n.labBlockData, value: widget.data),
            ToolKeyValue(
              label: l10n.labBlockPrevious,
              value: labGenesisPreviousHash,
              monospace: true,
            ),
            ToolKeyValue(
              label: l10n.labBlockNonce,
              value: '$_nonce',
              monospace: true,
            ),
            ToolKeyValue(
              label: l10n.labBlockHash,
              value: block.hash,
              monospace: true,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.labMineRule(widget.difficulty),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        LabMineControls(
          mineLabel: widget.mineLabel,
          mining: isMining,
          progress: progress,
          onMine: isMining ? null : _mine,
          onCancel: cancelMining,
        ),
        if (_outcome != _LabMineOutcome.none) ...[
          const SizedBox(height: AppSpacing.md),
          Text(switch (_outcome) {
            _LabMineOutcome.found => l10n.labMineFound(progress?.attempts ?? 0),
            _LabMineOutcome.stopped => l10n.labMineStopped,
            _ => l10n.labMineGaveUp,
          }, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}
