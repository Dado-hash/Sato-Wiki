import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/content/domain/content_models.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/navigation/sato_wiki_tab.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/settings/app_settings_scope.dart';
import 'package:sato_wiki/src/core/settings/theme_preference.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/features/tools/presentation/explorer_session.dart';
import 'package:sato_wiki/src/features/tools/presentation/explorer_setup_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

import 'explorer_test_support.dart' show FakeExplorerApi;

// Smoke matrix over the real seed bundles. Nothing here contacts a server:
// the explorer is off in every case and its client factory is a counter.

const _seedPaths = {
  'en': 'assets/content/seed_bundle_en.json',
  'it': 'assets/content/seed_bundle_it.json',
};

/// The app's bundled font files by family, as pubspec.yaml declares them.
const _appFontFiles = {
  'Inter': ['assets/fonts/inter/InterVariable.ttf'],
  'Space Grotesk': ['assets/fonts/space_grotesk/SpaceGrotesk-Variable.ttf'],
  'JetBrains Mono': [
    'assets/fonts/jetbrains_mono/JetBrainsMono-Regular.ttf',
    'assets/fonts/jetbrains_mono/JetBrainsMono-Medium.ttf',
    'assets/fonts/jetbrains_mono/JetBrainsMono-Bold.ttf',
  ],
};

/// Loads the app's fonts for the tests. Without this, flutter_test draws text
/// with a block font whose glyphs are wider than the real ones, so the
/// overflows would not match a phone. Call once from setUpAll.
Future<void> loadSmokeFonts() async {
  for (final entry in _appFontFiles.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      loader.addFont(
        Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
      );
    }
    await loader.load();
  }
}

/// One seed bundle as the app parses it, with its raw JSON for the repository.
final class SmokeSeed {
  SmokeSeed._(this.language, this.json, this.bundle);

  factory SmokeSeed.load(String language) {
    final path = _seedPaths[language];
    if (path == null) {
      throw ArgumentError.value(language, 'language');
    }
    final json = File(path).readAsStringSync();

    return SmokeSeed._(
      language,
      json,
      ContentBundleParser.parseJson(json).bundle,
    );
  }

  final String language;
  final String json;
  final ContentBundle bundle;
}

/// A phone size, a theme and a language. [textScale] scales the text only.
final class SmokeCombo {
  const SmokeCombo({
    required this.language,
    required this.dark,
    required this.width,
    required this.height,
    this.textScale = 1,
  });

  final String language;
  final bool dark;
  final double width;
  final double height;
  final double textScale;

  /// The full route list runs for these two combinations only. The other
  /// combinations run the reduced list, to keep the whole run short.
  bool get runsFullRouteList {
    return (language == 'en' && dark && width == 360 && textScale == 1) ||
        (language == 'it' && !dark && width == 320 && textScale == 1.3);
  }

  String get label {
    final theme = dark ? 'dark' : 'light';
    final scale = textScale == 1 ? '' : ' scale $textScale';

    return '$language $theme ${width.toInt()}x${height.toInt()}$scale';
  }
}

const smokeCombos = <SmokeCombo>[
  SmokeCombo(language: 'en', dark: true, width: 360, height: 740),
  SmokeCombo(language: 'en', dark: true, width: 320, height: 640),
  SmokeCombo(
    language: 'en',
    dark: true,
    width: 320,
    height: 640,
    textScale: 1.3,
  ),
  SmokeCombo(language: 'en', dark: false, width: 360, height: 740),
  SmokeCombo(language: 'en', dark: false, width: 320, height: 640),
  SmokeCombo(
    language: 'en',
    dark: false,
    width: 320,
    height: 640,
    textScale: 1.3,
  ),
  SmokeCombo(language: 'it', dark: true, width: 360, height: 740),
  SmokeCombo(language: 'it', dark: true, width: 320, height: 640),
  SmokeCombo(
    language: 'it',
    dark: true,
    width: 320,
    height: 640,
    textScale: 1.3,
  ),
  SmokeCombo(language: 'it', dark: false, width: 360, height: 740),
  SmokeCombo(language: 'it', dark: false, width: 320, height: 640),
  SmokeCombo(
    language: 'it',
    dark: false,
    width: 320,
    height: 640,
    textScale: 1.3,
  ),
];

/// Extra work done on a route after it opens, before the scroll.
enum SmokeInteraction { none, hashText, transactionExample, labMine }

final class SmokeRoute {
  const SmokeRoute(this.route, {this.interaction = SmokeInteraction.none});

  final String route;
  final SmokeInteraction interaction;
}

