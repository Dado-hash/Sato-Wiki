import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/lab_blockchain.dart';
import 'lab_block_miner.dart';
import 'tool_widgets.dart';

/// Lab step 5: transfers become the text of a block, one line each.
class LabTransactionsStep extends StatefulWidget {
  const LabTransactionsStep({super.key});

  @override
  State<LabTransactionsStep> createState() => _LabTransactionsStepState();
}

class _LabTransactionsStepState extends State<LabTransactionsStep> {
  final _transfers = <LabTransfer>[
    const LabTransfer(from: 'Alice', to: 'Bob', amount: 5),
    const LabTransfer(from: 'Bob', to: 'Carol', amount: 2),
  ];
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _amount = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _add() {
    final l10n = AppLocalizations.of(context);
    final from = _from.text.trim();
    final to = _to.text.trim();
    final amount = int.tryParse(_amount.text.trim());
    final String? error;
    if (from.isEmpty || to.isEmpty) {
      error = l10n.labTxNameError;
    } else if (amount == null || amount < 0) {
      error = l10n.labTxAmountError;
    } else {
      error = null;
    }
    setState(() {
      _error = error;
      if (error == null) {
        _transfers.add(LabTransfer(from: from, to: to, amount: amount!));
        _from.clear();
        _to.clear();
        _amount.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final data = encodeLabTransfers(_transfers);
    final blockHash = LabBlock(
      number: 1,
      nonce: 0,
      data: data,
      previousHash: labGenesisPreviousHash,
    ).hash;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.labTxIntro, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < _transfers.length; i++)
          _TransferRow(
            text: encodeLabTransfers([_transfers[i]]),
            removeTooltip: l10n.labTxRemove,
            onRemove: () => setState(() => _transfers.removeAt(i)),
          ),
        const SizedBox(height: AppSpacing.lg),
        ToolTextField(controller: _from, hintText: l10n.labTxFrom),
        const SizedBox(height: AppSpacing.sm),
        ToolTextField(controller: _to, hintText: l10n.labTxTo),
        const SizedBox(height: AppSpacing.sm),
        ToolTextField(
          controller: _amount,
          hintText: l10n.labTxAmount,
          keyboardType: TextInputType.number,
          errorText: _error,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: _add,
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          child: Text(l10n.labTxAdd),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_transfers.isEmpty)
          Text(
            l10n.labTxEmpty,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          ToolResultCard(
            label: l10n.labTxData,
            child: ToolMonoBlock(spans: [TextSpan(text: data)]),
          ),
          const SizedBox(height: AppSpacing.md),
          ToolResultCard(
            label: l10n.labTxBlockHash,
            child: ToolCopyValue(value: blockHash),
          ),
        ],
      ],
    );
  }
}

/// Coinbase line first, then the transfers. The miner's name is typed by the user.
class LabCoinbaseStep extends StatefulWidget {
  const LabCoinbaseStep({super.key});

  @override
  State<LabCoinbaseStep> createState() => _LabCoinbaseStepState();
}

class _LabCoinbaseStepState extends State<LabCoinbaseStep> {
  static const _reward = 50;
  static const _transfers = [
    LabTransfer(from: 'Alice', to: 'Bob', amount: 5),
    LabTransfer(from: 'Bob', to: 'Carol', amount: 2),
  ];

  final _miner = TextEditingController(text: 'Miner');

  @override
  void dispose() {
    _miner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final miner = _miner.text.trim();
    final text = miner.isEmpty
        ? null
        : encodeLabTransfers(
            _transfers,
            coinbase: LabTransfer(from: 'Coinbase', to: miner, amount: _reward),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.labCoinbaseIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        ToolTextField(
          controller: _miner,
          hintText: l10n.labCoinbaseMiner,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.labCoinbaseReward('$_reward'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (text == null)
          Text(
            l10n.labTxNameError,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          )
        else
          LabBlockMiner(number: 1, data: text, mineLabel: l10n.labMineButton),
      ],
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({
    required this.text,
    required this.removeTooltip,
    required this.onRemove,
  });

  final String text;
  final String removeTooltip;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(text, style: toolMonoStyle(context, size: 12))),
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: removeTooltip,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
