import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/app.dart';

void main() {
  testWidgets('SatoWiki shell renders primary tabs', (tester) async {
    await tester.pumpWidget(const SatoWikiApp());

    expect(find.text('SatoWiki'), findsOneWidget);
    expect(find.text('The Orange Book'), findsOneWidget);
    expect(find.text('Wiki'), findsOneWidget);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);

    await tester.tap(find.text('Code'));
    await tester.pump();

    expect(find.text('Code Dashboard'), findsWidgets);
  });
}
