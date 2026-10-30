import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/navigation/app_router.dart';
import 'package:sato_wiki/src/core/navigation/app_routes.dart';
import 'package:sato_wiki/src/core/settings/app_settings_controller.dart';
import 'package:sato_wiki/src/core/settings/app_settings_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/features/tools/data/secure_screen_channel.dart';
import 'package:sato_wiki/src/features/tools/domain/bip39.dart';
import 'package:sato_wiki/src/features/tools/domain/dice_detection.dart';
import 'package:sato_wiki/src/features/tools/domain/dice_entropy.dart';
import 'package:sato_wiki/src/features/tools/presentation/dice_result_view.dart';
import 'package:sato_wiki/src/features/tools/presentation/dice_sandbox_screen.dart';
import 'package:sato_wiki/src/features/tools/presentation/dice_widgets.dart';
import 'package:sato_wiki/src/features/tools/presentation/tool_dice_screen.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

import 'tools_dice_fakes.dart';
import 'tools_screen_fixtures.dart';

final _en = lookupAppLocalizations(const Locale('en'));

/// Phone size in logical pixels (dpr 1).
const _phoneSize = Size(390, 844);

/// The SeedSigner vector: 45 rolls of 2 then 54 rolls of 5 (99 rolls).
final _vectorRolls = [...List.filled(45, 2), ...List.filled(54, 5)];

/// The 24 words of [_vectorRolls], in order.
const _vectorWords = [
  'garden',
  'uphold',
  'level',
  'clog',
  'sword',
  'globe',
  'armor',
  'issue',
  'two',
  'cute',
  'scorpion',
  'improve',
  'verb',
  'artwork',
  'blind',
  'tail',
  'raw',
  'butter',
  'combine',
  'move',
  'produce',
  'foil',
  'feature',
  'wave',
];

/// Finds dice in one camera frame, laid out left to right at the same height.
/// Pass the same [values] to get the same scene.
List<DetectedDie> _frame(List<int> values, {List<double>? confidences}) {
  return [
    for (var i = 0; i < values.length; i++)
      DetectedDie(
        value: values[i],
        box: DieBox(left: 0.05 + i * 0.18, top: 0.4, width: 0.14, height: 0.2),
        confidence: confidences?[i] ?? 0.99,
      ),
  ];
}

/// Pumps frames and lets the route and sheet animations finish. The sandbox
/// pulses while it waits for dice, so pumpAndSettle would never end.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

/// Scrolls the list inside [within] until [text] is built, then brings it
/// into view. The screens are lazy lists, so off-screen text is not built.
Future<void> _scrollTo(
  WidgetTester tester,
  String text, {
  required Finder within,
}) async {
  final target = find.text(text);
  final list = find.descendant(of: within, matching: find.byType(Scrollable));
  for (var i = 0; i < 40 && target.evaluate().isEmpty; i++) {
    await tester.drag(list.first, const Offset(0, -300));
    await tester.pump();
  }
  await tester.ensureVisible(target.first);
  await tester.pump();
}

/// Taps the first widget with [text] inside [within], scrolling to it first.
Future<void> _tapText(
  WidgetTester tester,
  String text, {
  required Finder within,
}) async {
  await _scrollTo(tester, text, within: within);
  await tester.tap(find.text(text).first);
  await _settle(tester);
}

/// Pumps the intro screen in the app's theme, phone size and English.
/// Returns the navigator key, so a test can push named routes.
Future<GlobalKey<NavigatorState>> _pumpIntro(
  WidgetTester tester, {
  required FakeDiceDetector? detector,
  required FakeSecureScreen secure,
  bool dark = true,
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
  final store = content.content.store;
  final navigatorKey = GlobalKey<NavigatorState>();

  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
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
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: ToolDiceScreen(
        store: store,
        detectorFactory: detector == null ? null : () => detector,
        secureScreen: secure,
      ),
      onGenerateRoute: (routeSettings) {
        return AppRouter.generateRoute(routeSettings, settings, content);
      },
    ),
  );
  await _settle(tester);

  return navigatorKey;
}

/// Pumps the intro and opens the sandbox from its button.
Future<void> _openSandbox(
  WidgetTester tester, {
  required FakeDiceDetector? detector,
  required FakeSecureScreen secure,
  bool dark = true,
}) async {
  await _pumpIntro(tester, detector: detector, secure: secure, dark: dark);
  await _tapText(
    tester,
    _en.toolsDiceEnter,
    within: find.byType(ToolDiceScreen),
  );
  expect(find.byType(DiceSandboxScreen), findsOneWidget);
}

