import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/features/tools/presentation/lab_mining.dart';

import 'seed_smoke_support.dart';

/// Cases that fail on a real layout or runtime error, keyed by
/// "combination label, then route", with the reason. A key is skipped so the
/// suite stays green. Nothing here is a fix: remove the entry once the screen
/// is fixed. Empty in the last full run: every case passed with the app's
/// bundled fonts loaded.
const knownFailures = <String, String>{};

void main() {
  setUpAll(loadSmokeFonts);

  final seeds = {
    for (final language in ['en', 'it']) language: SmokeSeed.load(language),
  };

  group('seed bundles', () {
    for (final seed in seeds.values) {
      test('${seed.language} seed has the records the matrix opens', () {
        final bundle = seed.bundle;
        final slugs = {
          'products': bundle.products.map((p) => p.slug),
          'library': bundle.library.map((w) => w.slug),
          'references': bundle.references.map((t) => t.slug),
          'glossary': bundle.glossary.map((t) => t.slug),
          'paths': bundle.paths.map((p) => p.slug),
          'wiki': bundle.wiki.map((e) => e.slug),
        };

        expect(slugs['wiki'], containsAll(smokeWikiEntries));
        expect(slugs['glossary'], containsAll(smokeGlossaryTerms));
        expect(slugs['products'], isNotEmpty);
        expect(slugs['library'], hasLength(16));
        expect(slugs['references'], hasLength(5));
        expect(slugs['paths'], isNotEmpty);
        expect(fullSmokeRoutes(seed), isNotEmpty);
        expect(reducedSmokeRoutes(seed), isNotEmpty);
      });
    }
  });

  group('smoke matrix', () {
    for (final combo in smokeCombos) {
      final seed = seeds[combo.language]!;
      for (final smoke in smokeRoutesFor(seed, combo)) {
        final name = '${combo.label} ${smoke.route}';

        final reason = knownFailures[name];

        testWidgets(reason == null ? name : '$name [SKIPPED: $reason]', (
          tester,
        ) async {
          final run = await SmokeRun.pump(tester, combo: combo, seed: seed);
          await run.open(smoke.route);

          switch (smoke.interaction) {
            case SmokeInteraction.none:
              break;
            case SmokeInteraction.hashText:
              await tester.enterText(find.byType(TextField).first, 'abc');
              await run.settle();
              run.checkNoError('hash of "abc"');
              expect(
                selectableText(
                  'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
                ),
                findsOneWidget,
              );
            case SmokeInteraction.transactionExample:
              await run.tap(find.text(run.l10n.toolsTxLoadExample));
              run.checkNoError('transaction example');
              break;
            case SmokeInteraction.labMine:
              await run.tap(find.text(run.l10n.labMineButton));
              run.checkNoError('lab mine');
              // Mining runs one batch per pump, at most
              // labMaxMiningAttempts / labMiningBatchSize batches.
              const maxBatches = labMaxMiningAttempts ~/ labMiningBatchSize;
              for (var i = 0; i < maxBatches; i++) {
                if (find.text(run.l10n.labValid).evaluate().isNotEmpty) {
                  break;
                }
                await tester.pump(const Duration(milliseconds: 100));
                run.checkNoError('lab mining, pump $i');
              }
              expect(find.text(run.l10n.labValid), findsWidgets);
              break;
          }

          await run.scrollToBottom(smoke.route);
          run.checkNoExplorerRequests(smoke.route);
        }, skip: reason != null);
      }
    }
  });
}
