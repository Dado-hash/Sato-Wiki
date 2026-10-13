import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/tools_bytes.dart';
import 'tool_widgets.dart';

/// Lab step 1: the SHA-256 of a text, updated at every key press.
class LabHashStep extends StatefulWidget {
  const LabHashStep({super.key});

  @override
  State<LabHashStep> createState() => _LabHashStepState();
}

class _LabHashStepState extends State<LabHashStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final digest = hexEncode(sha256Bytes(utf8.encode(_controller.text)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.labHashIntro, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        ToolTextField(
          controller: _controller,
          hintText: l10n.labHashHint,
          onChanged: (_) => setState(() {}),
          minLines: 1,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.lg),
        ToolResultCard(
          label: l10n.labHashLabel,
          child: ToolCopyValue(value: digest),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.labHashNote, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
