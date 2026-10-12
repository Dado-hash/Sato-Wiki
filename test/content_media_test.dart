import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crypto/crypto.dart';

import 'package:sato_wiki/src/core/content/data/content_bundle_errors.dart';
import 'package:sato_wiki/src/core/content/data/content_media_store.dart';
import 'package:sato_wiki/src/core/content/data/content_bundle_parser.dart';
import 'package:sato_wiki/src/core/content/domain/content_media.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('extracts media references from every markdown content type', () {
    final bundle = ContentBundleParser.parseJson(
      _bundleJson(
        wiki: '![Wiki diagram](media/wiki/entry/wiki.svg "Wiki caption")',
        news: '![News chart](media/news/chart.png)',
        history: '![History map](media/history/map.webp)',
        bipSummary: '![BIP summary](media/code/bip-summary.jpg)',
        bipImpact: '![BIP impact](media/code/bip-impact.jpeg)',
        releaseUserImpact: '![User impact](media/releases/user.png)',
        releaseTechnicalChanges:
            '![Technical changes](media/releases/technical.svg)',
      ),
    ).bundle;

    final references = ContentMedia.referencesFromBundle(bundle);

    expect(
      references.map((reference) => reference.source),
      containsAll([
        'media/wiki/entry/wiki.svg',
        'media/news/chart.png',
        'media/history/map.webp',
        'media/code/bip-summary.jpg',
        'media/code/bip-impact.jpeg',
        'media/releases/user.png',
        'media/releases/technical.svg',
      ]),
    );
    expect(references.first.alt, 'Wiki diagram');
    expect(references.first.title, 'Wiki caption');
  });

  test('validates inline image conventions', () {
    final errors = ContentMedia.validateReferences([
      const ContentMediaReference(source: 'media/wiki/ok.svg', alt: 'OK'),
      const ContentMediaReference(source: 'https://example.com/x.png', alt: ''),
      const ContentMediaReference(source: '../escape.png', alt: 'Escape'),
      const ContentMediaReference(source: 'media/wiki/file.gif', alt: 'GIF'),
    ]);

    expect(errors, hasLength(4));
    expect(
      errors.map((error) => error.message),
      containsAll([
        'Image alt text is required.',
        'Image source must be a relative media path.',
        'Image source must start with media/.',
        'Image extension must be one of .jpeg, .jpg, .png, .svg, .webp.',
      ]),
    );
  });

  test('extracts wiki cover image media references', () {
    final json = File('assets/content/seed_bundle_en.json').readAsStringSync();
    final bundle = ContentBundleParser.parseJson(json).bundle;

    final references = ContentMedia.referencesFromBundle(bundle);

    expect(
      references.map((reference) => reference.source),
      contains('media/wiki/proof-of-work/pow-mining-loop.svg'),
    );
  });

  test('proof-of-work seed media assets are bundled', () async {
    final miningLoop = await rootBundle.load(
      'assets/content/media/wiki/proof-of-work/pow-mining-loop.svg',
    );
    final accumulatedWork = await rootBundle.load(
      'assets/content/media/wiki/proof-of-work/accumulated-work.svg',
    );

    expect(miningLoop.lengthInBytes, greaterThan(0));
    expect(accumulatedWork.lengthInBytes, greaterThan(0));
  });

  test('installs bundled media assets for seed content', () async {
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_seed_media',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final bundle = ContentBundleParser.parseJson(
      _bundleJson(
        wiki: '![Wiki diagram](media/wiki/entry/wiki.svg "Wiki caption")',
        news: '',
        history: '',
        bipSummary: '',
        bipImpact: '',
        releaseUserImpact: '',
        releaseTechnicalChanges: '',
      ),
    ).bundle;
    final store = ContentMediaStore(rootDirectory: mediaRoot);

    await store.installBundleMediaFromAssets(
      bundle: bundle,
      assetBundle: _FakeAssetBundle({
        'assets/content/media/wiki/entry/wiki.svg': [1, 2, 3],
      }),
    );

    expect(
      File(
        '${mediaRoot.path}/en/2026.05.25/media/wiki/entry/wiki.svg',
      ).readAsBytesSync(),
      [1, 2, 3],
    );
  });

  test('seed media with a missing asset is skipped without failing', () async {
    final mediaRoot = await Directory.systemTemp.createTemp(
      'satowiki_no_asset',
    );
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final bundle = ContentBundleParser.parseJson(
      _bundleJson(
        wiki: '![Missing](media/wiki/entry/missing.svg)',
        news: '',
        history: '',
        bipSummary: '',
        bipImpact: '',
        releaseUserImpact: '',
        releaseTechnicalChanges: '',
      ),
    ).bundle;

    await ContentMediaStore(
      rootDirectory: mediaRoot,
    ).installBundleMediaFromAssets(
      bundle: bundle,
      assetBundle: _FakeAssetBundle({}),
    );

    expect(
      File(
        '${mediaRoot.path}/en/2026.05.25/media/wiki/entry/missing.svg',
      ).existsSync(),
      isFalse,
    );
  });

  test('prefetch returns failed sources and installs the rest', () async {
    final mediaRoot = await Directory.systemTemp.createTemp('satowiki_partial');
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final bundleUrl = Uri.parse('https://example.com/content/en/bundle.json');
    final bundle = ContentBundleParser.parseJson(
      _bundleJson(
        wiki: '![A](media/wiki/entry/a.svg) ![B](media/wiki/entry/b.svg)',
        news: '',
        history: '',
        bipSummary: '',
        bipImpact: '',
        releaseUserImpact: '',
        releaseTechnicalChanges: '',
      ),
    ).bundle;
    final store = ContentMediaStore(
      rootDirectory: mediaRoot,
      downloader: _FakeMediaDownloader({
        'https://example.com/content/en/media/wiki/entry/a.svg': [1],
      }),
    );

    final failed = await store.prefetchBundleMedia(
      bundle: bundle,
      bundleUrl: bundleUrl,
    );

    expect(failed, ['media/wiki/entry/b.svg']);
    expect(
      File(
        '${mediaRoot.path}/en/2026.05.25/media/wiki/entry/a.svg',
      ).readAsBytesSync(),
      [1],
    );
    expect(
      Directory('${mediaRoot.path}/en/2026.05.25.tmp').existsSync(),
      isFalse,
    );
  });

  test('repair keeps installed media and waits before retrying', () async {
    final mediaRoot = await Directory.systemTemp.createTemp('satowiki_repair');
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final bundleUrl = Uri.parse('https://example.com/content/en/bundle.json');
    final bundle = ContentBundleParser.parseJson(
      _bundleJson(
        wiki: '![A](media/wiki/entry/a.svg) ![B](media/wiki/entry/b.svg)',
        news: '',
        history: '',
        bipSummary: '',
        bipImpact: '',
        releaseUserImpact: '',
        releaseTechnicalChanges: '',
      ),
    ).bundle;
    var now = DateTime.utc(2026, 10, 12, 9);
    final first = ContentMediaStore(
      rootDirectory: mediaRoot,
      clock: () => now,
      downloader: _FakeMediaDownloader({
        'https://example.com/content/en/media/wiki/entry/a.svg': [1],
      }),
    );
    await first.prefetchBundleMedia(bundle: bundle, bundleUrl: bundleUrl);

    // The server no longer has a.svg either; the installed copy must survive.
    final second = ContentMediaStore(
      rootDirectory: mediaRoot,
      clock: () => now,
      downloader: const _FakeMediaDownloader({}),
    );
    final failed = await second.prefetchBundleMedia(
      bundle: bundle,
      bundleUrl: bundleUrl,
    );

    expect(failed, ['media/wiki/entry/b.svg']);
    expect(
      File(
        '${mediaRoot.path}/en/2026.05.25/media/wiki/entry/a.svg',
      ).readAsBytesSync(),
      [1],
    );

    expect(
      second.canAttemptMediaRepair(language: 'en', version: '2026.05.25'),
      isTrue,
    );
    await second.recordIncompleteMediaRepair(
      language: 'en',
      version: '2026.05.25',
    );
    expect(
      second.canAttemptMediaRepair(language: 'en', version: '2026.05.25'),
      isFalse,
    );
    expect(
      second.canAttemptMediaRepair(language: 'en', version: '2026.05.26'),
      isTrue,
    );

    now = now.add(ContentMediaStore.mediaRepairCooldown);
    expect(
      second.canAttemptMediaRepair(language: 'en', version: '2026.05.25'),
      isTrue,
    );
  });

  test(
    'prefetch rejects media that does not match its manifest hash',
    () async {
      final mediaRoot = await Directory.systemTemp.createTemp(
        'satowiki_badhash',
      );
      addTearDown(() {
        if (mediaRoot.existsSync()) {
          mediaRoot.deleteSync(recursive: true);
        }
      });
      final bundle = ContentBundleParser.parseJson(
        _bundleJson(
          wiki: '![A](media/wiki/entry/a.svg)',
          news: '',
          history: '',
          bipSummary: '',
          bipImpact: '',
          releaseUserImpact: '',
          releaseTechnicalChanges: '',
        ),
      ).bundle;
      final store = ContentMediaStore(
        rootDirectory: mediaRoot,
        downloader: _FakeMediaDownloader({
          'https://example.com/content/en/media/wiki/entry/a.svg': [9, 9],
        }),
      );

      final failed = await store.prefetchBundleMedia(
        bundle: bundle,
        bundleUrl: Uri.parse('https://example.com/content/en/bundle.json'),
        mediaHashes: {
          'media/wiki/entry/a.svg': sha256.convert([1, 2, 3]).toString(),
        },
      );

      expect(failed, ['media/wiki/entry/a.svg']);
      expect(
        File(
          '${mediaRoot.path}/en/2026.05.25/media/wiki/entry/a.svg',
        ).existsSync(),
        isFalse,
      );
    },
  );

  test(
    'prefetch reuses old media, then deletes old versions and stale tmp',
    () async {
      final mediaRoot = await Directory.systemTemp.createTemp('satowiki_prune');
      addTearDown(() {
        if (mediaRoot.existsSync()) {
          mediaRoot.deleteSync(recursive: true);
        }
      });
      const mediaBytes = [7, 8, 9];
      final oldFile = File(
        '${mediaRoot.path}/en/2026.05.24/media/wiki/entry/a.svg',
      );
      await oldFile.create(recursive: true);
      await oldFile.writeAsBytes(mediaBytes);
      final staleTmp = File(
        '${mediaRoot.path}/en/2026.05.25.tmp/media/wiki/entry/stale.svg',
      );
      await staleTmp.create(recursive: true);
      await staleTmp.writeAsBytes([1]);
      final bundle = ContentBundleParser.parseJson(
        _bundleJson(
          version: '2026.05.26',
          wiki: '![A](media/wiki/entry/a.svg)',
          news: '',
          history: '',
          bipSummary: '',
          bipImpact: '',
          releaseUserImpact: '',
          releaseTechnicalChanges: '',
        ),
      ).bundle;
      final store = ContentMediaStore(
        rootDirectory: mediaRoot,
        downloader: const _FakeMediaDownloader({}),
      );

      final failed = await store.prefetchBundleMedia(
        bundle: bundle,
        bundleUrl: Uri.parse('https://example.com/content/en/bundle.json'),
        mediaHashes: {
          'media/wiki/entry/a.svg': sha256.convert(mediaBytes).toString(),
        },
      );

      expect(failed, isEmpty);
      expect(
        File(
          '${mediaRoot.path}/en/2026.05.26/media/wiki/entry/a.svg',
        ).readAsBytesSync(),
        mediaBytes,
      );
      expect(
        Directory(
          '${mediaRoot.path}/en',
        ).listSync().map((entity) => entity.path.split('/').last),
        ['2026.05.26'],
      );
    },
  );

  test('media store refuses versions that are not dotted numbers', () async {
    final mediaRoot = await Directory.systemTemp.createTemp('satowiki_badver');
    addTearDown(() {
      if (mediaRoot.existsSync()) {
        mediaRoot.deleteSync(recursive: true);
      }
    });
    final bundle = ContentBundleParser.parseJson(
      _bundleJson(
        version: '../escape',
        wiki: '![A](media/wiki/entry/a.svg)',
        news: '',
        history: '',
        bipSummary: '',
        bipImpact: '',
        releaseUserImpact: '',
        releaseTechnicalChanges: '',
      ),
    ).bundle;
    final store = ContentMediaStore(rootDirectory: mediaRoot);

    expect(
      store
          .resolverFor(language: 'en', version: '../escape')
          .resolve('media/wiki/entry/a.svg'),
      isNull,
    );
    expect(store.hasBundleMedia(bundle), isFalse);
    await expectLater(
      store.installBundleMediaFromAssets(
        bundle: bundle,
        assetBundle: _FakeAssetBundle({}),
      ),
      throwsA(isA<ContentBundleParseException>()),
    );
    expect(mediaRoot.listSync(), isEmpty);
  });
}

