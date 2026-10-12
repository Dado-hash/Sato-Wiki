import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/domain/content_media.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/core/widgets/markdown_text.dart';

void main() {
  testWidgets('renders markdown text and image placeholders with captions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: MarkdownText(
              'Intro paragraph.\n\n'
              '![Raster diagram](media/wiki/diagram.png "Raster caption")',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Intro paragraph.'), findsOneWidget);
    expect(find.text('Raster caption'), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(find.text('media/wiki/diagram.png'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Raster diagram',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows placeholder for unresolved images', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: SizedBox(
            width: 360,
            child: MarkdownText(
              '![Missing diagram](media/wiki/missing.png "Missing caption")',
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(find.text('media/wiki/missing.png'), findsOneWidget);
    expect(find.text('Missing caption'), findsOneWidget);
  });

  testWidgets('opens resolved images full screen on tap', (tester) async {
    final directory = Directory.systemTemp.createTempSync(
      'satowiki_markdown_image',
    );
    addTearDown(() {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    final imageFile = File('${directory.path}/diagram.svg')
      ..writeAsStringSync(
        '<svg width="10" height="10" viewBox="0 0 10 10" '
        'xmlns="http://www.w3.org/2000/svg"><rect width="10" '
        'height="10" fill="#f7931a"/></svg>',
      );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: MarkdownText(
              '![Diagram](media/wiki/diagram.svg)',
              mediaResolver: ContentMediaResolver(
                resolve: (_) => imageFile.uri,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('taps open http and https links and ignore other schemes', (
    tester,
  ) async {
    final opened = <Uri>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Text('opened ${settings.name}'),
        ),
        home: Scaffold(
          body: MarkdownText(
            '[Bitcoin](https://bitcoin.org)\n\n'
            '[Mail](mailto:satowiki@example.com)\n\n'
            '[Hash](wiki.sha-256)',
            openLink: (_, uri) async => opened.add(uri),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mail'));
    await tester.pumpAndSettle();
    expect(opened, isEmpty);

    await tester.tap(find.text('Bitcoin'));
    await tester.pumpAndSettle();
    expect(opened, [Uri.parse('https://bitcoin.org')]);

    await tester.tap(find.text('Hash'));
    await tester.pumpAndSettle();
    expect(find.text('opened /wiki/entries/sha-256'), findsOneWidget);
    expect(opened, hasLength(1));
  });
}
