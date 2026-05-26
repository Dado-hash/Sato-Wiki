import 'package:flutter/foundation.dart';

import '../../localization/app_locale.dart';
import '../../search/search_index.dart';
import '../app_content.dart';
import '../data/content_bundle_parser.dart';
import '../data/content_bundle_repository.dart';
import '../data/content_media_store.dart';
import '../domain/content_media.dart';
import '../domain/content_store.dart';

final class AppContentController extends ChangeNotifier {
  AppContentController._({
    required ContentBundleRepository repository,
    required String languageCode,
    required AppContent content,
    BackgroundContentUpdater? updater,
    ContentMediaStore? mediaStore,
  }) : _repository = repository,
       _languageCode = languageCode,
       _content = content,
       _updater = updater,
       _mediaStore = mediaStore;

  final ContentBundleRepository _repository;
  final BackgroundContentUpdater? _updater;
  final ContentMediaStore? _mediaStore;

  String _languageCode;
  AppContent _content;

  String get languageCode => _languageCode;

  AppContent get content => _content;

  static Future<AppContentController> load({
    required ContentBundleRepository repository,
    required String languageCode,
    BackgroundContentUpdater? updater,
    ContentMediaStore? mediaStore,
  }) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    final content = await _loadContent(
      repository,
      normalizedLanguageCode,
      mediaStore,
    );

    return AppContentController._(
      repository: repository,
      updater: updater,
      mediaStore: mediaStore,
      languageCode: normalizedLanguageCode,
      content: content,
    );
  }

  Future<void> loadLanguage(String languageCode) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    if (normalizedLanguageCode == _languageCode) {
      return;
    }

    final content = await _loadContent(
      _repository,
      normalizedLanguageCode,
      _mediaStore,
    );
    _languageCode = normalizedLanguageCode;
    _content = content;
    notifyListeners();
  }

  Future<void> checkForUpdates() async {
    final updater = _updater;
    if (updater == null) {
      return;
    }

    try {
      final result = await updater.checkForUpdates(_languageCode);
      if (result == null ||
          result.bundle.version == _content.store.bundle.version) {
        return;
      }

      _content = _contentFromResult(result, _mediaStore);
      notifyListeners();
    } on Object {
      // Background updates are best-effort; local content remains authoritative.
    }
  }

  static Future<AppContent> _loadContent(
    ContentBundleRepository repository,
    String languageCode,
    ContentMediaStore? mediaStore,
  ) async {
    final result = await repository.load(languageCode);
    await mediaStore?.installBundleMediaFromAssets(bundle: result.bundle);

    return _contentFromResult(result, mediaStore);
  }

  static AppContent _contentFromResult(
    ContentBundleParseResult result,
    ContentMediaStore? mediaStore,
  ) {
    final store = ContentStore(result.bundle);

    return AppContent(
      store: store,
      searchIndex: SearchIndex.fromBundle(result.bundle),
      mediaResolver:
          mediaStore?.resolverFor(
            language: result.bundle.language,
            version: result.bundle.version,
          ) ??
          ContentMediaResolver.empty,
      warnings: result.warnings,
    );
  }
}
