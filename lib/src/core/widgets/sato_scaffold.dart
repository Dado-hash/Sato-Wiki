import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../localization/app_locale.dart';
import '../navigation/sato_wiki_tab.dart';
import '../navigation/app_routes.dart';

class SatoScaffold extends StatelessWidget {
  const SatoScaffold({
    required this.selectedTab,
    required this.onTabSelected,
    required this.body,
    required this.localePreference,
    required this.onLocalePreferenceChanged,
    this.title = 'SatoWiki',
    super.key,
  });

  final SatoWikiTab selectedTab;
  final ValueChanged<SatoWikiTab> onTabSelected;
  final Widget body;
  final AppLocalePreference localePreference;
  final ValueChanged<AppLocalePreference> onLocalePreferenceChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.language),
          tooltip: l10n.languageSelectorTooltip,
          onPressed: () {
            _showLanguageSheet(context);
          },
        ),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.searchTooltip,
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.search);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: body,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: NavigationBar(
          selectedIndex: selectedTab.index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            onTabSelected(SatoWikiTab.fromIndex(index));
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book),
              label: l10n.wikiTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.newspaper_outlined),
              selectedIcon: const Icon(Icons.newspaper),
              label: l10n.newsTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_edu_outlined),
              selectedIcon: const Icon(Icons.history_edu),
              label: l10n.historyTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.terminal_outlined),
              selectedIcon: const Icon(Icons.terminal),
              label: l10n.codeTab,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Text(
                    l10n.languageTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RadioListTile<AppLocalePreference>(
                  title: Text(l10n.languageSystemDefault),
                  value: const AppLocalePreference.system(),
                  groupValue: localePreference,
                  onChanged: (preference) {
                    if (preference != null) {
                      onLocalePreferenceChanged(preference);
                    }
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<AppLocalePreference>(
                  title: Text(l10n.languageEnglish),
                  value: const AppLocalePreference.language('en'),
                  groupValue: localePreference,
                  onChanged: (preference) {
                    if (preference != null) {
                      onLocalePreferenceChanged(preference);
                    }
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<AppLocalePreference>(
                  title: Text(l10n.languageItalian),
                  value: const AppLocalePreference.language('it'),
                  groupValue: localePreference,
                  onChanged: (preference) {
                    if (preference != null) {
                      onLocalePreferenceChanged(preference);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
