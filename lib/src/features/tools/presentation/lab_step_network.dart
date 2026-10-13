import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/lab_blockchain.dart';
import 'lab_block_card.dart';
import 'lab_step_chain.dart';
import 'lab_steps.dart';
import 'tool_widgets.dart';

/// Lab step 4: three nodes, each with a copy of the chain. A node keeps a copy
/// only when every block in it is valid. Nothing is sent over a network: the
/// three copies live on this device.
class LabNetworkStep extends StatefulWidget {
  const LabNetworkStep({super.key});

  @override
  State<LabNetworkStep> createState() => _LabNetworkStepState();
}

class _LabNetworkStepState extends State<LabNetworkStep> {
  bool _tampered = false;

  /// Node B's copy with the data of block 2 changed and nothing re-mined.
  static List<LabBlock> _tamperedCopy(List<LabBlock> chain) {
    return [chain[0], chain[1].copyWith(data: 'Bob -> Carol: 200'), chain[2]];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final base = labDefaultChain();
    final nodes = <(String, List<LabBlock>)>[
      ('A', base),
      ('B', _tampered ? _tamperedCopy(base) : base),
      ('C', base),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.labNetworkIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final (name, chain) in nodes) ...[
          _NodeCard(
            title: l10n.labNetworkNode(name),
            chain: chain,
            keepsLabel: l10n.labNetworkKeeps,
            rejectsLabel: l10n.labNetworkRejects,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (_tampered)
          FilledButton(
            onPressed: () => setState(() => _tampered = false),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            child: Text(l10n.labNetworkRestore),
          )
        else
          OutlinedButton(
            onPressed: () => setState(() => _tampered = true),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            child: Text(l10n.labNetworkTamper),
          ),
      ],
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.title,
    required this.chain,
    required this.keepsLabel,
    required this.rejectsLabel,
  });

  final String title;
  final List<LabBlock> chain;
  final String keepsLabel;
  final String rejectsLabel;

  @override
  Widget build(BuildContext context) {
    final statuses = validateLabChain(chain, labToyDifficulty);
    final keeps = statuses.every((status) => status.valid);

    return LabBlockCard(
      title: title,
      valid: keeps,
      children: [
        Text(
          keeps ? keepsLabel : rejectsLabel,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ToolKeyValue(
          label: AppLocalizations.of(context).labBlockHash,
          value: chain.last.hash,
          monospace: true,
        ),
      ],
    );
  }
}
