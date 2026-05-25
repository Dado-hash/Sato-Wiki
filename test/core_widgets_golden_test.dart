import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sato_wiki/src/core/content/reading_level.dart';
import 'package:sato_wiki/src/core/localization/app_locale.dart';
import 'package:sato_wiki/src/core/widgets/content_card.dart';
import 'package:sato_wiki/src/core/widgets/filter_chip_bar.dart';
import 'package:sato_wiki/src/core/widgets/hero_media.dart';
import 'package:sato_wiki/src/core/widgets/metadata_row.dart';
import 'package:sato_wiki/src/core/widgets/reader_header.dart';
import 'package:sato_wiki/src/core/widgets/reading_level_selector.dart';
import 'package:sato_wiki/src/core/widgets/related_links_grid.dart';
import 'package:sato_wiki/src/core/widgets/sources_disclosure.dart';
import 'package:sato_wiki/src/core/widgets/status_badge.dart';
import 'package:sato_wiki/src/core/theme/app_theme.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  testWidgets('core editorial components match golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocale.supportedLocales,
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(width: 420, child: _CoreComponentCatalog()),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(_CoreComponentCatalog),
      matchesGoldenFile('goldens/core_editorial_components.png'),
    );
  });
}

class _CoreComponentCatalog extends StatelessWidget {
  const _CoreComponentCatalog();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      children: [
        const ReaderHeader(
          title: 'Proof of Work',
          subtitle: 'Consensus without a central coordinator.',
          metadata: [
            MetadataItem(label: '#Mining', isTag: true),
            MetadataItem(label: '5 min read', icon: Icons.schedule_outlined),
          ],
          trailing: StatusBadge(status: ContentStatus.active),
        ),
        const SizedBox(height: 16),
        ReadingLevelSelector(
          selectedLevel: ReadingLevel.medium,
          onLevelChanged: (_) {},
        ),
        const SizedBox(height: 16),
        FilterChipBar<String>(
          items: const ['All', 'Protocol', 'Economics'],
          selectedItem: 'Protocol',
          labelFor: (item) => item,
          onSelected: (_) {},
        ),
        const SizedBox(height: 16),
        const HeroMedia(icon: Icons.memory, label: 'Cryptographic work graph'),
        const SizedBox(height: 16),
        const ContentCard(
          child: Text(
            'Cards use tonal surfaces, thin borders and compact editorial spacing.',
          ),
        ),
        const SizedBox(height: 16),
        RelatedLinksGrid(
          links: const [
            RelatedLink(title: 'SHA-256 Algorithm', icon: Icons.link),
            RelatedLink(title: 'Difficulty Adjustment', icon: Icons.speed),
          ],
        ),
        const SizedBox(height: 16),
        const SourcesDisclosure(
          sources: [
            SourceReference(
              title: 'Bitcoin: A Peer-to-Peer Electronic Cash System',
              author: 'Satoshi Nakamoto',
            ),
          ],
        ),
      ],
    );
  }
}
