import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/content/domain/content_store.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/features/code/presentation/code_dashboard_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('BIP tracker counts complete BIPs alongside the other statuses', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      json: _codeFixtureJson(),
      home: (store) => CodeDashboardScreen(store: store),
    );

    // Fixture: 3 complete, 1 deployed, 2 draft, 4 closed (10 BIPs in total).
    expect(find.text('COMPLETE'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('Complete filter chip shows only complete BIPs', (tester) async {
    await _pumpScreen(
      tester,
      json: _codeFixtureJson(),
      home: (store) => BipListScreen(store: store),
    );

    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.text('BIP 410'), findsOneWidget);
    expect(find.text('BIP 404'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Complete'));
    await tester.pumpAndSettle();

    expect(find.text('BIP 401'), findsOneWidget);
    expect(find.text('BIP 402'), findsOneWidget);
    expect(find.text('BIP 403'), findsOneWidget);
    expect(find.text('BIP 404'), findsNothing);
    expect(find.text('BIP 410'), findsNothing);
  });

  testWidgets('Tapping a changelog item opens the release note screen', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      json: _codeFixtureJson(),
      home: (store) => CodeDashboardScreen(store: store),
    );

    await tester.scrollUntilVisible(find.text('Patch Release Fixture'), 300);
    await tester.tap(find.text('Patch Release Fixture'));
    await tester.pumpAndSettle();

    expect(find.byType(ReleaseNoteScreen), findsOneWidget);
    expect(find.text('User Impact'), findsOneWidget);
  });

  testWidgets('Patch release shows the patch badge, not minor', (tester) async {
    await _pumpScreen(
      tester,
      json: _codeFixtureJson(),
      home: (store) => ReleaseNoteScreen(
        store: store,
        project: 'bitcoin-core',
        version: '29.0.1',
      ),
    );

    expect(find.text('PATCH'), findsOneWidget);
    expect(find.text('MINOR'), findsNothing);
    expect(find.text('Jun 1, 2026'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets('Patch badge and tracker labels are localized in Italian', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      locale: const Locale('it'),
      json: _codeFixtureJson(),
      home: (store) => CodeDashboardScreen(store: store),
    );

    expect(find.text('COMPLETO'), findsOneWidget);
    expect(find.text('COMPLETE'), findsNothing);

    await _pumpScreen(
      tester,
      locale: const Locale('it'),
      json: _codeFixtureJson(),
      home: (store) => ReleaseNoteScreen(
        store: store,
        project: 'bitcoin-core',
        version: '29.0.1',
      ),
    );

    expect(find.text('PATCH'), findsOneWidget);
    expect(find.byTooltip('Indietro'), findsOneWidget);
  });

  testWidgets('BIP detail shows the title as headline and summary below it', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      json: _codeFixtureJson(),
      home: (store) => BipDetailScreen(store: store, number: 401),
    );

    expect(find.text('Complete One'), findsOneWidget);
    expect(find.text('Complete One summary.'), findsOneWidget);
    expect(find.text('Complete One: Complete One summary.'), findsNothing);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required String json,
  required Widget Function(ContentStore store) home,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final settingsController = await AppSettingsController.load(
    InMemoryAppSettingsRepository(),
  );
  final contentController = await AppContentController.load(
    repository: _TestContentBundleRepository(json),
    languageCode: 'en',
  );
  final store = contentController.content.store;

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocale.supportedLocales,
      home: home(store),
      onGenerateRoute: (settings) {
        return AppRouter.generateRoute(
          settings,
          settingsController,
          contentController,
        );
      },
    ),
  );
  await tester.pumpAndSettle();
}

final class _TestContentBundleRepository implements ContentBundleRepository {
  const _TestContentBundleRepository(this.json);

  final String json;

  @override
  Future<ContentBundleParseResult> load(String languageCode) async {
    return ContentBundleParser.parseJson(json);
  }

  @override
  Future<void> saveUpdatedBundleJson(String languageCode, String json) async {}
}

String _codeFixtureJson() {
  return jsonEncode({
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [],
    'news': [],
    'history': [],
    'bips': [
      _bip(401, 'complete', 'Complete One'),
      _bip(402, 'complete', 'Complete Two'),
      _bip(403, 'complete', 'Complete Three'),
      _bip(404, 'active', 'Deployed One'),
      _bip(405, 'draft', 'Draft One'),
      _bip(406, 'draft', 'Draft Two'),
      _bip(407, 'rejected', 'Closed One'),
      _bip(408, 'withdrawn', 'Closed Two'),
      _bip(409, 'rejected', 'Closed Three'),
      _bip(410, 'closed', 'Closed Four'),
    ],
    'changelogs': [
      _release(
        version: '29.0.1',
        title: 'Patch Release Fixture',
        importance: 'patch',
        releasedAt: '2026-06-01',
      ),
      _release(
        version: '29.0',
        title: 'Major Release Fixture',
        importance: 'major',
        releasedAt: '2026-04-20',
      ),
    ],
  });
}

Map<String, Object> _bip(int number, String status, String title) {
  return {
    'id': 'code.bip.$number',
    'number': number,
    'language': 'en',
    'title': title,
    'summary': '$title summary.',
    'status': status,
    'category': 'consensus',
    'authors': ['Author'],
    'createdAt': '2020-01-01',
    'summaryMarkdown': 'Summary.',
    'impactMarkdown': 'Impact.',
    'officialUrl': 'https://github.com/bitcoin/bips',
    'tags': ['Consensus'],
    'sources': [],
    'related': [],
    'statusHistory': [],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object> _release({
  required String version,
  required String title,
  required String importance,
  required String releasedAt,
}) {
  return {
    'id': 'code.changelog.bitcoin-core.$version',
    'slug': 'bitcoin-core-$version',
    'language': 'en',
    'project': 'bitcoin-core',
    'version': version,
    'title': title,
    'summary': '$title summary.',
    'releasedAt': releasedAt,
    'importance': importance,
    'userImpactMarkdown': 'Impact.',
    'technicalChangesMarkdown': 'Changes.',
    'officialUrl': 'https://github.com/bitcoin/bitcoin/releases',
    'tags': [],
    'sources': [],
    'related': [],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}
