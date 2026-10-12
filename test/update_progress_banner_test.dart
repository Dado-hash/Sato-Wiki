import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sato_wiki/src/core/content/application/app_content_controller.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_repository.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/core/widgets/update_progress_banner.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows nothing while idle', (tester) async {
    final fixture = await tester.runAsync(_ControllerFixture.create);
    await tester.pumpWidget(_host(fixture!.controller));
    final l10n = await _l10n();

    expect(find.text(l10n.contentUpdateDownloadingBundle), findsNothing);
    expect(find.byIcon(Icons.download_rounded), findsNothing);
    expect(find.byTooltip(l10n.close), findsNothing);
  });

  testWidgets('shows download progress and leaves the rest tappable', (
    tester,
  ) async {
    final fixture = await tester.runAsync(_ControllerFixture.create);
    final l10n = await _l10n();
    var tapped = 0;
    await tester.pumpWidget(
      _host(fixture!.controller, underneath: () => tapped++),
    );

    fixture.updater.startDownload(mediaCurrent: 1, mediaTotal: 4);
    await tester.pump();

    expect(
      find.text(l10n.contentUpdateDownloadingMediaFormatted(1, 4)),
      findsOneWidget,
    );
    final bannerRect = tester.getRect(find.byType(UpdateProgressBanner));
    expect(bannerRect.height, lessThan(120));

    await tester.tap(find.byKey(const ValueKey('underneath-button')));
    expect(tapped, 1);

    fixture.updater.finish();
    await tester.pump();
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('done message hides after 2500 ms', (tester) async {
    final fixture = await tester.runAsync(_ControllerFixture.create);
    final l10n = await _l10n();
    await tester.pumpWidget(_host(fixture!.controller));

    fixture.updater.startDownload(mediaCurrent: 0, mediaTotal: 0);
    await tester.pump();
    fixture.updater.finish();
    for (var i = 0; i < 10; i++) {
      await tester.pump();
    }

    expect(find.text(l10n.contentUpdateDone), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text(l10n.contentUpdateDone), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.contentUpdateDone), findsNothing);
  });

  testWidgets('close button hides the banner until the next download', (
    tester,
  ) async {
    final fixture = await tester.runAsync(_ControllerFixture.create);
    final l10n = await _l10n();
    await tester.pumpWidget(_host(fixture!.controller));

    fixture.updater.startDownload(mediaCurrent: 2, mediaTotal: 4);
    await tester.pump();
    expect(find.byTooltip(l10n.close), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text(l10n.contentUpdateDownloadingMediaFormatted(2, 4)),
      findsNothing,
    );

    fixture.updater.progress(3, 4);
    await tester.pump();
    expect(find.byTooltip(l10n.close), findsNothing);

    fixture.updater.finish();
    await tester.pump();
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<AppLocalizations> _l10n() {
  return AppLocalizations.delegate.load(const Locale('en'));
}

Widget _host(AppContentController controller, {VoidCallback? underneath}) {
  return MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              key: const ValueKey('underneath-button'),
              onPressed: underneath ?? () {},
              child: const Text('Underneath'),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 8,
            child: UpdateProgressBanner(contentController: controller),
          ),
        ],
      ),
    ),
  );
}

/// Drives an [AppContentController] update by hand through [checkForUpdates].
final class _ControllerFixture {
  _ControllerFixture._(this.controller, this.updater);

  final AppContentController controller;
  final _ControllableUpdater updater;

  static Future<_ControllerFixture> create() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = LocalFirstContentBundleRepository(
      preferences: preferences,
      assetBundle: _FakeAssetBundle(_bundleJson(version: '2026.05.25')),
    );
    final installable = await repository.load('en');
    final updater = _ControllableUpdater(installable);
    final controller = await AppContentController.load(
      repository: repository,
      languageCode: 'en',
      updater: updater,
    );
    updater.controllerDriver = controller;

    return _ControllerFixture._(controller, updater);
  }
}

/// Starts [AppContentController.checkForUpdates] and reports progress from
/// the test. [finish] completes the download with a valid bundle.
final class _ControllableUpdater implements BackgroundContentUpdater {
  _ControllableUpdater(this._installable);

  /// Loaded outside the fake-async zone, so the update installs without I/O.
  final ContentBundleParseResult _installable;
  AppContentController? controllerDriver;
  Completer<void>? _gate;
  void Function(int, int)? _onMediaProgress;

  void startDownload({required int mediaCurrent, required int mediaTotal}) {
    final driver = controllerDriver!;
    unawaited(driver.checkForUpdates());
    progress(mediaCurrent, mediaTotal);
  }

  void progress(int current, int total) {
    _onMediaProgress?.call(current, total);
  }

  /// Lets the download finish. The caller pumps so the controller installs it.
  void finish() {
    _gate?.complete();
  }

  @override
  Future<ContentBundleParseResult?> checkForUpdates(
    String languageCode, {
    void Function()? onWorkStarted,
    void Function(int current, int total)? onMediaProgress,
  }) async {
    _onMediaProgress = onMediaProgress;
    onWorkStarted?.call();
    final gate = _gate = Completer<void>();
    await gate.future;

    return _installable;
  }

  @override
  Future<ContentManifest?> fetchManifest(String languageCode) async => null;
}

final class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this.json);

  final String json;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(json));

    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => json;
}

String _bundleJson({required String version}) {
  return '''
{
  "schemaVersion": 1,
  "version": "$version",
  "language": "en",
  "generatedAt": "2026-05-25T00:00:00Z",
  "wiki": [],
  "news": [],
  "history": [],
  "bips": [],
  "changelogs": []
}
''';
}
