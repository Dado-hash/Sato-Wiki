import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/lab_blockchain.dart';
import 'lab_block_card.dart';
import 'lab_mining.dart';
import 'lab_steps.dart';
import 'tool_widgets.dart';

const List<String> _chainData = [
  'Alice -> Bob: 5',
  'Bob -> Carol: 2',
  'Carol -> Dan: 1',
];

/// Nonces that make each block of [labDefaultChain] meet [labToyDifficulty].
/// They were found with the lab's own search, so the chain starts valid.
const List<int> _chainNonces = [235902, 44748, 75389];

/// Three linked blocks, valid at the start.
List<LabBlock> labDefaultChain() {
  final chain = <LabBlock>[];
  var previousHash = labGenesisPreviousHash;
  for (var i = 0; i < _chainData.length; i++) {
    final block = LabBlock(
      number: i + 1,
      nonce: _chainNonces[i],
      data: _chainData[i],
      previousHash: previousHash,
    );
    chain.add(block);
    previousHash = block.hash;
  }

  return chain;
}

/// Lab step 3: a chain of three blocks. Editing one breaks it from there on.
class LabChainStep extends StatefulWidget {
  const LabChainStep({super.key});

  @override
  State<LabChainStep> createState() => _LabChainStepState();
}

class _LabChainStepState extends State<LabChainStep>
    with LabMiningMixin<LabChainStep> {
  final List<LabBlock> _chain = labDefaultChain();
  late final List<TextEditingController> _controllers = [
    for (final block in _chain) TextEditingController(text: block.data),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _edit(int index, String data) {
    cancelMining();
    setState(() => _chain[index] = _chain[index].copyWith(data: data));
  }

  /// Mines every block from the first invalid one to the end, each linked to
  /// the new hash of the block before it.
  Future<void> _remine(List<LabBlockStatus> statuses) {
    final first = statuses.indexWhere((status) => !status.valid);
    if (first < 0) {
      return Future<void>.value();
    }

    return runMining((isCancelled, onProgress) async {
      for (var i = first; i < _chain.length; i++) {
        final previousHash = i == 0
            ? labGenesisPreviousHash
            : _chain[i - 1].hash;
        final block = _chain[i].copyWith(nonce: 0, previousHash: previousHash);
        final found = await mineLabBlockInBatches(
          block,
          leadingZeros: labToyDifficulty,
          isCancelled: isCancelled,
          onProgress: onProgress,
        );
        if (found == null || !mounted) {
          return;
        }
        setState(() => _chain[i] = found);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statuses = validateLabChain(_chain, labToyDifficulty);
    final allValid = statuses.every((status) => status.valid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.labChainIntro, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < _chain.length; i++) ...[
          LabBlockCard(
            title: l10n.labBlockNumber(i + 1),
            valid: statuses[i].valid,
            children: [
              ToolTextField(
                controller: _controllers[i],
                hintText: l10n.labBlockData,
                onChanged: (text) => _edit(i, text),
              ),
              const SizedBox(height: AppSpacing.sm),
              ToolKeyValue(
                label: l10n.labBlockPrevious,
                value: _chain[i].previousHash,
                monospace: true,
              ),
              ToolKeyValue(
                label: l10n.labBlockNonce,
                value: '${_chain[i].nonce}',
                monospace: true,
              ),
              ToolKeyValue(
                label: l10n.labBlockHash,
                value: _chain[i].hash,
                monospace: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        LabMineControls(
          mineLabel: l10n.labChainRemine,
          mining: isMining,
          progress: miningProgress,
          onMine: allValid || isMining ? null : () => _remine(statuses),
          onCancel: cancelMining,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.labChainWhy, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