/// Opens the keypad sheet, taps [values] and saves them as one throw.
Future<void> _enterThrow(WidgetTester tester, List<int> values) async {
  await tester.tap(find.byTooltip(_en.toolsDiceKeypad));
  await _settle(tester);
  for (final value in values) {
    await tester.tap(
      find.descendant(
        of: find.byType(DiceKeypad),
        matching: find.text('$value'),
      ),
    );
    await tester.pump();
  }
  await tester.tap(find.text(_en.toolsDiceSaveThrow));
  await _settle(tester);
}

/// Enters every roll of [_vectorRolls] by keypad, five rolls per throw.
Future<void> _enterVectorRolls(WidgetTester tester) async {
  for (var start = 0; start < _vectorRolls.length; start += 5) {
    final end = start + 5 < _vectorRolls.length
        ? start + 5
        : _vectorRolls.length;
    await _enterThrow(tester, _vectorRolls.sublist(start, end));
  }
}

/// Subscribes the test to the fake's frames: waits until the sandbox listens.
Future<void> _waitForListener(
  WidgetTester tester,
  FakeDiceDetector detector,
) async {
  for (var i = 0; i < 10 && !detector.listening; i++) {
    await tester.pump();
  }
  expect(detector.listening, isTrue, reason: 'the sandbox must listen');
}

