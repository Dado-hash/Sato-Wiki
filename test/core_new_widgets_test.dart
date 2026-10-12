import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/settings/app_settings_scope.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/core/widgets/bookmark_button.dart';
import 'package:sato_wiki/src/core/widgets/content_thumbnail.dart';
import 'package:sato_wiki/src/core/widgets/detail_scaffold.dart';
import 'package:sato_wiki/src/core/widgets/round_icon_button.dart';
import 'package:sato_wiki/src/core/widgets/sato_segmented_control.dart';
import 'package:sato_wiki/src/core/widgets/status_pill.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

Widget _app(Widget home) {
  return MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  testWidgets('SatoSegmentedControl calls onChanged with the tapped item', (
    tester,
  ) async {
    final changes = <String>[];

    await tester.pumpWidget(
      _app(
        Scaffold(
          body: SatoSegmentedControl<String>(
            items: const ['one', 'two'],
            selected: 'one',
            labelFor: (item) => item == 'one' ? 'First' : 'Second',
            onChanged: changes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();

    expect(changes, ['two']);
  });

  testWidgets('RoundIconButton is 44x44 and exposes its tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: RoundIconButton(
            icon: Icons.share,
            tooltip: 'Share',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(RoundIconButton)), const Size(44, 44));
    expect(find.byTooltip('Share'), findsOneWidget);
  });

  testWidgets('BookmarkButton renders nothing without a settings scope', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const Scaffold(body: BookmarkButton(contentId: 'wiki.pow'))),
    );

    expect(find.byType(RoundIconButton), findsNothing);
    expect(find.byType(BookmarkButton), findsOneWidget);
  });

  testWidgets('BookmarkButton toggles the bookmark through the scope', (
    tester,
  ) async {
    final controller = await AppSettingsController.load(
      InMemoryAppSettingsRepository(),
    );

    await tester.pumpWidget(
      _app(
        AppSettingsScope(
          controller: controller,
          child: const Scaffold(body: BookmarkButton(contentId: 'wiki.pow')),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Save to bookmarks'));
    await tester.pumpAndSettle();

    expect(controller.isBookmarked('wiki.pow'), isTrue);
    expect(find.byTooltip('Remove from bookmarks'), findsOneWidget);
  });

  testWidgets('StatusPill shows its label', (tester) async {
    await tester.pumpWidget(
      _app(
        const Scaffold(
          body: StatusPill(label: 'Deployed', color: Colors.green),
        ),
      ),
    );

    expect(find.text('Deployed'), findsOneWidget);
  });

  testWidgets('DetailScaffold shows a back button with the back tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const DetailScaffold(title: 'Proof of Work', children: [Text('Body')]),
      ),
    );

    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.text('Proof of Work'), findsOneWidget);
  });

  testWidgets('ContentThumbnail shows the fallback icon without a source', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Scaffold(
          body: ContentThumbnail(
            source: null,
            width: 100,
            height: 100,
            fallbackIcon: Icons.bolt,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.bolt), findsOneWidget);
  });
}
