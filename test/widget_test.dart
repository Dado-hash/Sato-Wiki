import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/app.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/navigation/sato_wiki_tab.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';

void main() {
  testWidgets('SatoWiki shell renders primary tabs', (tester) async {
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);

    await tester.pumpWidget(
      SatoWikiApp(settingsController: settingsController),
    );

    expect(find.text('SatoWiki'), findsOneWidget);
    expect(find.text('The Orange Book'), findsOneWidget);
    expect(find.text('Wiki'), findsOneWidget);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);

    await tester.tap(find.text('Code'));
    await tester.pumpAndSettle();

    expect(find.text('Code Dashboard'), findsWidgets);
    expect(await repository.loadLastTab(), SatoWikiTab.code);
  });

  testWidgets('SatoWiki restores persisted reading level', (tester) async {
    final repository = InMemoryAppSettingsRepository(
      lastTab: SatoWikiTab.wiki,
      readingLevel: ReadingLevel.advanced,
    );
    final settingsController = await AppSettingsController.load(repository);

    await tester.pumpWidget(
      SatoWikiApp(settingsController: settingsController),
    );

    const advancedDescription =
        'Difficulty adjustment, SHA-256 hashing and accumulated work form the security model behind Bitcoin consensus.';

    await tester.scrollUntilVisible(
      find.text(advancedDescription),
      260,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(advancedDescription), findsOneWidget);
  });

  testWidgets('SatoWiki exposes deep link targets', (tester) async {
    final repository = InMemoryAppSettingsRepository();
    final settingsController = await AppSettingsController.load(repository);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        initialRoute: AppRoutes.codeBip(341),
        onGenerateRoute: (settings) {
          return AppRouter.generateRoute(settings, settingsController);
        },
      ),
    );

    expect(find.text('BIP detail'), findsOneWidget);
    expect(find.text('BIP 341'), findsOneWidget);
    expect(find.text('/code/bips/341'), findsOneWidget);
  });
}
