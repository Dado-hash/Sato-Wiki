import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/address_analyzer.dart';
import '../domain/base58.dart';
import '../domain/tools_bytes.dart';
import 'tool_widgets.dart';

/// Address tool: type, network, checksum and the parts of a pasted address.
///
/// Private keys and extended keys get a warning only. Their text is cleared
/// and never analysed or shown. Nothing typed here is stored.
class ToolAddressScreen extends StatefulWidget {
  const ToolAddressScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<ToolAddressScreen> createState() => _ToolAddressScreenState();
}

class _ToolAddressScreenState extends State<ToolAddressScreen> {
  final _controller = TextEditingController();

  /// Analysis of the current text. Null when the field is blank.
  AddressAnalysis? _analysis;

  /// Set after a private or extended key was pasted and cleared.
  AddressKind? _secretKind;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final analysis = analyzeAddress(value);
    if (analysis.kind == AddressKind.privateKeyWif ||
        analysis.kind == AddressKind.extendedKey) {
      // The key is not analysed or kept: the field is emptied right away.
      _controller.clear();
      setState(() {
        _analysis = null;
        _secretKind = analysis.kind;
      });

      return;
    }

    setState(() {
      _secretKind = null;
      _analysis = value.trim().isEmpty ? null : analysis;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final analysis = _analysis;
    final secretKind = _secretKind;

    return DetailScaffold(
      title: l10n.toolsAddressTitle,
      children: [
        ToolTextField(
          controller: _controller,
          hintText: l10n.toolsAddressHint,
          onChanged: _onChanged,
          minLines: 2,
          maxLines: 4,
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (secretKind != null)
          _SecretWarning(kind: secretKind)
        else if (analysis == null)
          Text(
            l10n.toolsAddressErrorEmpty,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else ...[
          _Pills(analysis: analysis),
          const SizedBox(height: AppSpacing.lg),
          ToolResultCard(
            label: _kindLabel(l10n, analysis.kind),
            child: Text(
              analysis.kind == AddressKind.invalid
                  ? _errorMessage(l10n, analysis.error)
                  : _kindDescription(l10n, analysis.kind),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ToolWikiLinks(
            store: widget.store,
            entryIds: _wikiIdsFor(analysis.kind),
          ),
          if (analysis.kind != AddressKind.invalid) ...[
            const SizedBox(height: AppSpacing.section),
            _Structure(text: _controller.text.trim(), analysis: analysis),
          ],
        ],
      ],
    );
  }
}

class _SecretWarning extends StatelessWidget {
  const _SecretWarning({required this.kind});

  final AddressKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.sato.accentTint,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kind == AddressKind.extendedKey
                  ? l10n.toolsAddressSecretExtendedTitle
                  : l10n.toolsAddressSecretWifTitle,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.toolsAddressSecretBody, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Checksum and network as text pills.
class _Pills extends StatelessWidget {
  const _Pills({required this.analysis});

  final AddressAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sato = context.sato;

    final checksumInvalid = analysis.error == AddressError.badChecksum;
    final network = analysis.network;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (checksumInvalid)
          StatusPill(
            label: l10n.toolsAddressChecksumInvalid,
            color: colorScheme.error,
          )
        else if (analysis.checksumValid)
          StatusPill(
            label: l10n.toolsAddressChecksumValid,
            color: sato.statusDeployed,
          ),
        if (network != null)
          StatusPill(
            label: switch (network) {
              BitcoinNetwork.mainnet => l10n.toolsAddressNetworkMainnet,
              BitcoinNetwork.testnet => l10n.toolsAddressNetworkTestnet,
              BitcoinNetwork.regtest => l10n.toolsAddressNetworkRegtest,
            },
            color: colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

/// The address with its parts coloured, and a legend that names each part.
///
/// SegWit strings are split into prefix, separator, witness version, program
/// and checksum. Base58Check strings do not line up with bytes, so they are
/// shown plain, with the version, payload and checksum listed below.
class _Structure extends StatelessWidget {
  const _Structure({required this.text, required this.analysis});

  final String text;
  final AddressAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isSegwit =
        analysis.encoding == AddressEncoding.bech32 ||
        analysis.encoding == AddressEncoding.bech32m;

    return ToolResultCard(
      label: l10n.toolsAddressBuiltTitle,
      child: isSegwit
          ? _segwitStructure(context, l10n)
          : _base58Structure(context, l10n, textTheme),
    );
  }

  Widget _segwitStructure(BuildContext context, AppLocalizations l10n) {
    final palette = toolFieldPalette(context);
    final parts = _Bech32Parts.of(text);
    final program = analysis.payload ?? Uint8List(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToolMonoBlock(
          spans: [
            TextSpan(
              text: parts.hrp,
              style: TextStyle(backgroundColor: palette[0]),
            ),
            TextSpan(
              text: parts.separator,
              style: TextStyle(backgroundColor: palette[1]),
            ),
            TextSpan(
              text: parts.version,
              style: TextStyle(backgroundColor: palette[2]),
            ),
            TextSpan(
              text: parts.program,
              style: TextStyle(backgroundColor: palette[3]),
            ),
            TextSpan(text: parts.checksum),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ToolLegendRow(
          color: palette[0],
          label: l10n.toolsPartPrefix,
          value: parts.hrp,
        ),
        ToolLegendRow(
          color: palette[1],
          label: l10n.toolsPartSeparator,
          value: parts.separator,
        ),
        ToolLegendRow(
          color: palette[2],
          label: l10n.toolsPartWitnessVersion,
          value: '${analysis.witnessVersion ?? parts.version}',
        ),
        ToolLegendRow(
          color: palette[3],
          label: l10n.toolsPartProgram,
          value: hexEncode(program),
        ),
        ToolLegendRow(
          color: context.sato.borderStrong,
          label: l10n.toolsPartChecksum,
          value: parts.checksum,
        ),
      ],
    );
  }

  Widget _base58Structure(
    BuildContext context,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    final bytes = base58Decode(text);
    final checksumStart = bytes.length - 4;
    final payload = bytes.sublist(1, checksumStart);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToolMonoBlock(spans: [TextSpan(text: text)]),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.toolsAddressBase58Note, style: textTheme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        ToolLegendRow(
          color: null,
          label: l10n.toolsPartVersionByte,
          value: hexEncode(bytes.sublist(0, 1)),
        ),
        ToolLegendRow(
          color: null,
          label: l10n.toolsPartPayloadHash,
          value: hexEncode(payload),
        ),
        ToolLegendRow(
          color: null,
          label: l10n.toolsPartBase58Checksum,
          value: hexEncode(bytes.sublist(checksumStart)),
        ),
      ],
    );
  }
}

/// The five visible parts of a Bech32 string, split at the last `1`.
final class _Bech32Parts {
  const _Bech32Parts({
    required this.hrp,
    required this.separator,
    required this.version,
    required this.program,
    required this.checksum,
  });

  factory _Bech32Parts.of(String text) {
    final separator = text.lastIndexOf('1');
    final data = text.substring(separator + 1);
    final checksumStart = data.length - 6;

    return _Bech32Parts(
      hrp: text.substring(0, separator),
      separator: '1',
      version: data.substring(0, 1),
      program: data.substring(1, checksumStart),
      checksum: data.substring(checksumStart),
    );
  }

  final String hrp;
  final String separator;
  final String version;
  final String program;
  final String checksum;
}

String _kindLabel(AppLocalizations l10n, AddressKind kind) {
  return switch (kind) {
    AddressKind.p2pkh => l10n.toolsAddressKindP2pkh,
    AddressKind.p2sh => l10n.toolsAddressKindP2sh,
    AddressKind.p2wpkh => l10n.toolsAddressKindP2wpkh,
    AddressKind.p2wsh => l10n.toolsAddressKindP2wsh,
    AddressKind.p2tr => l10n.toolsAddressKindP2tr,
    AddressKind.witnessUnknown => l10n.toolsAddressKindUnknownWitness,
    AddressKind.privateKeyWif ||
    AddressKind.extendedKey ||
    AddressKind.invalid => l10n.toolsAddressKindInvalid,
  };
}

String _kindDescription(AppLocalizations l10n, AddressKind kind) {
  return switch (kind) {
    AddressKind.p2pkh => l10n.toolsAddressDescP2pkh,
    AddressKind.p2sh => l10n.toolsAddressDescP2sh,
    AddressKind.p2wpkh => l10n.toolsAddressDescP2wpkh,
    AddressKind.p2wsh => l10n.toolsAddressDescP2wsh,
    AddressKind.p2tr => l10n.toolsAddressDescP2tr,
    AddressKind.witnessUnknown => l10n.toolsAddressDescUnknownWitness,
    AddressKind.privateKeyWif ||
    AddressKind.extendedKey ||
    AddressKind.invalid => l10n.toolsAddressKindInvalid,
  };
}

String _errorMessage(AppLocalizations l10n, AddressError? error) {
  return switch (error) {
    null => l10n.toolsAddressKindInvalid,
    AddressError.empty => l10n.toolsAddressErrorEmpty,
    AddressError.badCharacter => l10n.toolsAddressErrorBadCharacter,
    AddressError.badChecksum => l10n.toolsAddressErrorBadChecksum,
    AddressError.badLength => l10n.toolsAddressErrorBadLength,
    AddressError.unknownVersion => l10n.toolsAddressErrorUnknownVersion,
    AddressError.mixedCase => l10n.toolsAddressErrorMixedCase,
    AddressError.wrongBech32Variant => l10n.toolsAddressErrorWrongVariant,
    AddressError.missingSeparator => l10n.toolsAddressErrorMissingSeparator,
    AddressError.emptyHumanReadablePart => l10n.toolsAddressErrorEmptyHrp,
    AddressError.unknownHrp => l10n.toolsAddressErrorUnknownHrp,
    AddressError.emptyData => l10n.toolsAddressErrorEmptyData,
    AddressError.invalidPadding => l10n.toolsAddressErrorInvalidPadding,
  };
}

/// Wiki entries that explain an address type. Only the ones that exist in
/// the loaded bundle are shown.
List<String> _wikiIdsFor(AddressKind kind) {
  return switch (kind) {
    AddressKind.p2pkh => const [
      'wiki.bitcoin-addresses',
      'wiki.address-encodings',
    ],
    AddressKind.p2sh => const ['wiki.p2sh', 'wiki.address-encodings'],
    AddressKind.p2wpkh || AddressKind.p2wsh || AddressKind.witnessUnknown =>
      const ['wiki.segregated-witness', 'wiki.address-encodings'],
    AddressKind.p2tr => const ['wiki.taproot', 'wiki.address-encodings'],
    AddressKind.invalid ||
    AddressKind.privateKeyWif ||
    AddressKind.extendedKey => const ['wiki.address-encodings'],
  };
}
