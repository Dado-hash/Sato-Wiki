import 'dart:ui' show CheckedState;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/features/tools/data/secure_screen_channel.dart';
import 'package:sato_wiki/src/features/tools/presentation/tool_dice_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

import 'tools_dice_fakes.dart';
import 'tools_screen_fixtures.dart';

final _en = lookupAppLocalizations(const Locale('en'));

/// Phone size in logical pixels (dpr 1).
const _phoneSize = Size(390, 844);

/// Pumps the intro screen with [secure] as its native guard (null for none).
Future<void> _pumpIntro(
  WidgetTester tester, {
  required SecureScreen? secure,
}) async {
  tester.view.physicalSize = _phoneSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final settings = await AppSettingsController.load(
    InMemoryAppSettingsRepository(),
  );
  final content = await AppContentController.load(
    repository: _FixtureRepository(toolsFixtureJson()),
    languageCode: 'en',
  );

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: ToolDiceScreen(store: content.content.store, secureScreen: secure),
      onGenerateRoute: (routeSettings) {
        return AppRouter.generateRoute(routeSettings, settings, content);
      },
    ),
  );
  await _settle(tester);
}

/// Lets the async network check and the route animations finish.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

/// Semantics node of the checklist row whose title is [title].
SemanticsNode _row(WidgetTester tester, String title) {
  return tester.getSemantics(
    find.bySemanticsLabel(RegExp('^${RegExp.escape(title)}\\.')),
  );
}

/// Whether the checklist row whose title is [title] is ticked.
bool _isChecked(WidgetTester tester, String title) {
  final flags = _row(tester, title).getSemanticsData().flagsCollection;
  return flags.isChecked == CheckedState.isTrue;
}

/// Taps the checklist row whose title is [title], scrolling to it first.
Future<void> _tapRow(WidgetTester tester, String title) async {
  final target = find.text(title);
  await tester.ensureVisible(target.first);
  await tester.pump();
  await tester.tap(target.first);
  await _settle(tester);
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

void main() {
  testWidgets('offline network ticks the airplane row and says so', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final secure = FakeSecureScreen();
    addTearDown(secure.close);

    await _pumpIntro(tester, secure: secure);

    expect(find.text(_en.toolsDiceCheckAirplaneOffline), findsOneWidget);
    expect(find.text(_en.toolsDiceCheckAirplaneOpenSettings), findsNothing);
    expect(_isChecked(tester, _en.toolsDiceCheckAirplane), isTrue);
    handle.dispose();
  });

  testWidgets(
    'online on Android opens the airplane settings, then rechecks on resume',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final handle = tester.ensureSemantics();
      final secure = FakeSecureScreen(online: true);
      addTearDown(secure.close);

      await _pumpIntro(tester, secure: secure);

      expect(find.text(_en.toolsDiceCheckAirplaneOpenSettings), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
      expect(
        _row(tester, _en.toolsDiceCheckAirplane),
        matchesSemantics(
          hasCheckedState: true,
          isChecked: false,
          hasTapAction: true,
          hint: _en.toolsDiceCheckAirplaneOpenSettingsHint,
        ),
      );

      await _tapRow(tester, _en.toolsDiceCheckAirplane);
      expect(secure.settingsOpens, 1);

      // The user switches airplane mode on in the settings, then comes back.
      secure.online = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await _settle(tester);

      expect(find.text(_en.toolsDiceCheckAirplaneOffline), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new_rounded), findsNothing);
      expect(_isChecked(tester, _en.toolsDiceCheckAirplane), isTrue);
      handle.dispose();
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'online outside Android points to Control Center and does not open settings',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final handle = tester.ensureSemantics();
      final secure = FakeSecureScreen(online: true);
      addTearDown(secure.close);

      await _pumpIntro(tester, secure: secure);

      expect(
        find.text(_en.toolsDiceCheckAirplaneControlCenter),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.open_in_new_rounded), findsNothing);

      await _tapRow(tester, _en.toolsDiceCheckAirplane);
      expect(secure.settingsOpens, 0);
      expect(
        find.text(_en.toolsDiceCheckAirplaneControlCenter),
        findsOneWidget,
      );
      handle.dispose();
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('without a native guard the airplane row is ticked by hand', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await _pumpIntro(tester, secure: null);

    expect(find.text(_en.toolsDiceCheckAirplaneCaption), findsOneWidget);
    expect(_isChecked(tester, _en.toolsDiceCheckAirplane), isFalse);

    await _tapRow(tester, _en.toolsDiceCheckAirplane);
    expect(_isChecked(tester, _en.toolsDiceCheckAirplane), isTrue);

    await _tapRow(tester, _en.toolsDiceCheckAirplane);
    expect(_isChecked(tester, _en.toolsDiceCheckAirplane), isFalse);
    handle.dispose();
  });

  testWidgets('the physical rows start unticked and toggle by tap', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final secure = FakeSecureScreen(online: false);
    addTearDown(secure.close);

    await _pumpIntro(tester, secure: secure);

    for (final title in [
      _en.toolsDiceCheckPrivate,
      _en.toolsDiceCheckPaper,
      _en.toolsDiceCheckDice,
    ]) {
      expect(_isChecked(tester, title), isFalse);
      await _tapRow(tester, title);
      expect(_isChecked(tester, title), isTrue);
      await _tapRow(tester, title);
      expect(_isChecked(tester, title), isFalse);
    }
    expect(secure.settingsOpens, 0);
    handle.dispose();
  });
}
