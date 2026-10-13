import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/script_parser.dart';
import '../domain/tools_bytes.dart';
import 'tool_widgets.dart';

/// Stack items, top first. The top item carries a text label, not only its place.
class ScriptStackView extends StatelessWidget {
  const ScriptStackView({required this.stack, super.key});

  /// Items bottom first, as the machine reports them.
  final List<Uint8List> stack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (stack.isEmpty) {
      return Text(
        l10n.labScriptEmptyStack,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var depth = 0; depth < stack.length; depth++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '$depth',
                    style: toolMonoStyle(
                      context,
                      size: 12,
                    ).copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  child: Text(
                    _itemText(l10n, stack[stack.length - 1 - depth]),
                    style: toolMonoStyle(context, size: 12),
                  ),
                ),
                if (depth == 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  StatusPill(
                    label: l10n.labScriptTopLabel,
                    color: context.sato.statusDeployed,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  static String _itemText(AppLocalizations l10n, Uint8List item) {
    return item.isEmpty ? l10n.labScriptEmptyItem : hexEncode(item);
  }
}

/// The script from the next opcode on, with that opcode highlighted.
class ScriptRemainingView extends StatelessWidget {
  const ScriptRemainingView({
    required this.elements,
    required this.nextIndex,
    super.key,
  });

  final List<ScriptElement> elements;

  /// Position of the opcode that runs next.
  final int nextIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (nextIndex >= elements.length) {
      return Text(
        l10n.labScriptNothingLeft,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = nextIndex; index < elements.length; index++)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: index == nextIndex
                  ? context.sato.accentTint
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.thumb),
              border: Border.all(
                color: index == nextIndex
                    ? colorScheme.primary
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${index + 1}',
                    style: toolMonoStyle(
                      context,
                      size: 12,
                    ).copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  child: Text(
                    elements[index].toString(),
                    style: toolMonoStyle(context, size: 13),
                  ),
                ),
                if (index == nextIndex)
                  Text(
                    l10n.labScriptNextLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
