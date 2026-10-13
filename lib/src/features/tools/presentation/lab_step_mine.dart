import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'lab_block_miner.dart';
import 'lab_steps.dart';
import 'tool_widgets.dart';

/// Sample block data. Names and amounts stay the same in both languages.
const String labSampleBlockData = 'Alice -> Bob: 5';

/// Lab step 2: edit the data of a toy block, then mine it.
class LabMineStep extends StatefulWidget {
  const LabMineStep({this.difficulty = labToyDifficulty, super.key});

  /// Leading zero characters the hash needs. Tests use a lower value.
  final int difficulty;

  @override
  State<LabMineStep> createState() => _LabMineStepState();
}

class _LabMineStepState extends State<LabMineStep> {
  final _controller = TextEditingController(text: labSampleBlockData);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.labMineIntro, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        ToolTextField(
          controller: _controller,
          hintText: l10n.labBlockData,
          onChanged: (_) => setState(() {}),
          minLines: 1,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.lg),
        LabBlockMiner(
          number: 1,
          data: _controller.text,
          mineLabel: l10n.labMineButton,
          difficulty: widget.difficulty,
        ),
      ],
    );
  }
}
