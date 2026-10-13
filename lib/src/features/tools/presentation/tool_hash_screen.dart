import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/sato_segmented_control.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/hash160.dart';
import '../domain/tools_bytes.dart';
import 'tool_widgets.dart';

enum _HashInputMode { text, hex }

/// Hash tool: SHA-256, double SHA-256 and HASH160 of text or hex bytes.
class ToolHashScreen extends StatefulWidget {
  const ToolHashScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<ToolHashScreen> createState() => _ToolHashScreenState();
}

class _ToolHashScreenState extends State<ToolHashScreen> {
  final _controller = TextEditingController();
  _HashInputMode _mode = _HashInputMode.text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refresh(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text;
    final isHexMode = _mode == _HashInputMode.hex;
    final hexIsEmpty = isHexMode && text.trim().isEmpty;
    final hexIsInvalid = isHexMode && !hexIsEmpty && !isHex(text);
    final bytes = _inputBytes(text, isHexMode: isHexMode);

    return DetailScaffold(
      title: l10n.toolsHashTitle,
      children: [
        SatoSegmentedControl<_HashInputMode>(
          items: _HashInputMode.values,
          selected: _mode,
          labelFor: (mode) => switch (mode) {
            _HashInputMode.text => l10n.toolsHashModeText,
            _HashInputMode.hex => l10n.toolsHashModeHex,
          },
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        const SizedBox(height: AppSpacing.md),
        ToolTextField(
          controller: _controller,
          hintText: isHexMode ? l10n.toolsHashHexHint : l10n.toolsHashTextHint,
          onChanged: _refresh,
          minLines: 1,
          maxLines: 5,
          monospace: isHexMode,
          errorText: hexIsInvalid ? l10n.toolsHashInvalidHex : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (hexIsEmpty)
          Text(
            l10n.toolsHashEmptyHex,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else if (bytes != null) ...[
          ToolResultCard(
            label: l10n.toolsHashSha256,
            child: ToolCopyValue(value: hexEncode(sha256Bytes(bytes))),
          ),
          const SizedBox(height: AppSpacing.md),
          ToolResultCard(
            label: l10n.toolsHashDoubleSha256,
            child: ToolCopyValue(value: hexEncode(doubleSha256(bytes))),
          ),
          const SizedBox(height: AppSpacing.md),
          ToolResultCard(
            label: l10n.toolsHashHash160,
            child: ToolCopyValue(value: hexEncode(hash160(bytes))),
          ),
        ],
        const SizedBox(height: AppSpacing.section),
        Text(
          l10n.toolsHashNote,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        ToolWikiLinks(
          store: widget.store,
          entryIds: const ['wiki.hash-functions', 'wiki.sha-256'],
        ),
      ],
    );
  }
}

/// Bytes hashed for [text]: its UTF-8 bytes in text mode, the decoded hex in
/// hex mode. Null when hex mode has input that is not valid hex.
Uint8List? _inputBytes(String text, {required bool isHexMode}) {
  if (!isHexMode) {
    return Uint8List.fromList(utf8.encode(text));
  }
  if (text.trim().isEmpty || !isHex(text)) {
    return null;
  }

  return hexDecode(text);
}
