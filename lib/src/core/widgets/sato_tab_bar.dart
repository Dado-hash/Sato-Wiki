import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../navigation/sato_wiki_tab.dart';
import '../theme/app_tokens.dart';
import '../theme/sato_colors.dart';

/// Floating pill tab bar with one icon and label per [SatoWikiTab].
class SatoTabBar extends StatelessWidget {
  const SatoTabBar({
    required this.selectedTab,
    required this.onTabSelected,
    super.key,
  });

  final SatoWikiTab selectedTab;
  final ValueChanged<SatoWikiTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.sato.borderStrong),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.6 : 0.18,
            ),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final tab in SatoWikiTab.values) ...[
            if (tab.index > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _SatoTabItem(
                tab: tab,
                label: _labelFor(l10n, tab),
                isActive: tab == selectedTab,
                onTap: () => onTabSelected(tab),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _labelFor(AppLocalizations l10n, SatoWikiTab tab) {
    return switch (tab) {
      SatoWikiTab.today => l10n.todayTab,
      SatoWikiTab.wiki => l10n.wikiTab,
      SatoWikiTab.news => l10n.newsTab,
      SatoWikiTab.history => l10n.historyTab,
      SatoWikiTab.code => l10n.codeTab,
    };
  }
}

class _SatoTabItem extends StatelessWidget {
  const _SatoTabItem({
    required this.tab,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final SatoWikiTab tab;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sato = context.sato;
    final foreground = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    final labelStyle = (theme.textTheme.labelLarge ?? const TextStyle())
        .copyWith(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: foreground,
        );
    final borderRadius = BorderRadius.circular(AppRadii.card);

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(
          color: isActive ? sato.accentTint : Colors.transparent,
          borderRadius: borderRadius,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconFor(tab, isActive), size: 22, color: foreground),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(SatoWikiTab tab, bool active) {
    return switch (tab) {
      SatoWikiTab.today =>
        active ? Icons.wb_sunny_rounded : Icons.wb_sunny_outlined,
      SatoWikiTab.wiki =>
        active ? Icons.menu_book_rounded : Icons.menu_book_outlined,
      SatoWikiTab.news =>
        active ? Icons.newspaper_rounded : Icons.newspaper_outlined,
      SatoWikiTab.history => Icons.history_rounded,
      SatoWikiTab.code => Icons.code_rounded,
    };
  }
}