/// Wiki entries the matrix opens by slug. They exist in both seeds.
const smokeWikiEntries = [
  'hash-functions',
  'myth-anonymous',
  'software-wallets',
];

/// Glossary terms the matrix opens by slug. They exist in both seeds.
const smokeGlossaryTerms = ['address', 'block', 'proof-of-work'];

/// Every route the full list covers, for one seed. The list has 105 routes
/// with the 16 library works, 32 products and 5 reference tables of the seed.
List<SmokeRoute> fullSmokeRoutes(SmokeSeed seed) {
  final bundle = seed.bundle;

  return [
    for (final tab in SatoWikiTab.values) SmokeRoute(tab.routePath),
    for (final category in _categories(bundle))
      SmokeRoute(AppRoutes.wikiCategory(category)),
    for (final subcategory in _subcategories(bundle))
      SmokeRoute(AppRoutes.wikiSubcategory(subcategory)),
    for (final slug in smokeWikiEntries) SmokeRoute(AppRoutes.wikiEntry(slug)),
    for (final product in bundle.products)
      SmokeRoute(AppRoutes.product(product.slug)),
    const SmokeRoute(AppRoutes.glossary),
    for (final term in smokeGlossaryTerms)
      SmokeRoute(AppRoutes.glossaryTerm(term)),
    for (final path in bundle.paths)
      SmokeRoute(AppRoutes.learningPath(path.slug)),
    const SmokeRoute(AppRoutes.library),
    for (final work in bundle.library)
      SmokeRoute(AppRoutes.libraryWork(work.slug)),
    const SmokeRoute(
      AppRoutes.toolHash,
      interaction: SmokeInteraction.hashText,
    ),
    const SmokeRoute(AppRoutes.toolAddress),
    const SmokeRoute(
      AppRoutes.toolTransaction,
      interaction: SmokeInteraction.transactionExample,
    ),
    const SmokeRoute(AppRoutes.toolTarget),
    const SmokeRoute(AppRoutes.toolUnits),
    const SmokeRoute(AppRoutes.references),
    for (final table in bundle.references)
      SmokeRoute(AppRoutes.reference(table.slug)),
    const SmokeRoute(AppRoutes.lab),
    for (var step = 1; step <= 7; step++)
      SmokeRoute(
        AppRoutes.labStep(step),
        interaction: step == 2
            ? SmokeInteraction.labMine
            : SmokeInteraction.none,
      ),
    const SmokeRoute(AppRoutes.scriptStepper),
    const SmokeRoute(AppRoutes.explorer),
    const SmokeRoute(AppRoutes.search),
    const SmokeRoute(AppRoutes.settings),
    const SmokeRoute(AppRoutes.bookmarks),
  ];
}

/// The screens with the most content, for the combinations that do not run
/// the full list: each tab, the largest category and subcategory, the
/// longest product and library work, the largest reference table and the
/// lab and tool screens with interactions.
List<SmokeRoute> reducedSmokeRoutes(SmokeSeed seed) {
  final bundle = seed.bundle;
  final categories = _categories(bundle);
  final subcategories = _subcategories(bundle);
  final products = [...bundle.products]
    ..sort((a, b) => a.bodyMarkdown.length.compareTo(b.bodyMarkdown.length));
  final works = [...bundle.library]
    ..sort((a, b) => a.introduction.length.compareTo(b.introduction.length));
  final tables = [...bundle.references]
    ..sort((a, b) => a.rows.length.compareTo(b.rows.length));

  return [
    for (final tab in SatoWikiTab.values) SmokeRoute(tab.routePath),
    if (categories.isNotEmpty)
      SmokeRoute(
        AppRoutes.wikiCategory(
          _largest(categories, (c) => _entriesIn(bundle, c)),
        ),
      ),
    if (subcategories.isNotEmpty)
      SmokeRoute(
        AppRoutes.wikiSubcategory(
          _largest(subcategories, (s) => _itemsIn(bundle, s)),
        ),
      ),
    SmokeRoute(AppRoutes.wikiEntry(smokeWikiEntries.first)),
    if (products.isNotEmpty) SmokeRoute(AppRoutes.product(products.last.slug)),
    const SmokeRoute(AppRoutes.glossary),
    SmokeRoute(AppRoutes.glossaryTerm(smokeGlossaryTerms[1])),
    for (final path in bundle.paths)
      SmokeRoute(AppRoutes.learningPath(path.slug)),
    const SmokeRoute(AppRoutes.library),
    if (works.isNotEmpty) SmokeRoute(AppRoutes.libraryWork(works.last.slug)),
    const SmokeRoute(
      AppRoutes.toolHash,
      interaction: SmokeInteraction.hashText,
    ),
    const SmokeRoute(
      AppRoutes.toolTransaction,
      interaction: SmokeInteraction.transactionExample,
    ),
    const SmokeRoute(AppRoutes.references),
    if (tables.isNotEmpty) SmokeRoute(AppRoutes.reference(tables.last.slug)),
    const SmokeRoute(AppRoutes.lab),
    SmokeRoute(AppRoutes.labStep(2), interaction: SmokeInteraction.labMine),
    SmokeRoute(AppRoutes.labStep(7)),
    const SmokeRoute(AppRoutes.scriptStepper),
    const SmokeRoute(AppRoutes.explorer),
    const SmokeRoute(AppRoutes.search),
    const SmokeRoute(AppRoutes.settings),
    const SmokeRoute(AppRoutes.bookmarks),
  ];
}

