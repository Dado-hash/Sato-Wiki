import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/content_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/raw_transaction.dart';
import '../domain/units.dart';
import 'tool_widgets.dart';

/// Genesis coinbase transaction, loaded by the example button.
/// Source: test/tools_raw_transaction_test.dart.
const String _genesisExampleHex =
    '01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a01000000434104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac00000000';

/// Fields rendered as rows and coloured in the hex. The rest is left out
/// so that very large transactions stay cheap to draw.
const int _maxRenderedFields = 400;

/// Transaction tool: decodes a raw transaction and shows its ids, sizes,
/// coloured hex and every field with its decoded value.
class ToolTransactionScreen extends StatefulWidget {
  const ToolTransactionScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<ToolTransactionScreen> createState() => _ToolTransactionScreenState();
}

class _ToolTransactionScreenState extends State<ToolTransactionScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadExample() {
    _controller.text = _genesisExampleHex;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();

    Widget result;
    if (text.isEmpty) {
      result = Text(
        l10n.toolsTxEmpty,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    } else {
      try {
        final tx = decodeRawTransaction(text);
        result = _TransactionResult(
          store: widget.store,
          hex: text.toLowerCase(),
          tx: tx,
        );
      } on RawTransactionException catch (error) {
        result = Text(
          _errorMessage(l10n, error.reason),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    return DetailScaffold(
      title: l10n.toolsTxTitle,
      children: [
        ToolTextField(
          controller: _controller,
          hintText: l10n.toolsTxHint,
          onChanged: (_) => setState(() {}),
          minLines: 3,
          maxLines: 8,
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: _loadExample,
            child: Text(l10n.toolsTxLoadExample),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.toolsTxExampleNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        result,
      ],
    );
  }
}

class _TransactionResult extends StatelessWidget {
  const _TransactionResult({
    required this.store,
    required this.hex,
    required this.tx,
  });

  final ContentStore store;

  /// Lower-case hex of the transaction, two characters per byte.
  final String hex;
  final DecodedTransaction tx;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final palette = toolFieldPalette(context);
    final shownCount = tx.fields.length < _maxRenderedFields
        ? tx.fields.length
        : _maxRenderedFields;
    final hiddenCount = tx.fields.length - shownCount;

    final spans = <InlineSpan>[];
    var coloredEnd = 0;
    for (var i = 0; i < shownCount; i++) {
      final field = tx.fields[i];
      final start = field.offset * 2;
      final end = (field.offset + field.length) * 2;
      spans.add(
        TextSpan(
          text: hex.substring(start, end),
          style: TextStyle(backgroundColor: palette[i % palette.length]),
        ),
      );
      coloredEnd = end;
    }
    if (coloredEnd < hex.length) {
      spans.add(TextSpan(text: hex.substring(coloredEnd)));
    }

    final weightRoute = _loadedRoute(store, 'wiki.weight-units');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolResultCard(
          label: l10n.toolsTxSummary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabelledValue(label: l10n.toolsTxTxid, value: tx.txid),
              if (tx.wtxid != tx.txid)
                _LabelledValue(label: l10n.toolsTxWtxid, value: tx.wtxid),
              ToolKeyValue(
                label: l10n.toolsTxType,
                value: tx.isCoinbase
                    ? l10n.toolsTxTypeCoinbase
                    : l10n.toolsTxTypeRegular,
              ),
              ToolKeyValue(
                label: l10n.toolsTxFormat,
                value: tx.isSegwit
                    ? l10n.toolsTxFormatSegwit
                    : l10n.toolsTxFormatLegacy,
              ),
              ToolKeyValue(
                label: l10n.toolsTxSize,
                value: l10n.toolsTxBytes(tx.totalSize),
              ),
              ToolKeyValue(
                label: l10n.toolsTxWeight,
                value: l10n.toolsTxWeightUnits(tx.weight),
                onTap: weightRoute == null
                    ? null
                    : () => Navigator.of(context).pushNamed(weightRoute),
              ),
              ToolKeyValue(
                label: l10n.toolsTxVsize,
                value: l10n.toolsTxVbytes(tx.vsize),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ToolResultCard(
          label: l10n.toolsTxHexTitle,
          child: ToolMonoBlock(spans: spans),
        ),
        const SizedBox(height: AppSpacing.section),
        SectionTitle(title: l10n.toolsTxFieldsTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.toolsTxTapHint,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SatoGroupCard(
          children: [
            for (final field in tx.fields.take(shownCount))
              _FieldRow(store: store, field: field, tx: tx, hex: hex),
          ],
        ),
        if (hiddenCount > 0) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.toolsTxHiddenFields(hiddenCount),
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// Label above a monospace value that can be copied.
class _LabelledValue extends StatelessWidget {
  const _LabelledValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodySmall),
          ToolCopyValue(value: value),
        ],
      ),
    );
  }
}

/// One field of the serialization: name, position, decoded value and size.
class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.store,
    required this.field,
    required this.tx,
    required this.hex,
  });

