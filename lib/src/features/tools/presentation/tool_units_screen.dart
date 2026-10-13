import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../domain/units.dart';
import 'tool_widgets.dart';

/// Units tool: BTC and satoshi, weight units to virtual bytes, and fee versus
/// fee rate. Each converter updates while the user types. No prices.
class ToolUnitsScreen extends StatefulWidget {
  const ToolUnitsScreen({required this.store, super.key});

  final ContentStore store;

  @override
  State<ToolUnitsScreen> createState() => _ToolUnitsScreenState();
}

class _ToolUnitsScreenState extends State<ToolUnitsScreen> {
  final _btc = TextEditingController();
  final _satoshi = TextEditingController();
  final _weight = TextEditingController();
  final _feeSatoshi = TextEditingController();
  final _feeVsize = TextEditingController();
  final _rate = TextEditingController();
  final _rateVsize = TextEditingController();

  /// Error under the BTC field or the satoshi field of the first converter.
  String? _btcError;
  String? _satoshiError;

  @override
  void dispose() {
    for (final controller in [
      _btc,
      _satoshi,
      _weight,
      _feeSatoshi,
      _feeVsize,
      _rate,
      _rateVsize,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// BTC typed: the satoshi field follows, using integer math.
  void _onBtcChanged(String text) {
    final l10n = AppLocalizations.of(context);
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _satoshi.clear();
      setState(() {
        _btcError = null;
        _satoshiError = null;
      });

      return;
    }

    try {
      final satoshi = bitcoinTextToSatoshi(trimmed);
      _satoshi.text = '$satoshi';
      setState(() {
        _btcError = null;
        _satoshiError = null;
      });
    } on FormatException {
      setState(() {
        _btcError = _hasMoreThanEightDecimals(trimmed)
            ? l10n.toolsUnitsDecimalsError
            : l10n.toolsUnitsInvalidAmount;
      });
    }
  }

  /// Satoshi typed: the BTC field follows.
  void _onSatoshiChanged(String text) {
    final l10n = AppLocalizations.of(context);
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _btc.clear();
      setState(() {
        _btcError = null;
        _satoshiError = null;
      });

      return;
    }

    final satoshi = int.tryParse(trimmed);
    if (satoshi == null) {
      setState(() => _satoshiError = l10n.toolsUnitsInvalidWhole);

      return;
    }

    _btc.text = satoshiToBitcoinText(satoshi);
    setState(() {
      _btcError = null;
      _satoshiError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = toolLocale(context);
    final textTheme = Theme.of(context).textTheme;

    return DetailScaffold(
      title: l10n.toolsUnitsTitle,
      children: [
        Text(
          l10n.toolsUnitsNote,
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ToolResultCard(
          label: l10n.toolsUnitsBtcSatTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Field(
                label: l10n.toolsUnitsBtcLabel,
                controller: _btc,
                onChanged: _onBtcChanged,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                errorText: _btcError,
              ),
              const SizedBox(height: AppSpacing.md),
              _Field(
                label: l10n.toolsUnitsSatLabel,
                controller: _satoshi,
                onChanged: _onSatoshiChanged,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                errorText: _satoshiError,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ToolResultCard(
          label: l10n.toolsUnitsWeightTitle,
          child: _weightConverter(l10n),
        ),
        const SizedBox(height: AppSpacing.md),
        ToolResultCard(
          label: l10n.toolsUnitsRateFromFeeTitle,
          child: _rateFromFee(l10n, locale),
        ),
        const SizedBox(height: AppSpacing.md),
        ToolResultCard(
          label: l10n.toolsUnitsFeeFromRateTitle,
          child: _feeFromRate(l10n, locale),
        ),
        const SizedBox(height: AppSpacing.section),
        ToolWikiLinks(
          store: widget.store,
          entryIds: const ['wiki.weight-units', 'wiki.transaction-fees'],
        ),
      ],
    );
  }

  Widget _weightConverter(AppLocalizations l10n) {
    final weight = _nonNegativeInt(_weight.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          label: l10n.toolsUnitsWeightLabel,
          controller: _weight,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.number,
          errorText: _weight.text.trim().isNotEmpty && weight == null
              ? l10n.toolsUnitsInvalidWhole
              : null,
        ),
        if (weight != null) ...[
          const SizedBox(height: AppSpacing.md),
          _Result(
            label: l10n.toolsUnitsResult,
            value: l10n.toolsUnitsVbytesResult(vbytesFromWeight(weight)),
          ),
        ],
      ],
    );
  }

  Widget _rateFromFee(AppLocalizations l10n, String locale) {
    final fee = _nonNegativeInt(_feeSatoshi.text);
    final vsize = _nonNegativeInt(_feeVsize.text);
    final rateValue = fee != null && vsize != null && vsize > 0
        ? feeRate(feeSatoshi: fee, vbytes: vsize)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          label: l10n.toolsUnitsFeeLabel,
          controller: _feeSatoshi,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.number,
          errorText: _invalidWhole(_feeSatoshi.text, fee, l10n),
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          label: l10n.toolsUnitsVsizeLabel,
          controller: _feeVsize,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.number,
          errorText: _vsizeError(_feeVsize.text, vsize, l10n, dividesBy: true),
        ),
        if (rateValue != null) ...[
          const SizedBox(height: AppSpacing.md),
          _Result(
            label: l10n.toolsUnitsResult,
            value: l10n.toolsUnitsRateResult(
              NumberFormat('#,##0.##', locale).format(rateValue),
            ),
          ),
        ],
      ],
    );
  }

  Widget _feeFromRate(AppLocalizations l10n, String locale) {
    final rate = _nonNegativeRate(_rate.text);
    final vsize = _nonNegativeInt(_rateVsize.text);
    final feeValue = rate != null && vsize != null
        ? feeForRate(satPerVbyte: rate, vbytes: vsize)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          label: l10n.toolsUnitsRateLabel,
          controller: _rate,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          errorText: _rate.text.trim().isNotEmpty && rate == null
              ? l10n.toolsUnitsRateInvalid
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        _Field(
          label: l10n.toolsUnitsVsizeLabel,
          controller: _rateVsize,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.number,
          errorText: _vsizeError(_rateVsize.text, vsize, l10n),
        ),
        if (feeValue != null) ...[
          const SizedBox(height: AppSpacing.md),
          _Result(
            label: l10n.toolsUnitsResult,
            value: l10n.toolsUnitsFeeResult(feeValue),
          ),
        ],
      ],
    );
  }

  String? _invalidWhole(String text, int? parsed, AppLocalizations l10n) {
    return text.trim().isNotEmpty && parsed == null
        ? l10n.toolsUnitsInvalidWhole
        : null;
  }

  /// Virtual size must be a whole number of zero or more. The fee-rate
  /// converter divides by it, so there zero is an error as well.
  String? _vsizeError(
    String text,
    int? parsed,
    AppLocalizations l10n, {
    bool dividesBy = false,
  }) {
    if (text.trim().isEmpty) {
      return null;
    }
    if (parsed == null) {
      return l10n.toolsUnitsInvalidWhole;
    }
    if (dividesBy && parsed == 0) {
      return l10n.toolsUnitsVsizePositive;
    }

    return null;
  }
}

/// Labelled text field used by the converters.
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.keyboardType,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        ToolTextField(
          controller: controller,
          hintText: label,
          onChanged: onChanged,
          keyboardType: keyboardType,
          errorText: errorText,
        ),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelMedium),
        Text(value, style: textTheme.headlineSmall),
      ],
    );
  }
}

bool _hasMoreThanEightDecimals(String text) {
  return RegExp(r'[.,]\d{9,}').hasMatch(text);
}

int? _nonNegativeInt(String text) {
  final value = int.tryParse(text.trim());

  return value == null || value < 0 ? null : value;
}

double? _nonNegativeRate(String text) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));

  return value == null || !value.isFinite || value < 0 ? null : value;
}