/// Routes for [combo]: the full list or the reduced one.
List<SmokeRoute> smokeRoutesFor(SmokeSeed seed, SmokeCombo combo) {
  return combo.runsFullRouteList
      ? fullSmokeRoutes(seed)
      : reducedSmokeRoutes(seed);
}

List<String> _categories(ContentBundle bundle) {
  return bundle.wiki.map((entry) => entry.category).toSet().toList()..sort();
}

/// Subcategory ids from wiki entries and products, sorted.
List<String> _subcategories(ContentBundle bundle) {
  final ids = <String>{
    for (final entry in bundle.wiki)
      if (entry.subcategory case final id? when id.isNotEmpty) id,
    for (final product in bundle.products)
      if (product.subcategory.isNotEmpty) product.subcategory,
  };

  return ids.toList()..sort();
}

int _entriesIn(ContentBundle bundle, String category) {
  return bundle.wiki.where((entry) => entry.category == category).length;
}

int _itemsIn(ContentBundle bundle, String subcategory) {
  return bundle.wiki.where((entry) => entry.subcategory == subcategory).length +
      bundle.products.where((p) => p.subcategory == subcategory).length;
}

T _largest<T>(List<T> items, int Function(T item) size) {
  return items.reduce((a, b) => size(a) >= size(b) ? a : b);
}

/// Human-readable location of an error: the first lines of its message and
/// the project file and line it points to, when the message names one.
String describeSmokeError(Object error) {
  final text = error.toString();
  final lines = text
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .take(6)
      .join(' | ');
  final location = RegExp(r'lib/src/[^\s:)\x27"]+\.dart:\d+').firstMatch(text);
  final widget = RegExp(
    r'The relevant error-causing widget was:\s*\n\s*(\S+)',
  ).firstMatch(text);

  return '$lines'
      '${widget == null ? '' : ' | widget: ${widget.group(1)}'}'
      '${location == null ? '' : ' | at ${location.group(0)}'}';
}

/// One framework error: its first message lines, the widget it names and the
/// project file and line it points to.
String describeSmokeDetails(FlutterErrorDetails details) {
  final text = details.toString();
  final message = details
      .exceptionAsString()
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .take(2)
      .join(' ');
  final widget = RegExp(
    r'The relevant error-causing widget was:\s*\n\s*(\S+)',
  ).firstMatch(text)?.group(1);
  final location = RegExp(
    r'lib/src/[^\s:)\x27"]+\.dart:\d+',
  ).firstMatch(text)?.group(0);

  return '$message'
      '${widget == null ? '' : ' | widget: $widget'}'
      '${location == null ? '' : ' | at $location'}';
}

/// Drives one app instance: opens routes, scrolls, and checks for errors
/// after every step. Any error in a step fails the case at that step.
final class SmokeRun {
  SmokeRun._({
    required this.tester,
    required this.navigatorKey,
    required this.label,
    required this.clientsCreated,
    required this.api,
    required this.language,
    required this.recorded,
  });

  final List<FlutterErrorDetails> recorded;
  final WidgetTester tester;
  final GlobalKey<NavigatorState> navigatorKey;
  final String label;
  final String language;
  final List<Uri> clientsCreated;
  final FakeExplorerApi api;

  AppLocalizations get l10n => lookupAppLocalizations(Locale(language));