  final ContentStore store;
  final TxField field;
  final DecodedTransaction tx;
  final String hex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final details = _FieldDetails.of(l10n, field, tx, hex);
    final route = details.wikiId == null
        ? null
        : _loadedRoute(store, details.wikiId!);

    return InkWell(
      onTap: route == null
          ? null
          : () => Navigator.of(context).pushNamed(route),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (details.place != null)
                      Text(details.place!, style: textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      details.value,
                      style: toolMonoStyle(context, size: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.toolsTxBytes(field.length),
                    style: textTheme.labelMedium,
                  ),
                  if (route != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decoded view of one field. Built from the field kind and the decoded
/// transaction; the hex is used for fields that are raw bytes.
final class _FieldDetails {
  const _FieldDetails({
    required this.name,
    required this.value,
    this.place,
    this.wikiId,
  });

  factory _FieldDetails.of(
    AppLocalizations l10n,
    TxField field,
    DecodedTransaction tx,
    String hex,
  ) {
    final index = field.index;
    final kind = field.kind;
    final isInputField = _isInputKind(kind);
    final input = index != null && isInputField && index < tx.inputs.length
        ? tx.inputs[index]
        : null;
    final output = index != null && !isInputField && index < tx.outputs.length
        ? tx.outputs[index]
        : null;
    final isCoinbaseInput = tx.isCoinbase && index == 0 && isInputField;

    String? place;
    if (index != null) {
      if (kind == TxFieldKind.witnessItem ||
          kind == TxFieldKind.witnessItemLength) {
        place = l10n.toolsTxWitnessLabel(index, field.itemIndex ?? 0);
      } else if (isInputField) {
        place = isCoinbaseInput
            ? '${l10n.toolsTxInputLabel(index)} · ${l10n.toolsTxCoinbaseTag}'
            : l10n.toolsTxInputLabel(index);
      } else {
        place = l10n.toolsTxOutputLabel(index);
      }
    }

    final value = switch (kind) {
      TxFieldKind.version => '${tx.version}',
      TxFieldKind.lockTime => '${tx.lockTime}',
      TxFieldKind.marker ||
      TxFieldKind.flag ||
      TxFieldKind.scriptSig ||
      TxFieldKind.witnessItem => _bytesHex(hex, field),
      TxFieldKind.inputCount => '${tx.inputs.length}',
      TxFieldKind.outputCount => '${tx.outputs.length}',
      TxFieldKind.previousTxid => input?.previousTxid ?? '',
      TxFieldKind.previousIndex => '${input?.previousIndex ?? 0}',
      TxFieldKind.scriptSigLength => '${input?.scriptSig.length ?? 0}',
      TxFieldKind.sequence => '${input?.sequence ?? 0}',
      TxFieldKind.value =>
        output == null
            ? ''
            : l10n.toolsTxValueBoth(
                satoshiToBitcoinText(output.valueSatoshi),
                '${output.valueSatoshi}',
              ),
      TxFieldKind.scriptPubKeyLength => '${output?.scriptPubKey.length ?? 0}',
      TxFieldKind.scriptPubKey =>
        output == null ? '' : _scriptTypeLabel(l10n, output.scriptType),
      TxFieldKind.witnessItemCount => '${input?.witness.length ?? 0}',
      TxFieldKind.witnessItemLength =>
        '${_witnessItem(input, field)?.length ?? 0}',
    };

    final wikiId = isCoinbaseInput
        ? 'wiki.coinbase-transaction'
        : _wikiIdFor(kind);

    return _FieldDetails(
      name: _fieldName(l10n, kind),
      value: value,
      place: place,
      wikiId: wikiId,
    );
  }

  final String name;
  final String value;

  /// Input or output number, with the coinbase tag where it applies.
  final String? place;

  /// Wiki entry that explains the field, when one applies.
  final String? wikiId;
}

bool _isInputKind(TxFieldKind kind) {
  return switch (kind) {
    TxFieldKind.previousTxid ||
    TxFieldKind.previousIndex ||
    TxFieldKind.scriptSigLength ||
    TxFieldKind.scriptSig ||
    TxFieldKind.sequence ||
    TxFieldKind.witnessItemCount ||
    TxFieldKind.witnessItemLength ||
    TxFieldKind.witnessItem => true,
    _ => false,
  };
}

String? _wikiIdFor(TxFieldKind kind) {
  return switch (kind) {
    TxFieldKind.version ||
    TxFieldKind.inputCount ||
    TxFieldKind.previousTxid ||
    TxFieldKind.previousIndex ||
    TxFieldKind.outputCount ||
    TxFieldKind.value => 'wiki.transactions',
    TxFieldKind.marker ||
    TxFieldKind.flag ||
    TxFieldKind.witnessItemCount ||
    TxFieldKind.witnessItemLength ||
    TxFieldKind.witnessItem => 'wiki.segregated-witness',
    TxFieldKind.scriptSigLength ||
    TxFieldKind.scriptSig ||
    TxFieldKind.scriptPubKeyLength ||
    TxFieldKind.scriptPubKey => 'wiki.bitcoin-script',
    TxFieldKind.sequence || TxFieldKind.lockTime => 'wiki.timelocks',
  };
}

Uint8List? _witnessItem(TxInput? input, TxField field) {
  final item = field.itemIndex;
  final witness = input?.witness;
  if (witness == null || item == null || item >= witness.length) {
    return null;
  }

  return witness[item];
}

/// Hex of the bytes that [field] covers, read from the full [hex].
String _bytesHex(String hex, TxField field) {
  return hex.substring(field.offset * 2, (field.offset + field.length) * 2);
}

/// Route of a wiki entry, or null when the entry is not in the loaded bundle.
String? _loadedRoute(ContentStore store, String id) {
  if (recordTitleFor(store, id) == null) {
    return null;
  }

  return routeForContentId(id);
}

String _errorMessage(AppLocalizations l10n, RawTransactionErrorReason reason) {
  return switch (reason) {
    RawTransactionErrorReason.notHex => l10n.toolsTxErrorNotHex,
    RawTransactionErrorReason.truncated => l10n.toolsTxErrorTruncated,
    RawTransactionErrorReason.trailingBytes => l10n.toolsTxErrorTrailing,
    RawTransactionErrorReason.tooLarge => l10n.toolsTxErrorTooLarge,
    RawTransactionErrorReason.invalidStructure => l10n.toolsTxErrorInvalid,
  };
}

String _scriptTypeLabel(AppLocalizations l10n, ScriptType type) {
  return switch (type) {
    ScriptType.p2pk => l10n.toolsScriptP2pk,
    ScriptType.p2pkh => l10n.toolsScriptP2pkh,
    ScriptType.p2sh => l10n.toolsScriptP2sh,
    ScriptType.p2wpkh => l10n.toolsScriptP2wpkh,
    ScriptType.p2wsh => l10n.toolsScriptP2wsh,
    ScriptType.p2tr => l10n.toolsScriptP2tr,
    ScriptType.witnessUnknown => l10n.toolsScriptWitnessUnknown,
    ScriptType.bareMultisig => l10n.toolsScriptBareMultisig,
    ScriptType.opReturn => l10n.toolsScriptOpReturn,
    ScriptType.nonStandard => l10n.toolsScriptNonStandard,
  };
}

String _fieldName(AppLocalizations l10n, TxFieldKind kind) {
  return switch (kind) {
    TxFieldKind.version => l10n.toolsFieldVersion,
    TxFieldKind.marker => l10n.toolsFieldMarker,
    TxFieldKind.flag => l10n.toolsFieldFlag,
    TxFieldKind.inputCount => l10n.toolsFieldInputCount,
    TxFieldKind.previousTxid => l10n.toolsFieldPreviousTxid,
    TxFieldKind.previousIndex => l10n.toolsFieldPreviousIndex,
    TxFieldKind.scriptSigLength => l10n.toolsFieldScriptSigLength,
    TxFieldKind.scriptSig => l10n.toolsFieldScriptSig,
    TxFieldKind.sequence => l10n.toolsFieldSequence,
    TxFieldKind.outputCount => l10n.toolsFieldOutputCount,
    TxFieldKind.value => l10n.toolsFieldValue,
    TxFieldKind.scriptPubKeyLength => l10n.toolsFieldScriptPubKeyLength,
    TxFieldKind.scriptPubKey => l10n.toolsFieldScriptPubKey,
    TxFieldKind.witnessItemCount => l10n.toolsFieldWitnessItemCount,
    TxFieldKind.witnessItemLength => l10n.toolsFieldWitnessItemLength,
    TxFieldKind.witnessItem => l10n.toolsFieldWitnessItem,
    TxFieldKind.lockTime => l10n.toolsFieldLockTime,
  };
}