/// Repository that serves the fixture JSON.
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
  for (final dark in [true, false]) {
    final theme = dark ? 'dark' : 'light';

    group('intro ($theme)', () {
      testWidgets(
        'renders the checklist, the sandbox notes and the enter button',
        (tester) async {
          await _pumpIntro(
            tester,
            detector: FakeDiceDetector(),
            secure: FakeSecureScreen(),
            dark: dark,
          );

          expect(find.text(_en.toolsDiceEyebrow), findsOneWidget);
          expect(find.text(_en.toolsDiceChecklistTitle), findsOneWidget);
          expect(find.text(_en.toolsDiceCheckAirplane), findsOneWidget);
          await _scrollTo(
            tester,
            _en.toolsDiceSandboxInfoTitle,
            within: find.byType(ToolDiceScreen),
          );
          expect(find.text(_en.toolsDiceSandboxInfoTitle), findsOneWidget);
          expect(find.text(_en.toolsDiceEnter), findsOneWidget);
          expect(find.text(_en.toolsDiceHowMath), findsOneWidget);
          expect(find.byType(DiceSandboxScreen), findsNothing);
        },
      );
    });
  }

  group('intro', () {
    testWidgets(
      'the segmented control switches 24 and 12 words and the summary',
      (tester) async {
        await _pumpIntro(
          tester,
          detector: FakeDiceDetector(),
          secure: FakeSecureScreen(),
        );

        expect(
          find.text(_en.toolsDiceLengthSummary(99, 256, 20)),
          findsOneWidget,
          reason: '24 words is the default',
        );

        await _tapText(
          tester,
          _en.toolsDiceWords(12),
          within: find.byType(ToolDiceScreen),
        );

        expect(
          find.text(_en.toolsDiceLengthSummary(50, 128, 10)),
          findsOneWidget,
        );
        expect(
          find.text(_en.toolsDiceLengthSummary(99, 256, 20)),
          findsNothing,
        );

        await _tapText(
          tester,
          _en.toolsDiceWords(24),
          within: find.byType(ToolDiceScreen),
        );

        expect(
          find.text(_en.toolsDiceLengthSummary(99, 256, 20)),
          findsOneWidget,
        );
      },
    );

    testWidgets('the sandbox is pushed as an unnamed route, not a named one', (
      tester,
    ) async {
      final navigatorKey = await _pumpIntro(
        tester,
        detector: FakeDiceDetector(),
        secure: FakeSecureScreen(),
      );

      await _tapText(
        tester,
        _en.toolsDiceEnter,
        within: find.byType(ToolDiceScreen),
      );

      final route = ModalRoute.of(
        tester.element(find.byType(DiceSandboxScreen)),
      );
      expect(route?.settings.name, isNull);

      // A deep link to a made-up sandbox name must not open it.
      navigatorKey.currentState!.pushNamed('/code/tools/dice/sandbox');
      await _settle(tester);

      expect(find.byType(UnknownRouteScreen), findsOneWidget);
      expect(find.byType(DiceSandboxScreen), findsNothing);
    });

    testWidgets('the named tool route opens the intro, never the sandbox', (
      tester,
    ) async {
      final navigatorKey = await _pumpIntro(
        tester,
        detector: FakeDiceDetector(),
        secure: FakeSecureScreen(),
      );

      navigatorKey.currentState!.pushNamed(AppRoutes.toolDice);
      await _settle(tester);

      expect(find.byType(ToolDiceScreen), findsOneWidget);
      expect(find.byType(DiceSandboxScreen), findsNothing);
    });
  });

  group('sandbox native guard and exit', () {
    testWidgets('enable runs on open, disable and dispose run on exit', (
      tester,
    ) async {
      final detector = FakeDiceDetector();
      final secure = FakeSecureScreen();
      addTearDown(() async => detector.close());
      addTearDown(() async => secure.close());

      await _openSandbox(tester, detector: detector, secure: secure);

      expect(secure.enables, 1);
      expect(secure.disables, 0);

      await tester.tap(find.byTooltip(_en.toolsDiceExit));
      await _settle(tester);
      expect(find.text(_en.toolsDiceExitConfirmTitle), findsOneWidget);

      await tester.tap(
        find.widgetWithText(FilledButton, _en.toolsDiceExitConfirm),
      );
      await _settle(tester);

      expect(find.byType(DiceSandboxScreen), findsNothing);
      expect(secure.disables, 1);
      expect(detector.disposes, 1);
      expect(detector.stops, greaterThanOrEqualTo(1));
    });

    testWidgets('cancelling the exit dialog keeps the sandbox open', (
      tester,
    ) async {
      final detector = FakeDiceDetector();
      final secure = FakeSecureScreen();
      addTearDown(() async => detector.close());
      addTearDown(() async => secure.close());

      await _openSandbox(tester, detector: detector, secure: secure);

      await tester.tap(find.byTooltip(_en.toolsDiceExit));
      await _settle(tester);
      await tester.tap(find.widgetWithText(TextButton, _en.toolsDiceCancel));
      await _settle(tester);

      expect(find.byType(DiceSandboxScreen), findsOneWidget);
      expect(secure.disables, 0);
      expect(detector.disposes, 0);
    });
  });

  group('keypad only', () {
    testWidgets(
      'an unavailable detector shows the camera notice and no camera',
      (tester) async {
        final detector = FakeDiceDetector(available: false);
        final secure = FakeSecureScreen();
        addTearDown(() async => detector.close());
        addTearDown(() async => secure.close());

        await _openSandbox(tester, detector: detector, secure: secure);

        expect(find.text(_en.toolsDiceCameraUnavailable), findsOneWidget);
        expect(detector.starts, 0);
        expect(detector.listening, isFalse);

        await _enterThrow(tester, const [5, 1, 2, 3, 4]);

        expect(find.text(_en.toolsDiceCountOf(5, 99)), findsNWidgets(2));
      },
    );

    testWidgets('no detector at all also runs keypad only', (tester) async {
      final secure = FakeSecureScreen();
      addTearDown(() async => secure.close());

      await _pumpIntro(tester, detector: null, secure: secure);
      await _tapText(
        tester,
        _en.toolsDiceEnter,
        within: find.byType(ToolDiceScreen),
      );

      expect(find.text(_en.toolsDiceCameraUnavailable), findsOneWidget);
    });
  });

  group('manual entry of the SeedSigner vector', () {
    testWidgets(
      'keypad throws reach the result, and the words stay hidden until held',
      (tester) async {
        final detector = FakeDiceDetector(available: false);
        final secure = FakeSecureScreen();
        addTearDown(() async => detector.close());
        addTearDown(() async => secure.close());

        await _openSandbox(tester, detector: detector, secure: secure);
        await _enterVectorRolls(tester);

        expect(find.byType(DiceResultView), findsOneWidget);
        expect(find.text(_en.toolsDiceDone), findsOneWidget);

        final mnemonic = Bip39Mnemonic.fromEntropy(
          diceRollsToEntropy(_vectorRolls, DiceSeedLength.words24),
        );
        expect([for (var i = 0; i < 24; i++) mnemonic.wordAt(i)], _vectorWords);

        // Hidden: no word, no 11-bit group and no word index on screen.
        for (final word in _vectorWords) {
          expect(find.text(word), findsNothing, reason: 'hidden word $word');
        }
        for (final group in mnemonic.bitGroups()) {
          expect(
            find.textContaining(group),
            findsNothing,
            reason: 'hidden bit group $group',
          );
        }
        for (final index in mnemonic.indices) {
          expect(find.text('→ $index'), findsNothing);
        }

        // Nothing selectable, no text field and no editable text in the sandbox.
        final sandbox = find.byType(DiceSandboxScreen);
        for (final type in <Type>[
          SelectableText,
          SelectionArea,
          TextField,
          EditableText,
        ]) {
          expect(
            find.descendant(of: sandbox, matching: find.byType(type)),
            findsNothing,
            reason: '$type must not be in the sandbox',
          );
        }

        // Hold to reveal: the words show while the pointer is down.
        final hold = find.text(_en.toolsDiceHoldToReveal);
        await tester.ensureVisible(hold);
        await tester.pump();
        final gesture = await tester.startGesture(tester.getCenter(hold));
        await tester.pump();

        // One pinned control: while it is held the label changes.
        expect(find.text(_en.toolsDiceReleaseToHide), findsOneWidget);
        for (final word in _vectorWords) {
          expect(find.text(word), findsOneWidget, reason: 'revealed $word');
        }

        await gesture.up();
        await tester.pump();
        await _settle(tester);

        expect(find.text(_en.toolsDiceHoldToReveal), findsOneWidget);
        expect(find.text('garden'), findsNothing);
        expect(find.text('uphold'), findsNothing);
        expect(find.text('wave'), findsNothing);
      },
    );
  });

  group('result layout', () {
    testWidgets('the hold control stays pinned and reveals the math values', (
      tester,
    ) async {
      final detector = FakeDiceDetector(available: false);
      final secure = FakeSecureScreen();
      addTearDown(() async => detector.close());
      addTearDown(() async => secure.close());

      await _openSandbox(tester, detector: detector, secure: secure);
      await _enterVectorRolls(tester);

      // The math card is the last one; scroll the cards down to it.
      await _scrollTo(
        tester,
        _en.toolsDiceMathHidden,
        within: find.byType(DiceResultView),
      );
      expect(find.text(_en.toolsDiceMathHidden), findsOneWidget);

      final hold = find.text(_en.toolsDiceHoldToReveal);
      expect(hold.hitTestable(), findsOneWidget);

      final gesture = await tester.startGesture(tester.getCenter(hold));
      await tester.pump();

      expect(find.text(_en.toolsDiceMathHidden), findsNothing);

      await gesture.up();
      await tester.pump();
      await _settle(tester);

      expect(find.text(_en.toolsDiceMathHidden), findsOneWidget);
      expect(find.text(_en.toolsDiceHoldToReveal), findsOneWidget);
    });

    testWidgets(
      'the correction sheet keeps its save button above the navigation bar',
      (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

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
            theme: AppTheme.dark(),
            // Edge to edge: the system bars take 48 px at the bottom.
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewPadding: const EdgeInsets.only(bottom: 48),
                padding: const EdgeInsets.only(bottom: 48),
              ),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => DiceCorrectionSheet.show(
                    context,
                    values: const [1, 2, 3, 4, 5],
                    throwNumber: 1,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await _settle(tester);

        // The sheet is taller than the screen allows, so the save button
        // is at the end of its scroll view. Scroll there and measure.
        final sheetScroll = find.descendant(
          of: find.byType(DiceCorrectionSheet),
          matching: find.byType(SingleChildScrollView),
        );
        await tester.drag(sheetScroll, const Offset(0, -1000));
        await _settle(tester);

        final save = find.text(_en.toolsDiceSaveThrow);
        expect(save, findsOneWidget);
        expect(tester.getRect(save).bottom, lessThanOrEqualTo(600 - 48));
      },
    );
  });

  group('automatic capture', () {
    testWidgets(
      'a still scene opens the sheet, and only saving records the throw',
      (tester) async {
        final detector = FakeDiceDetector();
        final secure = FakeSecureScreen();
        addTearDown(() async => detector.close());
        addTearDown(() async => secure.close());

        await _openSandbox(tester, detector: detector, secure: secure);
        await _waitForListener(tester, detector);

        for (var i = 0; i < 6; i++) {
          detector.push(_frame(const [2, 2, 2, 2, 2]));
          await tester.pump();
        }
        await _settle(tester);

        // Every die is above 0.85, and the throw still waits for the sheet.
        expect(find.byType(DiceCorrectionSheet), findsOneWidget);
        expect(find.text(_en.toolsDiceCountOf(0, 99)), findsNWidgets(2));

        await tester.tap(find.text(_en.toolsDiceSaveThrow));
        await _settle(tester);

        // Rolls and throws both show "5 / 99" and "1 / 20" once each.
        expect(find.text(_en.toolsDiceCountOf(5, 99)), findsNWidgets(2));
        expect(find.text(_en.toolsDiceCountOf(1, 20)), findsOneWidget);

        // The same dice, with a die missed and a frame without dice, are
        // not asked again.
        for (final values in const [
          [2, 2, 2, 2, 2],
          [2, 2, 2, 2],
          <int>[],
          [2, 2, 2, 2, 2],
          [2, 2, 2, 2, 2],
          [2, 2, 2, 2, 2],
          [2, 2, 2, 2, 2],
          [2, 2, 2, 2, 2],
        ]) {
          detector.push(_frame(values));
          await tester.pump();
        }
        await _settle(tester);

        expect(find.byType(DiceCorrectionSheet), findsNothing);
        expect(find.text(_en.toolsDiceCountOf(5, 99)), findsNWidgets(2));
        expect(find.text(_en.toolsDiceCountOf(10, 99)), findsNothing);
      },
    );

    testWidgets('closing the sheet records nothing and does not ask again', (
      tester,
    ) async {
      final detector = FakeDiceDetector();
      final secure = FakeSecureScreen();
      addTearDown(() async => detector.close());
      addTearDown(() async => secure.close());

      await _openSandbox(tester, detector: detector, secure: secure);
      await _waitForListener(tester, detector);

      for (var i = 0; i < 4; i++) {
        detector.push(_frame(const [1, 2, 3, 4, 5]));
        await tester.pump();
      }
      await _settle(tester);
      expect(find.byType(DiceCorrectionSheet), findsOneWidget);

      await tester.tap(find.byTooltip(_en.toolsDiceClose));
      await _settle(tester);

      for (var i = 0; i < 6; i++) {
        detector.push(_frame(const [1, 2, 3, 4, 5]));
        await tester.pump();
      }
      await _settle(tester);

      expect(find.byType(DiceCorrectionSheet), findsNothing);
      expect(find.text(_en.toolsDiceCountOf(0, 99)), findsNWidgets(2));
    });

    testWidgets(
      'a low-confidence die opens the correction sheet, and saving records it',
      (tester) async {
        final detector = FakeDiceDetector();
        final secure = FakeSecureScreen();
        addTearDown(() async => detector.close());
        addTearDown(() async => secure.close());

        await _openSandbox(tester, detector: detector, secure: secure);
        await _waitForListener(tester, detector);

        for (var i = 0; i < 4; i++) {
          detector.push(
            _frame(
              const [1, 3, 4, 6, 6],
              confidences: const [0.99, 0.7, 0.99, 0.99, 0.99],
            ),
          );
          await tester.pump();
        }
        await _settle(tester);

        expect(find.byType(DiceCorrectionSheet), findsOneWidget);
        expect(find.text(_en.toolsDiceCorrectTitle(1)), findsOneWidget);
        expect(find.text(_en.toolsDiceCountOf(0, 99)), findsNWidgets(2));

        await tester.tap(find.text(_en.toolsDiceSaveThrow));
        await _settle(tester);

        expect(find.byType(DiceCorrectionSheet), findsNothing);
        expect(find.text(_en.toolsDiceCountOf(5, 99)), findsNWidgets(2));
      },
    );
  });

  group('network check', () {
    testWidgets('the checklist follows a network event to offline', (
      tester,
    ) async {
      final secure = FakeSecureScreen(online: true);
      addTearDown(() async => secure.close());

      await _pumpIntro(tester, detector: null, secure: secure);
      expect(find.text(_en.toolsDiceCheckAirplaneOffline), findsNothing);

      secure.online = false;
      secure.emit(SecureScreenEvent.wentOffline);
      await _settle(tester);

      expect(find.text(_en.toolsDiceCheckAirplaneOffline), findsOneWidget);
    });

    testWidgets('resume rechecks the network, and again after a short delay', (
      tester,
    ) async {
      final secure = FakeSecureScreen(online: true);
      addTearDown(() async => secure.close());

      await _pumpIntro(tester, detector: null, secure: secure);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text(_en.toolsDiceCheckAirplaneOffline), findsNothing);

      // The OS still reports the old network right after resume; the change
      // shows up only in the delayed recheck.
      secure.online = false;
      await tester.pump(const Duration(seconds: 2));

      expect(find.text(_en.toolsDiceCheckAirplaneOffline), findsOneWidget);
    });

    testWidgets('airplane mode with Wi-Fi still on leaves the row unticked', (
      tester,
    ) async {
      final secure = FakeSecureScreen(online: true, airplaneMode: true);
      addTearDown(() async => secure.close());

      await _pumpIntro(tester, detector: null, secure: secure);

      expect(find.text(_en.toolsDiceCheckAirplaneWifiStillOn), findsOneWidget);
      expect(find.text(_en.toolsDiceCheckAirplaneOffline), findsNothing);
      expect(find.text(_en.toolsDiceCheckAirplaneOpenSettings), findsNothing);
    });

    testWidgets(
      'the sandbox warns about Wi-Fi in airplane mode, then clears when offline',
      (tester) async {
        final detector = FakeDiceDetector();
        final secure = FakeSecureScreen(online: true, airplaneMode: true);
        addTearDown(() async => detector.close());
        addTearDown(() async => secure.close());

        await _openSandbox(tester, detector: detector, secure: secure);

        expect(find.text(_en.toolsDiceOnlineWarningWifi), findsOneWidget);
        expect(find.text(_en.toolsDiceOnlineWarning), findsNothing);
        expect(find.text(_en.toolsDiceOnline), findsOneWidget);

        secure.online = false;
        secure.emit(SecureScreenEvent.wentOffline);
        await _settle(tester);

        expect(find.text(_en.toolsDiceOnlineWarningWifi), findsNothing);
        expect(find.text(_en.toolsDiceOnlineWarning), findsNothing);
        expect(find.text(_en.toolsDiceOffline), findsOneWidget);
      },
    );
  });

  group('lifecycle', () {
    testWidgets(
      'inactive shows the veil, paused erases and returns to the intro',
      (tester) async {
        final detector = FakeDiceDetector();
        final secure = FakeSecureScreen();
        addTearDown(() async => detector.close());
        addTearDown(() async => secure.close());

        await _openSandbox(tester, detector: detector, secure: secure);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await _settle(tester);
        expect(find.text(_en.toolsDiceVeil), findsOneWidget);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await _settle(tester);
        expect(find.text(_en.toolsDiceVeil), findsNothing);
        expect(find.byType(DiceSandboxScreen), findsOneWidget);

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await _settle(tester);
        // Frames are paused while the app is in the background, so the route
        // leaves the screen once the app is resumed.
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await _settle(tester);

        expect(find.byType(DiceSandboxScreen), findsNothing);
        expect(find.text(_en.toolsDiceEnter), findsOneWidget);
        expect(find.text(_en.toolsDiceWipedNotice), findsOneWidget);
        expect(secure.disables, 1);
        expect(detector.disposes, 1);
      },
    );

    testWidgets('a screenshot shows the dialog and erases the session', (
      tester,
    ) async {
      final detector = FakeDiceDetector();
      final secure = FakeSecureScreen();
      addTearDown(() async => detector.close());
      addTearDown(() async => secure.close());

      await _openSandbox(tester, detector: detector, secure: secure);
      await _enterThrow(tester, const [1, 2, 3, 4, 5]);
      expect(find.text(_en.toolsDiceCountOf(5, 99)), findsNWidgets(2));

      secure.emit(SecureScreenEvent.screenshotTaken);
      await _settle(tester);

      expect(find.text(_en.toolsDiceScreenshotTitle), findsOneWidget);
      expect(find.text(_en.toolsDiceScreenshotBody), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, _en.toolsDiceClose));
      await _settle(tester);

      expect(find.byType(DiceSandboxScreen), findsNothing);
      expect(find.text(_en.toolsDiceEnter), findsOneWidget);
      expect(secure.disables, 1);
      expect(detector.disposes, 1);

      // A new session starts from zero: the screenshot erased the rolls.
      await _tapText(
        tester,
        _en.toolsDiceEnter,
        within: find.byType(ToolDiceScreen),
      );
      expect(find.text(_en.toolsDiceCountOf(0, 99)), findsNWidgets(2));
      expect(find.text(_en.toolsDiceCountOf(5, 99)), findsNothing);
    });
  });
}