  /// Pumps the real router inside the app's theme and locale, the way
  /// SatoWikiApp does, minus the content update banner and the background
  /// update check. Content comes from [seed]. The explorer is off.
  static Future<SmokeRun> pump(
    WidgetTester tester, {
    required SmokeCombo combo,
    required SmokeSeed seed,
  }) async {
    tester.view.physicalSize = Size(combo.width, combo.height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final settings = await AppSettingsController.load(
      InMemoryAppSettingsRepository(
        lastTab: SatoWikiTab.today,
        themePreference: combo.dark
            ? ThemePreference.dark
            : ThemePreference.light,
        explorerEnabled: false,
      ),
    );
    final clients = <Uri>[];
    final api = FakeExplorerApi();
    ExplorerSession.replaceFor(
      settings,
      ExplorerSession(
        settings: settings,
        apiFactory: (uri) {
          clients.add(uri);

          return api;
        },
      ),
    );
    final content = await AppContentController.load(
      repository: _SeedRepository(seed.json),
      languageCode: combo.language,
    );
    final navigatorKey = GlobalKey<NavigatorState>();

    // takeException returns only the first error of a step and not the widget
    // or file it points to. Recording the details keeps every error. The test
    // framework's handler still runs, so takeException keeps working.
    final recorded = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      recorded.add(details);
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        locale: Locale(combo.language),
        supportedLocales: AppLocale.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: combo.dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(combo.textScale)),
            child: AppSettingsScope(
              controller: settings,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        initialRoute: AppRoutes.root,
        onGenerateRoute: (routeSettings) {
          return AppRouter.generateRoute(routeSettings, settings, content);
        },
      ),
    );

    final run = SmokeRun._(
      tester: tester,
      navigatorKey: navigatorKey,
      label: combo.label,
      language: combo.language,
      clientsCreated: clients,
      api: api,
      recorded: recorded,
    );
    await run.settle();
    run.checkNoError('start');

    return run;
  }

  /// Replaces the stack with [route] and lets it settle. Fails if the route
  /// fell through to the unknown-route screen.
  Future<void> open(String route) async {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(route, (_) => false);
    await settle();
    checkNoError('open $route');
    if (find.byType(UnknownRouteScreen).evaluate().isNotEmpty) {
      fail('[$label] $route: the route is not known to the router');
    }
    checkNoExplorerRequests(route);
  }

  /// Pumps until no animation is left. Screens with a timer that never ends
  /// are pumped for a fixed time instead, so they do not hang the test.
  Future<void> settle() async {
    try {
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 2),
      );
    } on FlutterError {
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
  }

  /// Scrolls the outermost vertical scrollable to its end in steps. Does
  /// nothing when the screen does not scroll.
  Future<void> scrollToBottom(String route) async {
    final finder = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    if (finder.evaluate().isEmpty) {
      return;
    }
    for (var step = 0; step < 120; step++) {
      final position = tester.state<ScrollableState>(finder.first).position;
      if (position.pixels >= position.maxScrollExtent) {
        return;
      }
      await tester.drag(finder.first, const Offset(0, -450));
      await tester.pump(const Duration(milliseconds: 50));
      checkNoError('scroll step $step on $route');
    }
    fail('[$label] $route: scrolling did not reach the end in 120 steps');
  }

  /// Fails with every error the framework reported since the last check,
  /// each with its message, the widget it names and the project file.
  void checkNoError(String step) {
    final error = tester.takeException();
    final details = List<FlutterErrorDetails>.of(recorded);
    recorded.clear();
    if (error == null && details.isEmpty) {
      return;
    }
    final described = details.isEmpty
        ? [describeSmokeError(error!)]
        : [for (final detail in details) describeSmokeDetails(detail)];
    fail('[$label] $step: ${described.join(' ;; ')}');
  }

  /// With the explorer off, no client may be created and no call made.
  void checkNoExplorerRequests(String route) {
    if (clientsCreated.isNotEmpty || api.calls.isNotEmpty) {
      fail(
        '[$label] $route: the explorer made ${clientsCreated.length} client(s) '
        'and ${api.calls.length} call(s) while off: ${api.calls}',
      );
    }
  }

  /// Taps the first finder match after bringing it into view.
  Future<void> tap(Finder finder) async {
    await tester.ensureVisible(finder.first);
    await tester.pump();
    await tester.tap(finder.first);
    await settle();
  }
}

/// Repository that serves the seed JSON the test loaded.
final class _SeedRepository implements ContentBundleRepository {
  const _SeedRepository(this.json);

  final String json;

  @override
  Future<ContentBundleParseResult> load(String languageCode) async {
    return ContentBundleParser.parseJson(json);
  }

  @override
  Future<void> saveUpdatedBundleJson(String languageCode, String json) async {}
}

/// Finder for a SelectableText that shows exactly [value].
Finder selectableText(String value) {
  return find.byWidgetPredicate(
    (widget) => widget is SelectableText && widget.data == value,
  );
}

/// Screen the explorer shows while it is off.
Finder explorerActivationScreen() => find.byType(ExplorerSetupScreen);
