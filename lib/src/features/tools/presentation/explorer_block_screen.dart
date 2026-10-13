import 'package:flutter/material.dart';

import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../data/esplora_models.dart';
import 'explorer_session.dart';
import 'explorer_widgets.dart';
import 'tool_widgets.dart';

/// Block screen: the fields the server gives for one block by hash.
class ExplorerBlockScreen extends StatelessWidget {
  const ExplorerBlockScreen({
    required this.session,
    required this.store,
    required this.hash,
    super.key,
  });

  final ExplorerSession session;
  final ContentStore store;

  /// Block hash from the route, checked by the client before it is sent.
  final String hash;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DetailScaffold(
      title: l10n.explorerBlockTitle,
      children: [
        ExplorerLoader<EsploraBlock>(
          session: session,
          load: (api) => api.block(hash),
          builder: (context, block) => _BlockView(block: block, store: store),
        ),
      ],
    );
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block, required this.store});

  final EsploraBlock block;
  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final previous = block.previousBlockHash;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolKeyValue(
          label: l10n.explorerHeight,
          value: '${block.height}',
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerTime,
          value: explorerUtcTime(block.timestamp),
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerTransactionCount,
          value: '${block.txCount}',
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerSize,
          value: '${block.size} B',
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerWeight,
          value: '${block.weight} WU',
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        ExplorerField(
          label: l10n.explorerHash,
          child: ToolCopyValue(value: block.id),
        ),
        const SizedBox(height: AppSpacing.lg),
        ExplorerField(
          label: l10n.explorerMerkleRoot,
          child: ToolCopyValue(value: block.merkleRoot),
        ),
        if (previous != null) ...[
          const SizedBox(height: AppSpacing.lg),
          ExplorerField(
            label: l10n.explorerPreviousBlock,
            child: ExplorerLink(
              value: previous,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.explorerBlock(previous)),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        ToolKeyValue(
          label: l10n.explorerNonce,
          value: '${block.nonce}',
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerBits,
          value: '0x${block.bits.toRadixString(16).padLeft(8, '0')}',
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerDifficulty,
          value: block.difficulty.round().toString(),
          monospace: true,
        ),
        ToolKeyValue(
          label: l10n.explorerVersion,
          value: '${block.version}',
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.section),
        ToolWikiLinks(
          store: store,
          entryIds: const [
            'wiki.block-header',
            'wiki.proof-of-work',
            'wiki.difficulty-adjustment',
          ],
        ),
      ],
    );
  }
}