String _bundleJson({
  String version = '2026.05.25',
  required String wiki,
  required String news,
  required String history,
  required String bipSummary,
  required String bipImpact,
  required String releaseUserImpact,
  required String releaseTechnicalChanges,
}) {
  final data = {
    'schemaVersion': 1,
    'version': version,
    'language': 'en',
    'generatedAt': '2026-05-25T00:00:00Z',
    'wiki': [
      {
        'id': 'wiki.inline-media',
        'slug': 'inline-media',
        'language': 'en',
        'category': 'protocol',
        'title': 'Inline Media',
        'description': 'Inline media test.',
        'readingLevels': {
          'base': {'bodyMarkdown': wiki},
          'medium': {'bodyMarkdown': 'Medium.'},
          'advanced': {'bodyMarkdown': 'Advanced.'},
        },
        'difficulty': 'base',
        'readTimeMinutes': 1,
        'tags': [],
        'sources': [],
        'related': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'news': [
      {
        'id': 'news.inline-media',
        'slug': 'inline-media',
        'language': 'en',
        'title': 'Inline Media',
        'summary': 'Inline media test.',
        'category': 'protocol',
        'author': {'displayName': 'Author'},
        'publishedAt': '2026-05-25',
        'readTimeMinutes': 1,
        'bodyMarkdown': news,
        'tags': [],
        'sources': [],
        'related': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'history': [
      {
        'id': 'history.inline-media',
        'slug': 'inline-media',
        'language': 'en',
        'date': '2026-05-25',
        'title': 'Inline Media',
        'category': 'protocol',
        'summary': 'Inline media test.',
        'bodyMarkdown': history,
        'tags': [],
        'sources': [],
        'related': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'bips': [
      {
        'id': 'code.bip.1',
        'number': 1,
        'language': 'en',
        'title': 'Inline Media',
        'summary': 'Inline media test.',
        'status': 'draft',
        'category': 'process',
        'authors': ['Author'],
        'createdAt': '2026-05-25',
        'summaryMarkdown': bipSummary,
        'impactMarkdown': bipImpact,
        'officialUrl': 'https://example.com/bip',
        'tags': [],
        'sources': [],
        'related': [],
        'statusHistory': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
    'changelogs': [
      {
        'id': 'release.inline-media.1',
        'slug': 'inline-media-1',
        'language': 'en',
        'project': 'inline-media',
        'version': '1.0',
        'title': 'Inline Media',
        'summary': 'Inline media test.',
        'releasedAt': '2026-05-25',
        'importance': 'minor',
        'userImpactMarkdown': releaseUserImpact,
        'technicalChangesMarkdown': releaseTechnicalChanges,
        'officialUrl': 'https://example.com/release',
        'tags': [],
        'sources': [],
        'related': [],
        'updatedAt': '2026-05-25T00:00:00Z',
      },
    ],
  };

  return jsonEncode(data);
}

final class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this.assets);

  final Map<String, List<int>> assets;

  @override
  Future<ByteData> load(String key) async {
    final bytes = assets[key];
    if (bytes == null) {
      throw FlutterError('Missing asset: $key');
    }

    final data = Uint8List.fromList(bytes);
    return ByteData.view(data.buffer);
  }
}

final class _FakeMediaDownloader implements ContentMediaDownloader {
  const _FakeMediaDownloader(this.media);

  final Map<String, List<int>> media;

  @override
  Future<List<int>> downloadMedia(Uri mediaUrl) async {
    final bytes = media[mediaUrl.toString()];
    if (bytes == null) {
      throw const ContentBundleParseException('Media missing.');
    }

    return bytes;
  }
}
