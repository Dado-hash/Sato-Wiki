import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/compact_target.dart';
import '../domain/header_mining.dart';
import '../domain/tools_bytes.dart';
import 'lab_block_card.dart';
import 'tool_widgets.dart';

/// Lab step 7: the real genesis header, decoded field by field and hashed.
/// Data is embedded in the code; nothing is fetched.
class LabHeaderStep extends StatelessWidget {
  const LabHeaderStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = toolLocale(context);
    final header = genesisHeader;
    final hex = hexEncode(header.serialize());
    final target = targetFromBits(header.bits);
    final palette = toolFieldPalette(context);
    final time = DateTime.fromMillisecondsSinceEpoch(
      header.time * 1000,
      isUtc: true,
    );

    // Hex sizes in characters for version, previous hash, merkle root, time,
    // bits and nonce. The same colour marks each field in the bytes and the list.
    final fields = <(String, String, int)>[
      (l10n.labHeaderVersion, '${header.version}', 8),
      (l10n.labBlockPrevious, header.previousBlockHash, 64),
      (l10n.labHeaderMerkle, header.merkleRoot, 64),
      (
        l10n.labHeaderTime,
        '${DateFormat('yyyy-MM-dd HH:mm:ss', locale).format(time)} UTC',
        8,
      ),
      (
        l10n.labHeaderBits,
        '0x${header.bits.toRadixString(16).padLeft(8, '0')}',
        8,
      ),
      (l10n.labBlockNonce, '${header.nonce}', 8),
    ];

    final spans = <InlineSpan>[];
    var offset = 0;
    for (var i = 0; i < fields.length; i++) {
      final length = fields[i].$3;
      spans.add(
        TextSpan(
          text: hex.substring(offset, offset + length),
          style: TextStyle(backgroundColor: palette[i % palette.length]),
        ),
      );
      offset += length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.labHeaderIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        ToolResultCard(
          label: l10n.labHeaderBytes,
          child: ToolMonoBlock(spans: spans),
        ),
        const SizedBox(height: AppSpacing.md),
        ToolResultCard(
          label: l10n.labHeaderFields,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < fields.length; i++)
                ToolLegendRow(
                  color: palette[i % palette.length],
                  label: fields[i].$1,
                  value: fields[i].$2,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ToolResultCard(
          label: l10n.labHeaderDoubleHash,
          child: ToolCopyValue(value: header.hash),
        ),
        const SizedBox(height: AppSpacing.md),
        ToolResultCard(
          label: l10n.labHeaderTarget,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolCopyValue(value: targetToHex(target)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.labHeaderBelowTarget,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  LabValidityPill(valid: headerMeetsTarget(header, target)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
