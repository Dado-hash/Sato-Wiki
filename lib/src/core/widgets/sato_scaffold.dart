import 'package:flutter/material.dart';

import '../navigation/sato_wiki_tab.dart';
import '../theme/app_tokens.dart';
import 'sato_tab_bar.dart';

class SatoScaffold extends StatelessWidget {
  const SatoScaffold({
    required this.selectedTab,
    required this.onTabSelected,
    required this.body,
    super.key,
  });

  final SatoWikiTab selectedTab;
  final ValueChanged<SatoWikiTab> onTabSelected;
  final Widget body;

  /// Bottom padding for a scrollable tab body: the height the floating tab
  /// bar covers, plus a gap so the last item never touches the bar.
  static double bottomClearanceOf(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + AppSpacing.tabBarGap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: body,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.tabBarLift,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.tabBarLift),
          child: SatoTabBar(
            selectedTab: selectedTab,
            onTabSelected: onTabSelected,
          ),
        ),
      ),
    );
  }
}
