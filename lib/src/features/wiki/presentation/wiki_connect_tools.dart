import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/section_title.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'wiki_tree_widgets.dart';

/// The kinds of tool a wiki entry can point to in its "Try it" section.
enum WikiConnectKind {
  hash,
  address,
  transaction,
  target,
  units,
  lab,
  labStep,
  script,
}

/// One "Try it" row: a tool, or one step of the blockchain lab.
final class WikiConnectTarget {
  const WikiConnectTarget(this.kind, [this.step]);

  static const hash = WikiConnectTarget(WikiConnectKind.hash);
  static const address = WikiConnectTarget(WikiConnectKind.address);
  static const transaction = WikiConnectTarget(WikiConnectKind.transaction);
  static const target = WikiConnectTarget(WikiConnectKind.target);
  static const units = WikiConnectTarget(WikiConnectKind.units);
  static const lab = WikiConnectTarget(WikiConnectKind.lab);
  static const script = WikiConnectTarget(WikiConnectKind.script);
  static const labStep1 = WikiConnectTarget(WikiConnectKind.labStep, 1);
  static const labStep2 = WikiConnectTarget(WikiConnectKind.labStep, 2);
  static const labStep3 = WikiConnectTarget(WikiConnectKind.labStep, 3);
  static const labStep6 = WikiConnectTarget(WikiConnectKind.labStep, 6);
  static const labStep7 = WikiConnectTarget(WikiConnectKind.labStep, 7);

  final WikiConnectKind kind;

  /// Lab step number, only for [WikiConnectKind.labStep].
  final int? step;

  String get route => switch (kind) {
    WikiConnectKind.hash => AppRoutes.toolHash,
    WikiConnectKind.address => AppRoutes.toolAddress,
    WikiConnectKind.transaction => AppRoutes.toolTransaction,
    WikiConnectKind.target => AppRoutes.toolTarget,
    WikiConnectKind.units => AppRoutes.toolUnits,
    WikiConnectKind.lab => AppRoutes.lab,
    WikiConnectKind.labStep => AppRoutes.labStep(step ?? 1),
    WikiConnectKind.script => AppRoutes.scriptStepper,
  };

  IconData get icon => switch (kind) {
    WikiConnectKind.hash => Icons.numbers_rounded,
    WikiConnectKind.address => Icons.qr_code_2_rounded,
    WikiConnectKind.transaction => Icons.receipt_long_outlined,
    WikiConnectKind.target => Icons.speed_outlined,
    WikiConnectKind.units => Icons.swap_horiz_rounded,
    WikiConnectKind.lab || WikiConnectKind.labStep => Icons.science_outlined,
    WikiConnectKind.script => Icons.code_rounded,
  };

  String title(AppLocalizations l10n) => switch (kind) {
    WikiConnectKind.hash => l10n.connectHashTitle,
    WikiConnectKind.address => l10n.connectAddressTitle,
    WikiConnectKind.transaction => l10n.connectTransactionTitle,
    WikiConnectKind.target => l10n.connectTargetTitle,
    WikiConnectKind.units => l10n.connectUnitsTitle,
    WikiConnectKind.lab => l10n.connectLabTitle,
    WikiConnectKind.labStep => l10n.connectLabStepTitle(step ?? 1),
    WikiConnectKind.script => l10n.connectScriptTitle,
  };

  String caption(AppLocalizations l10n) => switch (kind) {
    WikiConnectKind.hash => l10n.connectHashCaption,
    WikiConnectKind.address => l10n.connectAddressCaption,
    WikiConnectKind.transaction => l10n.connectTransactionCaption,
    WikiConnectKind.target => l10n.connectTargetCaption,
    WikiConnectKind.units => l10n.connectUnitsCaption,
    WikiConnectKind.lab => l10n.connectLabCaption,
    WikiConnectKind.script => l10n.connectScriptCaption,
    WikiConnectKind.labStep => switch (step) {
      1 => l10n.connectLabStep1Caption,
      2 => l10n.connectLabStep2Caption,
      3 => l10n.connectLabStep3Caption,
      6 => l10n.connectLabStep6Caption,
      7 => l10n.connectLabStep7Caption,
      _ => l10n.connectLabCaption,
    },
  };
}

/// Wiki entry id to the tools that show it in "Try it". Entries not listed
/// show no section.
const wikiConnectTargets = <String, List<WikiConnectTarget>>{
  'wiki.hash-functions': [WikiConnectTarget.hash, WikiConnectTarget.labStep1],
  'wiki.sha-256': [WikiConnectTarget.hash],
  'wiki.blockchain': [WikiConnectTarget.lab],
  'wiki.blocks': [WikiConnectTarget.labStep3],
  'wiki.block-header': [WikiConnectTarget.labStep7],
  'wiki.proof-of-work': [WikiConnectTarget.labStep2, WikiConnectTarget.target],
  'wiki.mining': [WikiConnectTarget.labStep2],
  'wiki.difficulty-adjustment': [WikiConnectTarget.target],
  'wiki.bitcoin-script': [WikiConnectTarget.script],
  'wiki.p2sh': [WikiConnectTarget.script],
  'wiki.transactions': [WikiConnectTarget.transaction],
  'wiki.coinbase-transaction': [WikiConnectTarget.labStep6],
  'wiki.bitcoin-addresses': [WikiConnectTarget.address],
  'wiki.address-encodings': [WikiConnectTarget.address],
  'wiki.transaction-fees': [WikiConnectTarget.units],
  'wiki.weight-units': [WikiConnectTarget.units],
};

/// "Try it" section of the wiki reader: one row per tool, each opening its
/// route with `pushNamed`.
class WikiTryItSection extends StatelessWidget {
  const WikiTryItSection({required this.targets, super.key});

  final List<WikiConnectTarget> targets;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: l10n.connectTryIt),
        const SizedBox(height: AppSpacing.md),
        ...spaced([
          for (final target in targets) _TryItRow(target: target),
        ], AppSpacing.md),
      ],
    );
  }
}

class _TryItRow extends StatelessWidget {
  const _TryItRow({required this.target});

  final WikiConnectTarget target;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return WikiCardSurface(
      onTap: () => Navigator.of(context).pushNamed(target.route),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            WikiIconTile(icon: target.icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(target.title(l10n), style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    target.caption(l10n),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
