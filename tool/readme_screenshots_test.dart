// Renders the README screenshots in docs/screenshots/.
//
// This is not part of the test suite: it lives in tool/ so `flutter test`
// does not pick it up. Run it by hand after a visible UI change:
//
//   flutter test tool/readme_screenshots_test.dart
//
// Each shot pumps the real app with the real seed bundle, bundled fonts and
// seed media, then draws the result inside a plain phone frame.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/app.dart';
import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/content/data/content_media_store.dart';
import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/navigation/sato_wiki_tab.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/settings/theme_preference.dart';

const _outputDirectory = 'docs/screenshots';
const _screenSize = Size(393, 852);
const _pixelRatio = 2.0;
const _bezel = 12.0;
const _screenRadius = 44.0;

final class _Shot {
  const _Shot(
    this.name, {
    this.tab = SatoWikiTab.today,
    this.route,
    this.language = 'en',
    this.theme = ThemePreference.dark,
  });

  final String name;
  final SatoWikiTab tab;
  final String? route;
  final String language;
  final ThemePreference theme;
}

final _shots = <_Shot>[
  const _Shot('today'),
  const _Shot('wiki', tab: SatoWikiTab.wiki),
  _Shot(
    'wiki-entry',
    tab: SatoWikiTab.wiki,
    route: AppRoutes.wikiEntry('proof-of-work'),
  ),
  const _Shot('history', tab: SatoWikiTab.history),
  const _Shot('code', tab: SatoWikiTab.code),
  _Shot('bip', tab: SatoWikiTab.code, route: AppRoutes.codeBip(341)),
  _Shot(
    'wiki-entry-light',
    tab: SatoWikiTab.wiki,
    route: AppRoutes.wikiEntry('proof-of-work'),
    theme: ThemePreference.light,
  ),
  const _Shot('today-it', language: 'it'),
  const _Shot('settings', route: AppRoutes.settings),
];

void main() {
  setUpAll(_loadFonts);

  for (final shot in _shots) {
    testWidgets('screenshot ${shot.name}', (tester) async {
      tester.view.physicalSize = _screenSize * _pixelRatio;
      tester.view.devicePixelRatio = _pixelRatio;
      // Safe areas of a recent iPhone, so headers and the tab bar sit where
      // they do on a device.
      tester.view.padding = const FakeViewPadding(
        top: 54 * _pixelRatio,
        bottom: 34 * _pixelRatio,
      );
      addTearDown(tester.view.reset);

      final mediaDirectory = Directory.systemTemp.createTempSync('satowiki');
      addTearDown(() => mediaDirectory.deleteSync(recursive: true));

      final settings = await AppSettingsController.load(
        InMemoryAppSettingsRepository(
          lastTab: shot.tab,
          readingLevel: ReadingLevel.medium,
          localePreference: AppLocalePreference.language(shot.language),
          themePreference: shot.theme,
          bookmarks: const ['wiki.taproot', 'code.bip.341'],
          readingProgress: const {
            'wiki.proof-of-work': 0.6,
            'wiki.utxo-model': 0.25,
          },
          lastRead: const ['wiki.proof-of-work', 'wiki.utxo-model'],
        ),
      );
      final content = (await tester.runAsync(
        () => AppContentController.load(
          repository: const _SeedFileRepository(),
          mediaStore: ContentMediaStore(rootDirectory: mediaDirectory),
          languageCode: shot.language,
        ),
      ))!;

      final appKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: appKey,
          child: SatoWikiApp(
            settingsController: settings,
            contentController: content,
          ),
        ),
      );
      await _settle(tester);

      final route = shot.route;
      if (route != null) {
        tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
        await _settle(tester);
      }

      final screen = await _capture(tester, appKey);

      // Second pass: draw the captured screen inside the phone frame.
      final frameSize = Size(
        _screenSize.width + _bezel * 2,
        _screenSize.height + _bezel * 2,
      );
      tester.view.physicalSize = frameSize * _pixelRatio;
      tester.view.padding = FakeViewPadding.zero;
      final frameKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: frameKey,
          child: _PhoneFrame(screen: screen),
        ),
      );
      await tester.pump();

      final framed = await _capture(tester, frameKey);
      await tester.runAsync(() async {
        final bytes = await framed.toByteData(format: ui.ImageByteFormat.png);
        final file = File('$_outputDirectory/${shot.name}.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
      });
    });
  }
}

/// Lets route transitions finish and gives file-backed images and SVGs real
/// time to decode, which `pump` alone never does.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i += 1) {
    await tester.pump(const Duration(milliseconds: 200));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
  }
  await tester.pump();
}

Future<ui.Image> _capture(WidgetTester tester, GlobalKey key) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await tester.runAsync(
    () => boundary.toImage(pixelRatio: _pixelRatio),
  );

  return image!;
}

Future<void> _loadFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('Inter', ['assets/fonts/inter/InterVariable.ttf']);
  await load('Space Grotesk', [
    'assets/fonts/space_grotesk/SpaceGrotesk-Variable.ttf',
  ]);
  await load('JetBrains Mono', [
    'assets/fonts/jetbrains_mono/JetBrainsMono-Regular.ttf',
    'assets/fonts/jetbrains_mono/JetBrainsMono-Medium.ttf',
    'assets/fonts/jetbrains_mono/JetBrainsMono-Bold.ttf',
  ]);
  // The icon font ships with the Flutter SDK, not with the app.
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

/// Reads the seed bundles straight from the repository.
final class _SeedFileRepository implements ContentBundleRepository {
  const _SeedFileRepository();

  @override
  Future<ContentBundleParseResult> load(String languageCode) async {
    final file = File('assets/content/seed_bundle_$languageCode.json');

    return ContentBundleParser.parseJson(await file.readAsString());
  }

  @override
  Future<void> saveUpdatedBundleJson(String languageCode, String json) async {}
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.screen});

  final ui.Image screen;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D22),
          borderRadius: BorderRadius.circular(_screenRadius + _bezel),
          border: Border.all(color: const Color(0xFF3A3D45), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_bezel),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_screenRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RawImage(image: screen, fit: BoxFit.fill),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 112,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
