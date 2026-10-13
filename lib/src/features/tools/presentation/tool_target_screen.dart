import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/compact_target.dart';
import 'tool_widgets.dart';

const String _defaultBits = '1d00ffff';

/// Above this many expected hashes the result also reads in scientific style.
final BigInt _scientificThreshold = BigInt.from(10).pow(15);

/// Target tool: from compact `bits` to the 256-bit target, the difficulty and
/// the expected number of hashes per block.
class ToolTargetScreen extends StatefulWidget {
  const ToolTargetScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<ToolTargetScreen> createState() => _ToolTargetScreenState();
}

class _ToolTargetScreenState extends State<ToolTargetScreen> {
  final _controller = TextEditingController(text: _defaultBits);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = toolLocale(context);
    final target = _targetFor(_controller.text);

    return DetailScaffold(
      title: l10n.toolsTargetTitle,
      children: [
        ToolTextField(
          controller: _controller,
          hintText: l10n.toolsTargetHint,
          onChanged: (_) => setState(() {}),
          monospace: true,
          errorText: target == null ? l10n.toolsTargetInvalid : null,
        ),
        if (target != null) ...[
          const SizedBox(height: AppSpacing.lg),
          ToolResultCard(
            label: l10n.toolsTargetTargetLabel,
            child: ToolCopyValue(value: targetToHex(target)),
          ),
          const SizedBox(height: AppSpacing.md),
          ToolResultCard(
            label: l10n.toolsTargetDifficulty,
            child: Text(
              NumberFormat(
                '#,##0.##',
                locale,
              ).format(difficultyFromTarget(target)),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ExpectedHashes(
            label: l10n.toolsTargetExpected,
            value: expectedHashes(target),
            locale: locale,
            scientificLabel: (mantissa, exponent) =>
                l10n.toolsTargetScientific(mantissa, exponent),
          ),
        ],
        const SizedBox(height: AppSpacing.section),
        Text(
          l10n.toolsTargetNote,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        ToolWikiLinks(
          store: widget.store,
          entryIds: const [
            'wiki.block-header',
            'wiki.difficulty-adjustment',
            'wiki.proof-of-work',
          ],
        ),
      ],
    );
  }
}

/// Target for the typed bits, or null when they are not valid. A zero target
/// has no difficulty, so it is treated as invalid too.
BigInt? _targetFor(String text) {
  try {
    final target = targetFromBits(parseBits(text));

    return target == BigInt.zero ? null : target;
  } on FormatException {
    return null;
  }
}

class _ExpectedHashes extends StatelessWidget {
  const _ExpectedHashes({
    required this.label,
    required this.value,
    required this.locale,
    required this.scientificLabel,
  });

  final String label;
  final BigInt value;
  final String locale;
  final String Function(String mantissa, int exponent) scientificLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final digits = value.toString();
    final exponent = digits.length - 1;

    return ToolResultCard(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_groupDigits(digits, locale), style: textTheme.titleMedium),
          if (value > _scientificThreshold) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              scientificLabel(_mantissa(digits, locale), exponent),
              style: toolMonoStyle(context, size: 12),
            ),
          ],
        ],
      ),
    );
  }
}

/// Digits with thousands separators for [locale].
String _groupDigits(String digits, String locale) {
  final separator = NumberFormat.decimalPattern(locale).symbols.GROUP_SEP;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(separator);
    }
    buffer.write(digits[i]);
  }

  return buffer.toString();
}

/// First digits of [digits] as a number between 1 and 10, with two decimals.
String _mantissa(String digits, String locale) {
  final head = digits.substring(0, digits.length < 3 ? digits.length : 3);
  final mantissa = double.parse(
    '${head[0]}.${head.substring(1).padRight(2, '0')}',
  );

  return NumberFormat('0.00', locale).format(mantissa);
}
