import 'package:flutter/foundation.dart';

import '../../localization/app_locale.dart';
import '../../search/search_index.dart';
import '../app_content.dart';
import '../data/content_bundle_parser.dart';
import '../data/content_bundle_repository.dart';
import '../domain/content_store.dart';

final class AppContentController extends ChangeNotifier {
  AppContentController._({
    required ContentBundleRepository repository,
    required String languageCode,
    required AppContent content,
    BackgroundContentUpdater? updater,
  }) : _repository = repository,
       _languageCode = languageCode,
       _content = content,
       _updater = updater;

  final ContentBundleRepository _repository;
  final BackgroundContentUpdater? _updater;

  String _languageCode;
  AppContent _content;

  String get languageCode => _languageCode;

  AppContent get content => _content;

  static Future<AppContentController> load({
    required ContentBundleRepository repository,
    required String languageCode,
    BackgroundContentUpdater? updater,
  }) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    final content = await _loadContent(repository, normalizedLanguageCode);

    return AppContentController._(
      repository: repository,
      updater: updater,
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

    final content = await _loadContent(_repository, normalizedLanguageCode);
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

      _content = _contentFromResult(result);
      notifyListeners();
    } on Object {
      // Background updates are best-effort; local content remains authoritative.
    }
  }

  static Future<AppContent> _loadContent(
    ContentBundleRepository repository,
    String languageCode,
  ) async {
    final result = await repository.load(languageCode);

    return _contentFromResult(result);
  }

  static AppContent _contentFromResult(ContentBundleParseResult result) {
    final store = ContentStore(result.bundle);

    return AppContent(
      store: store,
      searchIndex: SearchIndex.fromBundle(result.bundle),
      warnings: result.warnings,
    );
  }
}
