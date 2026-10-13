import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/script_examples.dart';
import '../domain/script_machine.dart';
import '../domain/script_parser.dart';
import 'script_messages.dart';
import 'script_stack_view.dart';
import 'tool_widgets.dart';

/// Script step by step: pick an example or type a script, then run it one
/// opcode at a time and watch the stack.
class ScriptStepperScreen extends StatefulWidget {
  const ScriptStepperScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<ScriptStepperScreen> createState() => _ScriptStepperScreenState();
}

class _ScriptStepperScreenState extends State<ScriptStepperScreen> {
  final _typedController = TextEditingController(text: '2 3 OP_ADD 5 OP_EQUAL');

  /// The chosen example, or null for a typed script.
  ScriptExample? _example = scriptExamples.first;
  List<ScriptElement> _elements = const [];
  ScriptMachine? _machine;
  ScriptParseException? _parseError;
  ScriptStepResult? _last;
  int _stepsRun = 0;

  @override
  void initState() {
    super.initState();
    _loadExample(scriptExamples.first);
  }

  @override
  void dispose() {
    _typedController.dispose();
    super.dispose();
  }

  void _loadExample(ScriptExample example) {
    _example = example;
    _elements = parseScriptAsm('${example.unlocking} ${example.locking}');
    _machine = ScriptMachine(
      _elements,
      lockTime: example.lockTime,
      inputSequence: example.inputSequence,
      txVersion: example.txVersion,
      validSignatures: example.validSignatures,
    );
    _parseError = null;
    _last = null;
    _stepsRun = 0;
  }

  void _loadTyped(String asm) {
    _example = null;
    _last = null;
    _stepsRun = 0;
    try {
      _elements = parseScriptAsm(asm);
      _machine = ScriptMachine(_elements);
      _parseError = null;
    } on ScriptParseException catch (error) {
      _elements = const [];
      _machine = null;
      _parseError = error;
    }
  }

  void _select(ScriptExample? example) {
    setState(() {
      if (example == null) {
        _loadTyped(_typedController.text);
      } else {
        _loadExample(example);
      }
    });
  }

  void _step() {
    final machine = _machine;
    if (machine == null || machine.isFinished) {
      return;
    }
    setState(() {
      _last = machine.step();
      _stepsRun++;
    });
  }

  void _runToEnd() {
    final machine = _machine;
    if (machine == null || machine.isFinished) {
      return;
    }
    setState(() {
      while (!machine.isFinished) {
        _last = machine.step();
        _stepsRun++;
      }
    });
  }

  void _reset() {
    final machine = _machine;
    setState(() {
      machine?.reset();
      _last = null;
      _stepsRun = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final machine = _machine;
    final finished = machine?.isFinished ?? false;
    final example = _example;

    return DetailScaffold(
      title: l10n.labScriptTitle,
      children: [
        Text(
          l10n.labScriptIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        _SimulationNotice(text: l10n.labScriptSimulated),
        const SizedBox(height: AppSpacing.lg),
        _ExampleChips(selected: example, onSelected: _select),
        const SizedBox(height: AppSpacing.lg),
        if (example != null) ...[
          Text(
            scriptExampleDescription(l10n, example),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ToolResultCard(
            label: l10n.labScriptSourceLabel,
            child: ToolMonoBlock(
              spans: [
                TextSpan(text: '${example.unlocking} ${example.locking}'),
              ],
            ),
          ),
        ] else ...[
          ToolTextField(
            controller: _typedController,
            hintText: l10n.labScriptCustomHint,
            monospace: true,
            minLines: 1,
            maxLines: 4,
            onChanged: (text) => setState(() => _loadTyped(text)),
            errorText: _parseError == null
                ? null
                : l10n.labScriptParseError(
                    _parseError!.index + 1,
                    scriptParseReasonMessage(l10n, _parseError!.reason),
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.labScriptCustomNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _Controls(
          canStep: machine != null && !finished,
          canReset: machine != null,
          onStep: _step,
          onRunToEnd: _runToEnd,
          onReset: _reset,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _stepsRun == 0
              ? l10n.labScriptNotStarted
              : l10n.labScriptRunCount(_stepsRun),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        ToolResultCard(
          label: l10n.labScriptRemaining,
          child: ScriptRemainingView(
            elements: _elements,
            nextIndex: _last == null ? 0 : _last!.index + 1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ToolResultCard(
          label: l10n.labScriptStack,
          child: ScriptStackView(stack: _last?.stack ?? const []),
        ),
        if ((_last?.altStack ?? const []).isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ToolResultCard(
            label: l10n.labScriptAltStack,
            child: ScriptStackView(stack: _last!.altStack),
          ),
        ],
        if (_last?.note case final note?) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            scriptNoteMessage(l10n, note),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (machine != null && finished) ...[
          const SizedBox(height: AppSpacing.md),
          _ResultCard(machine: machine),
        ],
        const SizedBox(height: AppSpacing.section),
        ToolWikiLinks(
          store: widget.store,
          entryIds: [example?.wikiEntryId ?? 'wiki.bitcoin-script'],
        ),
      ],
    );
  }
}

class _SimulationNotice extends StatelessWidget {
  const _SimulationNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _ExampleChips extends StatelessWidget {
  const _ExampleChips({required this.selected, required this.onSelected});

  /// Null when a typed script is selected.
  final ScriptExample? selected;
  final ValueChanged<ScriptExample?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final example in scriptExamples)
          ChoiceChip(
            label: Text(scriptExampleName(l10n, example)),
            selected: selected?.id == example.id,
            onSelected: (_) => onSelected(example),
          ),
        ChoiceChip(
          label: Text(l10n.labScriptCustomChip),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.canStep,
    required this.canReset,
    required this.onStep,
    required this.onRunToEnd,
    required this.onReset,
  });

  final bool canStep;
  final bool canReset;
  final VoidCallback onStep;
  final VoidCallback onRunToEnd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const buttonSize = Size(0, 48);

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton(
          onPressed: canStep ? onStep : null,
          style: FilledButton.styleFrom(minimumSize: buttonSize),
          child: Text(l10n.labScriptStep),
        ),
        OutlinedButton(
          onPressed: canStep ? onRunToEnd : null,
          style: OutlinedButton.styleFrom(minimumSize: buttonSize),
          child: Text(l10n.labScriptRunToEnd),
        ),
        TextButton(
          onPressed: canReset ? onReset : null,
          style: TextButton.styleFrom(minimumSize: buttonSize),
          child: Text(l10n.labScriptReset),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.machine});

  final ScriptMachine machine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final succeeded = machine.succeeded ?? false;
    final error = machine.error;

    final text = succeeded
        ? l10n.labScriptSucceeds
        : l10n.labScriptFails(
            error == null
                ? l10n.labScriptFalseTop
                : scriptErrorMessage(l10n, error),
          );

    return ToolResultCard(
      label: l10n.labScriptResult,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            succeeded ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 20,
            color: succeeded ? context.sato.statusDeployed : colorScheme.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: textTheme.titleSmall)),
        ],
      ),
    );
  }
}
