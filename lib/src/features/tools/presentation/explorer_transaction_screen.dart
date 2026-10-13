import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/esplora_models.dart';
import '../domain/units.dart';
import 'explorer_session.dart';
import 'explorer_widgets.dart';
import 'tool_widgets.dart';

/// Transaction screen: status, fee, inputs and outputs of one txid. Addresses
/// and previous transactions open their own explorer screens.
class ExplorerTransactionScreen extends StatelessWidget {
  const ExplorerTransactionScreen({
    required this.session,
    required this.store,
    required this.txid,
    super.key,
  });

  final ExplorerSession session;
  final ContentStore store;

  /// Txid from the route, checked by the client before it is sent.
  final String txid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DetailScaffold(
      title: l10n.explorerTransactionTitle,
      children: [
        ExplorerLoader<EsploraTransaction>(
          session: session,
          load: (api) => api.transaction(txid),
          builder: (context, tx) => _TransactionView(tx: tx, store: store),
        ),
      ],
    );
  }
}

class _TransactionView extends StatelessWidget {
  const _TransactionView({required this.tx, required this.store});

  final EsploraTransaction tx;
  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sato = context.sato;
    final status = tx.status;
    final fee = tx.fee;
    final vbytes = vbytesFromWeight(tx.weight);
    final hasCoinbase = tx.inputs.any((input) => input.isCoinbase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExplorerField(
          label: l10n.explorerTxid,
          child: ToolCopyValue(value: tx.txid),
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: StatusPill(
            label: status.confirmed
                ? l10n.explorerConfirmed
                : l10n.explorerUnconfirmed,
            color: status.confirmed ? sato.statusDeployed : sato.statusDraft,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _blockRow(context, l10n, status),
        if (status.confirmed && status.blockTime != null)
          ToolKeyValue(
            label: l10n.explorerTime,
            value: explorerUtcTime(status.blockTime!),
            monospace: true,
          ),
        if (fee != null) ...[
          ToolKeyValue(
            label: l10n.explorerFee,
            value: explorerAmountText(l10n, fee),
            monospace: true,
          ),
          if (vbytes > 0)
            ToolKeyValue(
              label: l10n.explorerFeeRate,
              value: l10n.explorerFeeRateValue(
                feeRate(feeSatoshi: fee, vbytes: vbytes).toStringAsFixed(1),
              ),
              monospace: true,
            ),
        ],
        ToolKeyValue(
          label: l10n.explorerSize,
          value: '${tx.size} B',
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerWeight,
          value: '${tx.weight} WU',
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerVersion,
          value: '${tx.version}',
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.section),
        SectionTitle(title: l10n.explorerInputs),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < tx.inputs.length; i++)
          _InputRow(index: i, input: tx.inputs[i]),
        const SizedBox(height: AppSpacing.section),
        SectionTitle(title: l10n.explorerOutputs),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < tx.outputs.length; i++)
          _OutputRow(index: i, output: tx.outputs[i]),
        const SizedBox(height: AppSpacing.section),
        ToolWikiLinks(
          store: store,
          entryIds: [
            'wiki.transactions',
            'wiki.transaction-fees',
            'wiki.weight-units',
            'wiki.bitcoin-script',
            if (hasCoinbase) 'wiki.coinbase-transaction',
          ],
        ),
      ],
    );
  }

  Widget _blockRow(
    BuildContext context,
    AppLocalizations l10n,
    EsploraTxStatus status,
  ) {
    final height = status.blockHeight;
    final hash = status.blockHash;
    if (!status.confirmed || height == null) {
      return ToolKeyValue(
        label: l10n.explorerBlockOfTransaction,
        value: l10n.explorerBlockUnknown,
      );
    }

    return ToolKeyValue(
      label: l10n.explorerBlockOfTransaction,
      value: '$height',
      monospace: true,
      onTap: hash == null
          ? null
          : () =>
                Navigator.of(context).pushNamed(AppRoutes.explorerBlock(hash)),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({required this.index, required this.input});

  final int index;
  final EsploraInput input;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prevout = input.prevout;
    final address = prevout?.address;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: ExplorerField(
        label: l10n.explorerInputNumber(index),
        child: input.isCoinbase
            ? Text(
                l10n.explorerCoinbase,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prevout != null)
                    Text(
                      explorerAmountText(l10n, prevout.valueSatoshi),
                      style: toolMonoStyle(context),
                    ),
                  if (address != null)
                    ExplorerLink(
                      value: address,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.explorerAddress(address)),
                    ),
                  ExplorerLink(
                    value: '${input.previousTxid}:${input.previousIndex}',
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.explorerTransaction(input.previousTxid),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OutputRow extends StatelessWidget {
  const _OutputRow({required this.index, required this.output});

  final int index;
  final EsploraOutput output;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final address = output.address;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: ExplorerField(
        label: l10n.explorerOutputNumber(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              explorerAmountText(l10n, output.valueSatoshi),
              style: toolMonoStyle(context),
            ),
            if (address != null)
              ExplorerLink(
                value: address,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.explorerAddress(address)),
              ),
            ToolKeyValue(
              label: l10n.explorerScriptType,
              value: output.scriptPubKeyType,
              monospace: true,
            ),
          ],
        ),
      ),
    );
  }
}
