import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
