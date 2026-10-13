import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/section_title.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/esplora_models.dart';
import 'explorer_session.dart';
import 'explorer_widgets.dart';
import 'tool_widgets.dart';

/// Address screen: balances and the latest transactions of one address.
///
/// The address is sent to the server. Anyone who can see the server can link
/// it to the device's IP address, as the activation screen says.
class ExplorerAddressScreen extends StatelessWidget {
  const ExplorerAddressScreen({
    required this.session,
    required this.store,
    required this.address,
    super.key,
  });

  final ExplorerSession session;
  final ContentStore store;

  /// Address from the route, checked by the client before it is sent.
  final String address;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DetailScaffold(
      title: l10n.explorerAddressTitle,
      children: [
        ExplorerLoader<_AddressData>(
          session: session,
          load: (api) async {
            final stats = await api.address(address);
            final transactions = await api.addressTransactions(address);

            return _AddressData(stats, transactions);
          },
          builder: (context, data) =>
              _AddressView(address: address, data: data, store: store),
        ),
      ],
    );
  }
}

/// Both answers the address screen needs, loaded together.
final class _AddressData {
  const _AddressData(this.stats, this.transactions);

  final EsploraAddressStats stats;
  final List<EsploraTransaction> transactions;
}

class _AddressView extends StatelessWidget {
  const _AddressView({
    required this.address,
    required this.data,
    required this.store,
  });

  final String address;
  final _AddressData data;
  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = data.stats;
    final chain = stats.chain;
    final mempool = stats.mempool;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExplorerField(
          label: l10n.explorerAddressTitle,
          child: ToolCopyValue(value: address),
        ),
        const SizedBox(height: AppSpacing.lg),
        ToolKeyValue(
          label: l10n.explorerAddressBalance,
          value: explorerAmountText(
            l10n,
            chain.fundedTxoSum - chain.spentTxoSum,
          ),
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerTransactionCount,
          value: '${chain.txCount}',
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerAddressMempool,
          value: explorerAmountText(
            l10n,
            mempool.fundedTxoSum - mempool.spentTxoSum,
          ),
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerAddressReceived,
          value: explorerAmountText(l10n, chain.fundedTxoSum),
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerAddressSpent,
          value: explorerAmountText(l10n, chain.spentTxoSum),
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.section),
        SectionTitle(title: l10n.explorerAddressTransactions),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.explorerAddressFirstPage,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        if (data.transactions.isEmpty)
          Text(
            l10n.explorerNoTransactions,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          for (final tx in data.transactions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExplorerLink(
                    value: tx.txid,
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.explorerTransaction(tx.txid)),
                  ),
                  Text(
                    tx.status.confirmed
                        ? l10n.explorerConfirmed
                        : l10n.explorerUnconfirmed,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        const SizedBox(height: AppSpacing.section),
        ToolWikiLinks(
          store: store,
          entryIds: const ['wiki.bitcoin-addresses', 'wiki.address-encodings'],
        ),
      ],
    );
  }
}
