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
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

/// Fixture bundle for the tools tests: the wiki entries the tools link to,
/// and two reference tables (one with a status column and a link).
String toolsFixtureJson() {
  return jsonEncode({
    'schemaVersion': 1,
    'version': 'test',
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [
      for (final entry in const [
        ('bitcoin-addresses', 'Bitcoin addresses'),
        ('address-encodings', 'Address encodings'),
        ('segregated-witness', 'Segregated witness'),
        ('p2sh', 'Pay to script hash'),
        ('taproot', 'Taproot'),
        ('hash-functions', 'Hash functions'),
        ('sha-256', 'About SHA-256'),
        ('transactions', 'Transactions'),
        ('bitcoin-script', 'Bitcoin Script'),
        ('timelocks', 'Timelocks'),
        ('coinbase-transaction', 'Coinbase transaction'),
        ('weight-units', 'Weight units'),
        ('transaction-fees', 'Transaction fees'),
        ('block-header', 'Block header'),
        ('difficulty-adjustment', 'Difficulty adjustment'),
        ('proof-of-work', 'Proof of work'),
      ])
        _wikiEntry(slug: entry.$1, title: entry.$2),
    ],
    'news': <Object?>[],
    'history': <Object?>[],
    'bips': <Object?>[],
    'changelogs': <Object?>[],
    'references': [
      _referenceTable(
        slug: 'script-opcodes',
        title: 'Script opcodes',
        columns: const [
          {'key': 'name', 'label': 'Name'},
          {'key': 'hex', 'label': 'Hex'},
          {'key': 'status', 'label': 'Status'},
          {'key': 'description', 'label': 'Description'},
        ],
        rows: const [
          {
            'cells': {
              'name': 'OP_0',
              'hex': '0x00',
              'status': 'enabled',
              'description': 'Pushes an empty array.',
            },
          },
          {
            'cells': {
              'name': 'OP_CAT',
              'hex': '0x7e',
              'status': 'disabled',
              'description': 'Concatenates two strings.',
            },
          },
          {
            'cells': {
              'name': 'OP_NOP',
              'hex': '0x61',
              'status': 'nop',
              'description': 'Does nothing.',
            },
            'link': 'wiki.bitcoin-script',
          },
        ],
      ),
      _referenceTable(
        slug: 'units',
        title: 'Units',
        columns: const [
          {'key': 'unit', 'label': 'Unit'},
          {'key': 'value', 'label': 'Value'},
        ],
        rows: const [
          {
            'cells': {'unit': 'satoshi', 'value': '0.00000001 BTC'},
          },
          {
            'cells': {'unit': 'bitcoin', 'value': '100000000 sat'},
          },
        ],
      ),
    ],
  });
}

Map<String, Object?> _wikiEntry({required String slug, required String title}) {
  const body = {'bodyMarkdown': 'Body text.'};

  return {
    'id': 'wiki.$slug',
    'slug': slug,
    'language': 'en',
    'category': 'protocol',
    'title': title,
    'description': '$title summary.',
    'readingLevels': {'base': body, 'medium': body, 'advanced': body},
    'difficulty': 'base',
    'readTimeMinutes': 3,
    'tags': <String>[],
    'sources': <Object?>[],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

Map<String, Object?> _referenceTable({
  required String slug,
  required String title,
  required List<Map<String, Object?>> columns,
  required List<Map<String, Object?>> rows,
}) {
  return {
    'id': 'reference.$slug',
    'slug': slug,
    'language': 'en',
    'title': title,
    'description': '$title table.',
    'columns': columns,
    'rows': rows,
    'sources': [
      {
        'title': 'Bitcoin Core source',
        'url': 'https://example.com/source',
        'author': 'Contributors',
      },
    ],
    'related': <Object?>[],
    'updatedAt': '2026-05-25T00:00:00Z',
  };
}

/// Pumps [home] with the app's theme, localizations and router, so that
/// pushed named routes resolve as they do in the app.
Future<ContentStore> pumpToolsScreen(
  WidgetTester tester, {
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
    repository: _FixtureRepository(toolsFixtureJson()),
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

  return store;
}

final class _FixtureRepository implements ContentBundleRepository {
  const _FixtureRepository(this.json);

  final String json;

  @override
  Future<ContentBundleParseResult> load(String languageCode) async {
    return ContentBundleParser.parseJson(json);
  }

  @override
  Future<void> saveUpdatedBundleJson(String languageCode, String json) async {}
}
